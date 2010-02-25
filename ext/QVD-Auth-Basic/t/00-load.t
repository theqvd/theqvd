#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::Auth::Basic' );
}

diag( "Testing QVD::Auth::Basic $QVD::Auth::Basic::VERSION, Perl $], $^X" );
