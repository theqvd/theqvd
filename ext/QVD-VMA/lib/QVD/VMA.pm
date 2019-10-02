package QVD::VMA;

our $VERSION = '0.02';

use warnings;
use strict;
use 5.010;

use QVD::HTTPD;
use base qw(QVD::HTTPD::Fork);

sub post_configure_hook {
    my $self = shift;
    my $impl = QVD::VMA::Impl->new();
    $impl->set_http_request_processors($self, '/vma/*');
    QVD::VMA::Impl::_delete_nxagent_state_and_pid_and_call_hook();
}

sub post_child_cleanup_hook {
    QVD::VMA::Impl::_stop_session();
    QVD::VMA::Impl::_delete_nxagent_state_and_pid_and_call_hook();
}

package QVD::VMA::Impl;

use POSIX;
use Fcntl qw(:flock);
use feature qw(switch say);
use Config::Properties;

use QVD::Config;
use QVD::Log;
use QVD::HTTP::Headers qw(header_eq_check);
use QVD::HTTP::StatusCodes ();
use Time::HiRes qw(sleep);

$SIG{__WARN__} = sub { WARN "WARN: @_"; };
$SIG{__DIE__} = sub { ERROR "DIE: @_"; };


use parent 'QVD::SimpleRPC::Server';

my $log_path        = cfg('path.log');
my $run_path        = cfg('path.run');
my $nxagent         = cfg('command.nxagent');
my $nxdiag          = cfg('command.nxdiag');
my $x_session       = cfg('command.x-session');
my $xinit           = cfg('command.xinit');
my $x11vnc          = cfg('command.x11vnc');
my $enable_audio    = cfg('vma.audio.enable');
my $enable_slave    = cfg('vma.slave.enable');
my $command_slave   = cfg('vma.slave.command');
my $enable_printing = cfg('vma.printing.enable');
my $printing_conf   = cfg('internal.vma.printing.config');
my $slave_conf      = cfg('internal.vma.slave.config');
my $nxagent_conf    = cfg('internal.vma.nxagent.config');
my $pulse_conf      = cfg('internal.vma.pulseaudio.config');
my $tolerance_checks     = cfg('internal.vma.nxagent.tolerancechecks');

my $nxagent_args_extra   = cfg('command.nxagent.args.extra');
my $x_session_args_extra = cfg('command.x-session.args.extra');
# unquote arguments using the shell via glob!!!
my @nxagent_args_extra   = ($nxagent_args_extra   =~ /\S/ ? < $nxagent_args_extra   > : ());
my @x_session_args_extra = ($x_session_args_extra =~ /\S/ ? < $x_session_args_extra > : ());

my $groupadd        = cfg('command.groupadd');
my $useradd         = cfg('command.useradd');
my $userdel         = cfg('command.userdel');
my $groupdel        = cfg('command.groupdel');
my $slaveclient     = cfg('command.slaveclient');

my $mount           = cfg('command.mount');
my $umount          = cfg('command.umount');
my $qvd_client      = cfg('command.qvd-client');

my $default_user_name   = cfg('vma.user.default.name');
my $default_user_groups = cfg('vma.user.default.groups');

my $home_fs    = cfg('vma.user.home.fs');
my $home_path  = cfg('vma.user.home.path');
my $home_drive = cfg('vma.user.home.drive');

my $user_shell = cfg('vma.user.shell');

my $home_partition = $home_drive . '1';

my $shares_path = cfg('vma.user.shares.path');


my %on_action =       ( pre_connect    => cfg('vma.on_action.pre-connect'),
                        connect        => cfg('vma.on_action.connect'),
                        stop           => cfg('vma.on_action.stop'),
                        suspend        => cfg('vma.on_action.suspend'),
                        poweroff       => cfg('vma.on_action.poweroff'),
                        expire         => cfg('vma.on_action.expire') );

my %on_state =        ( connected      => cfg('vma.on_state.connected'),
                        suspended      => cfg('vma.on_state.suspended'),
                        stopped        => cfg('vma.on_state.disconnected') );

my %on_provisioning = ( mount_home     => cfg('vma.on_provisioning.mount_home'),
                        add_user       => cfg('vma.on_provisioning.add_user'),
                        after_add_user => cfg('vma.on_provisioning.after_add_user') );

my %on_printing =     ( connected      => cfg('internal.vma.on_printing.connected'),
                        suspended      => cfg('internal.vma.on_printing.suspended'),
                        stopped        => cfg('internal.vma.on_printing.stopped'));

my $display       = cfg('internal.nxagent.display');
my $printing_port = $display + 2000;
my $slave_port    = $display + 11000;

my %timeout = ( initiating => cfg('internal.nxagent.timeout.initiating'),
                listening  => cfg('internal.nxagent.timeout.listening'),
                suspending => cfg('internal.nxagent.timeout.suspending'),
                stopping   => cfg('internal.nxagent.timeout.stopping') );

