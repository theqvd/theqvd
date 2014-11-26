#!/usr/lib/qvd/bin/perl
use Mojolicious::Lite;
use lib::glob '/home/benjamin/wat/*/lib/';
use QVD::Admin4::REST;
use Mojo::JSON qw(encode_json decode_json);
use QVD::Admin4::Exception;
use QVD::Config;
use MojoX::Session;
use File::Copy qw(copy move);
use File::Basename qw(basename dirname);
use Mojo::IOLoop::ForkCall;

# MojoX::Session::Transport::WAT Package 

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

my $DB_CONNECTION_INFO = "dbi:Pg:dbname=".cfg('database.name').";host=".cfg('database.host');
plugin PgAsync => {dbi => [$DB_CONNECTION_INFO,cfg('database.user'),cfg('database.password'), 
			   {AutoCommit => 1, RaiseError => 1}]};
app->config(hypnotoad => {listen => ['http://192.168.56.101:3000']});
my $QVD_ADMIN4_API = QVD::Admin4::REST->new();

# HELPERS

helper (qvd_admin4_api => sub { $QVD_ADMIN4_API; });
helper (get_input_json => \&get_input_json);
helper (process_api_query => \&process_api_query);
helper (get_api_channels => \&get_api_channels);
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
    my $json = $c->get_input_json;
    my $response = $c->process_api_query($json);
    $c->render(json => $response);
};


get '/proofs' => 'proofs';

websocket '/ws' => sub {
    my $c = shift;

    $c->app->log->debug("WebSocket opened");
    $c->inactivity_timeout(30);
    
    my ($timer,$listener); 
    
    my $json = $c->get_input_json;
    my $res = $c->process_api_query($json);
    my $action = $json->{action};
    my @channels = @{$c->get_api_channels($action)};
    push @channels, 'foo' unless @channels; 
    $c->send(encode_json($res));

    $c->on(message => sub {
        my ($c, $msg) = @_;
        $c->app->log->debug("WebSocket $msg signal received");
        
	Mojo::IOLoop->remove($timer) if $timer;
	$timer = Mojo::IOLoop->timer(25 => sub { $c->send('AKN');});
 
	my $channel = 'foo';
	Mojo::IOLoop->delay(sub { my $delay = shift;
				  $c->pg_listen($channel, $delay->begin);},
			    sub {$res = $c->process_api_query($json);
				 $c->send(encode_json($res));});
	});

    $c->on(finish => sub {
        my ($c, $code) = @_;
        Mojo::IOLoop->remove($timer) if $timer;
        $c->app->log->debug("WebSocket closed with status $code");});

};


app->start;

#################
### FUNCTIONS ###
#################

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
    my $res = $c->qvd_admin4_api->process_query($json);
    $res->{sid} = $c->res->headers->header('sid');
    $res;
}

sub get_api_channels
{
    my ($c,$json) = @_;
    $c->qvd_admin4_api->get_channels($json);
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
      var ws = new WebSocket('ws://localhost:3000/ws?login=superadmin&password=superadmin&action=vm_get_details&filters={"id":"4"}');                                                    
      ws.onmessage =                                                                                                                                                                          
        function (event)                                                                                                                                                                      
        {                                                                                                                                                                                     
              document.getElementById("state").innerHTML = event.data;                                                                                                                       
              ws.send('Hello!!');                                                                                                                                                             
        };                                                                                                                                                                                    
                                                                                                                                                                                              
</script>                                                                                                                                                                                     
</head>                                                                                                                                                                                       
<body>                                                                                                                                                                                        
<div id="state"></div>                                                                                                                                                                        
</body>                                                                                                                                                                                       
</html>                                                                                                                                                                                       



