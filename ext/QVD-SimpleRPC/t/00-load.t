#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::SimpleRPC' );
}

diag( "Testing QVD::SimpleRPC $QVD::SimpleRPC::VERSION, Perl $], $^X" );