our $nxagent_state_fn = "$run_path/nxagent.state";
our $nxagent_pid_fn   = "$run_path/nxagent.pid";

my %nx2x = ( initiating   => 'starting',
             provisioning => 'provisioning',
             starting     => 'listening',
             resuming     => 'listening',
             started      => 'connected',
             resumed      => 'connected',
             suspending   => 'suspending',
             suspended    => 'suspended',
             terminating  => 'stopping',
             aborting     => 'stopping',
             aborted      => 'stopped',
             terminated   => 'stopped',
             stopped      => 'stopped',
             ''           => 'stopped');

my %running   = map { $_ => 1 } qw(listening connected suspending suspended);
my %connected = map { $_ => 1 } qw(listening connected);



sub _open_log {
    my $name = shift;
    my $log_fn = "$log_path/qvd-$name.log";
    open my $log, '>>', $log_fn or die "unable to open $name log file $log_fn\n";
    my $ofh = select $log;
    $| = 1;
    select $ofh;
    print $log "=== Opened log file at " . scalar localtime . " ====\n";
    DEBUG "Opened $name log at $log_path/qvd-$name.log";
    return $log;
}

sub _call_hook {
    my $name = shift;
    my $file = shift;
    my $detach = shift;

    if (length $file) {
        DEBUG "calling hook '$file' for $name" ;
        my $pid = fork;
        if (!$pid) {
            defined $pid or die "fork failed: $!\n";
            eval {
                my $log = _open_log('hooks');
                my $logfd = fileno $log;
                POSIX::dup2($logfd, 1);
                POSIX::dup2($logfd, 2);
                open STDIN, '<', '/dev/null';
                if ($detach) {
                    local $SIG{CHLD};
                    my $pid2 = fork;
                    if (!$pid2) {
                        defined $pid2 and exec $file, @_;
                        DEBUG "execution of hook $file for $name failed: $!";
                        # defined $pid2 and POSIX::_exit(0); # grandchild just fallbacks to...
                    }
                    POSIX::_exit(0);
                }
                else {
                    do {exec $file, @_ };
                    die "exec failed: $!\n";
                }
            };
            DEBUG "execution of hook $file for $name failed: $@" if $@;
            POSIX::_exit(1);
        }
        while (1) {
            # FIXME: implement timeout for hooks
            my $kid = waitpid($pid, 0);
            if ($kid < 0) {
                die "hook process $pid for $name disappeared";
            }
            if ($kid == $pid) {
                $? and die "hook $file for $name failed, rc: ". ($? >> 8);
                return 1;
            }
            DEBUG "waitpid returned $kid unexpectedly";
            sleep 1;
        }
    }
    return undef;
}

sub _call_provisioning_hook {
    my $action = shift;
    _call_hook("on provisioning $action", $on_provisioning{$action}, 0,
           @_, 'qvd.hook.on_provisioning', $action);
}

sub _call_action_hook {
    my $action = shift;
    my $state = _state();
    _call_hook("action $action on state $state", $on_action{$action}, 0,
           @_, 'qvd.vm.session.state', $state, 'qvd.hook.on_action', $action);
}

sub _call_state_hook {
    my $state = _state();
    local $@;
    # state hooks are called detached and may not fail:
    eval { _call_hook("state $state", $on_state{$state}, 1, @_, 'qvd.hook.on_state', $state) };
    ERROR $@ if $@;
}

sub _call_printing_hook {
    my $state = _state();
    local $@;
    eval {
        my $props = Config::Properties->new;
        open my $fh, '<', $printing_conf or die "Unable to open printing configuration file '$printing_conf': $!";
        $props->load($fh);
        close $fh;
        _call_hook("printing $state", $on_printing{$state}, 1, $props->properties,
               'qvd.hook.on_printing', $state);
    };
    ERROR $@ if $@;
}

sub _become_user {
    # Formerly copied from cftools http://sourceforge.net/projects/cftools/
    # Copyright 2003-2005 Martin Andrews
    my $user = shift;
    my ($login, $pass, $uid, $gid, $quota, $comment, $gcos, $home, $shell) =
    ($user =~ /^[0-9]+$/ ? getpwuid($user) : getpwnam($user))
        or die "Unknown user $user";

    my @groups = ($gid, $gid);
    setgrent();
    my $quser = quotemeta $user;
    my $re = qr/\b$quser\b/;
    while( my (undef, undef, $gid2, $members) = getgrent() ) {
        push @groups, $gid2 if $members =~ $re;
    }

    ($(, $)) = ($gid, join(' ', @groups));
    ($<, $>) = ($uid, $uid);
    $ENV{'HOME'} = $home;
    $ENV{'LOGNAME'} = $user;
    $ENV{'USER'} = $user;
    $ENV{'MAIL'} = '/var/mail/'.$user;
    chdir $home;
}

