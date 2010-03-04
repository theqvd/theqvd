package QVD::HKD2;

use warnings;
use strict;

use QVD::Config;
use QVD::DB::Simple;
use QVD::VMAS;

use Sys::Hostname;
use POSIX ":sys_wait_h";

# FIXME: read nodename from configuration file!
my $host_id = rs(Host)->search(name => hostname)->first->id;

# FIXME: implement a better port allocation strategy
my $port = 2000;
sub _allocate_port { $port++ }

sub _reap_children { 1 while (waitpid(-1, WNOHANG) > 0) }

sub new {
    my ($class, %opts) = @_;
    my $self = {};
    bless $self, $class;
    $self;
}

sub run {
    my $self = shift;

    $self->_reset_timestamps;

    while (1) {
	my @vmrts = rs(VM_Runtime)->search({host_id => $host_id});
	my (@vmrts_need_check);

	for my $vmrt (@vmrts) {
	    my $id = $vmrt->id;
	    my $state = $vmrt->vm_state;
	    my $cmd = $vmrt->vm_cmd;

	    DEBUG "checking vm $id in state $state";

	    next if ($state eq 'failed');

	    if ($state eq 'stopped') {
		if (defined $vm_cmd) {
		    DEBUG "processing command $vm_cmd";
		    txn_eval {
			$self->_discard_changes($vmrt, "process vm_cmd - stopped");
			$self->_clear_vm_cmd($vmrt);
			if ($vm_cmd eq 'start') {
			    DEBUG "starting vm";
			    $self->_start_vm($vmrt);
			}
			else {
			    ERROR "unexpected vm command $vm_cmd received in state stopped";
			}
		    };
		}
		next;
	    }

	    unless ($vmas->check_vm_process($vmrt)) {
		ERROR "vm process has disappeared!, id: $id";
		my $new_state = ($state eq 'stopping' ? 'stopped' : 'failed');
		$self->_set_vm_state($new_state => $vmrt);
		next;
	    }

	    if ($state eq 'starting' or $state eq 'running') {
		my $stopped;
		if (defined $vm_cmd) {
		    DEBUG "processing command $vm_cmd";
		    txn_eval {
			# we dont clear vm_cmd if it is stop and state
			# is starting so it gets delaying until the
			# state is running.
			$self->_discard_changes($vmrt, "process vm_cmd - $state");
			if ($vm_cmd eq 'stop') {
			    if ($state eq 'starting') {
				$self->_clear_vm_cmd($vmrt);
				$self->_stop_vm($vmrt);
				$stopped = 1;
			    }
			}
			else {
			    $self->_clear_vm_cmd($vmrt);
			}
		    };
		}
		push @vmrts_need_check, $vmrt unless $stopped;
		next;
	    }

	    if (defined $vm_cmd) {
		# unqueue any vm command not processed so far
		ERROR "deleting vm command $vm_cmd";
		$self->_clear_vm_cmd;
	    }

	    if ($state eq 'stopping') {
		# FIXME: go zombie on timeout!
		next;
	    }

	    if ($state eq 'zombie') {
		$self->_kill_zombie_vm($vmrt);
	    }
	}

	# code below applies only to machines in state starting or running
	my @vma_response = $vmas->vma_status_parallel(@vmrts_need_check);

	for my $ix (0.. $#vmrts_need_check) {
	    my $vmrt = $vmrts_need_check[$ix];
	    my $status = $vmrt->status;
	    my $id = $vmrt->id;
	    my $vma_response = $vma_response[$ix];
	    my $vma_status = $vma_response->{status};

	    if ($vma_status ne 'ok') {
		my $vma_ok_ts = $vmrt->vma_ok_ts;
		if ($vma_ok_ts + $vma_ok_timeout < time) {
		    # FIXME: check also that the number of consecutive
		    # failed checks goes over some threshold
		    ERROR "machine has not responded for a long time, going zombie!".
		    " id: $id, vma_ok_ts: $vma_ok_ts, time: ".time;
		    $self->_set_vm_state(zombie => $vmrt);

		    next;
		}
		# handle timeouts and consecutive failures.
	    }
	    else {
		$self->_set_vm_state(running => $vmrt)
			if $status eq 'starting';

		$vmrt->update({vma_ok_ts => undef});

		my $old_x_state = $vmrt->x_state;
		my $new_x_state = $vma_response->{x_state} // 'disconnected';

		if ($old_x_state ne $new_x_state) {
		    $self->_set_x_state($new_x_state => $vmrt);
		}
		else {
		    # check x timeout
		    if ($new_x_state eq 'connecting' and
			$vmrt->x_state_ts + x_state_connecting_timeout < time) {
			ERROR "x connecting state timed out! vm id: $id";
			$self->_set_x_state(disconnecting => $vrmt);
		    }
		}

		if (defined($vmrt->x_cmd)) {
		    txn_eval {
			$self->_discard_changes($vmrt, "process vm cmd");
			# reread x_cmd inside the transaction just in case...
			if (defined(my $x_cmd = $vmrt->x_cmd)) {
			    if ($x_cmd eq 'connect') {
				if ($new_x_state eq 'disconnected') {
				    $self->_clear_x_cmd($vmrt);
				    $self->_set_x_state(connecting => $vmrt);
				    $self->_cmd_x_connect($vmrt);
				}
				elsif ($new_x_state ne 'disconnected') {
				    $self->_clear_x_cmd($vmrt);
				}
			    }
			    elsif ($x_cmd eq 'disconnect') {
				$self->_clear_x_cmd($vmrt);
				if (grep $new_x_state eq $_, qw( connecting
								 listening
								 connected )) {
				    $self->_set_x_state(disconnecting => $vrmt);
				    $self->_cmd_x_disconnect($vmrt);
				}
			    }
			}
		    };
		}


		$self->_update_x_timers($vrmt);

		# FIXME: anything else to do? (was x _do event in HKD)

		# FIXME: anything else to do? (was vm _do event in HKD)

		$self->_check_vm_timers($vrmt);

		$self->_check_vm_cmd($vrmt);
	    }
	    else {
		# FIXME: vm is not responding, do something, whatever!!!
	    }
	}
    }
}

sub _discard_changes {
    my ($self, $vm, $message) = @_;
    if ($vm->is_changed()) {
	DEBUG "Detected uncommitted changes in VM ".$vm->vm_id." while $message";
    }
    $vm->discard_changes();
}

sub _set_state {
    my ($self, $type, $state, $vmrt) = @_;
    txn_do {
	my $method = $self->can("enter_${type}_state_${state}");
	$self->_discard_changes($vmrt, "changing to ${type} state $state");
	$method->($self, $vmrt) if $method;
	$vmrt->update({"${type}_state" => $x_state,
		       "${type}_state_ts" => time});
    }
}

sub _set_vm_state { shift->_set_state(vm => @_) }
sub _set_x_state { shift->_set_state(x => @_) }
sub _set_user_state { shift->_set_state(user => @_) }

