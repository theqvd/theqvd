#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::Frontend' );
}

diag( "Testing QVD::Frontend $QVD::Frontend::VERSION, Perl $], $^X" );
