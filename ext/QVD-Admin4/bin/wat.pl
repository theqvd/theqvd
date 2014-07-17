#!/usr/bin/env perl
use Mojolicious::Lite;
use lib::glob '/home/benjamin/qvdadmin4/ext/*/lib/';
use QVD::Admin4::REST;

app->secrets(['QVD']);

helper (_rest => sub { QVD::Admin4::REST->new(); });
 
under sub {

    my $c = shift;
    my $pass = $c->_rest->_auth($c->req->json);

    $pass->{'status'} ? $c->render( json => { status => $pass->{'status'}}) : return 1;
};

any '/' => sub { 

    my $c = shift;
    $c->render(json => $c->_rest->_admin($c->req->json));
};


app->start;