sub _set_environment {

    # Environment doesn't get set properly when logging in through QVD,
    # so we set it manually.

    foreach my $file (qw( /etc/locale.conf /etc/default/locale /etc/environment $ENV{HOME}/.qvd_environment )) {
        DEBUG "Trying to load environment from $file";
        if ( open(my $fh, '<', $file) ) {
            DEBUG "$file opened, processing";

            while(my $line = <$fh>) {
                chomp $line;
                $line =~ s/[^\\]#.*$//; # Remove comments
                my ($k, $v) = split(/=/, $line, 2);
                if ( defined $k && defined $v ) {
                    $ENV{$k} = $v;
                }
            }
        }
    }

    if (!$ENV{LANG}) {
        # $LANG should be set to an UTF-8 code. Lack of this results in ?'s in
        # filenames that use non-latin1 characters in the terminal.
        $ENV{LANG} = cfg('vma.default.lang');
    }
}

sub _read_line {
    my $fn = shift;
    DEBUG "_read_line($fn)";
    open my $fh, '<', $fn or return '';
    flock $fh, LOCK_SH;
    my $line = <$fh>;
    flock $fh, LOCK_UN;
    close $fh;
    chomp $line;
    DEBUG "  => $line";
    $line;
}

sub _write_line {
    my ($fn, $line) = @_;
    DEBUG "_write_line($fn, $line)";
    sysopen my $fh, $fn, O_CREAT|O_RDWR, 644
        or die "sysopen $fn failed";
    flock $fh, LOCK_EX;
    seek($fh, 0, 0);
    truncate $fh, 0;
    say $fh $line;
    flock $fh, LOCK_UN;
    close $fh;
}

sub _save_nxagent_state {
    _write_line($nxagent_state_fn, join(':', shift, time) );
}

sub _save_nxagent_state_and_call_hook {
    DEBUG "_save_nxagent_state_and_call_hook: " . join(', ', @_);

    _save_nxagent_state(@_);
    _call_printing_hook if $enable_printing;
    _call_state_hook;
}
sub _save_nxagent_pid   { _write_line($nxagent_pid_fn, shift) }

sub _delete_nxagent_state_and_pid_and_call_hook {
    DEBUG "deleting pid and state files";
    unlink $nxagent_pid_fn;
    unlink $nxagent_state_fn;
    _call_printing_hook if $enable_printing;
    _call_state_hook;
}

sub _timestamp {
    my @t = gmtime; $t[5] += 1900; $t[4] += 1;
    sprintf("%04d%02d%02d%02d%02d%02d", @t[5, 4, 3, 2, 1, 0]);
}

sub _provisionate_user {
    my %props = @_;
    my $user = $props{'qvd.vm.user.name'};
    my $uid = $props{'qvd.vm.user.uid'};
    my $gid = $props{'qvd.vm.user.gid'};
    my $group = $props{'qvd.vm.user.group'} // $user;
    my $user_home = $props{'qvd.vm.user.home'};
    my $groups = $props{'qvd.vm.user.groups'};

    $groups =~ s/\s//g;

    unless (-d $user_home) {
        DEBUG "user home does not exist yet";
        _save_nxagent_state('provisioning');
        unless (_call_provisioning_hook(mount_home => @_)) {
            DEBUG "no custom provisioning for mount_home";
            if (length $home_drive and -e $home_drive) {
                my $root_dev = (stat '/')[0];
                my $home_dev = (stat $home_path)[0];
                if ($root_dev == $home_dev) {
                    DEBUG "mounting $home_partition as $home_path";
                    unless (-e $home_partition) {
                        DEBUG "partitioning $home_drive";
                        system ("echo , | sfdisk $home_drive")
                            and die "Unable to create partition table on user storage";
                        system ("mkfs.$home_fs" =>  $home_partition)
                            and die "Unable to create file system on user storage";
                    }
                    system $mount => $home_partition, $home_path
                        and die 'Unable to mount user storage';
                }
            }
            else {
                DEBUG "using root drive also for homes";
            }
        }
    }

    unless (getpwnam($user)) {
        _save_nxagent_state('provisioning');
        if (_call_provisioning_hook(add_user => @_)) {
            _call_provisioning_hook(after_add_user => @_);
        }
        else {
            eval {
                my @group_args;
                push @group_args, (-g => $gid) if defined $gid;
                push @group_args, $group;
                DEBUG "executing $groupadd => @group_args";
                unless (system($groupadd => @group_args) == 0) {
                    WARN "provisioning of group '$group' failed\n";
                }

                my @user_args = ( '-m',              ## create home
                                  '-d', $user_home,  ## home dir
                                  '-g', $group,      ## main group
                                  '-s', $user_shell, ## shell
                                );
                push @user_args, -G => $groups if length $groups;
                push @user_args, -u => $uid if $uid;
                push @user_args, $user;

                DEBUG "executing $useradd => @user_args";
                system $useradd => @user_args and die "provisioning of user '$user' failed\n";

                _call_provisioning_hook(after_add_user => @_);
            };
            if ($@) {
                # clean up, do not left the system in an inconsistent state
                DEBUG "deleting user $user";
                system $userdel => '-rf', $user and WARN "'$userdel -rf $user' failed";
                DEBUG "deleting group $user";
                system $groupdel => $user and WARN "'$groupdel $user' failed";
                die $@;
            }
        }
    }
}

