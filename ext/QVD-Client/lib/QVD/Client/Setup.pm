package QVD::Client::Setup;

use strict;
use warnings;
use 5.010;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw($WINDOWS $DARWIN $user_dir $app_dir $user_config_fn);

our ($WINDOWS, $DARWIN, $LINUX, $user_dir, $app_dir, $user_config_fn);

use File::Spec;
use Cwd;

BEGIN {
    # Calculate configuration files and main directories

    $WINDOWS = ($^O eq 'MSWin32');
    $DARWIN = ($^O eq 'darwin');
    $LINUX = ($^O eq "linux");

    # Make sure cups service is online (in El Capitan , cups is not running until used)
    if ( $DARWIN ){ system('/usr/sbin/cupsctl >/dev/null 2>&1'); }

    $user_dir = File::Spec->rel2abs($WINDOWS
                                    ? File::Spec->join($ENV{APPDATA}, 'QVD')
                                    : File::Spec->join((getpwuid $>)[7] // $ENV{HOME}, '.qvd'));
    mkdir($user_dir);

    $user_config_fn = File::Spec->join($user_dir, 'client.conf');

    no warnings;
    $QVD::Config::USE_DB = 0;
    @QVD::Config::Core::FILES = (($WINDOWS ? () : ('/etc/qvd/client.conf')),
                                  $user_config_fn);

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
		###################################################################
		# WARNING: This gets used in the slaveserver, so debug prints on
		# STDOUT will interfere with the HTTP protocol. 
		###################################################################
		
		#print STDERR "Determining application directory. Binary path is $0\n";
        my ($drive, $dir, $file) = File::Spec->splitpath(File::Spec->rel2abs($0));
		
		#print STDERR "Drive: '$drive'; dir '$dir'; file '$file'\n";
        my $bin_dir = File::Spec->catpath($drive, $dir);
		
		#print STDERR "Directory of the binary: $bin_dir\n";
        my @dirs = File::Spec->splitdir($bin_dir);
		
		# Remove the last path component.
		# splitdir leaves a final / that gets counted as a path component, so things
		# get parsed like this:
		#
		# /home/qindel/qvd-src/ext/QVD-Client/bin/qvd-gui-client.pl        # $0
		# /home/qindel/qvd-src/ext/QVD-Client/bin/      qvd-gui-client.pl  # $bin_dir and $file
		# /home /qindel /qvd-src /ext /QVD-Client /bin /
        $app_dir = File::Spec->catdir( @dirs[0..$#dirs-2] );
		
		if ( $WINDOWS && !-d "$app_dir/pixmaps" ) {
			#print STDERR "Win32, running from installed location\n";
			$app_dir = File::Spec->catdir( @dirs[0..$#dirs-1] );
		}
		#print STDERR "Final app_dir: '$app_dir'\n";
    }

    # Fix bad log levels
    set_core_cfg('log.level', 'ERROR')
        unless core_cfg('log.level') =~ /^(?:DEBUG|INFO|WARN|ERROR|FATAL|TRACE|ALL|OFF)$/;
}

use QVD::Log;

INFO "user_dir: $user_dir";
INFO "app_dir: $app_dir";

if ( $LINUX ) {
	# When run inside a QVD session without using a terminal (when launched from a desktop
	# icon, for instance), the QVD client can inherit the sockets used by nxagent.
	#
	# The result of that is that nxagent output becomes mixed with the qvdclient output,
	# which confuses VMA because the client launches nxproxy.
	#
	# To ensure this doesn't happen, we turn off console output when there isn't a console.
	if ( readlink("/proc/self/fd/0") !~ /^\/dev/ ) {
		INFO "stdin is not a terminal, closing";
		open(STDIN, "<", "/dev/null");
	}
	if ( readlink("/proc/self/fd/1") !~ /^\/dev/ ) {
		INFO "stdout is not a terminal, closing";
		open(STDOUT, ">", "/dev/null");
	}
	if ( readlink("/proc/self/fd/2") !~ /^\/dev/ ) {
		INFO "stderr is not a terminal, closing";
		open(STDERR, ">", "/dev/null");
	}
}

1;
