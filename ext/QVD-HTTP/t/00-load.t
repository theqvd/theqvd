#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::HTTP' );
}

diag( "Testing QVD::HTTP $QVD::HTTP::VERSION, Perl $], $^X" );
