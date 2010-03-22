package QVD::HKD;

use warnings;
use strict;

use QVD::Config;
use QVD::DB::Simple;
use QVD::VMAS;

use Sys::Hostname;
use POSIX qw(:sys_wait_h SIGTERM SIGKILL);
use List::Util qw(max);

use Log::Log4perl qw(:levels :easy);
Log::Log4perl::init('log4perl.conf');

# FIXME: read nodename from configuration file!
my $host_id = rs(Host)->search(name => hostname)->first->id;

sub _reap_children { 1 while (waitpid(-1, WNOHANG) > 0) }

sub new {
    my ($class, %opts) = @_;
    my $self = {};
    bless $self, $class;
    $self;
}

my %timeout = ( starting => cfg(vm_state_starting_timeout),
	        stopping => cfg(vm_state_stopping_timeout) );

my $vm_state_zombie_sigkill_timeout = cfg(vm_state_zombie_sigkill_timeout);

sub run {
    my $self = shift;
    my $vmas = QVD::VMAS->new;
    $self->{vmas} = $vmas; # FIXME: remove vmas usage

    my $start_time = time;
    $self->_reset_timestamps;

    my $vma_ok_timeout = cfg(vm_state_running_vma_timeout); 
    my $x_connecting_timeout = cfg(x_state_connecting_timeout);

    while (1) {
	$self->_reap_children;

	my @vmrts = rs(VM_Runtime)->search({host_id => $host_id});
	my (@vmrts_need_check);

	for my $vmrt (@vmrts) {
	    my $id = $vmrt->id;
	    my $vm_state = $vmrt->vm_state;
	    my $vm_cmd = $vmrt->vm_cmd;

	    DEBUG "checking vm $id in state $vm_state";

	    next if ($vm_state eq 'failed');

	    if ($vm_state eq 'stopped') {
		if (defined $vm_cmd) {
		    DEBUG "processing command $vm_cmd";
		    local $@;
		    txn_eval {
			$self->_discard_changes($vmrt, "process vm_cmd - stopped");
			$self->_clear_vm_cmd($vmrt);
			if ($vm_cmd eq 'start') {
			    DEBUG "starting vm";
			    $self->_assign_vm_ports($vmrt);
			    $vmas->start_vm($vmrt);
			    $self->_move_vm_to_state(starting => $vmrt);
			}
			else {
			    ERROR "unexpected vm command $vm_cmd received in state stopped";
			}
		    };
		    $@ and ERROR "txn_eval failed: $@";
		}
		next;
	    }

	    unless ($vmas->check_vm_process($vmrt)) {
		ERROR "vm process has disappeared!, id: $id";
		my $new_state = ($vm_state eq 'stopping' ? 'stopped' : 'failed');
		$self->_move_vm_to_state($new_state => $vmrt);
		next;
	    }


	    if (defined(my $timeout = $timeout{$vm_state})) {
		my $vm_state_ts = $vmrt->vm_state_ts;
		WARN "timeout in state $vm_state is $timeout, elapsed "
		    . (time - $vm_state_ts);

		if ((max($start_time, $vm_state_ts) + $timeout < time) {
		    ERROR "vm staled in state $vm_state,".
			" id: $id, state_ts: $vm_state_ts, time: ".time;
		    $self->_move_vm_to_state(zombie => $vmrt);
		    next;
		}
	    }

	    if ($vm_state eq 'starting' or $vm_state eq 'running') {
		my $stopped;
		if (defined $vm_cmd) {
		    DEBUG "processing command $vm_cmd";
		    txn_eval {
			# we dont clear vm_cmd if it is stop and state
			# is starting so it gets delaying until the
			# state is running.
			$self->_discard_changes($vmrt, "process vm_cmd - $vm_state");
			$vm_state = $vmrt->vm_state;
			$vm_cmd = $vmrt->vm_cmd;
			if ($vm_cmd eq 'stop') {
			    if ($vm_state eq 'running') {
				$self->_clear_vm_cmd($vmrt);
				$self->{vmas}->stop_vm($vmrt);
				$self->_move_vm_to_state(stopping => $vmrt);
				$stopped = 1;
			    }
			    elsif ($vm_state ne 'starting') {
				ERROR "command $vm_cmd received in state $vm_state";
				$self->_clear_vm_cmd($vmrt);
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

	    if ($vm_state eq 'zombie') {
		my $vm_state_ts = $vmrt->vm_state_ts;
		my $force = (max($start_time, $vm_state_ts)
			       + $vm_state_zombie_sigkill_timeout < time);
		$self->_kill_zombie_vm($vmrt, $force);
		next;
	    }
	}

	# code below applies only to machines in state starting or running
	my @vma_response = $vmas->vma_status_parallel(@vmrts_need_check);

	for my $ix (0.. $#vmrts_need_check) {
	    my $vmrt = $vmrts_need_check[$ix];
	    my $vm_state = $vmrt->vm_state;
	    my $id = $vmrt->id;
	    my $vma_response = $vma_response[$ix];
	    my $vma_status = $vma_response->{status};

	    use Data::Dumper;
	    warn Data::Dumper->Dump([$vma_response], ['vma_response']);

	    if (!defined $vma_status or $vma_status ne 'ok') {
		if ($vm_state eq 'running') {
		    my $vma_ok_ts = $vmrt->vma_ok_ts;
		    DEBUG "vma_timeout $vma_ok_timeout, elapsed " . (time - $vma_ok_ts);
		    if (max($start_time, $vma_ok_ts) + $vma_ok_timeout < time) {
			# FIXME: check also that the number of consecutive
			# failed checks goes over some threshold
			ERROR "machine has not responded for a long time ($elapsed seconds), going zombie!".
			    " id: $id, vma_ok_ts: $vma_ok_ts, time: ".time;
			$self->_move_vm_to_state(zombie => $vmrt);
		}
		# else just go on until timeout or ok
	    }
	    else {
		$self->_move_vm_to_state(running => $vmrt)
			if $vm_state eq 'starting';

		$vmrt->update({vma_ok_ts => time});

		my $old_x_state = $vmrt->x_state;
		my $new_x_state = $vma_response->{x_state} // 'disconnected';

		if ($old_x_state ne $new_x_state) {
		    $self->_move_x_to_state($new_x_state => $vmrt);
		}
		else {
		    # check x timeout
		    if ($new_x_state eq 'connecting' and
			max($start_time, $vmrt->x_state_ts) + $x_connecting_timeout < time) {
			ERROR "x connecting state timed out! vm id: $id";
			$self->_move_x_to_state(disconnecting => $vmrt);
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
				    $self->_move_x_to_state(connecting => $vmrt);
				    $self->{vmas}->start_vm_listener($vmrt)->{request} eq 'success'
					or die "unable to start listener: $@";
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
				    $self->_move_x_to_state(disconnecting => $vmrt);
				    $self->_cmd_x_disconnect($vmrt);
				}
			    }
			}
		    };
		}
	    }
	}
	sleep 5;
    }
}

# FIXME: implement a better port allocation strategy
my $port = 2000;
sub _allocate_port { $port++ }

sub _assign_vm_ports {
    my ($self, $vmrt) = @_;
    $vmrt->update({vm_address => $vmrt->host->address,
		   vm_vma_port => $self->_allocate_port,
		   vm_x_port => $self->_allocate_port,
		   vm_ssh_port => $self->_allocate_port,
		   vm_vnc_port => 5900 + $vmrt->vm_id });
}


sub _clear_vm_cmd {
    # FIXME: move this to the model
    my ($self, $vmrt) = @_;
    WARN "clear_vm_cmd called";
    $vmrt->update({vm_cmd => undef});
}

sub _clear_x_cmd {
    # FIXME: move this to the model
    my ($self, $vmrt) = @_;
    WARN "clear_x_cmd called";
    $vmrt->update({x_cmd => undef});
}

sub _reset_timestamps {
    $vm->
    # FIXME
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
    DEBUG "move $type to state $state";

    my $old_state = ($type eq 'vm' ? $vmrt->vm_state :
		     $type eq 'x'  ? $vmrt->x_state  :
		     die "bad type $type");
    my $leave_name = "_leave_${type}_${old_state}";
    my $leave = $self->can($leave_name)
	or DEBUG "method $leave_name does not exist";

    my $enter_name = "_enter_${type}_state_${state}";
    my $enter = $self->can($enter_name)
	or DEBUG "method $enter_name does not exist";

    txn_do {
	$leave->($self, $vmrt) if $leave;
	$enter->($self, $vmrt) if $enter;
	$vmrt->update({"${type}_state" => $state,
		       "${type}_state_ts" => time});
    }
}

sub _move_vm_to_state { shift->_set_state(vm => @_) }
sub _move_x_to_state { shift->_set_state(x => @_) }
# sub _set_user_state { shift->_set_state(user => @_) }

sub _leave_vm_state_running {
    my ($self, $vmrt) = @_;
    $vmrt->update({vma_ts_ok => undef});
}

### do-nothing callbacks commented out:

# sub _enter_vm_state_starting {
#     my ($self, $vmrt) = @_;
#     my $vmas = $self->{vmas};
#     # FIXME!
# }
# sub _enter_vm_state_running {
#     my ($self, $vmrt) = @_;
#     my $vmas = $self->{vmas};
#     # FIXME!
# }

sub _enter_vm_state_stopping {
    my ($self, $vmrt) = @_;
    my $vmas = $self->{vmas};
    # Siempre que se pase a este estado desde cualquier otro...
    # * se eliminara cualquier comando de x_cmd
    # * se pone x_state a "Disconnected"
    $vmas->push_nx_state($vmrt, 'disconnected');
    $vmas->clear_nx_cmd($vmrt);
}

sub _enter_vm_state_stopped {
    my ($self, $vmrt) = @_;
    my $vmas = $self->{vmas};
    $vmas->clear_nx_cmd($vmrt);
    $vmas->push_nx_state($vmrt, 'disconnected');
    $vmas->clear_vm_cmd($vmrt);
    $vmas->clear_vm_host($vmrt);
}

sub _enter_vm_state_zombie {
    my ($self, $vmrt) = @_;
    my $vmas = $self->{vmas};
    # Siempre que se pase a este estado desde cualquier otro...
    # * se elimina cualquier comando de vm_cmd
    # * se elimina cualquier comando de x_cmd
    # * se cambia el estado x_state a "Disconnected" 
    $vmas->clear_vm_cmd($vmrt);
    $vmas->clear_nx_cmd($vmrt);
    $vmas->push_nx_state($vmrt, 'disconnected');
}

sub _enter_vm_state_failed {
    my ($self, $vmrt) = @_;
    my $vmas = $self->{vmas};
    DEBUG "vm enter state failed";
    # Acciones de entrada
    # * se elimina cualquier comando de vm_cmd
    # * se elimina cualquier comando de x_cmd
    # * se cambia el estado x_state a "Disconnected"
    # * se elimina la entrada vm_runtime.host de la base de datos
    $vmas->clear_nx_cmd($vmrt);
    $vmas->push_nx_state($vmrt, 'disconnected');
    $vmas->clear_vm_cmd($vmrt);
    $vmas->clear_vm_host($vmrt);
    DEBUG "vm enter state failed - ok";
}

sub _kill_zombie_vm {
    my ($self, $vmrt, $force) = @_;
    my $pid = $vmrt->vm_pid;
    my $signal = ($force ? SIGKILL : SIGTERM);
    DEBUG "kill process $pid with signal $signal";
    kill($signal, $pid) if defined $pid;
}

