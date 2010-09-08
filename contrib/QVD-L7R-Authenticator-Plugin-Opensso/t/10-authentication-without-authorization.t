#!perl

#use Test::More qw(no_plan);
use Test::More;
use Data::Dumper;
#use warnings;
#use strict;

BEGIN {
    use File::Spec;
    my ($volume,$directories,$file) = File::Spec->splitpath($0);
    push @INC, $directories;
}

# Check if test parameters are set
require "lib/defaults.pl";

{
    no warnings 'once';
    if (!defined($QVD::Test::Defaults::test_authenticate_uri) ||
	!defined($QVD::Test::Defaults::test_user) ||
	!defined($QVD::Test::Defaults::test_pass)) {
	plan skip_all => 'Please define $QVD::Test::Defaults::test_uri, $QVD::Test::Defaults::test_user and $QVD::Test::Defaults::test_pass in lib/defaults.pl';
    }
}

plan tests =>5;

# Main

# Overwrite configs
{
    # Only authenticate no authorize
    no warnings 'once';
    $QVD::Test::Defaults::test_target_uri='';
}
my $filename = QVD::Test::Defaults->createTestConfig ();
{
    no warnings 'once';
    push @QVD::Config::FILES , $filename;
    $QVD::Config::DB = 0;
}
require_ok( 'QVD::Config' ) || 
    BAIL_OUT("Bail out!: Unable to load QVD::Config");
QVD::Config->import('set_core_cfg', 'cfg');
# Load plugin
use_ok( 'QVD::L7R::Authenticator' );
use_ok( 'QVD::L7R::Authenticator::Plugin::Opensso' ) || 
    BAIL_OUT "Bail out!: Unable to load QVD::L7R::Authenticator::Plugin::Opensso";

my $auth_obj = QVD::L7R::Authenticator->new();

# Test fail with wrong password
my $auth=QVD::L7R::Authenticator::Plugin::Opensso->authenticate_basic($auth_obj, $QVD::Test::Defaults::test_user, $QVD::Test::Defaults::test_pass . "fail");
isnt($auth, 1, "Test unsuccessful auth with wrong pass");

# Test auth
$auth=QVD::L7R::Authenticator::Plugin::Opensso->authenticate_basic($auth_obj, $QVD::Test::Defaults::test_user, $QVD::Test::Defaults::test_pass);

is($auth, 1, "Test successful auth");



