package QVD::HKD;

use warnings;
use strict;

use Sys::Hostname;

use QVD::VMAS;
use QVD::DB::Simple;
use QVD::Config;

use Log::Log4perl qw(:levels :easy);
Log::Log4perl::init('log4perl.conf');

our $VERSION = '0.01';

# Load parameters from configuration file
my $vm_state_starting_timeout = cfg('vm_state_starting_timeout');
my $vm_state_running_vma_timeout = cfg('vm_state_running_vma_timeout');
my $vm_state_stopping_timeout = cfg('vm_state_stopping_timeout');
my $vm_state_zombie_sigkill_timeout = cfg('vm_state_zombie_sigkill_timeout');
my $x_state_connecting_timeout = cfg('x_state_connecting_timeout');

sub new {
    my ($class, %opts) = @_;
    my $loop_wait_time = delete $opts{loop_wait_time};
    my $vmas = QVD::VMAS->new();
    my $host_id = rs(Host)->search(name => hostname)->first->id;
    my $vm_state_map = {
    	stopped => {
	    start 	=> {new_state => 'starting',
			    action => 'start_vm'},
	    _enter	=> {action => 'enter_stopped'},
	},
	starting => {
	    _fail 	=> {new_state => 'failed'},
	    _timeout 	=> {new_state => 'zombie'},
	    _vma_ok 	=> {new_state => 'running',
			    action => 'update_vma_ok_ts'},
	},
	running => {
	    _fail 	=> {new_state => 'failed'},
	    _timeout 	=> {new_state => 'zombie'},
	    _vma_ok 	=> {action => 'update_vma_ok_ts'},
	    stop 	=> {new_state => 'stopping',
	    		    action => 'stop_vm'},
	},
	stopping => {
	    _enter 	=> {action => 'enter_stopping'},
	    _fail 	=> {new_state => 'stopped'},
	    _timeout 	=> {new_state => 'zombie'},
	},
	zombie => {
	    _fail 	=> {new_state => 'failed'},
	    _do 	=> {action => 'signal_zombie_vm'},
	    _timeout 	=> {action => 'kill_vm'},
	    _enter 	=> {action => 'enter_zombie'},
	},
	failed => {
	    _enter 	=> {action => 'enter_failed'},
	},
    };
    my $nx_state_map = {
    	disconnected => {
	    connect 	=> {new_state => 'connecting',
			    action => 'start_nx'},
	},
	connecting => {
	    disconnect	=> {new_state => 'disconnecting',
	    		    action => 'disconnect_nx'},
	    _timeout 	=> {new_state => 'disconnecting'},
	    _detect_listening => {new_state => 'listening'},
	    _fail	=> {new_state => 'disconnected',
			    action => 'abort'},
	},
	listening => {
	    disconnect	=> {new_state => 'disconnecting',
	    		    action => 'disconnect_nx'},
	    _detect_connected => {new_state => 'connected'},
	    _fail	=> {new_state => 'disconnected',
			    action => 'abort'},
	},
	connected => {
	    disconnect	=> {new_state => 'disconnected',
	    		    action => 'disconnect_nx'},
	    _fail	=> {new_state => 'disconnected',
			    action => 'abort'},
	},
	disconnecting => {
	    _fail 	=> {new_state => 'disconnected'},
	},
    };
    my $self = { 
	loop_wait_time => $loop_wait_time,
	host_id => $host_id,
	vmas => $vmas,
	vm_state_map => $vm_state_map,
	nx_state_map => $nx_state_map,
    };
      
    bless $self, $class;
}

sub _reap_children {
    use POSIX ":sys_wait_h";
    1 while (waitpid(-1, WNOHANG) > 0);
}

sub _handle_SIGUSR1 {
    my $signame = shift;
    INFO ("Received $signame");
}

sub _install_signals {
    my $self = shift;
    $SIG{USR1} = \&_handle_SIGUSR1;
}

sub _check_timeout {
    my ($state, $statestring, $ts, $timeout) = @_;
    if ($state eq $statestring) {
	if (defined $ts and time > $ts + $timeout) {
	    return '_timeout';
	}
    }
    undef
}

sub _do_vm_action {
    shift->_do_action('vm', @_)
}

sub _do_nx_action {
    shift->_do_action('nx', @_)
}

sub _is_command {
    shift =~ /^[^_]/;
}

