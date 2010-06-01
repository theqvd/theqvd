package QVD::VMA;

our $VERSION = '0.02';

use warnings;
use strict;

use parent 'QVD::HTTPD';

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
use QVD::Config;
use QVD::Log;
use Config::Properties;

use parent 'QVD::SimpleRPC::Server';

my $log_path        = cfg('path.log');
my $run_path        = cfg('path.run');
my $nxagent         = cfg('command.nxagent');
my $nxdiag          = cfg('command.nxdiag');
my $x_session       = cfg('command.x-session');
my $as_user         = cfg('vma.nxagent.as_user');
my $enable_audio    = cfg('vma.audio.enable');
my $enable_printing = cfg('vma.printing.enable');
my $printing_conf   = cfg('vma.printing.config');

my %on_action =   ( connect    => cfg('vma.on_action.connect'),
		    disconnect => cfg('vma.on_action.disconnect'),
		    suspend    => cfg('vma.on_action.suspend'),
		    poweroff   => cfg('vma.on_action.poweroff') );

my %on_state =    ( connected => cfg('vma.on_state.connected'),
		    suspended => cfg('vma.on_state.suspended'),
		    stopped   => cfg('vma.on_state.disconnected') );

my %on_printing = ( connected => cfg('internal.vma.on_printing.connected'),
		    suspended => cfg('internal.vma.on_printing.suspended'),
		    stopped   => cfg('internal.vma.on_printing.stopped'));

my $display       = cfg('internal.nxagent.display');
my $printing_port = $display + 2000;

my %timeout = ( initiating => cfg('internal.nxagent.timeout.initiating'),
		listening  => cfg('internal.nxagent.timeout.listening'),
		suspending => cfg('internal.nxagent.timeout.suspending'),
		stopping   => cfg('internal.nxagent.timeout.stopping') );

our $nxagent_state_fn = "$run_path/nxagent.state";
our $nxagent_pid_fn   = "$run_path/nxagent.pid";

my %nx2x = ( initiating  => 'starting',
	     starting    => 'listening',
	     resuming    => 'listening',
	     started     => 'connected',
	     resumed     => 'connected',
	     suspending  => 'suspending',
	     suspended   => 'suspended',
	     terminating => 'stopping',
	     aborting    => 'stopping',
	     aborted     => 'stopped',
	     stopped     => 'stopped',
	     ''          => 'stopped');

my %running   = map { $_ => 1 } qw(listening connected suspending suspended);
my %connected = map { $_ => 1 } qw(listening connected);

sub _open_log {
    my $name = shift;
    my $log_fn = "$log_path/qvd-$name.log";
    open my $log, '>>', $log_fn or die "unable to open $name log file $log_fn\n";
    return $log;
}

sub _call_hook {
    my $name = shift;
    my $file = shift;
    my $detach = shift;
    if (length $file) {
	DEBUG "calling hook $file for $name with args @_";
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
		die "hook process $pid disappeared";
	    }
	    if ($kid == $pid) {
		$? and die "hook $file for $name failed, rc: ". ($? >> 8);
		return;
	    }
	    DEBUG "waitpid returned $kid unexpectedly";
	    sleep 1;
	}
    }
}

