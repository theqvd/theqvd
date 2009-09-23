#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::DB' );
}

diag( "Testing QVD::DB $QVD::DB::VERSION, Perl $], $^X" );