sub _do_action {
    my ($self, $mode, $event, $vm) = @_;
    my $vmas = $self->{vmas};
    my $vm_id = $vm->vm_id;
    my $state = $mode eq "nx" ? $vm->x_state : $vm->vm_state;
    my $event_map = $self->{$mode."_state_map"}{$state};
        unless (exists $event_map->{$event}) {
	# DEBUG "VM($vm_id,$vm_state,$event) - event ignored";
	return;
    }
    my $new_state = $event_map->{$event}{new_state};
    if (defined $new_state) {
	# This allows to call push_vm_state or push_nx_state based on
	# $mode value
	my $push_state = $vmas->can('push_'.$mode.'_state');
	unless ($push_state) {
	    ERROR ("_do_action: not implemented: push_${mode}_state");
	    return;
	}
	eval {
	    txn_do {
		# FIXME: $vm comes from outside the transaction
		# $vm->discard_changes?
		if (_is_command($event)) {
		    my $clear_cmd = $vmas->can('clear_'.$mode.'_cmd');
		    $vmas->$clear_cmd($vm);
		}
		$vmas->$push_state($vm, $new_state);
	    };
	};
	if ($@) {
	    # If state change failed no actions should be performed
	    WARN("Unable to change state of VM $vm_id from $state to $new_state");
	    return;
	}

	my $enter = $self->{$mode."_state_map"}{$new_state}{_enter}{action};
	if ($enter) {
	    my $method = $self->can('hkd_action_'.$enter);
	    unless ($method) {
		ERROR ("_do_action: not implemented: $method");
		return;
	    }
	    eval { $self->$method($vm, $state, $event) };
	    WARN "Caught from hkd_action_$method($vm_id, $state, $event): $@" if $@;
	}
    }
    my $action = $event_map->{$event}{action};
    if (defined $action) {
	DEBUG ("_do_actions: Handling VM($vm_id,$state,$event) with $action");
	my $method = $self->can('hkd_action_'.$action);
	unless ($method) {
	    ERROR ("_do_actions: not implemented: $action");
	    return;
	}
	eval { $self->$method($vm, $state, $event) };
	WARN "Caught from hkd_action_$action($vm_id, $state, $event): $@" if $@;
    }
}

sub run {
    my $self = shift;
    $self->_install_signals;
    my $vmas = $self->{vmas};
    while (1) {
	$self->_reap_children;
	my @vm_ids = $vmas->get_vm_ids_for_host($self->{host_id});
	foreach my $vm_id (@vm_ids) {
	    my $vm_runtime = $vmas->get_vm_runtime_for_vm_id($vm_id);
	    my $vm_state = $vm_runtime->vm_state;
	    if ($vm_state ne 'stopped' and
		$vm_state ne 'failed') {
		# Process monitoring
		if (! $vmas->is_vm_running($vm_runtime)) {
		    $self->_do_vm_action(_fail => $vm_runtime);
		    next;
		}
		if ($vm_state ne 'zombie' and
		    $vm_state ne 'stopping') {
		    # This condition structure assures here vm_state eq running
		    # Check VMA responds
		    my $vma_status = $vmas->get_vma_status($vm_runtime);
		    if (defined $vma_status and $vma_status->{status} eq 'ok') {
			$self->_do_vm_action(_vma_ok => $vm_runtime);

			my $old_x_state = $vm_runtime->x_state;
			my $new_x_state = $vma_status->{x_state};
			$old_x_state = $old_x_state // 'disconnected';
			if (grep $old_x_state eq $_, qw(connecting listening connected)
			    and ($new_x_state eq 'disconnected')) {
			    $self->_do_nx_action(_fail => $vm_runtime);
			} 
			elsif ($old_x_state eq 'connecting' and $new_x_state eq 'listening') {
			    $self->_do_nx_action(_detect_listening => $vm_runtime);
			}
			elsif ($old_x_state eq 'listening' and $new_x_state eq 'connected') {
			    $self->_do_nx_action(_detect_connected => $vm_runtime);
			}
			if (_check_timeout($old_x_state, 'starting',
				   $vm_runtime->x_state_ts, $x_state_connecting_timeout)) {
			    $self->_do_nx_action(_timeout => $vm_runtime);
			}

			my $cmd = $vm_runtime->x_cmd;
			if (defined $cmd) {
			    $self->_do_nx_action($cmd => $vm_runtime);
			}
			$self->_do_nx_action(_do => $vm_runtime);
		    }
		}
		# Timeout events
		if (_check_timeout($vm_runtime->vm_state, 'starting',
				   $vm_runtime->vm_state_ts, $vm_state_starting_timeout) or
		    _check_timeout($vm_runtime->vm_state, 'running',
				   $vm_runtime->vma_ok_ts, $vm_state_running_vma_timeout) or
		    _check_timeout($vm_runtime->vm_state, 'stopping',
				   $vm_runtime->vm_state_ts, $vm_state_stopping_timeout) or
		    _check_timeout($vm_runtime->vm_state, 'zombie',
				   $vm_runtime->vm_state_ts, $vm_state_zombie_sigkill_timeout)) {
		    $self->_do_vm_action(_timeout => $vm_runtime);
		}
		$self->_do_vm_action( _do => $vm_runtime);
	    }
	    # Command event
	    my $cmd = $vm_runtime->vm_cmd;
	    if (defined $cmd) {
		$self->_do_vm_action($cmd => $vm_runtime);
	    }
	}
	sleep $self->{loop_wait_time};
    }
}