sub _call_action_hook {
    my $action = shift;
    my $state = _state();
    _call_hook("action $action on state $state", $on_action{$action}, 0,
	       @_, 'qvd.session.state', $state, 'qvd.hook.on_action', $action);
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
	open my $fh, '<', $printing_conf or die "Unable to open printing configuration";
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

sub _save_nxagent_state_and_call_hook {
    _write_line($nxagent_state_fn, join(':', shift, time) );
    _call_printing_hook;
    _call_state_hook;
}
sub _save_nxagent_pid   { _write_line($nxagent_pid_fn, shift) }

sub _delete_nxagent_state_and_pid_and_call_hook {
    DEBUG "deleting pid and state files";
    unlink $nxagent_pid_fn;
    unlink $nxagent_state_fn;
    _call_printing_hook;
    _call_state_hook;
}

sub _timestamp {
    my @t = gmtime; $t[5] += 1900; $t[4] += 1;
    sprintf("%04d%02d%02d%02d%02d%02d", @t[5, 4, 3, 2, 1, 0]);
}

my %props2nx = ( 'qvd.client.keyboard'   => 'keyboard',
		 'qvd.client.os'         => 'client',
		 'qvd.client.link'       => 'link',
		 'qvd.client.geometry'   => 'geometry',
		 'qvd.client.fullscreen' => 'fullscreen' );

sub _fork_monitor {
    my %props = @_;
    my $log = _open_log('nxagent');
    my $logfd = fileno $log;
    select $log;
    $| = 1;

    say _timestamp . ": Starting nxagent";

    _save_nxagent_state_and_call_hook 'initiating';

    my $pid = fork;
    if (!$pid) {
	defined $pid or die "Unable to start monitor, fork failed: $!\n";
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

	    $SIG{CHLD} = 'IGNORE';

	    _save_nxagent_state_and_call_hook 'initiating';

	    my $pid = open(my $out, '-|');
	    if (!$pid) {
		defined $pid or die ERROR "unable to start X server, fork failed: $!\n";

		eval {
		    POSIX::dup2(1, 2); # equivalent to shell 2>&1
		    _become_user($as_user);

		    my @nx_args = ('nx/nx');
		    for my $key (keys %props2nx) {
			my $val = $props{$key} // cfg("vma.default.$key", 0);
			if (defined $val and length $val) {
			    $val =~ m{^[\w/\-\+]+$}
				or die "invalid characters in parameter $key";
			    push @nx_args, "$props2nx{$key}=$val";
			}
		    }

		    if ($enable_audio) {
			push @nx_args, 'media=1';
			$ENV{PULSE_SERVER} = "tcp:localhost:".($display+7000);
		    }

		    if ($enable_printing) {
			push @nx_args, 'cups=1';
		    }

		    my $nx_display = join(',', @nx_args) . ":$display";
		    $ENV{NX_CLIENT} = $nxdiag;

		    # FIXME: reimplement xinit in Perl in order to allow capturing nxagent ouput alone
		    my @cmd = (xinit => $x_session, '--', $nxagent, ":$display", '-ac', '-name', 'QVD', '-display', $nx_display);
		    say "running @cmd";
		    exec @cmd;
		};
		say "Unable to start X server: " .($@ || $!);
		POSIX::_exit(1);
	    }

	    while(defined (my $line = <$out>)) {
		given ($line) {
		    when (/Info: Agent running with pid '(\d+)'/) {
			_save_nxagent_pid $1;
		    }
		    when (/Session: (\w+) session at/) {
			_save_nxagent_state_and_call_hook lc $1;
		    }
		    when (/Session: Session (\w+) at/) {
			_save_nxagent_state_and_call_hook lc $1;
		    }
		}
		print $line;
	    }
	    print "out closed";
	};
	DEBUG $@ if $@;
	_delete_nxagent_state_and_pid_and_call_hook;
    }
}

