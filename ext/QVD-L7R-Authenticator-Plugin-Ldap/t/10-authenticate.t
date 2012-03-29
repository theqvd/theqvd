#!perl

use Test::More tests => 3;


if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}
my $user = 'user';
my $pass = 'pass';
my $failpass= 'a'.$pass;
use_ok( 'QVD::L7R::Authenticator::Plugin::Ldap' );
my $authenticator = QVD::L7R::Authenticator;
my $ldap = QVD::L7R::Authenticator::Plugin::Ldap;
ok(QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, $pass, undef), "Authenticate basic");
ok(!QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, $failpass, undef), "Authenticate basic");
