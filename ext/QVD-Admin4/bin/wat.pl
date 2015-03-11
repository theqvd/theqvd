#!/usr/bin/perl
use Mojolicious::Lite;
use lib::glob '/home/benjamin/wat/*/lib/';
use Mojo::JSON qw(encode_json decode_json j);
use QVD::Admin4::Exception;
use MojoX::Session;
use File::Copy qw(copy move);
use Mojo::IOLoop::ForkCall;
use Mojo::Log;
use Mojo::ByteStream 'b';
use Deep::Encode;

plugin 'QVD::Admin4::REST';

# MojoX::Session::Transport::WAT Package 

$ENV{MOJO_MAX_MESSAGE_SIZE} = 0;
$ENV{MOJO_TMPDIR} = app->qvd_admin4_api->_cfg('path.storage.images');

app->hook(after_build_tx => sub {
    my ($tx, $app) = @_;

    $tx->req->on(progress => sub{
        my $message = shift;
        return unless my $len = $message->headers->content_length;
        my $size = $message->content->progress;
	my $percent = $size == $len ? 100 : int($size / ($len / 100));
        print 'Progress: ', $percent , '%', " size: $size","\r";
		 })
});

any [qw(POST GET)] => '/info' => sub {
  my $c = shift;

  $c->res->headers->header('Access-Control-Allow-Origin' => '*');

  QVD::Config::reload();
  my $json = { status => 0,
	       multitenant => $c->qvd_admin4_api->_cfg('wat.multitenant'),
               version => { database => $c->qvd_admin4_api->database_version }};

  $c->render(json => $json );
};

package MojoX::Session::Transport::WAT
{
    use base qw(MojoX::Session::Transport);

    sub get {
	my ($self) = @_;
	my $json = $self->tx->req->json;
	my $sid = $json ? $json->{sid} : $self->tx->req->params->param('sid');

	return $sid;
    }

    sub set {
	my ($self, $sid, $expires) = @_;
	$self->tx->res->headers->header('sid' => $sid);
	return 1;
    }
}

# GENERAL CONFIG AND PLUGINS

app->config(hypnotoad => {listen => ['http://localhost:3000']});

# HELPERS

helper (api_info => \&api_info);
helper (get_input_json => \&get_input_json);
helper (process_api_query => \&process_api_query);
helper (get_action_channels => \&get_action_channels);
helper (get_auth_method => \&get_auth_method);
helper (create_session => \&create_session);
helper (update_session => \&update_session);
helper (reject_access => \&reject_access);

#######################
### Routes Handlers ###
#######################

under sub {

    my $c = shift;

    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
    $c->res->headers->header('Access-Control-Expose-Headers' => 'sid');
    QVD::Config::reload();
    my $json = $c->req->json // { map { $_ => $c->param($_) } $c->param };
    
    my %session_args = (
	store  => [dbi => {dbh => QVD::DB->new()->storage->dbh}],
	transport => MojoX::Session::Transport::WAT->new(),
	tx => $c->tx);

    my $session = MojoX::Session->new(%session_args);

    my $auth_method = $c->get_auth_method($session,$json);

    my ($bool,$exception) = $c->$auth_method($session,$json);
    $c->render(json => $exception->json) if $exception;

    return $bool;
};

any [qw(POST GET)] => '/' => sub {

    my $c = shift;

    $c->inactivity_timeout(30000);     
    my $json = $c->get_input_json;
    my $response = $c->process_api_query($json);
    deep_utf8_decode($response);
    $c->render(text => b(encode_json($response))->decode('UTF-8'));
};

websocket '/ws' => sub {
    my $c = shift;
    $c->app->log->debug("WebSocket opened");
    $c->inactivity_timeout(30000);     
    my $json = $c->get_input_json;
    my $notification = 0;

    my $res = $c->process_api_query($json);
    $c->send(b(encode_json($res))->decode('UTF-8'));

    for my $channel ($c->get_action_channels($json))
    {
	$c->qvd_admin4_api->_pool->listen($channel,on_notify => sub { $notification = 1; });
    }

    my $recurring = Mojo::IOLoop->recurring(
	2 => sub { return 1 unless $notification;
		   $c->app->log->debug("WebSocket refreshing information");
		   my $res = $c->process_api_query($json);
		   $c->send(b(encode_json($res))->decode('UTF-8'));
		   $notification = 0;});

    my $timer;
    $c->on(message => sub {
        my ($c, $msg) = @_;
        $c->app->log->debug("WebSocket $msg signal received");
	Mojo::IOLoop->remove($timer) if $timer;
	$timer = Mojo::IOLoop->timer(25 => sub { $c->send('AKN');});});

    $c->on(finish => sub {
        my ($c, $code) = @_;
        Mojo::IOLoop->remove($timer) if $timer;
        Mojo::IOLoop->remove($recurring) if $recurring;
        $c->app->log->debug("WebSocket closed with status $code");});
};


