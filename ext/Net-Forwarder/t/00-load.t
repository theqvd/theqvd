#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Net::Forwarder' );
}

diag( "Testing Net::Forwarder $Net::Forwarder::VERSION, Perl $], $^X" );
