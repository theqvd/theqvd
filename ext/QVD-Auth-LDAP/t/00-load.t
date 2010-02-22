#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::Auth::LDAP' );
}

diag( "Testing QVD::Auth::LDAP $QVD::Auth::LDAP::VERSION, Perl $], $^X" );
