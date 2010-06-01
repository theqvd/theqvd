#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::L7R::Authenticator::Plugin::LDAP' ) || print "Bail out!
";
}

diag( "Testing QVD::L7R::Authenticator::Plugin::LDAP $QVD::L7R::Authenticator::Plugin::LDAP::VERSION, Perl $], $^X" );
