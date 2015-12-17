#!/usr/bin/perl

use strict; 
use warnings; 

use Mojolicious::Lite;

app->config(hypnotoad => {listen => ['http://*:80']});

plugin ('Directory' => { root => "/usr/lib/qvd/wat" ,
		dir_index => [qw/index.html index.htm/] 
	 })->start ; 

