#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::Config' );
}

diag( "Testing QVD::Config $QVD::Config::VERSION, Perl $], $^X" );
