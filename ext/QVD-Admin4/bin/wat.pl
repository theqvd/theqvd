#!/usr/lib/qvd/bin/perl                                                                                                                                                                                                                                                                                                                                                                     
use Mojolicious::Lite;
use lib::glob '/home/ubuntu/wat/*/lib/';
use QVD::Admin4::REST;
use Mojo::JSON qw(encode_json decode_json);
use QVD::Admin4::Exception;
use QVD::Config;
use MojoX::Session;
use File::Copy qw(copy move);
use Mojo::IOLoop::ForkCall;
use AnyEvent::Pg::Pool;

# MojoX::Session::Transport::WAT Package 

my $pool = AnyEvent::Pg::Pool->new( {host     => cfg('database.host'),
				     dbname   => cfg('database.name'),
				     user     => cfg('database.user'),
				     password => cfg('database.password') },
				    timeout            => cfg('internal.database.pool.connection.timeout'),
				    global_timeout     => cfg('internal.database.pool.connection.global_timeout'),
				    connection_delay   => cfg('internal.database.pool.connection.delay'),
				    connection_retries => cfg('internal.database.pool.connection.retries'),
				    size               => cfg('internal.database.pool.size'),
				    on_connect_error   => sub {},
				    on_transient_error => sub {},
                                    );


package MojoX::Session::Transport::WAT
{
    use base qw(MojoX::Session::Transport);

    sub get {
	my ($self) = @_;
	my $sid = $self->tx->req->params->param('sid');
	return $sid;
    }

    sub set {
	my ($self, $sid, $expires) = @_;
	$self->tx->res->headers->header('sid' => $sid);
	return 1;
    }
}

# GENERAL CONFIG AND PLUGINS

app->config(hypnotoad => {listen => ['http://192.168.3.7:3000']});
my $QVD_ADMIN4_API = QVD::Admin4::REST->new();

# HELPERS

helper (qvd_admin4_api => sub { $QVD_ADMIN4_API; });
helper (get_input_json => \&get_input_json);
helper (process_api_query => \&process_api_query);
helper (get_action_channels => \&get_action_channels);
helper (get_action_size => \&get_action_size);
helper (get_auth_method => \&get_auth_method);
helper (create_session => \&create_session);
helper (update_session => \&update_session);
helper (reject_access => \&reject_access);
helper (create_di => \&create_di);

#######################
### Routes Handlers ###
#######################

under sub {

    my $c = shift;
    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
    $c->res->headers->header('Access-Control-Expose-Headers' => 'sid');
    
    my %session_args = (
	store  => [dbi => {dbh => QVD::DB->new()->storage->dbh}],
	transport => MojoX::Session::Transport::WAT->new(),
	tx => $c->tx);

    my $session = MojoX::Session->new(%session_args);
    my $json = $c->req->json // { map { $_ => $c->param($_) } $c->param };
    my $auth_method = $c->get_auth_method($session,$json);

    my ($bool,$exception) = $c->$auth_method($session,$json);
    $c->render(json => $exception->json) if $exception;
    return $bool;
};

any '/' => sub {

    my $c = shift;
    $c->inactivity_timeout(30000);     
    my $json = $c->get_input_json;
    my $action_size = $c->get_action_size($json);
    my $response = $c->process_api_query($json);

    $c->render(json => $response);
};


get '/proofs' => 'proofs';

