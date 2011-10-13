#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'QVD::L7R::Authenticator::Plugin::Ldap' ) || print "Bail out!
";
}

diag( "Testing QVD::L7R::Authenticator::Plugin::Ldap $QVD::L7R::Authenticator::Plugin::Ldap::VERSION, Perl $], $^X" );
