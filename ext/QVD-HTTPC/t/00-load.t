#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::HTTPC' );
}

diag( "Testing QVD::HTTPC $QVD::HTTPC::VERSION, Perl $], $^X" );
