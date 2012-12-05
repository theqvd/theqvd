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
    require_ok( 'QVD::Config::Core' ) || 
	BAIL_OUT("Bail out!: Unable to load QVD::Config::Core");

    QVD::Config::Core->import('set_core_cfg');

    set_core_cfg('auth.passthrough.return_code', 1);
}

if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}


# Load plugin
use_ok( 'QVD::L7R::Authenticator' );
use_ok( 'QVD::L7R::Authenticator::Plugin::Passthrough' );
my $auth_obj = QVD::L7R::Authenticator->new();
my $auth = QVD::L7R::Authenticator::Plugin::Passthrough->authenticate_basic($auth_obj, $login, $pass);
ok($auth, "Successful auth");

done_testing;
