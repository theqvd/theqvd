#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'JSON::SimpleRPC' );
}

diag( "Testing JSON::SimpleRPC $JSON::SimpleRPC::VERSION, Perl $], $^X" );
