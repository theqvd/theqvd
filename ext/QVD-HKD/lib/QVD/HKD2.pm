package QVD::HKD;

use warnings;
use strict;

use feature 'switch';
use QVD::Config;
use QVD::DB::Simple;
use QVD::ParallelNet;
use QVD::SimpleRPC::Client;
use QVD::SimpleRPC::Client::Parallel;

use Sys::Hostname;
use POSIX qw(:sys_wait_h SIGTERM SIGKILL);
use List::Util qw(max);
use POSIX;

use Log::Log4perl qw(:levels :easy);
Log::Log4perl::init('log4perl.conf');

my %timeout = ( starting   => cfg(vm_state_starting_timeout,   200),
	        stopping_1 => cfg(vm_state_stopping_1_timeout,  30),
		stopping_2 => cfg(vm_state_stopping_1_timeout, 200),
		zombie_1   => cfg(vm_state_zombie_1_timeout,    30) );

# FIXME: read nodename from configuration file!
my $this_host_id = rs(Host)->search(name => hostname)->first->id;

sub _reap_children { 1 while (waitpid(-1, WNOHANG) > 0) }

sub new {
    my ($class, %opts) = @_;
    my $self = {};
    bless $self, $class;
    $self;
}

sub run {
    my $self = shift;

    my $vma_ok_timeout = cfg(vm_state_running_vma_timeout); 
    my $x_connecting_timeout = cfg(x_state_connecting_timeout);

    my $round = 0;

    while (1) {
	DEBUG "HKD run, round: $round";

	$self->_reap_children;

	my $par = QVD::ParallelNet->new;

	my @vms = rs(VM_Runtime)->search({host_id => $this_host_id});
	my (@active_vms, @vmas);

	for my $vm (@vms) {
	    my $id = $vm->id;

	    # Command processing...
	    my $start;
	    if (defined $vm->vm_cmd) {
		txn_eval {
		    $vm->discard_changes;
		    given($vm->vm_cmd) {
			when('start') {
			    given($vm->vm_state) {
				when ('stopped') {
				    $self->_assign_vm_ports($vm);
				    $self->_move_vm_to_state(starting => $vm);
				    $start = 1;
				}
				default {
				    ERROR "unexpected VM command start received in state $_";
				    $vm->clear_vm_cmd;
				}
			    }
			}
			when('stop') {
			    given($vm->vm_state) {
				when ('running')  { $self->_move_vm_to_state(stopping_1 => $vm) }
				when ('starting') { } # stop is delayed!
				default {
				    ERROR "unexpected VM command stop received in state $_";
				    $vm->clear_vm_cmd;
				}
			    }
			}
			when(undef) {
			    DEBUG "command dissapeared";
			}
			default {
			    ERROR "unexpected VM command $_ received in state " . $vm->vm_state;
			}
		    }
		};
		$@ and ERROR "vm_cmd processing failed: $@";
	    }

	    # no error checking is performed here, failed virtual
	    # machines startings are captured later or on the next
	    # run:
	    if ($start) {
		eval { $self->_start_vm($vm) };
		$@ and ERROR "Unable to start VM: $@";
	    }

	    next if $vm->vm_state eq 'stopped';

	    unless ($self->_check_vm_process($vm)) {
		if ($vm->vm_state ne 'stopping') {
		    ERROR "vm process has disappeared!, id: $id";
		    $vm->block;
		}
		txn_eval { $self->_move_vm_to_state(stopped => $vm) };
		$@ and ERROR "unable to move VM $id to state stopped";

		next;
	    }

	    my $vma_method;
	    given ($vm->vm_state) {
		when('running'   ) { $vma_method = 'status' unless $round }
		when('starting'  ) { $vma_method = 'status' }
		when('stopping_1') { $vma_method = 'poweroff' }
		when('zombie_1'  ) { $self->_signal_vm($vm, SIGTERM) }
		when('zombie_2'  ) { $self->_signal_vm($vm, SIGKILL) }
	    }

	    if (defined $vma_method) {
		my $vma = QVD::SimpleRPC::Client::Parallel->new($vm->vma_url);
		$vma->queue_request($vma_method);
		$par->register($vma);
		push @vmas, $vma;
		push @active_vms, $vm;
	    }
	    else {
		$self->_go_zombie_on_timeout($vm);
	    }
	}

	$par->run(time => 2) if @active_vms;

	while (@active_vms) {
	    my $vm = shift @active_vms;
	    my $vma = shift @vmas;
	    my $id = $vm->id;
	    eval { $vma->unqueue_response };
	    if ($@) {
		DEBUG "VMA call in VM $id failed: $@";
		given ($vm->vm_state) {
		    when('running') {
			my $vma_ok_ts = $vm->vma_ok_ts;
			DEBUG "vma_timeout $vma_ok_timeout, elapsed " . (time - $vma_ok_ts);
			if (max($^T, $vma_ok_ts) + $vma_ok_timeout < time) {
			    # FIXME: check also that the number of consecutive
			    # failed checks goes over some threshold
			    ERROR "machine has not responded for a long time (" .
				(time - $vma_ok_ts) . " seconds), going zombie!" .
				    " id: $id, vma_ok_ts: $vma_ok_ts, time: " . time;
			    txn_eval { $self->_move_vm_to_state(zombie => $vm) };
			    $@ and ERROR "unable to move VM to state zombie";
			}
		    }
		    default {
			$self->_go_zombie_on_timeout($vm);
		    }
		}
	    }
	    else {
		$vm->update_vma_ok_ts;

		my $new_state;
		given ($vm->vm_state) {
		    when ('starting')   { $new_state = 'running' }
		    when ('stopping_1') { $new_state = 'stopping_2' }
		}
		if (defined $new_state) {
		    txn_eval { $self->_move_vm_to_state($new_state => $vm) };
		    $@ and ERROR "Unable to move VM $id to state $new_state: $@";
		}
	    }
	}

	# check for dissapearing L7Rs processes
	my @l7rs = rs(VM_Runtime)->search({l7r_host => $this_host_id});
	for (@l7rs) {
            $_->clear_l7r_all
                unless $self->_check_l7r_process($_);
        }

	# flag to test VMAs on running machines once every twelve runs
	$round = (($round + 1) % 12);
	sleep 2;
    }
}

