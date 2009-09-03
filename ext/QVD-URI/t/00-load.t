#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::URI' );
}

diag( "Testing QVD::URI $QVD::URI::VERSION, Perl $], $^X" );
