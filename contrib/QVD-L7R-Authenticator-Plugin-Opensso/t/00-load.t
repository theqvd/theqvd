#!perl -T

use Test::More;

BEGIN {
    use File::Spec;
    my ($volume,$directories,$file) = File::Spec->splitpath($0);
    push @INC, $directories;
}

require "lib/defaults.pl";

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

plan tests => 2;
my $filename = QVD::Test::Defaults->createTestConfig ();
{
    no warnings 'once';
    push @QVD::Config::FILES , $filename;
}

require_ok( 'QVD::Config' ) || 
    BAIL_OUT("Bail out!: Unable to load QVD::Config");
use_ok( 'QVD::L7R::Authenticator::Plugin::Opensso' ) || print "Bail out!
";

diag( "Testing QVD::L7R::Authenticator::Plugin::Opensso $QVD::L7R::Authenticator::Plugin::Opensso::VERSION, Perl $], $^X" );
