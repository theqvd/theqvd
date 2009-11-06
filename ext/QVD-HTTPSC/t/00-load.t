#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::HTTPSC' );
}

diag( "Testing QVD::HTTPSC $QVD::HTTPSC::VERSION, Perl $], $^X" );
