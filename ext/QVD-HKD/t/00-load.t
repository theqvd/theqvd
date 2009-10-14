#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::HKD' );
}

diag( "Testing QVD::HKD $QVD::HKD::VERSION, Perl $], $^X" );
