#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::Auth' );
}

diag( "Testing QVD::Auth $QVD::Auth::VERSION, Perl $], $^X" );