sub hkd_action_start_vm {
    my ($self, $vm, $state, $event) = @_;
    my $r = $self->{vmas}->start_vm($vm);
    if (defined $r->{request} && $r->{request} eq 'error') {
	ERROR ("Starting VM ".$vm->vm_id." error: ".$r->{error});
    } else {
	ERROR ("Starting VM ".$vm->vm_id." success");
    }
}

sub hkd_action_enter_zombie {
    # Siempre que se pase a este estado desde cualquier otro...
    # * se elimina cualquier comando de vm_cmd
    # * se elimina cualquier comando de x_cmd
    # * se cambia el estado x_state a "Disconnected" 
    my ($self, $vm, $state, $event) = @_;
    txn_do {
	# FIXME: $vm comes from outside the transaction!
	$self->{vmas}->clear_vm_cmd($vm);
	$self->{vmas}->clear_nx_cmd($vm);
	$self->{vmas}->push_nx_state($vm, 'disconnected');
    };
}

sub hkd_action_signal_zombie_vm {
    my ($self, $vm, $state, $event) = @_;
    $self->{vmas}->terminate_vm($vm);
}

sub hkd_action_kill_vm {
    my ($self, $vm, $state, $event) = @_;
    $self->{vmas}->kill_vm($vm);
}

sub hkd_action_update_vma_ok_ts {
    my ($self, $vm, $state, $event) = @_;
    eval {$self->{vmas}->update_vma_ok_ts($vm)}; DEBUG $@ if $@;
}

sub hkd_action_stop_vm {
    my ($self, $vm, $state, $event) = @_;
    my $r = $self->{vmas}->stop_vm($vm);
    if ($r->{request} eq 'error') {
	ERROR ("Stopping VM ".$vm->vm_id." error: ".$r->{error});
    } else {
	INFO ("Stopping VM ".$vm->vm_id." success");
    }
}

sub hkd_action_enter_stopped {
    # Siempre que se entre en este estado desde cualquier otro...
    # * se borrara la entrada vm_runtime.host de la base de datos
    my ($self, $vm, $state, $event) = @_;
    $self->{vmas}->clear_vm_host($vm);
}

sub hkd_action_enter_stopping {
    # Siempre que se pase a este estado desde cualquier otro...
    # * se eliminara cualquier comando de x_cmd
    # * se pone x_state a "Disconnected"
    my ($self, $vm, $state, $event) = @_;
    txn_do {
	# FIXME: $vm comes from the outside!
	$self->{vmas}->push_nx_state($vm, 'disconnected');
	$self->{vmas}->clear_nx_cmd($vm);
    };
}

sub hkd_action_enter_failed {
    # Acciones de entrada
    # * se elimina cualquier comando de vm_cmd
    # * se elimina cualquier comando de x_cmd
    # * se cambia el estado x_state a "Disconnected"
    # * se elimina la entrada vm_runtime.host de la base de datos
    my ($self, $vm, $state, $event) = @_;
    txn_do {
	# FIXME: $vm comes from the outside!
	$self->{vmas}->clear_vm_cmd($vm);
	$self->{vmas}->clear_nx_cmd($vm);
	$self->{vmas}->push_nx_state($vm, 'disconnected');
	$self->{vmas}->clear_vm_host($vm);
    };
}

sub hkd_action_abort {
    my ($self, $vm, $state, $event) = @_;
    # FIXME What's this method supposed to do? See [wiki:NxagentStates]
}

sub hkd_action_start_nx {
    my ($self, $vm, $state, $event) = @_;
    $self->{vmas}->start_vm_listener($vm);
}

sub hkd_action_disconnect_nx {
    my ($self, $vm, $state, $event) = @_;
    $self->{vmas}->disconnect_nx($vm);
}

1;

__END__

=head1 NAME

QVD::HKD - The QVD house-keeping daemon

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    use QVD::HKD;
    my $hkd = QVD::HKD->new;
    $hkd->run;

=head2 API

=over

=item new(loop_wait_time => time)

Construct a new HKD. 

=item run

Run the HKD processing loop.

=back

=head1 AUTHOR

Joni Salonen, C<< <jsalonen at qindel.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Group, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
