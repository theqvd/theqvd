package QVD::VMA;

our $VERSION = '0.02';

use warnings;
use strict;

use parent 'QVD::HTTPD';

sub post_configure_hook {
    my $self = shift;
    my $impl = QVD::VMA::Impl->new();
    $impl->set_http_request_processors($self, '/vma/*');
    QVD::VMA::Impl::_delete_nxagent_state_and_pid();
}

sub post_child_cleanup_hook {
    QVD::VMA::Impl::_stop_session();
    QVD::VMA::Impl::_delete_nxagent_state_and_pid();
}

package QVD::VMA::Impl;

use POSIX;
use Fcntl qw(:flock);
use feature qw(switch say);
use QVD::Config;
use QVD::Log;

use parent 'QVD::SimpleRPC::Server';

my $log_path  = cfg('path.log');
my $run_path  = cfg('path.run');
my $nxagent   = cfg('command.nxagent');
my $x_session = cfg('command.x-session');
my $as_user   = cfg('vma.nxagent.as_user');

my $display   = cfg('internal.nxagent.display');


my %timeout = ( initiating => cfg('internal.nxagent.timeout.initiating'),
		listening  => cfg('internal.nxagent.timeout.listening'),
		suspending => cfg('internal.nxagent.timeout.suspending'),
		stopping   => cfg('internal.nxagent.timeout.stopping') );

our $nxagent_state_fn = "$run_path/nxagent.state";
our $nxagent_pid_fn   = "$run_path/nxagent.pid";

my %x_env;
for (core_cfg_keys) {
    /^(vma\.x-session\.env\.(.*))$/
	and $x_env{$2} = core_cfg $1;
}

my %nx2x = ( initiating  => 'starting',
	     starting    => 'listening',
	     resuming    => 'listening',
	     started     => 'connected',
	     resumed     => 'connected',
	     suspending  => 'suspending',
	     suspended   => 'suspended',
	     terminating => 'stopping',
	     aborting    => 'stopping',
	     suspended   => 'stopped',
	     aborted     => 'stopped',
	     stopped     => 'stopped',
	     ''          => 'stopped');

my %running   = map { $_ => 1 } qw(listening connected suspending suspended);
my %connected = map { $_ => 1 } qw(listening connected);

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

sub _save_nxagent_state { _write_line($nxagent_state_fn, join(':', shift, time) ) }
sub _save_nxagent_pid   { _write_line($nxagent_pid_fn, shift) }

sub _delete_nxagent_state_and_pid {
    DEBUG "deleting pid and state files";
    unlink $nxagent_pid_fn;
    unlink $nxagent_state_fn;
}

sub _timestamp {
    my @t = gmtime; $t[5] += 1900; $t[4] += 1;
    sprintf("%04d%02d%02d%02d%02d%02d", @t[5, 4, 3, 2, 1, 0]);
}

sub _open_log {
    my $log_fn = "$log_path/nxagent.log"; # -" . _timestamp . ".log";
    open my $log, '>>', $log_fn or die "unable to open nxagent log file $log_fn\n";
    return $log;
}

sub _fork_monitor {
    my %x_args = @_;
    my $log = _open_log;
    select $log;
    $| = 1;

    say _timestamp . ": Starting nxagent";

    _save_nxagent_state 'initiating';

    my $pid = fork;
    if (!$pid) {
	defined $pid or die "Unable to start monitor, fork failed: $!\n";
	eval {
	    mkdir $run_path, 755;
	    -d $run_path or die "Directory $run_path does not exist\n";

	    # detach from stdio and from process group so it is not killed by Net::Server
	    open STDIN,  '<', '/dev/null';
	    open STDOUT, '>', '/tmp/xinit-out'; #/dev/null';
	    open STDERR, '>', '/tmp/xinit-err'; #/dev/null';
	    setpgrp(0, 0);

	    $SIG{CHLD} = 'IGNORE';

	    _save_nxagent_state 'initiating';

	    my $pid = open(my $out, '-|');
	    if (!$pid) {
		defined $pid or die ERROR "unable to start X server, fork failed: $!\n";

		eval {
		    POSIX::dup2(1, 2); # equivalent to shell 2>&1
		    _become_user($as_user);

		    $ENV{PULSE_SERVER} = "tcp:localhost:".($display+7000);

		    my $nx_display = join(',', 'nx/nx', 'link=lan', 'media=1',
					  map "$_=$x_args{$_}", keys %x_args) . ":$display";

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
			_save_nxagent_state lc $1;
		    }
		    when (/Session: Session (\w+) at/) {
			_save_nxagent_state lc $1;
		    }

		    print $line;
		    print STDOUT $line;
		}
	    }
	};
	DEBUG $@ if $@;
	_delete_nxagent_state_and_pid;
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

    _delete_nxagent_state_and_pid if $state eq 'stopped';

    return wantarray ? ($state, $pid) : $state;
}

sub _suspend_session {
    my ($state, $pid) = _state;
    if ($pid and $connected{$state}) {
	kill HUP => $pid;
	return 'starting';
    }
    $state;
}

sub _stop_session {
    my ($state, $pid) = _state;
    if ($pid) {
	kill TERM => $pid;
	return 'stopping'
    }
    $state;
}

sub _start_session {
    my ($state, $pid) = _state;
    DEBUG "starting session in state $state, pid $pid";
    given ($state) {
	when ('suspended') {
	    DEBUG "awaking nxagent";
	    _save_nxagent_state 'initiating';
	    kill HUP => $pid;
	}
	when ('connected') {
	    DEBUG "suspend and fail";
	    kill HUP => $pid;
	    die "Can't connect to X session in state connected, suspending it, retry later\n";
	}
	when ('stopped') {
	    _fork_monitor(@_);
	}
	default {
	    die "Unable to start/resume X session in state $_";
	}
    }
    'starting';
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
    system(init => 0);
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
    my ($self, %x_args) = @_;
    INFO "starting/resuming X session";

    # check args:
    while (my ($k, $v) = each %x_args) {
	$k =~ m{^(?:keyboard|client)$}
	    or die "invalid parameter $k";
	$v =~ m{^[\w/\-\+]+$}
	    or die "invalid characters in parameter $k";
    }

    _start_session(%x_args);
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
