#!/usr/bin/env perl
use Mojolicious::Lite;
use lib::glob '/home/qindel/qvdadmin4/ext/*/lib/';
use QVD::Admin4::REST;
use Mojo::JSON qw(decode_json encode_json);
use QVD::Admin4::REST::Response;

app->secrets(['QVD']);
my $REST = QVD::Admin4::REST->new();

app->config(hypnotoad => {listen => ['http://192.168.3.4:3000']});
helper (_rest => sub { $REST; });
helper (_parse => sub { $REST; });

under sub {

    my $c = shift;

    my $json = $c->req->json // 
    { map { $_ => $c->param($_) } $c->param };
    
    my $response = $c->_rest->_auth($json);

    if ($response->{status})
    {
	$c->render(json => $response);
	return 0;
    } 
    else
    {   
	$c->session(%{$response->{result}});
	return 1;
    }
};

any '/' => sub { 

    my $c = shift;

    my $json = $c->req->json // { map { $_ => $c->param($_) } $c->param };
    @$json{qw(tenant role)} = ($c->session('tenant'),$c->session('role')); 

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