websocket '/staging' => sub {
    my $c = shift;
    $c->inactivity_timeout(3000);
    $c->app->log->debug("Staging WebSocket opened");
    my $json = $c->get_input_json;
    $json->{action} = 'di_create_from_staging';
    my $images_path  = $c->qvd_admin4_api->_cfg('path.storage.images');
    my $staging_path = $c->qvd_admin4_api->_cfg('path.storage.staging');
    my $staging_file = eval { $json->{arguments}->{disk_image} } // '';
    my $images_file = $staging_file . '-tmp'. rand;
    $json->{parameters}->{tmp_file_name} = $images_file;

    my $accomplished=0;

    $c->on(message => sub { my ($c,$msg) = @_;
                            my $sf_size = eval { -s "$staging_path/$staging_file" } // 0;
                            my $if_size = eval { -s "$images_path/$images_file" } // 0;
                            $c->send(b(encode_json({ status => 1000,
						     total_size => $sf_size,
						     copy_size => $if_size }))->decode('UTF-8'))
				unless $accomplished;});

    my $fc = Mojo::IOLoop::ForkCall->new;
    $fc->run(
        sub { $c->app->log->debug("Starting copy");
              my $response = $c->qvd_admin4_api->process_query($json);
              return $response; },
        sub { my ($fc, $err, $response) = @_;
	      $err //= 'no error signals';
              $c->app->log->debug("Copy finished: $err");
	      $accomplished=1;
              $c->send(b(encode_json($response))->decode('UTF-8')); }
        );
};

#$controller->tx->connection


any [qw(POST OPTIONS)] => '/di/upload' => sub {

    my $c = shift;
    $c->inactivity_timeout(30000);     
    my $response;

    if ($c->req->method eq 'POST')
    {
	my $json = $c->get_input_json;
	$json->{action} = 'di_create_from_upload';
	$response = $c->process_api_query($json);

	if ($response->{status} eq 0)
	{
	    eval 
	    { 
		my $disk_image = $json->{arguments}->{disk_image};
		my $images_path  = $c->qvd_admin4_api->_cfg('path.storage.images');
		my $di_id = ${$response->{rows}}[0]->{id};

		my $file = $c->req->upload('file');
		$file->move_to($images_path .'/'. $di_id . '-'. $disk_image);
	    }; 
	    print $@ if $@;
	    $c->render(json => QVD::Admin4::Exception->new(code => 2210)->json) if $@;
	}
    }
    else
    {
	$response = {status => 0};
    }
    deep_utf8_decode($response);
    $c->render(text => b(encode_json($response))->decode('UTF-8'));
};

app->start;

#################
### FUNCTIONS ###
#################

sub get_input_json
{
    my $c = shift;
    my $json = $c->req->json;
    deep_utf8_decode($json) if $json;
    return $json if $json;

    $json =  { map { $_ => b($c->param($_))->encode('UTF-8')->to_string } $c->param };
 
    eval
    {
        $json->{filters} =  decode_json($json->{filters}) if exists $json->{filters};
        $json->{arguments} = decode_json($json->{arguments}) if exists $json->{arguments};
        $json->{order_by} = decode_json($json->{order_by}) if exists $json->{order_by};
        $json->{fields} = decode_json($json->{fields}) if exists $json->{fields};
        $json->{parameters} = decode_json($json->{parameters}) if exists $json->{parameters}
    };

    $c->render(json => QVD::Admin4::Exception->new(code => 6100)->json) if $@;

    $json;
}

sub process_api_query
{
    my ($c,$json) = @_;

    my $response = $c->qvd_admin4_api->process_query($json);
    $response->{sid} = $c->res->headers->header('sid');
    return $response;
}

sub get_action_channels
{
    my ($c,$json) = @_;
    my $channels = $c->qvd_admin4_api->get_channels($json->{action}) // [];
    @$channels;
}

sub get_auth_method
{
    my ($c,$session,$json) = @_;   
    return 'create_session' if 
	defined $json->{login} && defined $json->{password};

    return 'update_session' if
	$session->load;

    return 'reject_access';
}

sub create_session
{
    my ($c,$session,$json) = @_;
    my %args = (login => $json->{login}, 
		password => $json->{password});
    $args{tenant} = $json->{tenant} if defined $json->{tenant};
    my $admin = $c->qvd_admin4_api->validate_user(%args);

    return (0,QVD::Admin4::Exception->new(code =>3200)) 
	unless $admin;

    $c->qvd_admin4_api->load_user($admin);
    $session->create;
    $session->data(admin_id => $admin->id);
    $session->flush; 

    return 1;
}

sub update_session
{
    my ($c,$session,$json) = @_;

    if ($session->is_expired)
    { $session->flush;
      return (0,QVD::Admin4::Exception->new(code =>3300));}
    
    my ($bool,$exception) = (1, undef);

    $session->extend_expires; 

    my $admin = $c->qvd_admin4_api->validate_user(id => $session->data('admin_id'));
    return (0,QVD::Admin4::Exception->new(code =>3200)) 
	unless $admin;
    $c->qvd_admin4_api->load_user($admin);

    for (1 .. 5) { eval { $session->flush }; last unless $@;}
    ($bool,$exception) = (0,QVD::Admin4::Exception->new(code => 3400)) if $@;

    return ($bool,$exception);
}

sub reject_access
{
  (0,QVD::Admin4::Exception->new(code => 3100));
}

