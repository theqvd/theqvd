#!perl
use Test::More tests => 2;


if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}
my $user = 'ptem_user';
my $pass = 'ptem';

my $host = qx{qvd-admin.pl config get auth.ldap.host};

my ($orighost) = ($host =~ /^[^=]+=(.*)/);
$failhost="$orighost:1111";
system("qvd-admin.pl config set auth.ldap.host=$failhost");

use_ok( 'QVD::L7R::Authenticator::Plugin::Ldap' );
my $ldap = QVD::L7R::Authenticator::Plugin::Ldap;
ok(!QVD::L7R::Authenticator::Plugin::Ldap->authenticate_basic($authenticator, $user, $pass, undef), "Authenticate basic");

system("qvd-admin.pl config set auth.ldap.host=$orighost");