my %props2nx = ( 'qvd.client.keyboard'   => 'keyboard',
         'qvd.client.os'         => 'client',
         'qvd.client.link'       => 'link',
         'qvd.client.geometry'   => 'geometry',
         'qvd.client.fullscreen' => 'fullscreen' );

sub _fill_props {
    my (%props) = @_;
    my $user = $props{'qvd.vm.user.name'} //= $default_user_name;
    $props{'qvd.vm.user.groups'} //= $default_user_groups;
    $props{'qvd.vm.user.home'} //= "$home_path/$user";
    return %props;
}

sub _umount_remote_shares {
    my $home = shift // do {
        ERROR "Can't umount remote shares because home is not defined";
        return;
    };
    my $root = $shares_path;
    $root =~ s{^\~/}{$home/} or do {
        ERROR "vma.user.shares.root ($shares_path) does not point inside the user home";
        return;
    };
    opendir my($dh), $root or do {
        DEBUG "Unable to open shares directory $root: $!";
        return;
    };
    DEBUG "umounting shares in $root...";
    while (defined(my $fn = readdir $dh)) {
        next if $fn eq '.' or $fn eq '..';
        my $path = File::Spec->join($root, $fn);
        DEBUG "umounting $path";
        system $umount => -l => $path
            and DEBUG "$umount failed: $?";
        unlink $path
            or WARN "Unable to remove directory $path: $!";
    }
    close $dh;
}