sub _state {
    -f $nxagent_state_fn or return 'stopped'; # shortcut!

    my $state_line = _read_line $nxagent_state_fn;
    my ($nxstate, $timestamp) = $state_line =~ /^(.*?)(?::(.*))?$/;

    my $state = $nx2x{$nxstate};
    my $timeout = $timeout{$state};
    my $pid = _read_line $nxagent_pid_fn;
    DEBUG ("_state: $state, nxstate: $nxstate, ts: $timestamp, timeout: $timeout");

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

sub _save_printing_conf {
    my %args = @_;
    my $props = Config::Properties->new;
    $props->setProperty('qvd.printing.enabled' => ($enable_printing && $args{'qvd.client.printing.enabled'}) // 0);
    $props->setProperty('qvd.client.os' => $args{'qvd.client.os'});
    $props->setProperty('qvd.printing.port' => $printing_port);

    my $tmp = "$printing_conf.tmp";
    open my $fh, '>', $tmp or die "Unable to save printing configuration to $tmp";
    $props->save($fh);
    close $fh or die "Unable to write printing configuration to $tmp";
    rename $tmp, $printing_conf or die "Unable to write printing configuration to $printing_conf";
}

sub _start_session {
    my ($state, $pid) = _state;
    DEBUG "starting session in state $state, pid $pid";
    given ($state) {
	when ('suspended') {
	    _call_action_hook('connect',  @_);
	    DEBUG "awaking nxagent";
	    _save_printing_conf(@_);
	    _save_nxagent_state_and_call_hook 'initiating';
	    kill HUP => $pid;
	}
	when ('connected') {
	    DEBUG "suspend and fail";
	    kill HUP => $pid;
	    die "Can't connect to X session in state connected, suspending it, retry later\n";
	}
	when ('stopped') {
	    _call_action_hook('connect', @_);
	    _save_printing_conf(@_);
	    _fork_monitor(@_);
	}
	default {
	    die "Unable to start/resume X session in state $_";
	}
    }
    'starting';
}

sub _poweroff {
    _call_action_hook('poweroff', @_);
    system(init => 0);
}

################################ RPC methods ######################################

sub SimpleRPC_ping {
    DEBUG "pinged";
    1
}

sub SimpleRPC_x_state {
    DEBUG "x_state called";
    _state
}

sub SimpleRPC_poweroff {
    INFO "shutting system down";
    _poweroff;
}

sub SimpleRPC_x_suspend {
    INFO "suspending X session";
    _suspend_session
}

sub SimpleRPC_x_stop {
    INFO "stopping X session";
    _stop_session
}

sub SimpleRPC_x_start {
    my $self = shift;
    INFO "starting/resuming X session";
    _start_session(@_);
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

=item start_vm_listener()

Respond to the RPC C<start_vm_listener> by starting or resuming an nx session.

Returns a hash with host and port to connect to.

=item status()

Respond to the RPC C<status>.

Returns a hash with the state of the VMA (always 'ok') and the state of
nxagent. The state of nxagent is given as one of disconnected, connecting,
listening, connected, and disconnecting.

=item poweroff()

Respond to the RPC C<poweroff> by scheduling the shutdown of the machine. By
default the shutdown is scheduled within 1 minute.

Returns a hash with the key C<poweroff> and the value minutes until shutdown or
C<undef> if scheduling power off failed.

=item disconnect_session()

Disconnect the user session if it is running.

Returns a hash with the key C<disconnect> having a true value if the session
was disconnected and undef if the session wasn't running in the first place.

=back

=head2 Internal API

These methods are for internal use.

=over

=item _get_nxagent_pid

Returns the last recorded pid of nxagent.

=item _shutdown($type, $minutes)

Power off, reboot, or halt the system using C<shutdown(8)>.  Successful
shutdown is verified by checking the existence of the pid file
F</var/run/shutdown.pid>.

=over

=item $type: Options to pass to shutdown: 'P' to power off, 'r' to reboot, etc.

=item $minutes: Number of minutes to wait before shutting down.

=back

Returns 1 if the shutdown was started succesfully, 0 in other case.

=item _get_nxagent_status

Returns the last recorded nxagent status. While nxagent is running it is one of

=over

=item starting,

=item started,

=item suspending,

=item suspended,

=item resuming,

=item resumed,

=item terminating,

=item terminated,

=item aborting or

=item aborted.

=back

When nxagent exits, the status becomes "exited I<last_status>", where
I<last_status> is the previous recorded status (likely terminated or aborted).

=item _is_nxagent_started

Checks if nxagent is in "started" state. In a started state the status can be
started or resumed.

=item _is_nxagent_suspended

Checks if nxagent is in suspended state.

=item _is_nxagent_running

Checks if nxagent is running by getting its pid and checking if it exists.

=item _start_or_resume_session

Performs the necessary steps to start a session. Resuming existing sessions is
automatically attempted.

=back

=head1 AUTHORS

Salvador FandiE<ntilde>o (sfandino@yahoo.com)

Joni Salonen 

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
