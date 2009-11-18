#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::RC' );
}

diag( "Testing QVD::RC $QVD::RC::VERSION, Perl $], $^X" );