sub _go_zombie_on_timeout {
    my ($self, $vm) = @_;
    my $vm_state = $vm->vm_state;
    my $id = $vm->id;
    my $timeout = $timeout{$vm_state};
    if (defined $timeout) {
	my $vm_state_ts = $vm->vm_state_ts;
	DEBUG "timeout in state $vm_state is $timeout, elapsed "
	    . (time - $vm_state_ts);
	if (max($^T, $vm_state_ts) + $timeout < time) {
	    ERROR "vm staled in state $vm_state,".
		" id: $id, state_ts: $vm_state_ts, time: ".time;
	    my $new_state = ($vm_state eq 'zombie_1' ? 'zombie_2' : 'zombie_1');
	    eval { $self->_move_vm_to_state($new_state => $vm) };
	    $@ and ERROR "Unable to move VM $id to state $new_state: $@";
	}
    }
}


# FIXME: implement a better port allocation strategy
my $port = 2000;
sub _allocate_port { $port++ }

sub _assign_vm_ports {
    my ($self, $vm) = @_;
    $vm->update({vm_address => $vm->host->address,
		 vm_vma_port => $self->_allocate_port,
		 vm_x_port => $self->_allocate_port,
		 vm_ssh_port => $self->_allocate_port,
		 vm_vnc_port => 5900 + $vm->vm_id });
}

# this method must always be called from inside a txn_eval block!!!
sub _move_vm_to_state {
    my ($self, $vm_state, $vm) = @_;
    my $old_vm_state = $vm->vm_state;
    my $id = $vm->id;
    DEBUG "move VM $id from state $old_vm_state to $vm_state";

    my $leave = $self->can("_leave_vm_state_$old_vm_state")
	or DEBUG "method _leave_vm_state_$old_vm_state does not exist";
    my $enter = $self->can("_enter_vm_state_$vm_state")
	or DEBUG "method _enter_vm_state_$vm_state does not exist";

    $leave->($self, $vm) if $leave;
    $enter->($self, $vm) if $enter;
    $vm->set_vm_state($vm_state);
}

sub _leave_vm_state_running {
    my ($self, $vm) = @_;
    $vm->clear_vma_ok_ts;
}

### do-nothing callbacks commented out:

# sub _enter_vm_state_starting {
#     my ($self, $vm) = @_;
#     # FIXME!
# }
# sub _enter_vm_state_running {
#     my ($self, $vm) = @_;
#     # FIXME!
# }

sub _enter_vm_state_stopping {
    my ($self, $vm) = @_;
    # Siempre que se pase a este estado desde cualquier otro...
    # * se eliminara cualquier comando de x_cmd
    # * se pone x_state a "Disconnected"
    $vm->set_x_state('disconnected');
    $vm->clear_x_cmd;
}

sub _enter_vm_state_stopped {
    my ($self, $vm) = @_;
    $vm->set_x_state('disconnected');
    $vm->clear_x_cmd($vm);
    $vm->clear_vm_cmd;
    $vm->clear_host_id;
}

