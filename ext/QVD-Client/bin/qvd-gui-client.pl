#!/usr/bin/perl

package QVD::Client::App;

use strict;
use warnings;
use 5.010;

use Cwd;
use File::Spec;
use Proc::Background;

our ($WINDOWS, $DARWIN, $user_dir, $app_dir, $user_config_filename, $user_certs_dir, $pixmaps_dir);

my $prev_bad_log_level;

BEGIN {
    $WINDOWS = ($^O eq 'MSWin32');
    $DARWIN = ($^O eq 'darwin');

    $user_dir = File::Spec->rel2abs($WINDOWS
                                    ? File::Spec->join($ENV{APPDATA}, 'QVD')
                                    : File::Spec->join((getpwuid $>)[7] // $ENV{HOME}, '.qvd'));
    mkdir($user_dir);

    # FIXME NX_CLIENT is used for showing the user information on things
    # like broken connection, perhaps we should show them to the user
    # instead of ignoring them? 
    $ENV{NX_CLIENT} = $WINDOWS ? 'cmd.exe /c :' : 'false';

    $user_config_filename = $ARGV[0] // File::Spec->join($user_dir, 'client.conf');

    no warnings;
    $QVD::Config::USE_DB = 0;
    @QVD::Config::Core::FILES = ( ($WINDOWS ? () : ('/etc/qvd/client.conf')),
                                  $user_config_filename );
}

use QVD::Config::Core qw(set_core_cfg core_cfg);

# change defaults for log configuration before loading it
BEGIN {
    for (@ARGV) {
        if (my ($k, $v) = /^\s*([\w\.]+)\s*[:=\s]\s*(.*?)\s*$/) {
            set_core_cfg($k, $v);
        }
    }

    set_core_cfg('client.log.filename', File::Spec->join($user_dir, 'qvd-client.log'))
        unless defined core_cfg('client.log.filename', 0);
    $QVD::Log::DAEMON_NAME = 'client';

    $app_dir = core_cfg('path.client.installation', 0);
    if (!$app_dir) {
        my $bin_dir = File::Spec->join((File::Spec->splitpath(File::Spec->rel2abs($0)))[0, 1]);
        my @dirs = File::Spec->splitdir($bin_dir);
        $app_dir = File::Spec->catdir( @dirs[0..$#dirs-1] ); 
    }

	
	if ( core_cfg('log.level') !~ /^(DEBUG|INFO|WARN|ERROR|FATAL|TRACE|ALL|OFF)$/ ) {
		$prev_bad_log_level = core_cfg('log.level');

		warn "Bad log.level '$prev_bad_log_level', changing to DEBUG";
		set_core_cfg('log.level', 'DEBUG');
	}
}

use QVD::Log;

if ( $prev_bad_log_level ) {
	WARN "Bad log.level in config file: '$prev_bad_log_level'";
	WARN "Changed to " . core_cfg('log.level');
}

INFO "user_dir: $user_dir";
INFO "app_dir: $app_dir";

$user_certs_dir = File::Spec->rel2abs(core_cfg('path.ssl.ca.personal'), $user_dir);
mkdir $user_certs_dir;

INFO "user_certs_dir: $user_certs_dir";

$pixmaps_dir = File::Spec->rel2abs(core_cfg('path.client.pixmaps'), $app_dir);
$pixmaps_dir = File::Spec->rel2abs(core_cfg('path.client.pixmaps.alt'), $app_dir) unless -d $pixmaps_dir;
INFO "pixmaps_dir: $pixmaps_dir";

$SIG{PIPE} = 'IGNORE';
$SIG{__WARN__} = sub { WARN "@_"; };
$SIG{__DIE__} = sub { ERROR "@_"; die (@_) };

use QVD::Client::Frame;
use parent 'Wx::App';

sub OnInit {
    my $self = shift;
    DEBUG("OnInit called");

    if ($WINDOWS or $DARWIN) {
        unless( $ENV{DISPLAY} || $ENV{QVD_PP_BUILD} ) {
            my @cmd;
            my $proc;

            if ($WINDOWS) {
			    DEBUG "Running on Windows, detecting X server";
				
                $ENV{DISPLAY} = '127.0.0.1:0';
				my $xming_bin = File::Spec->rel2abs(core_cfg('command.windows.xming'), $app_dir);
				my $vcxsrv_bin = File::Spec->rel2abs(core_cfg('command.windows.vcxsrv'), $app_dir);
				
				if ( -f $xming_bin ) {
				    DEBUG "Xming found at $xming_bin";
					
					@cmd = ( $xming_bin,
							'-multiwindow', '-notrayicon', '-nowinkill', '-clipboard', '+bs', '-wm',
							'-logfile' => File::Spec->join($user_dir, "xserver.log") );
				} elsif ( -f $vcxsrv_bin ) {
				    DEBUG "VcxSrv found at $vcxsrv_bin";
					
				    @cmd = ( $vcxsrv_bin,
							'-multiwindow', '-notrayicon', '-nowinkill', '-clipboard', '+bs', '-wm',
							'-listen', 'tcp', '-logfile' => File::Spec->join($user_dir, "xserver.log") );
				} else {
				    die "X server not found! Tried '$xming_bin' and '$vcxsrv_bin'";
				}
            }
            else { # DARWIN!
                $ENV{DISPLAY} = ':0';
                my $x11_cmd = core_cfg('command.darwin.x11');
                @cmd = qq(open -a $x11_cmd --args true);
            }

            DEBUG("DISPLAY set to $ENV{DISPLAY}");
            DEBUG("Starting X11 server: " . join(' ', @cmd));

            if ( ($proc = Proc::Background->new(@cmd))  ) {
                DEBUG("X server started");
                if ( $DARWIN ) {
                    DEBUG("Waiting to see if X starts");
                    my $timeout=5;
                    my $all_ok;
                    while($timeout-- > 0) {
                        if (!$proc->alive) {
                            if (!defined $proc->wait || ($proc->wait << 8) > 0 ) {
                                _osx_error("Failed to start X server. Please install XQuartz.");
                                exit(1);
                            } else {
                                $all_ok = 1;
                                last;
                            }
                        }
                        sleep(1);
                    }

                    if (!$all_ok) {
                        WARN("X server command still seems to be running. Can't exactly determine whether the server started");
                    }
                }
            } else {
                ERROR("X server failed to start");
                if ($DARWIN) {
                     _osx_error("Failed to start X server. Please install XQuartz.");
                }
            }
        } else {
			if (  $ENV{QVD_PP_BUILD} ) {
				DEBUG("Running under a PP build, not starting X");
			} else {
				DEBUG("X11 server already running on display $ENV{DISPLAY}, using that.");
			}
        }
    }

    DEBUG("Showing frame");
    my $frame = QVD::Client::Frame->new();
    $self->SetTopWindow($frame);
    $frame->Show();
    if ($self->should_autoconnect()) {
	INFO("Launching autoconnect");
	$frame->OnClickConnect;
    }

    return 1;
};

sub _osx_error {
    my ($message) = @_;
    ERROR("$message");

    open(OSA, "|/usr/bin/osascript") or die "Can't call osascript: $!";
    print OSA <<SCRIPT;
        tell application "System Events"
            activate
            display dialog "$message" buttons {"Ok"} with title "QVD Client" with icon 0
        end tell
SCRIPT

    close(OSA);
}

sub should_autoconnect {
    core_cfg('client.auto_connect', 0);
}
package main;

use QVD::Log;

Wx::InitAllImageHandlers();
my $app = QVD::Client::App->new();

DEBUG("Starting main loop");
$app->MainLoop();
INFO("Exiting");

__END__

=head1 NAME

qvd-client - The QVD GUI Client

=head1 DESCRIPTION

B<qvd-client> is a graphic client that lets a user to connect to a virtual machine and take control of the remote desktop.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
