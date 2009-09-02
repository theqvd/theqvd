#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::L7R::Forwarder' );
}

diag( "Testing QVD::L7R::Forwarder $QVD::L7R::Forwarder::VERSION, Perl $], $^X" );
