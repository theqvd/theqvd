#!perl -T
use Test::More;
use warnings;
use strict;
use Data::Dumper;

my ($login, $pass) = ('myuser', 'mypass');

BEGIN {
    use File::Spec;
    my ($volume,$directories,$file) = File::Spec->splitpath($0);
    push @INC, $directories;
}

if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}

require_ok( 'QVD::Config::Core' ) || 
    BAIL_OUT("Bail out!: Unable to load QVD::Config::Core");

QVD::Config->import('set_core_cfg');


# Load plugin
use_ok( 'QVD::L7R::Authenticator' );
use_ok( 'QVD::L7R::Authenticator::Plugin::Passthrough' );
my $auth_obj = QVD::L7R::Authenticator->new();
my $auth = QVD::L7R::Authenticator::Plugin::Passthrough->authenticate_basic($auth_obj, $login, $pass);
ok(!defined($auth), "Successful auth returns false");

QVD::L7R::Authenticator::Plugin::Passthrough->before_connect_to_vm($auth_obj);

is($auth_obj->{params}->{'qvd.auth.passthrough.passwd'}, $pass, "Check that the pasword is passed up $pass");

done_testing;
