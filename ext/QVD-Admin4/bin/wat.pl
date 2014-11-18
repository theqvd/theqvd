#!/usr/lib/qvd/bin/perl
use Mojolicious::Lite;
use lib::glob '/home/benjamin/wat/*/lib/';
use QVD::Admin4::REST;
use Mojo::JSON qw(encode_json decode_json);
use QVD::Admin4::Exception;
use QVD::Config;
use MojoX::Session;
app->config(hypnotoad => {listen => ['http://192.168.56.101:3000']});

my $QVD_ADMIN4_API = QVD::Admin4::REST->new();
my $DB_CONNECTION_INFO = "dbi:Pg:dbname=".cfg('database.name').";host=".cfg('database.host');

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

plugin PgAsync => {dbi => [$DB_CONNECTION_INFO,cfg('database.user'),cfg('database.password'), 
			   {AutoCommit => 1, RaiseError => 1}]};

helper (qvd_admin4_api => sub { $QVD_ADMIN4_API; });
helper (get_input_json => \&get_input_json);
helper (process_api_query => \&process_api_query);

under sub {

    my $c = shift;

    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
    $c->res->headers->header('Access-Control-Expose-Headers' => 'sid');

    my $session = MojoX::Session->new( 
	store  => [dbi => {dbh => QVD::DB->new()->storage->dbh}],
	transport => MojoX::Session::Transport::WAT->new(),
	tx => $c->tx );

    my $json = $c->req->json // 
    { map { $_ => $c->param($_) } $c->param };
 
    if (defined $json->{login} &&
	defined $json->{password})
    {
	my $admin = $c->qvd_admin4_api->validate_user(login    => $json->{login}, 
						      password => $json->{password});
	if ($admin)
	{
	    $c->qvd_admin4_api->load_user($admin);
	    $session->create;
	    $session->flush; 
	    $session->data(admin_id => $admin->id);
	    $session->flush; 
	    return 1;
	} 
	else
	{
	    $c->render(json => 
		       QVD::Admin4::Exception->new(code =>23)->json);
	    return 0;
	}
    }
    elsif ($session->load) 
    {
        if ($session->is_expired)
	{  
	    $session->flush; 
	    $c->render(json => 
		       QVD::Admin4::Exception->new(code => 24)->json);
	    return 0;
	}
	else
	{
	    $session->extend_expires;

	    for (1 .. 5)
            {
                eval { $session->flush };
                $@ ? print $@ : last;
            }
            if ($@)
            {
                $c->render(json =>
                           QVD::Admin4::Exception->new(code => 25)->json);
                return 0;
            }

	    $c->qvd_admin4_api->load_user($session->data('admin_id'));
	    return 1;
	}
    }
    else 
    {
	$c->render(json => 
		   QVD::Admin4::Exception->new(code => 22)->json);
	return 0;
    }
};

get '/' => sub {

    my $c = shift;
    my $json = $c->get_input_json;
    $c->stash(action => $json->{action}, 
	      sid => $c->res->headers->header('sid'));
    $c->render(template => 'index');
};

any '/api' => sub {

    my $c = shift;
    my $json = $c->get_input_json;
    my $response = $c->process_api_query($json);
    $c->render(json => $response);
};

websocket '/listen/:action' => sub {
    my $c = shift;
    my $action = $c->stash('action');
    my $loop = Mojo::IOLoop->singleton;
    $c->app->log->debug("WebSocket LISTEN opened");

    my $recurring = $loop->recurring(1 => sub { 
	my $response = $c->process_api_query({action => $action }); 
	$c->send(${$response->{rows}}[0]); });

    $c->on(finish => sub {
	my ($c, $code) = @_;
	$c->app->log->debug("WebSocket LISTEN closed with status $code");
	$loop->remove($recurring);});
};

websocket '/stream/:action' => sub {
    my $c = shift;
    my $action = $c->stash('action');
    my $loop = Mojo::IOLoop->singleton;
    $c->app->log->debug("WebSocket STREAM opened");
    $c->inactivity_timeout(3000);

    my $tx = $c->tx;
    my ($cb,$pg_listener); $cb = 
	sub { $pg_listener = $loop->delay(
		  sub { my $delay = shift;
			$c->pg_listen('foo', $delay->begin);},
		  sub { my $delay = shift;
			$c->app->log->debug('FOO notified');
			my $response = $c->process_api_query({action => $action }); 
			$c->send(${$response->{rows}}[0]); $cb->();},); };
    $cb->();
    
    $c->on(finish => sub {
	my ($c, $code) = @_;
	$c->app->log->debug("WebSocket STREAM closed with status $code");
	$loop->remove($pg_listener); });
};

sub get_input_json
{
    my $c = shift;
    my $json = $c->req->json;
    unless ($json)
    {
        $json =  { map { $_ => $c->param($_) } $c->param };
        eval { $json->{filters} = decode_json($json->{filters}) if exists $json->{filters};
               $json->{arguments} = decode_json($json->{arguments}) if exists $json->{arguments};
               $json->{order_by} = decode_json($json->{order_by}) if exists $json->{order_by} };
    }
    $json;
}

sub process_api_query
{
    my ($c,$json) = @_;

    print $@ if $@;
    my $response = ($@ ?
                    QVD::Admin4::Exception->new(code => 6100)->json  :
                    $c->qvd_admin4_api->process_query($json));

    $response->{sid} = $c->res->headers->header('sid');
    $response;
}


app->start;

__DATA__

@@ index.html.ep
<html>
<head>
<title>Web Sockets Proofs</title>
<script type="text/javascript">

    var listen = new WebSocket('<%= "ws://localhost:3000/listen/$action?sid=$sid" %>');
    listen.onmessage = function (event) { document.getElementById("listen").innerHTML = event.data };
     var stream = new WebSocket('<%= "ws://localhost:3000/stream/$action?sid=$sid" %>');
    stream.onmessage = function (event) { document.getElementById("stream").innerHTML = event.data };

</script>

</head>
<body>
    <h1>Web Sockets Proofs</h1>
    <a href="http://localhost:3000/api?login=superadmin&password=superadmin&action=user_get_list">bye bye</a>
    <hr/>
    <section>LISTEN<br/><div id="listen"></div></section>
    <br/>
    <section>STREAM<br/><div id="stream"></div></section>
</body>

</html>
