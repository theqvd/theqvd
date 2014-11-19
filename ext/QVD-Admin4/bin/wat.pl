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
		       QVD::Admin4::Exception->new(code =>3200)->json);
	    return 0;
	}
    }
    elsif ($session->load) 
    {
        if ($session->is_expired)
	{  
	    $session->flush; 
	    $c->render(json => 
		       QVD::Admin4::Exception->new(code => 3300)->json);
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
                           QVD::Admin4::Exception->new(code => 3400)->json);
                return 0;
            }

	    $c->qvd_admin4_api->load_user($session->data('admin_id'));
	    return 1;
	}
    }
    else 
    {
	$c->render(json => 
		   QVD::Admin4::Exception->new(code => 3100)->json);
	return 0;
    }
};

get '/index' => sub {

    my $c = shift;
    my $json = $c->get_input_json;
    $c->stash(query => $json, 
	      sid => $c->res->headers->header('sid'));
    $c->render(template => 'index');
};

any '/' => sub {

    my $c = shift;
    my $json = $c->get_input_json;
    my $response = $c->process_api_query($json);
    $c->render(json => $response);
};

websocket '/stream' => sub {
    my $c = shift;
    my $json = $c->get_input_json;

    $c->app->log->debug("WebSocket stream opened");

    my $recurring = Mojo::IOLoop->recurring(1 => sub { 
	my $response = $c->process_api_query($json); 
	$c->send(encode_json($response)); });

    $c->on(finish => sub {
	my ($c, $code) = @_;
	$c->app->log->debug("WebSocket stream closed with status $code");
	Mojo::IOLoop->remove($recurring);});
};

websocket '/notify' => sub {
    my $c = shift;
    my $json = $c->get_input_json;

    $c->app->log->debug("WebSocket notify opened");
    $c->inactivity_timeout(3000); 

    my $cb; $cb = sub { 
	$c->pg_listen('foo', sub { 
	    $c->app->log->debug('FOO notified');
	    my $response = $c->process_api_query($json); 
	    $c->send(encode_json($response)); $cb->();} );};

    $c->send(encode_json($c->process_api_query($json)));
    $cb->();
    
    $c->on(finish => sub {
	my ($c, $code) = @_;
	$c->app->log->debug("WebSocket notify closed with status $code");});
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

      var stream = new WebSocket('ws://localhost:3000/stream?login=superadmin&password=superadmin&action=qvd_objects_statistics');
      stream.onmessage = function (event) { obj = JSON.parse(event.data); 
                                            document.getElementById("total").innerHTML = obj.vms_count;
                                            document.getElementById("blocked").innerHTML = obj.blocked_vms_count;
                                            document.getElementById("running").innerHTML = obj.running_vms_count;};
      var notify = new WebSocket('ws://localhost:3000/notify?login=superadmin&password=superadmin&action=vm_get_state&filters={"id":"1"}');
      notify.onmessage = function (event) { obj = JSON.parse(event.data); 
                                            document.getElementById("state").innerHTML = obj.rows[0].state;
                                            document.getElementById("user_state").innerHTML = obj.rows[0].user_state; };

</script>

</head>
<body>
    <h1>Web Sockets Proofs</h1>
    <a href="http://localhost:3000/?login=superadmin&password=superadmin&action=user_get_list">bye bye</a>
    <hr/>
    <section>
    <h3>VMs in QVD</h3>
    Total: <span id="total"></span></br>
    Blocked: <span id="blocked"></span></br>
    Running: <span id="running"></span></br>
    </section>
    <section>
    <h3>VM1 Monitoring</h3>
    State: <span id="state"></span></br>
    User state: <span id="user_state"></span></br>
    </section>
</body>

</html>
