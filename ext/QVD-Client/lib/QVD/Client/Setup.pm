use strict;
use warnings;
use 5.010;

our ($WINDOWS, $DARWIN, $user_dir, $app_dir);

package QVD::Client::Setup;

use File::Spec;
use Cwd;

BEGIN {
    # Calculate configuration files and main directories

    $WINDOWS = ($^O eq 'MSWin32');
    $DARWIN = ($^O eq 'darwin');

    $user_dir = File::Spec->rel2abs($WINDOWS
                                    ? File::Spec->join($ENV{APPDATA}, 'QVD')
                                    : File::Spec->join((getpwuid $>)[7] // $ENV{HOME}, '.qvd'));
    mkdir($user_dir);

    my $cfg_fn = $ARGV[0] || File::Spec->join($user_dir, 'client.conf');

    no warnings;
    $QVD::Config::USE_DB = 0;
    @QVD::Config::Core::FILES = ( ($WINDOWS ? () : ('/etc/qvd/client.conf')),
                                  $user_config_filename );
}

# we can load the configuration now:
use QVD::Config::Core qw(set_core_cfg core_cfg);

# change defaults for log configuration before loading it
BEGIN {
    set_core_cfg('client.log.filename', File::Spec->join($user_dir, 'qvd-client.log'))
        unless defined core_cfg('client.log.filename', 0);
    $QVD::Log::DAEMON_NAME = 'client';

    $app_dir = core_cfg('path.client.installation', 0);
    unless ($app_dir) {
        my ($drive, $dir, $file) = File::Spec->splitpath(File::Spec->rel2abs($0));
        my $bin_dir = File::Spec->catpath($drive, $dir);
        if ($WINDOWS) {
            $app_dir = $bin_dir;
        }
        else {
            my @dirs = File::Spec->splitdir($bin_dir);
            $app_dir = File::Spec->catdir( @dirs[0..$#dirs-1] );
        }
    }

    # Fix bad log levels
    set_core_cfg('log.level', 'ERROR')
        unless core_cfg('log.level') =~ /^(?:DEBUG|INFO|WARN|ERROR|FATAL|TRACE|ALL|OFF)$/;
}

use QVD::Log;

INFO "user_dir: $user_dir";
INFO "app_dir: $app_dir";

1;
