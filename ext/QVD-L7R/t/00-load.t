#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::L7R' );
}

diag( "Testing QVD::L7R $QVD::L7R::VERSION, Perl $], $^X" );