websocket '/ws' => sub {
    my $c = shift;
    $c->app->log->debug("WebSocket opened");
    $c->inactivity_timeout(30000);     
    my $json = $c->get_input_json;
    my $notification = 0;

    my $res = $c->process_api_query($json);
    $c->send(encode_json($res));

    for my $channel ($c->get_action_channels($json))
    {
	$pool->listen($channel,on_notify => sub { $notification = 1; });
    }

    my $recurring = Mojo::IOLoop->recurring(
	2 => sub { return 1 unless $notification;
		   $c->app->log->debug("WebSocket refreshing information");
		   my $res = $c->process_api_query($json);
		   $c->send(encode_json($res));
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
    my $images_path  = cfg('path.storage.images');
    my $staging_path = cfg('path.storage.staging');
    my $staging_file = eval { $json->{arguments}->{disk_image} } // '';
    my $images_file = $staging_file . '-tmp'. rand;
    $json->{parameters}->{tmp_file_name} = $images_file;

    $c->on(message => sub { my ($c,$msg) = @_;
                            my $sf_size = eval { -s "$staging_path/$staging_file" } // 0;
                            my $if_size = eval { -s "$images_path/$images_file" } // 0;
                            $c->send(encode_json({ status => 1000,
                                                   total_size => $sf_size,
                                                   copy_size => $if_size }));});

    my $fc = Mojo::IOLoop::ForkCall->new;
    $fc->run(
        sub { $c->app->log->debug("Starting copy");
              my $response = $c->qvd_admin4_api->process_query($json);
              return $response; },
        sub { my ($fc, $err, $response) = @_;
	      $err //= 'no error signals';
              $c->app->log->debug("Copy finished: $err");
              $c->send(encode_json($response)); }
        );
};

app->start;

#################
### FUNCTIONS ###
#################

sub create_di
{
    my ($c,$fs,$copy_response,$db_query_request) = @_;
    
    return $copy_response unless $copy_response->{status} eq '0000';
    my $db_query_response = $c->qvd_admin4_api->process_query($db_query_request);

    unless ($db_query_response->{status})
    {
	my $di_name_normalization = $c->qvd_admin4_api->process_query(
	    { action => 'normalize_di_path', 
	      filters => { filesystem => $fs}});

	return $di_name_normalization unless $di_name_normalization->{status} eq '0000';
    }
    $db_query_response;
}

sub get_input_json
{
    my $c = shift;
    my $json = $c->req->json;
    return $json if $json;
    $json =  { map { $_ => $c->param($_) } $c->param };

    eval
    {
        $json->{filters} = decode_json($json->{filters}) if exists $json->{filters};
        $json->{arguments} = decode_json($json->{arguments}) if exists $json->{arguments};
        $json->{order_by} = decode_json($json->{order_by}) if exists $json->{order_by}
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

sub get_action_size
{
    my ($c,$json) = @_;
    my $size = $c->qvd_admin4_api->get_size($json->{action}) 
	// 'normal';
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
    my %args = (login => $json->{login}, password => $json->{password});
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
    $c->qvd_admin4_api->load_user($session->data('admin_id'));

    for (1 .. 5) { eval { $session->flush }; last unless $@;}
    ($bool,$exception) = (0,QVD::Admin4::Exception->new(code => 3400)) if $@;

    return ($bool,$exception);
}

sub reject_access
{
  (0,QVD::Admin4::Exception->new(code => 3100));
}


__DATA__                                                                                                                                                                                      
                                                                                                                                                                                              
@@ proofs.html.ep                                                                                                                                                                              
<html>                                                                                                                                                                                        
<head>                                                                                                                                                                                        
<title>Web Sockets Proofs</title>                                                                                                                                                             
<script type="text/javascript">                                                                                                                                                               

      var staging = new WebSocket('ws://172.20.126.16:8080/staging?login=superadmin&password=superadmin&action=di_create&arguments={"disk_image":"ubuntu-13.04-i386-qvd.tar.gz","osf_id":"14"}');                     
      staging.onopen =                                                                                                                                                                          
        function (event)                                                                                                                                                                      
        { 
            staging.send('Hola');
        };
                               
      staging.onmessage =                                                                                                                                                                          
        function (event)                                                                                                                                                                      
        {                                                                                                                                                                                   
                obj = JSON.parse(event.data);
                
                if (obj.status == 1000) 
                { 
                   document.getElementById("dis_copy_progress").innerHTML = obj.copy_size ;
                   staging.send('Hola');
                }
                else
                {
                   document.getElementById("dis_copy_status").innerHTML = obj.status ;
                   staging.close();
                }
        };                                                                                                                                                                                    

 
</script>                                                                                                                                                                                     
</head>                                                                                                                                                                                       
<body>                                                                                                                                                                                        
<div>DI Copy Progress: <span id="dis_copy_progress"></span></div><br/>
<div>DI Copy Status: <span id="dis_copy_status"></span></div><br/>

</body>                                                                                                                                                                                       
</html>                                                                                                                                                                                       



