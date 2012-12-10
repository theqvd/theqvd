#!perl -T
use Test::More;
use warnings;
use strict;
use File::Temp;
use Data::Dumper;

my ($testuser, $testpass, $home, $testfile) = ('testuser', 'testpass', $ENV{HOME}, '.qvd.deleteme');

if ( not $ENV{TEST_AUTHOR} ) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan( skip_all => $msg );
}

my $filename = createTestConfig($testfile);
{
    no warnings 'once';
    push @QVD::Config::Core::FILES , $filename;
    $QVD::Config::Core::USE_DB = 0;
}

require_ok( 'QVD::Config' ) || 
    BAIL_OUT("Bail out!: Unable to load QVD::Config");
QVD::Config::Core->import('set_core_cfg');

use_ok('QVD::VmaHook::Passthrough', qw(save_credentials));


ok(!QVD::VmaHook::Passthrough::save_credentials(), "No parameters passed to save_credentials");
ok(!QVD::VmaHook::Passthrough::save_credentials([
	'qvd.vm.user.name' => $testuser,
   ]), "Only username");
ok(!QVD::VmaHook::Passthrough::save_credentials([
	'qvd.auth.passthrough.passwd' => $testpass,
   ]), "Only pass");
ok(!QVD::VmaHook::Passthrough::save_credentials([
	'qvd.vm.user.home' => $home,
   ]), "Only home");
ok(! -f "$ENV{HOME}/.qvd.deleteme", "No credential file");
ok(!QVD::VmaHook::Passthrough::save_credentials([
	'qvd.vm.user.name' => $testuser,
	'qvd.auth.passthrough.passwd' => $testpass,
   ]), "use and passwd no home");
ok(!QVD::VmaHook::Passthrough::save_credentials([
	'qvd.vm.user.name' => $testuser,
	'qvd.vm.user.home' => $home,
   ]), "uset and home no passwd");
ok(!QVD::VmaHook::Passthrough::save_credentials([
	'qvd.auth.passthrough.passwd' => $testpass,
	'qvd.vm.user.home' => $home,
   ]), "no user passed");
ok(QVD::VmaHook::Passthrough::save_credentials([
	'qvd.vm.user.name' => $testuser,
	'qvd.auth.passthrough.passwd' => $testpass,
	'qvd.vm.user.home' => $home,
   ]), "All parameters passed");
ok(-f "$ENV{HOME}/.qvd.deleteme", "credential file exists");
in_file_ok("$ENV{HOME}/.qvd.deleteme", 
	   "qvduser exists in file" => "qvduser=$testuser", 
	   "qvdpassword exists in file" => "qvdpassword=$testpass");

done_testing();

# Config file
sub createTestConfig {
    my $envfile = shift;
    my $fh = File::Temp->new(UNLINK => 0);
    my $filename = $fh->filename;
    print $fh <<EOF;
log.level = DEBUG
EOF
    if (defined($envfile)) {
	print $fh <<EOF;
qvd.vmahook.passthrough.envfile=$envfile
EOF
}
    close $fh;
    
    return $filename;

}

sub in_file_ok {
    my ($filename, %regex) = @_;
    open( my $fh, '<', $filename )
        or die "couldn't open $filename for reading: $!";

    my %violated;

    while (my $line = <$fh>) {
        while (my ($desc, $regex) = each %regex) {
            if ($line =~ $regex) {
                push @{$violated{$desc}||=[]}, $.;
            }
        }
    }

    if (%violated) {
        pass("$filename contains text");
    } else {
        fail("$filename contains no boilerplate text");
    }
}
