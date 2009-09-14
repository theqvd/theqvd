#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::Client' );
}

diag( "Testing QVD::Client $QVD::Client::VERSION, Perl $], $^X" );
