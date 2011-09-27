#!perl

#use Test::More qw(no_plan);
use Test::More;
#use Data::Dumper;

BEGIN {
    use File::Spec;
    my ($volume,$directories,$file) = File::Spec->splitpath($0);
    push @INC, $directories;
}

# Check if test parameters are set
require "lib/defaults.pl";

{
    no warnings 'once';
    if (!defined($QVD::Test::Defaults::test_smtphost) ||
	!defined($QVD::Test::Defaults::test_smtpto) ||
	!defined($QVD::Test::Defaults::test_user) ||
	!defined($QVD::Test::Defaults::test_pass)) {
	plan skip_all => 'Please define $QVD::Test::Defaults::test_smtphost, $QVD::Test::Defaults::test_smtpto lib/defaults.pl';
    }

    my $filename = QVD::Test::Defaults->createTestConfig ();
    push @QVD::Config::FILES , $filename;
    $QVD::Config::USE_DB = 0;
}

plan tests => 8;

require_ok( 'QVD::Config' ) || 
    BAIL_OUT("Bail out!: Unable to load QVD::Config");
QVD::Config->import('set_core_cfg', 'cfg');
use_ok('QVD::L7R::Authenticator');

use_ok( 'QVD::L7R::Authenticator::Plugin::Notifybymail' ) || print "Bail out!
";

my $auth_obj = QVD::L7R::Authenticator->new();

my $smtp = Net::SMTP->new($QVD::Test::Defaults::test_smtphost);
ok($smtp, "Be able to get connection to smtp host ".$QVD::Test::Defaults::test_smtphost);
$smtp->quit;


my $auth=QVD::L7R::Authenticator::Plugin::Notifybymail->authenticate_basic($auth_obj, $QVD::Test::Defaults::test_user, $QVD::Test::Defaults::test_pass);
isnt($auth, 1, "Test for unsuccesful auth but send email");
$auth_obj->{login} = $QVD::Test::Defaults::test_user;

QVD::L7R::Authenticator::Plugin::Notifybymail->before_list_of_vms($auth_obj);
ok(1, "Called before_list_of_vms");

$auth=QVD::L7R::Authenticator::Plugin::Notifybymail->authenticate_basic($auth_obj, $QVD::Test::Defaults::test_userskip, $QVD::Test::Defaults::test_pass);
isnt($auth, 1, "Test for unsuccesful auth but send email");
$auth_obj->{login} = $QVD::Test::Defaults::test_userskip;

QVD::L7R::Authenticator::Plugin::Notifybymail->before_list_of_vms($auth_obj);
ok(1, "Called before_list_of_vms");
