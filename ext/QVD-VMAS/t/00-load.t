#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::VMAS' );
}

diag( "Testing QVD::VMAS $QVD::VMAS::VERSION, Perl $], $^X" );
