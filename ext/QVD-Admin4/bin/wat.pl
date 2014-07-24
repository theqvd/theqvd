#!/usr/bin/env perl
use Mojolicious::Lite;
use lib::glob '/home/benjamin/qvdadmin4/ext/*/lib/';
use QVD::Admin4::REST;

app->secrets(['QVD']);

my $REST;

helper (_rest => sub { $REST //= QVD::Admin4::REST->new(); });
 
under sub {

    my $c = shift;
    
    $c->session('role') && return 1;
    $c->session(role => $c->_rest->_auth($c->req->json));
    $c->session('role') ? return 1 : $c->render( json => { status => 401 });
};

any '/' => sub { 

    my $c = shift;
    my $json = $c->req->json;
    $json->{tenant} = $c->session('role'); 

    $c->render(json => $c->_rest->_admin($json));
};


app->start;