sub _fork_monitor {
    my %props = _fill_props(@_);
    my $log = _open_log('nxagent');
    my $logfd = fileno $log;
    select $log;
    $| = 1;

    say _timestamp . ": Starting nxagent";

    _save_nxagent_state_and_call_hook 'initiating';

    $SIG{CHLD} = 'IGNORE';
    my $pid = fork;
    my $pulse_proc;
    
    my $enable_audio_compression = $props{'qvd.client.audio.compression.enable'} // 0;

    if (!$pid) {
        defined $pid or die "Unable to start monitor, fork failed: $!\n";
        undef $SIG{CHLD};
        eval {
            mkdir $run_path, 755;
            -d $run_path or die "Directory $run_path does not exist\n";

            # detach from stdio and from process group so it is not killed by Net::Server
            open STDIN,  '<', '/dev/null';
            POSIX::dup2($logfd, 1);
            POSIX::dup2($logfd, 2);
            # open STDOUT, '>', '/tmp/xinit-out'; #/dev/null';
            # open STDERR, '>', '/tmp/xinit-err'; #/dev/null';
            setpgrp(0, 0);

            _save_nxagent_state_and_call_hook 'initiating';

            my $pid = open(my $out, '-|');
            if (!$pid) {
                defined $pid or die ERROR "unable to start X server, fork failed: $!\n";
                eval {
                    POSIX::dup2(1, 2); # equivalent to shell 2>&1
                    _provisionate_user(%props);
                    _call_action_hook(connect => %props);
                    _make_nxagent_config(%props);

                    $ENV{NX_CLIENT} = $nxdiag;
                    $ENV{NX_SLAVE_CMD} = $command_slave if $command_slave;
                    # Keep QVD_SLAVE_CMD for retrocompatibility
                    $ENV{QVD_SLAVE_CMD} = $command_slave if $command_slave;

                    # FIXME: Include VM name in -name argument.
                    # FIXME: Reimplement xinit in Perl in order to allow capturing nxagent ouput alone.
                    my @cmd = ($xinit => $x_session, @x_session_args_extra,
                           '--',
                           $nxagent, ":$display",
                           '-ac', '-name', 'QVD',
                           # '-norender', '-defer', '0', # GTK/Cairo require Xrender to work properly
                           '-display', "nx/nx,options=$nxagent_conf:$display",
                           @nxagent_args_extra);
                    say "running @cmd";
                    _become_user($props{'qvd.vm.user.name'});
                    _set_environment();
                    exec @cmd;
                };
                say "Unable to start X server: " .($@ || $!);
                POSIX::_exit(1);
            }
            
            while(defined (my $line = <$out>)) {
                given ($line) {
                    when (/Info: Agent running with pid '(\d+)'/) {
                        DEBUG "Agent running";
                        _save_nxagent_pid $1;
                    }
                    when (/Session: (\w+) session at/) {
                        my $state = lc $1;
                        if ($state eq 'suspended') {
                            _umount_remote_shares($props{'qvd.vm.user.home'});
                            _suspend_pulseaudio($pulse_proc, $props{'qvd.vm.user.name'});
                        }
                        DEBUG "Session $state, calling hooks";
                        _save_nxagent_state_and_call_hook $state;
                    }
                    when (/Session: Session (\w+) at/) {
                        my $state = lc $1;
                        if ($state eq 'suspended') {
                            _umount_remote_shares($props{'qvd.vm.user.home'});
                            _suspend_pulseaudio($pulse_proc, $props{'qvd.vm.user.name'});
                        }
                        DEBUG "Session $state, calling hooks";
                        _save_nxagent_state_and_call_hook $state;
    
                        if ( $state =~ /term|abort|suspend/i ) {
                            _stop_process($pulse_proc, "PulseAudio");
                            undef $pulse_proc;
                        }
                    }
                    when (/Listening to slave connections on port '(?:tcp:\w+:)?(\d+)'/) {
                        DEBUG "Slave channel opened";

                        if ( $props{'qvd.client.usb.enabled' } ) {
                            DEBUG "USB forwarding is enabled, implementation is " . $props{'qvd.client.usb.implementation'};

                            if ( $props{'qvd.client.usb.implementation'} =~ /USBIP/ ) {
                                _start_usbip($1);
                            } else {
                                _start_usb($1);
                            }
                        }
                    }
                    when (/Listening to multimedia connections on port '(?:tcp:\w+:)?(\d+)'/ ) {
                        my $pa_port = $1;
                        DEBUG "Multimedia channel opened on port $pa_port";

                        if ( $enable_audio ) {
                            if ( $pulse_proc ) {
                                my @sink_args = ("sink_name=QVD_Audio", "server=tcp:127.0.0.1:$pa_port", "sink=\@DEFAULT_SINK\@");

                                if ( $enable_audio_compression ) {
                                    DEBUG "Audio compression enabled, using compression for the audio sink";
                                    push @sink_args, "compression=opus";
                                }

                                DEBUG "PulseAudio already running under pid $pulse_proc, reestablishing channel";
                                _bgrun({user => $props{'qvd.vm.user.name'}}, "pacmd", "load-module", "module-tunnel-sink-new", @sink_args);
                            } else {
                                DEBUG "PulseAudio not running, starting " . ($enable_audio_compression ? "with compression" : "");
                                $pulse_proc = _start_pulseaudio($pa_port, $props{'qvd.vm.user.name'}, $enable_audio_compression);
                            }
                        }
                    }
                }
                print $line;

                if ( $pulse_proc ) {
                    my $ret = waitpid($pulse_proc, WNOHANG );

                    if ( $ret ) {
                        undef $pulse_proc;
                        ERROR "PulseAudio terminated with code " . ($? >> 8);
                    }
                }
            }
            print "out closed";

            if ($pulse_proc) {
                INFO "Stopping PulseAudio with pid $pulse_proc";
                kill 'TERM', $pulse_proc;
                my $tries = 10;
                my $killed;
                while($tries > 0 && (!$killed || $killed <= 0)) {
                    $killed = waitpid($pulse_proc, WNOHANG);
                    break if $killed;
                    $tries--;
                }

                if (!$killed) {
                    WARN "PulseAudio did not exit, terminating forcefully";
                    kill 'KILL', $pulse_proc;
                    waitpid($pulse_proc, 0);
               }
            }

        };
        if ( $@ ) {
            ERROR "Error in VMA monitor: $@";
        }

        _delete_nxagent_state_and_pid_and_call_hook;
    }
}

sub _state {
    my $state_line = _read_line $nxagent_state_fn;
    my ($nxstate, $timestamp) = $state_line =~ /^(.*?)(?::(.*))?$/;

    return 'stopped' if $nxstate eq ''; # shortcut!

    my $state = $nx2x{$nxstate};
    unless (defined $state) {
        ERROR "unhandled nxstate '$state_line'";
        $state = 'stopped';
    }
    my $timeout = $timeout{$state};
    my $pid = _read_line $nxagent_pid_fn;

    { no warnings; DEBUG ("_state: $state, nxstate: $nxstate, ts: $timestamp, timeout: $timeout") };

    if ($timeout and $timestamp) {
        if (time > $timestamp + $timeout) {
            DEBUG "timeout!";
            $pid and kill TERM => $pid;
            return 'stopping';
        }
    }

    if ($running{$state}) {
        unless ($pid and kill 0, $pid) {
            DEBUG "nxagent disappeared, pid $pid";
            $state = 'stopped';
        }
    }

    _delete_nxagent_state_and_pid_and_call_hook if $state eq 'stopped';

    return wantarray ? ($state, $pid) : $state;
}

