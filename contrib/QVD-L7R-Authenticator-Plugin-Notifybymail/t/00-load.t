#!perl -T

use Test::More;
use Data::Dumper;

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

plan tests => 2;

require_ok( 'QVD::Config' ) || 
    BAIL_OUT("Bail out!: Unable to load QVD::Config");

use_ok( 'QVD::L7R::Authenticator::Plugin::Notifybymail' ) || print "Bail out!
";

diag( "Testing QVD::L7R::Authenticator::Plugin::Notifybymail $QVD::L7R::Authenticator::Plugin::Notifybymail::VERSION, Perl $], $^X" );
