package QVD::VMA;

our $VERSION = '0.01';

use warnings;
use strict;

use QVD::VMA::Config;
use parent 'QVD::HTTPD';

sub post_configure_hook {
    my $self = shift;
    my $impl = QVD::VMA::Impl->new();
    $impl->set_http_request_processors($self, '/vma/*');
}


package QVD::VMA::Impl;

use Carp;
use File::Slurp qw(slurp);
use File::Spec;
use POSIX;
use QVD::Config;
use QVD::Log;
use feature qw(switch);

use parent 'QVD::SimpleRPC::Server';

sub _slurp_line {
    my $fname = shift;
    my $txt = slurp $fname;
    chomp $txt;
    $txt;
}

sub _touch {
    my $fname = shift;
    open FH, ">>", $fname or carp "Couldn't create $fname: $!";
    close FH;
    chmod 0666, $fname or carp "Couldn't set permissions for $fname: $!";
}

# FIXME
# fix status/state dichotomy

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();

    my $run_dir = cfg('vma.run_dir', '/var/run/qvd');
    $self->{_desktop} = cfg('x_session.desktop', '/etc/X11/Xsession');
    $self->{_run_dir} = $run_dir;
    $self->{_run_state_fn} = "$run_dir/state";
    $self->{_run_nxagent_pid_fn} = "$run_dir/nxagent.pid";
    $self->{_run_nxagent_log_fn} = "$run_dir/nxagent.log";

    my ($vol,$dir) = File::Spec->splitpath(File::Spec->rel2abs($0));
    $self->{_xagent} = File::Spec->catpath($vol,$dir,'nxagent-monitor.pl');

    -e $run_dir or mkdir $run_dir;
    -d $run_dir or croak "Couldn't create run directory: $!";
    _touch $self->{_run_state_fn};
    _touch $self->{_run_nxagent_pid_fn};
    _touch $self->{_run_nxagent_log_fn};
    $self
}

sub _get_nxagent_pid { _slurp_line shift->{_run_nxagent_pid_fn} }

sub _get_nxagent_status { _slurp_line shift->{_run_state_fn} }

sub _is_nxagent_running {
    my $self = shift;
    my $pid = $self->_get_nxagent_pid;
    # FIXME Who says that no other process can take the pid?
    # Very unlikely, Linux does not reuse PIDs lightly --Salva
    $pid and kill(0, $pid);
}

sub _is_nxagent_suspended {
    my $self = shift;
    my $status = $self->_get_nxagent_status;
    $status eq 'suspended';
}

sub _is_nxagent_started {
    my $self = shift;
    my $status = $self->_get_nxagent_status;
    $status eq 'started' or $status eq 'resumed';
}

sub _is_nxagent_starting {
    my $self = shift;
    my $status = $self->_get_nxagent_status;
    $status eq 'starting' or $status eq 'resuming';
}

sub _suspend_or_wakeup_session {
    my $self = shift;
    my $pid = $self->_get_nxagent_pid;
    DEBUG ("Trying to suspend / wakeup nxagent");
    kill(HUP => $pid);
}

