#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::VMA' );
}

diag( "Testing QVD::VMA $QVD::VMA::VERSION, Perl $], $^X" );
