#!/usr/lib/qvd/bin/perl
use Mojolicious::Lite;
use lib::glob '/home/benjamin/WAT/ext/*/lib/';
use QVD::Admin4::REST;
use Mojo::JSON qw(decode_json encode_json);
use QVD::Admin4::REST::Response;
use Mojolicious::Plugin::Authentication;

my $QVD_ADMIN4_API = QVD::Admin4::REST->new();

app->secrets(['Lucky Ben']);
app->sessions->cookie_name('amazingwat');
#app->sessions->default_expiration(0);
app->config(hypnotoad => {listen => ['http://192.168.3.5:3000']});
helper (qvd_admin4_api => sub { $QVD_ADMIN4_API; });

plugin 'authentication', 
{
    load_user     => sub { my ($c,$uid) = @_; 
			   $c->qvd_admin4_api->load_user(%$uid);
			   $uid;},
    validate_user => sub { my ($c,$login,$password) = @_;
			   $c->qvd_admin4_api->validate_user(login    => $login, 
							     password => $password);
			 
}
};

under sub {

    my $c = shift;

    my $json = $c->req->json // 
    { map { $_ => $c->param($_) } $c->param };
 
    if (defined $json->{login} &&
	defined $json->{password})
    {
	$c->logout;
	$c->authenticate($json->{login},
			 $json->{password}); 
    }

    $c->is_user_authenticated && return 1;

    $c->render(json => 
	QVD::Admin4::REST::Response->new(status => 3)->json);
    return 0;
};

any '/' => sub { 

    my $c = shift;

    my $json = $c->req->json;
    $c->res->headers->header('Access-Control-Allow-Origin' => '*');

    unless ($json)
    {
	$json =  { map { $_ => $c->param($_) } $c->param };
	eval { $json->{filters} = decode_json($json->{filters}) if exists $json->{filters};
	       $json->{arguments} = decode_json($json->{arguments}) if exists $json->{arguments};
	       $json->{order_by} = decode_json($json->{order_by}) if exists $json->{order_by} };
    }
    
    print $@ if $@;
    my $response = ($@ ? 
		    QVD::Admin4::REST::Response->new(status => 15)->json  :
		    $c->qvd_admin4_api->process_query($json));

    $c->render(json => $response);
};


app->start;