sub _start_or_resume_session {
    # FIXME: fully rewrite this method!
    my ($self, %x_args) = @_;
    INFO("start or resume session with @_");
    if ($self->_is_nxagent_running) {
	if ($self->_is_nxagent_suspended) {
	    DEBUG("Waking up suspended nxagent..");
	    $self->_suspend_or_wakeup_session;
	} elsif ($self->_is_nxagent_started) {
	    DEBUG ("Suspending active nxagent to steal session..");
	    $self->_suspend_or_wakeup_session;
	    DEBUG "Waiting for session to suspend..";
	    # FIXME: this method shouldn't block!
	    while (! $self->_is_nxagent_suspended) {
		DEBUG "Still waiting to session to suspend..";
		sleep 1;
	    }
	    DEBUG ("Waking up suspended nxagent to steal session..");
	    $self->_suspend_or_wakeup_session;
	} elsif ($self->_is_nxagent_starting) {
	    until ($self->_is_nxagent_started) {
		# FIXME: remove this sleep
		# let the L7R take care of this
		DEBUG ("Waiting for starting nxagent to become ready..");
		sleep 1;
	    }
	} else {
	    # nxagent is aborting, terminating, suspending or stopped
	    DEBUG ("Waiting for ".$self->_get_nxagent_status." nxagent to stop..");
	    # FIXME: remove this sleep
	    # let the L7R take care of this
	    sleep 2;
	    $self->_start_or_resume_session(%x_args);
	}
    } else {
	my $desktop = $self->{_desktop};
	my $xagent = $self->{_xagent};
	INFO("nxagent ($xagent) wasn't running, starting it with session $desktop");
	my $pid = fork;
	if (!$pid) {
	    defined $pid or carp "fork failed";
	    my $displayn = 1000;
	    $ENV{PULSE_SERVER} = "tcp:localhost:".($displayn+7000);

	    my $display = join(',', 'nx/nx', 'link=lan',
			       (map "$_=$x_args{$_}", keys %x_args),
			       'media=1') . ":$displayn";
			    
	    # FIXME: remove su, do it in perl

	    # FIXME: remove shell call to invoke xinit

	    # FIXME: remove -ac as we are not certain this does not impact on the security of the platform
	    { exec "su - qvd -c \"xinit $desktop -- $xagent :$displayn -name QVD -display $display -ac\"" }
	    POSIX::_exit(-1);
	}
    }
    1;
}

sub _shutdown {
    my $self = shift;
    my $type = shift;
    DEBUG "shutting system down";
    system("init 0") == 0
}

sub SimpleRPC_start_x_listener {
    my ($self, %x_args) = @_;
    INFO "starting X listener";

    while (my ($k, $v) = each %x_args) {
	$k =~ m{^(?:keyboard|system)$}
	    or die "invalid parameter $k";
	$v =~ m{^[\w/\-\+]$}
	    or die "invalid characters in parameter $k";
    }

    $self->_start_or_resume_session(%x_args);
}

sub SimpleRPC_x_state { shift->_x_state }

sub _x_state {
    my $self = shift;
    my $nx_state =  $self->_get_nxagent_status();
    given ($nx_state) {
	when ('initiated')                               { return 'connecting'    }
	when (['starting', 'resuming'])                  { return 'listening'     }
	when (['started', 'resumed'])                    { return 'connected'     }
 	when (['suspending', 'terminating', 'aborting']) { return 'disconnecting' }
	when (['', 'suspended', 'terminated', 'aborted',
	       'exited terminated','exited aborted'])    { return 'disconnected'  }
    }
    die "Internal error: no mapping for nxagent state $nx_state";
}

sub SimpleRPC_status {
    # FIXME: remove this method
    my $self = shift;
    my $nx_state = $self->_get_nxagent_status();

    my $x_state;
    if ($nx_state eq 'initiated') {
	$x_state = 'connecting';
    } elsif (grep $nx_state eq $_, qw(starting resuming)) {
	$x_state = 'listening';
    } elsif (grep $nx_state eq $_, qw(started resumed)) {
	$x_state = 'connected';
    } elsif (grep $nx_state eq $_, qw(suspending terminating aborting)) {
	$x_state = 'disconnecting';
    } elsif (grep $nx_state eq $_, qw(suspended terminated aborted),
					'exited terminated','exited aborted') {
	$x_state = 'disconnected';
    } else {
	ERROR "No mapping for nxagent state '".$nx_state."'";
	$x_state = 'disconnected';
    }

    {status => 'ok', x_state => $x_state, __deprecated__ => 1}
}


sub SimpleRPC_poweroff {
    my $self = shift;
    my $mins = 1;
    # FIXME: shutdown arguments have changed
    if ($self->_shutdown('P', $mins)) {
	{'poweroff' => $mins};
    } else {
	{'poweroff' => undef};
    }
}

sub SimpleRPC_disconnect_session {
    # FIXME: this method should return nothing and die on failure
    my $self = shift;
    DEBUG "Trying to disconnect session in state ".$self->_get_nxagent_status;
    if ($self->_is_nxagent_started or $self->_is_nxagent_starting) {
	DEBUG ("Trying to disconnect the session that is already started or starting");
	$self->_suspend_or_wakeup_session;
	{disconnect => 1};
    } else {
	{disconnect => undef};
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
