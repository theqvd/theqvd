#!perl

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::Admin' );
}

diag( "Testing QVD::Admin $QVD::Admin::VERSION, Perl $], $^X" );
