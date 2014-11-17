#!/usr/lib/qvd/bin/perl
use Mojolicious::Lite;
use lib::glob '/home/benjamin/wat/*/lib/';
use QVD::Admin4::REST;
use Mojo::JSON qw(encode_json decode_json);
use QVD::Admin4::Exception;
use QVD::DB;
use MojoX::Session;

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

my $QVD_ADMIN4_API = QVD::Admin4::REST->new();

app->config(hypnotoad => {listen => ['http://192.168.56.101:3000']});

helper (qvd_admin4_api => sub { $QVD_ADMIN4_API; });
helper (events_notifier => sub { $QVD_ADMIN4_API->_db->mypool; });

under sub {

    my $c = shift;

    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
    $c->res->headers->header('Access-Control-Expose-Headers' => 'sid');
#    $c->res->headers->header('Access-Control-Allow-Headers' => 'accept, content-type');
    my $session = MojoX::Session->new( 
	store  => [dbi => {dbh => QVD::DB->new()->storage->dbh}],
	transport => MojoX::Session::Transport::WAT->new(),
	tx => $c->tx );
#    $session->expires_delta(60);

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


any '/' => sub { 

    my $c = shift;

    my $json = $c->req->json;

    unless ($json)
    {
	$json =  { map { $_ => $c->param($_) } $c->param };
	eval { $json->{filters} = decode_json($json->{filters}) if exists $json->{filters};
	       $json->{arguments} = decode_json($json->{arguments}) if exists $json->{arguments};
	       $json->{order_by} = decode_json($json->{order_by}) if exists $json->{order_by} };
    }
    
    print $@ if $@;
    my $response = ($@ ? 
		    QVD::Admin4::Exception->new(code => 6100)->json  :
		    $c->qvd_admin4_api->process_query($json));

    $response->{sid} = $c->res->headers->header('sid');
    $c->render(json => $response);
};

websocket '/echo' => sub {
    my $c = shift;
    $c->app->log->debug('WebSocket opened.');

    $c->send("echo:"); 
# Probar con Mojolicious/Plugin/PgAsync.pm
    my $en = $c->events_notifier;
    $en->listen('kkk',
		on_notify => 
		sub { use Data::Dumper; 
		      print Dumper [@_];
		      $c->send("Hola!"); });
};

app->start;
