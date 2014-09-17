#!/usr/bin/env perl
use Mojolicious::Lite;
use lib::glob '/home/qindel/qvdadmin4/ext/*/lib/';
use QVD::Admin4::REST;
use Mojo::JSON qw(decode_json encode_json);
use QVD::Admin4::REST::Response;
use Mojolicious::Plugin::Authentication;

my $REST = QVD::Admin4::REST->new();

app->secrets(['Lucky Ben']);
#app->sessions->cookie_name('amazingwat');
app->sessions->default_expiration(0);
app->config(hypnotoad => {listen => ['http://192.168.3.4:3000']});
helper (_rest => sub { $REST; });

plugin 'authentication', 
{
    load_user     => sub { my ($c,$uid) = @_; 
			   $c->_rest->load_user(%$uid);
			   $uid;},
    validate_user => sub { my ($c,$login,$password) = @_;
			   $c->_rest->validate_user(login    => $login, 
						    password => $password);}
};

under sub {

    my $c = shift;

#   print $c->cookie('amazingwat');
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
        
    my $json = $c->req->json // { map { $_ => $c->param($_) } $c->param };
    $c->res->headers->header('Access-Control-Allow-Origin' => '*');

    eval { $json->{filters} = decode_json($json->{filters}) if exists $json->{filters};
	   $json->{arguments} = decode_json($json->{arguments}) if exists $json->{arguments};
	   $json->{order_by} = decode_json($json->{order_by}) if exists $json->{order_by} };

    my $response = ($@ ? 
		    QVD::Admin4::REST::Response->new(status => 15)->json  :
		    $c->_rest->_admin($json));

    $c->render(json => $response);
};


app->start;

