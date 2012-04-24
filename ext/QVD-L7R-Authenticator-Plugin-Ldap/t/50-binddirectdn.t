#!perl
use Data::Dumper;
use Test::More tests => 5;


if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}
my $user = 'ptem_user';
my $pass = 'ptem';
my $nouser = 'nouser';
my $failpass= 'a'.$pass;

system "qvd-admin.pl config set auth.ldap.userbindpattern=uid=%u,ou=People,dc=qindel,dc=com";
use_ok( 'QVD::L7R::Authenticator::Plugin::Ldap' );
my $ldap = QVD::L7R::Authenticator::Plugin::Ldap;
ok(QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, $pass, undef), "Authenticate basic");
# Cached
ok(QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, $pass, undef), "Authenticate basic cached");
ok(!QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, $failpass, undef), "Authenticate basic failed");
ok(!QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $nouser, $pass, undef), "Authenticate basic failed");

system "qvd-admin.pl config del auth.ldap.userbindpattern";
