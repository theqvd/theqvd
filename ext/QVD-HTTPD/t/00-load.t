#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'QVD::HTTPD' );
}

diag( "Testing QVD::HTTPD $QVD::HTTPD::VERSION, Perl $], $^X" );