sub _suspend_session {
    my ($state, $pid) = _state;
    if ($pid and $connected{$state}) {
        _call_action_hook('suspend', @_);
        kill HUP => $pid;
        return 'starting';
    }
    $state;
}

sub _stop_session {
    my ($state, $pid) = _state;
    if ($pid) {
        _call_action_hook('stop', @_);
        kill TERM => $pid;
        return 'stopping'
    }
    $state;
}

sub _save_slave_config {
    my %args = @_;
    my $tmp = "$slave_conf.tmp";
    open my $fh, '>', $tmp or die "Unable to save printing configuration to $tmp";
    print $fh $args{'qvd.slave.key'};
    close $fh or die "Unable to write printing configuration to $tmp";
    rename $tmp, $slave_conf or die "Unable to write slave key to $slave_conf";
}

sub _save_printing_config {
    my %args = @_;
    my $props = Config::Properties->new;
    $props->setProperty('qvd.printing.enabled' => ($enable_printing && $args{'qvd.client.printing.enabled'}) // 0);
    $props->setProperty('qvd.printing.port' => $printing_port);
    $props->setProperty('qvd.slave.port' => $slave_port);

    for my $key (qw(qvd.client.os qvd.client.printing.flavor)) {
        if (defined (my $v = $args{$key})) {
            $props->setProperty($key, $v);
        }
    }

    my $tmp = "$printing_conf.tmp";
    open my $fh, '>', $tmp or die "Unable to save printing configuration to $tmp";
    $props->save($fh);
    close $fh or die "Unable to write printing configuration to $tmp";
    rename $tmp, $printing_conf or die "Unable to write printing configuration to $printing_conf";
}

sub _make_nxagent_config {
    my %props = @_;
    my @nx_args;
    for my $key (keys %props2nx) {
        my $val = $props{$key} // cfg("vma.default.$key", 0);
        if (defined $val and length $val) {
            $val =~ m{^[\w/\-\+]+$}
                or die "invalid characters in parameter $key";
            push @nx_args, "$props2nx{$key}=$val";
        }
    }

    push @nx_args, 'media=1' if $enable_audio;
    push @nx_args, 'slave=1' if $enable_slave;
    push @nx_args, "tolerancechecks=$tolerance_checks" if $tolerance_checks;
    push @nx_args, $props{'qvd.client.nxagent.extra_args'} if ($props{'qvd.client.nxagent.extra_args'});

    if ($enable_printing && $props{'qvd.client.printing.enabled'}) {
        my $channel = $props{'qvd.client.os'} eq 'windows' ? 'smb' : 'cups';
        push @nx_args, "$channel=$printing_port" ;
    }

    my $tmp = "$nxagent_conf.tmp";
    open my $fh, '>', $tmp or die "Unable to save nxagent configuration to $tmp";
    print $fh join(',', 'nx/nx', @nx_args), ":$display\n";
    close $fh or die "Unable to write nxagent configuration to $tmp";
    rename $tmp, $nxagent_conf or die "Unable to write nxagent configuration to $nxagent_conf";
}

sub _start_session {
    my ($state, $pid) = _state;
    my (%props) = _fill_props @_;
    DEBUG "starting session in state $state, pid $pid";

    if ( cfg('vma.apps.desktop_icons.enable') ) {
        _start_desktop_app_icons( $props{'auth_token'}, $props{'host_address'}, $props{'qvd.vm.user.name'} );
    }

    given ($state) {
        when ('suspended') {
            _call_action_hook(pre_connect => %props);
            DEBUG "awaking nxagent";
            _save_slave_config(%props);
            _save_printing_config(%props);
            _save_nxagent_state_and_call_hook 'initiating';
            _make_nxagent_config(%props);
            kill HUP => $pid;
            _call_action_hook(connect => %props);
        }
        when ('connected') {
            DEBUG "suspend and fail";
            kill HUP => $pid;
            die "Can't connect to X session in state connected, suspending it, retry later\n";
        }
        when ('stopped') {
            _call_action_hook(pre_connect => %props);
            _save_slave_config(%props);
            _save_printing_config(%props);
            DEBUG "Forking monitor";
            _fork_monitor(%props);
        }
        default {
            die "Unable to start/resume X session in state $_, try again in a few minutes\n";
        }
    }
    'starting';
}

sub _poweroff {
    _call_action_hook('poweroff', @_);
    system(init => 0);
}

sub _expire {
    _call_action_hook('expire', @_);
}



sub _vnc_connect {
    my ($httpd, $headers) = @_;

    unless (header_eq_check($headers, Connection => 'Upgrade') and
            header_eq_check($headers, Upgrade => 'VNC')) {
        INFO 'Upgrade HTTP header required';
        $httpd->throw_http_error(QVD::HTTP::StatusCodes::HTTP_UPGRADE_REQUIRED);
    };

    $httpd->send_http_response(QVD::HTTP::StatusCodes::HTTP_PROCESSING,
                               "X-QVD-VMA-Info: Starting VNC service");

    my ($state, $pid) = _state;

    $httpd->throw_http_error(QVD::HTTP::StatusCodes::HTTP_SERVICE_UNAVAILABLE, "Unable to start VNC service while session is in state $state\n")
        unless $state =~ /^(?:connected|suspended)$/;

    $httpd->throw_http_error(QVD::HTTP::StatusCodes::HTTP_SERVICE_UNAVAILABLE, "nxagent is not running\n")
        unless defined $pid;

    my $uid = (stat "/proc/$pid")[4];
    $httpd->throw_http_error(QVD::HTTP::StatusCodes::HTTP_SERVICE_UNAVAILABLE, "Unable to retrieve UID for nxagent process\n")
        unless defined $uid;

    my $log = _open_log("x11vnc");
    $httpd->throw_http_error(QVD::HTTP::StatusCodes::HTTP_SERVICE_UNAVAILABLE, "Unable to open log file for x11vnc\n")
        unless defined $log;

    $httpd->send_http_response(QVD::HTTP::StatusCodes::HTTP_SWITCHING_PROTOCOLS);

    eval {
        POSIX::dup2(fileno($log), 2);

        setpgrp(0, 0);
        _become_user($uid);

        POSIX::dup2(fileno($httpd->{server}{client}), 0);
        POSIX::dup2(fileno($httpd->{server}{client}), 1);

        exec($x11vnc, -display => ":$display", '-inetd')
    };

    print {$log} "Unable to start x11vnc: " . ($@ || $!);
    POSIX::_exit(-1);
}

sub _start_usb {
    my ($port) = @_;
    DEBUG "Starting USB";
    my @cmd = ($slaveclient, "--forward-usb");

    system(@cmd) == 0 or ERROR "Failed to execute " . join(' ', @cmd) . ": $?";
}

sub _start_usbip {
   my ($port) = @_;
   DEBUG "Starting USBIP";
   my @cmd;

   eval {
       DEBUG "Creating SlaveClient object";
       require QVD::SlaveClient;
       my $slave = QVD::SlaveClient->new('localhost:11100');

       DEBUG "Setting up USBIP forwarding";
       $slave->forward_usbip();

       DEBUG "Forwarding devices";
       $slave->forward_usbip_devices();

   };
   if ( $@ ) {
       if ( $@ =~ /SlaveClient.pm in \@INC/ ) {
           ERROR "The qvd-slaveclient package is required for USBIP functionality";
       } else {
           ERROR "Error while setting up USBIP: $@";
       }
   }

}

sub _start_pulseaudio {
    my ($port, $user, $compression) = @_;
    my $proc;

    INFO "Starting PulseAudio on port $port, user $user";

    # Make sure that we don't break the session if something goes wrong here.
    eval {
        my ($buf, $ofh, $ifh);
        my $packaged_pulse_conf = cfg('path.qvd.etc') . "/pulse/default.pa";

        DEBUG "Reading $packaged_pulse_conf";
        if (!open($ifh, '<', $packaged_pulse_conf) ) {
            ERROR "Failed to open $packaged_pulse_conf: $!";
            return undef;
        }

        local $/;
        undef $/;
        $buf = <$ifh>;
        close $ifh;

        DEBUG "Writing $pulse_conf";
        if (!open($ofh, '>', $pulse_conf)) {
            ERROR "Failed to create $pulse_conf: $!";
            return undef;
        }

        print $ofh "$buf\n";
        print $ofh "load-module module-tunnel-sink-new sink_name=QVD_Audio " .
                   "server=tcp:127.0.0.1:$port sink=\@DEFAULT_SINK\@";
        if ( $compression ) {
            print $ofh " compression=opus";
            DEBUG "Audio compression enabled";
        }

        print $ofh "\n";
        close $ofh;

        my @cmd = (cfg('path.qvd.bin') . "/pulseaudio",
                   "-vv", "--log-target=file:/tmp/qvd-pulseaudio-$user.log",
                   "-n", "-F", $pulse_conf, "--exit-idle-time", "-1");

        INFO "Executing PulseAudio";
        DEBUG "Arguments: " . join(' ', @cmd);

        $proc = _bgrun({ user => $user }, @cmd);

        if (!$proc) {
            ERROR "Failed to start pulseaudio: $!";
            return undef;
        }
    };
    if ( $@ ) {
        ERROR "Error while starting PulseAudio: $@";
        return undef;
    }

    return $proc;
}

sub _start_desktop_app_icons {
    my ($token, $host, $user) = @_;

    if (!$token) {
        ERROR "Can't start icon creation: no token provided. Server too old?";
        return;
    }

    if (!$host) {
        ERROR "Can't start icon creation: no host provided. Server too old?";
        return;
    }

    INFO "Starting icon creation for user $user. Server is $host; token is $token";

    my $proc = _bgrun({ user => $user }, $qvd_client, "--token", $token, "--host", $host, "--ssl-errors=continue", "--create-icons");
    if (!$proc) {
        ERROR "Failed to run $qvd_client";
    }

    return $proc;
}

sub _stop_process {
    my ($pid, $name) = @_;
    return unless ($pid);

    my $tries = 10;
    my $killed;

    INFO "Stopping $name with pid $pid";
    kill 'TERM', $pid;

    while($tries-- > 0) {
        $killed = waitpid($pid, WNOHANG);
        break if $killed;
    }

    if (!$killed) {
        WARN "$name did not exit, terminating forcefully";
        kill 'KILL', $pid;
        waitpid($pid, 0);
    }

}

################################ RPC methods ######################################

sub SimpleRPC_ping {
    DEBUG "pinged";
}

sub SimpleRPC_x_state {
    DEBUG "x_state called";
    _state;
}

sub SimpleRPC_poweroff {
    my $self=shift;
    my $httpd=shift;
    INFO "shutting system down";
    _poweroff;
    $httpd->server_close; # In case the VMA was not killed by init 0, v.g. docker
}

sub SimpleRPC_x_suspend {
    INFO "suspending X session";
    _suspend_session;
}

sub SimpleRPC_x_stop {
    INFO "stopping X session";
    _stop_session;
}

sub SimpleRPC_x_start {
    my $self = shift;
    INFO "starting/resuming X session";
    _start_session(@_);
}

sub SimpleRPC_expire {
    INFO "VM DI has expired";
    _expire(@_);
}

sub HTTP_vnc_connect {
    my ($self, $httpd, $headers) = @_;
    DEBUG "starting a VNC monitoring session";
    _vnc_connect($httpd, $headers);
}

sub _bgrun {
    my ($opts, @cmd) = @_;

    local $SIG{CHLD};
    undef $SIG{CHLD};

    DEBUG sprintf("_bgrun: opts=%s; command=%s", join(',', %$opts), join(' ', @cmd));

    my $pid = fork();
    if ( !$pid ) {
        die "Fork failed: $!" unless (defined $pid);
        if ( $opts->{user} ) {
            _become_user($opts->{user});
            _set_environment();
        }

        exec(@cmd) or POSIX::exit(1);
    } else {
        return $pid;
    }

}

sub _suspend_pulseaudio {
    my ($pid, $user) = @_;
    if ( $pid ) {
        DEBUG "Suspending PulseAudio for user $user";
        _bgrun({user => $user}, "pacmd", "unload-module", "module-tunnel-sink-new");
    } else {
        DEBUG "PulseAudio not running, not suspending";
    }
}

sub _run {
	my @cmd = @_;
	my $cmdstr = join(' ', @cmd);

	DEBUG "Going to run command '$cmdstr'";

	my $ret = system(@cmd);
	if ( $ret == -1 ) {
		ERROR "Failed to execute '$cmdstr': $!\n";
		return 1;
	} elsif ( $ret & 127 ) {
		my $msg = sprintf("died with signal %d, %s coredump\n", ( $?&127), ($?&128) ? 'with' : 'without');
		ERROR "Command '$cmdstr' $msg";
		return 1;
	} else {
		if ( ($? >> 8) > 0 ) {
			ERROR "Command '$cmdstr' exited with value " . ( $? >> 8 );
			return $? >> 8;
		} else {
			DEBUG "Command '$cmdstr' exited successfully";
			return 0;
		}
	}
}

1;

__END__

=head1 NAME

QVD::VMA - The QVD Virtual Machine Agent

=head1 SYNOPSIS

    use QVD::VMA;

    my $vma = QVD::VMA->new(port => 3030);
    $vma->run();

=head1 DESCRIPTION

The VMA runs on virtual machines and implements an RPC interface to control
them.

=head2 API

The following RPC calls are available.

=over

=item ping

This methods does nothing and always returns 1.

It can be used to check that the VM and VMA are up.

=item x_state

Returns the current state of the VMA/nxagent. See
L<https://intranet.qindel.com/trac/QVD/wiki/NxagentStates> for
a description of the acceptable states.

=item poweroff

Starts the machine power off process.

=item x_suspend

Asks the nxagent to disconnect the user and suspend itself.

=item x_stop

Asks the nxagent to stop itself.

=item x_start

Runs the provisioning tasks and starts the nxagent.

=back

=head1 AUTHORS

Salvador FandiE<ntilde>o (sfandino@yahoo.com)

Joni Salonen

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
