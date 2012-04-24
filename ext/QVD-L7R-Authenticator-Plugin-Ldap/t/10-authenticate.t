#!perl

use Test::More tests => 8;


if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}
my $user = 'ptem_user';
my $nouser = 'nouser';
my $pass = 'ptem';
my $failpass= 'a'.$pass;
use_ok( 'QVD::L7R::Authenticator::Plugin::Ldap' );
my $authenticator = QVD::L7R::Authenticator;
my $ldap = QVD::L7R::Authenticator::Plugin::Ldap;
ok(QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, $pass, undef), "Authenticate basic");
# The second should be cached
ok(QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, $pass, undef), "Authenticate basic cached");
# Delete cache different password
ok(!QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, $failpass, undef), "Authenticate basic fail");
# Reauthenticate
ok(QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, $pass, undef), "Authenticate basic accept with cache");
# User does not exist
ok(!QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $nouser, $pass, undef), "Authenticate basic, wrong user");
# Empty pass
ok(!QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, '', undef), "Authenticate basic, empty pass");
ok(!QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, undef, undef), "Authenticate basic, undef pass");
