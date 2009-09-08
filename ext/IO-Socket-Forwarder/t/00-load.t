#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'IO::Socket::Forwarder' );
}

diag( "Testing IO::Socket::Forwarder $IO::Socket::Forwarder::VERSION, Perl $], $^X" );
