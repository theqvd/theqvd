package QVD::VMA;

our $VERSION = '0.01';

use warnings;
use strict;

use Proc::ProcessTable;

use parent 'QVD::HTTPD';

sub post_configure_hook {
    my $self = shift;
    my $impl = QVD::VMA::Impl->new();
    $impl->set_http_request_processors($self, '/vma/*');
}

package QVD::VMA::Impl;

use parent 'QVD::SimpleRPC::Server';

# FIXME Move session dir and un-priviledged user name to config file

sub qvd_touch {
    my $fname = shift;
    open FH, ">>", $fname or die "Couldn't create $fname: $!";
    close FH;
    chmod 0666, $fname or die "Couldn't set permissions for $fname: $!";
}

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    my $QVD_SESSION_DIR = '/var/run/qvd';
    mkdir $QVD_SESSION_DIR or die "Couldn't create run directory: $!"
    	unless -e $QVD_SESSION_DIR;
    qvd_touch $QVD_SESSION_DIR.'/state';
    qvd_touch $QVD_SESSION_DIR.'/nxagent.pid';
    qvd_touch $QVD_SESSION_DIR.'/nxagent.log';
    $self
}

sub _get_nxagent_pid {
    my $self = shift;
    return `cat /var/run/qvd/nxagent.pid`;
}


sub _get_nxagent_status {
    my $self = shift;
    my $status = `cat /var/run/qvd/state`;
    chomp($status);
    return $status;
}

sub _is_nxagent_running {
    my $self = shift;
    my $pid = $self->_get_nxagent_pid;
    if ($pid) {
	# FIXME Who says that no other process can take the pid?
	return kill 0, $pid;
    } else {
	return 0;
    }
}

sub _is_nxagent_suspended {
    my $self = shift;
    my $status = $self->_get_nxagent_status;
    return $status eq 'suspended';
}

sub _is_nxagent_started {
    my $self = shift;
    my $status = $self->_get_nxagent_status;
    return $status eq 'started' || $status eq 'resumed';
}

sub _start_or_resume_session {
    my $self = shift;
    my $pid = $self->_get_nxagent_pid;
    if ($self->_is_nxagent_running) {
	if ($self->_is_nxagent_suspended) {
	    warn "Waking up suspended nxagent..";
	    kill('HUP', $pid);
	} elsif ($self->_is_nxagent_started) {
	    warn "Suspending active nxagent to steal session..";
	    kill('HUP', $pid);
	    while (! $self->_is_nxagent_suspended) {
		# FIXME: timeout
		sleep 1;
	    }
	    warn "Waking up suspended nxagent to steal session..";
	    kill('HUP', $pid);
	} else {
	    # FIXME: Need to process the *ing-states+aborted+exited
	    die "Nxagent is running but not started nor suspended!";
	}
    } else {
	my $pid = fork;
	if (!$pid) {
	    defined $pid or die "fork failed";
	    { exec "su - qvd -c \"xinit /usr/bin/gnome-session -- /home/qvd/QVD/ext/QVD-VMA/bin/nxagent-monitor.pl :1000 -display nx/nx,link=lan:1000 -ac\"" };
	    { exec "/bin/false" };
	    require POSIX;
	    POSIX::_exit(-1);
	}
    }
}


sub _shutdown {
    my $self = shift;
    my $type = shift;
    my $minutes = shift;
    my $pid = fork;
    if (!$pid) {
	defined $pid or die "Shutdown: fork failed: $!";
	{ exec "shutdown -$type +$minutes" };
	die "Shutdown: exec failed: $!";
    }
    # Wait 2 seconds and check the presence of pid file
    sleep 2;
    return -e "/var/run/shutdown.pid";
}


sub SimpleRPC_start_vm_listener {
    my $self = shift;
    $self->_start_or_resume_session;
    {host => 'localhost', port => 5000};
}


sub SimpleRPC_status {
    {status => 'ok'};
}


sub SimpleRPC_poweroff {
    my $self = shift;
    my $mins = 1;
    if ($self->_shutdown('P', $mins)) {
	{'poweroff' => $mins};
    } else {
	{'poweroff' => undef};
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

=item start_vm_listener()

Respond to the RPC C<start_vm_listener> by starting or resuming an nx session.

Returns a hash with host and port to connect to.

=item status()

Respond to the RPC C<status>.

Returns a hash with the status of the VMA (always 'ok').

=item poweroff()

Respond to the RPC C<poweroff> by scheduling the shutdown of the machine. By
default the shutdown is scheduled within 1 minute.

Returns a hash with the key C<poweroff> and the value minutes until shutdown or
C<undef> if scheduling power off failed.

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

=head1 COPYRIGHT & LICENSE

Copyright E<copy> 2009 Qindel Formacion y Servicios S.L., all rights
reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

