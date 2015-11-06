#!/usr/bin/perl

use strict; 
use warnings; 

use Mojolicious::Lite;
plugin ('Directory' => { root => "/usr/lib/qvd/wat/wat" ,
		dir_index => [qw/index.html index.htm/] 
	 })->start ; 

