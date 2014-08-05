#!/usr/bin/env perl
use Mojolicious::Lite;
use lib::glob '/home/qindel/qvdadmin4/ext/*/lib/';
use QVD::Admin4::REST;
use Mojo::JSON qw(decode_json encode_json);

app->secrets(['QVD']);
my $REST = QVD::Admin4::REST->new();

app->config(hypnotoad => {listen => ['http://192.168.3.4:3000']});
helper (_rest => sub { $REST; });

under sub {

    my $c = shift;

    my $json = $c->req->json // { map { $_ => $c->param($_) } $c->param };
    $c->session(%{$c->_rest->_auth($json)});

    ($c->session('role') && $c->session('role')) ? 
	return 1 : 
	$c->render( json => { status => 401 });
};

any '/' => sub { 

    my $c = shift;

    my $json = $c->req->json // { map { $_ => $c->param($_) } $c->param };
    @$json{qw(tenant role)} = ($c->session('tenant'),$c->session('role')); 

    my $filters = delete $json->{filters};
    $json->{filters} = decode_json($filters) if $filters;
    $c->res->headers->header('Access-Control-Allow-Origin' => '*');
    $c->render(json => $c->_rest->_admin($json));
};


app->start;