sub _enter_vm_state_zombie {
    my ($self, $vm) = @_;
    # Siempre que se pase a este estado desde cualquier otro...
    # * se elimina cualquier comando de vm_cmd
    # * se elimina cualquier comando de x_cmd
    # * se cambia el estado x_state a "Disconnected" 
    $vm->set_x_state('disconnected');
    $vm->clear_vm_cmd;
    $vm->clear_x_cmd;
}

sub _enter_vm_state_failed {
    my ($self, $vm) = @_;
    DEBUG "vm enter state failed";
    # Acciones de entrada
    # * se elimina cualquier comando de vm_cmd
    # * se elimina cualquier comando de x_cmd
    # * se cambia el estado x_state a "Disconnected"
    # * se elimina la entrada vm_runtime.host de la base de datos
    $vm->set_x_state('disconnected');
    $vm->clear_x_cmd;
    $vm->clear_vm_cmd;
    $vm->clear_host_id;
}

sub _start_vm {
    my ($self, $vm) = @_;
    my $id = $vm->vm_id;
    my $vma_port = $vm->vm_vma_port;
    my $x_port = $vm->vm_x_port;
    my $ssh_port = $vm->vm_ssh_port;
    my $vnc_display = $vm->vm_vnc_port - 5900;
    my $osi = $vm->rel_vm_id->osi;

    INFO "starting VM $id";

    my @cmd = ('kvm',
               -m => $osi->memory.'M',
               -vnc => ":${vnc_display}",
               -redir => "tcp:${x_port}::5000",
               -redir => "tcp:${vma_port}::3030",
               -redir => "tcp:${ssh_port}::22");

    my $image = $self->_vm_image_path($vm, 1) //
	die "no disk image for vm $id";

    DEBUG "Using image $image for VM $id";
    push @cmd, -hda => $image;

    if (defined $osi->user_storage_size) {
        my $user_storage = $self->_vm_user_storage_path($vm, 1) //
            die "no user storage for vm $id";

	DEBUG "Using user storage $user_storage for VM $id";
        push @cmd, -hdb => $user_storage;
    }

    my $pid = fork;
    unless ($pid) {
	$pid // die "unable to fork virtual machine process";
	do { exec  @cmd };
	ERROR "exec @cmd failed\n";
	POSIX::_exit(1);
    }
    DEBUG "kvm pid: $pid\n";
    $vm->set_vm_pid($pid);
}

sub _vm_image_path {
    my ($self, $vm, $create_if_needed) = @_;
    my $id = $vm->id;
    my $osi = $vm->rel_vm_id->osi;
    my $osiid = $osi->id;
    my $image = cfg(ro_storage_path).'/'.$osi->disk_image;

    unless (-f $image) {
	ERROR "Image $image attached to VM $id does not exist on disk";
	return undef;
    }
    return $image unless $osi->use_overlay;

    # FIXME: use a better policy for overlay allocation
    my $overlay_dir = cfg(rw_storage_path);
    my $overlay = "$overlay_dir/$osiid-$id-overlay.qcow2";
    return $overlay if -f $overlay;

    unless ($create_if_needed) {
        ERROR "Image overlay $overlay attached to VM $id does not exist on disk";
        return undef;
    }

    # FIXME: use a relative path to the base image?
    #my $image_relative = File::Spec->abs2rel($image, $overlay_dir);
    my @cmd = (cfg(kvm_img_command => 'kvm-img'),
               'create',
               -f => 'qcow2',
               -b => $image,
               $overlay);

    DEBUG "Running @cmd";
    system(@cmd) == 0 and -f $overlay and return $overlay;
    ERROR "Unable to create overlay image $overlay for VM $id ($?)";
    return undef;
}

sub _vm_user_storage_path {
    my ($self, $vm, $create_if_needed) = @_;
    my $id = $vm->id;
    my $osi = $vm->rel_vm_id->osi;
    my $size = $osi->user_storage_size // return undef;

    my $home = cfg('home_storage_path');
    my $image = "$home/$id-data.qcow2";
    return $image if -f $image;

    unless ($create_if_needed) {
        ERROR "User storage $image attached to VM $id does not exist on disk";
        return undef;
    }

    my @cmd = (cfg(kvm_img_command => 'kvm-img'),
               'create',
               -f => 'qcow2',
               $image, "${size}M");
    system(@cmd) == 0 and -f $image and return $image;

    ERROR "Unable to create user storage $image for VM $id";
    return undef;
}

sub _signal_vm {
    my ($self, $vm, $signal) = @_;
    my $pid = $vm->vm_pid;
    DEBUG "kill process $pid with signal $signal";
    kill($signal, $pid);
}

sub _check_vm_process {
    my ($self, $vm) = @_;
    $self->_signal_vm($vm, 0);
}

sub _check_l7r_process {
    my ($self, $vm) = @_;
    my $pid = $vm->l7r_pid;
    kill(0, $pid);
}

1;
