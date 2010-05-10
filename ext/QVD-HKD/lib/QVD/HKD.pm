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

my %timeout = ( starting    => cfg(vm_state_starting_timeout,    200),
	        stopping_1  => cfg(vm_state_stopping_1_timeout,   30),
		stopping_2  => cfg(vm_state_stopping_2_timeout,  200),
		zombie_1    => cfg(vm_state_zombie_1_timeout,     30),
		vma         => cfg(vm_state_running_vma_timeout, 120) );

my %cmd = ( kvm     => cfg(shell_command_kvm     => 'kvm'    ),
	    kvm_img => cfg(shell_command_kvm_img => 'kvm-img') );

# FIXME: read nodename from configuration file!
my $this_host_id = rs(Host)->search(name => hostname)->first->id;

# The class QVD::HKD does not have state so we use the class name as
# the object.
#
# sub new { ... }

sub run {
    my $hkd = shift;

    # flag to test VMAs on running machines once every twelve runs
    my $round = 0;

    while (1) {
	DEBUG "HKD run, round: $round";

	$hkd->_reap_children;

	my $check_all = not $round++ % 12;
	$hkd->_check_vms($check_all);

	$hkd->_check_l7rs;

	sleep 2;
    }
}

sub _reap_children { 1 while (waitpid(-1, WNOHANG) > 0) }

sub _check_vms {
    my ($hkd, $check_all) = @_;

    my (@active_vms, @vmas);
    my $par = QVD::ParallelNet->new;

    for my $vm (rs(VM_Runtime)->search({host_id => $this_host_id})) {
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
				$hkd->_assign_vm_ports($vm);
				$hkd->_move_vm_to_state(starting => $vm);
				$vm->clear_vm_cmd;
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
			    when ('running')  {
				$hkd->_move_vm_to_state(stopping_1 => $vm);
				$vm->clear_vm_cmd;
			    }
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
			$vm->clear_vm_cmd;
		    }
		}
	    };
	    $@ and ERROR "vm_cmd processing failed: $@";
	}

	# no error checking is performed here, failed virtual
	# machines startings are captured later or on the next
	# run:
	if ($start) {
	    eval { $hkd->_start_vm($vm) };
	    $@ and ERROR "Unable to start VM: $@";
	}

	next if $vm->vm_state eq 'stopped';

	unless ($hkd->_check_vm_process($vm)) {
	    given ($vm->vm_state) {
		when ('stopping_1') {}
		when ('stopping_2') {
		    WARN "vm process exited without passing through stopping_2"
		}
		default {
		    ERROR "vm process has disappeared!, id: $id";
		    $vm->block;
		}
	    }
	    txn_eval { $hkd->_move_vm_to_state(stopped => $vm) };
	    $@ and ERROR "unable to move VM $id to state stopped";
	    next;
	}

	my $vma_method;
	given ($vm->vm_state) {
	    when('running') {
		no warnings 'uninitialized';
		if ($vm->user_cmd eq 'abort' and $vm->user_state eq 'connected') {
		    # HKD does this on behalf of the contending L7R to
		    # handle the case where the abort is sent using
		    # the administration tools.
		    #
		    # There is a race condition here: if the former
		    # connection closes and the new is stablished
		    # before the message is delivered the new one will
		    # be aborted. This is very unlikely and mostly
		    # harmless, so we didn't care!
		    $vma_method = 'disconnect_session';
		}
		elsif ($check_all) {
		    $vma_method = 'status';
		}
	    }
	    when('starting'  ) { $vma_method = 'status' }
	    when('stopping_1') { $vma_method = 'poweroff' }
	    when('zombie_1'  ) { $hkd->_signal_vm($vm, SIGTERM) }
	    when('zombie_2'  ) { $hkd->_signal_vm($vm, SIGKILL) }
	}

	if (defined $vma_method) {
	    my $vma = QVD::SimpleRPC::Client::Parallel->new($vm->vma_url);
	    $vma->queue_request($vma_method);
	    $par->register($vma);
	    push @vmas, $vma;
	    push @active_vms, $vm;
	}
	else {
	    $hkd->_go_zombie_on_timeout($vm);
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
		    DEBUG "vma_timeout $timeout{vma}, elapsed " . (time - $vma_ok_ts);
		    if (max($^T, $vma_ok_ts) + $timeout{vma} < time) {
			# FIXME: check also that the number of consecutive
			# failed checks goes over some threshold
			ERROR "machine has not responded for a long time (" .
			    (time - $vma_ok_ts) . " seconds), going zombie!" .
				" id: $id, vma_ok_ts: $vma_ok_ts, time: " . time;
			txn_eval { $hkd->_move_vm_to_state(zombie_1 => $vm) };
			$@ and ERROR "unable to move VM to state zombie_1";
		    }
		}
		default {
		    $hkd->_go_zombie_on_timeout($vm);
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
		txn_eval { $hkd->_move_vm_to_state($new_state => $vm) };
		$@ and ERROR "Unable to move VM $id to state $new_state: $@";
	    }
	}
    }
}

sub _check_l7rs {
    my $hkd = shift;
    # check for dissapearing L7Rs processes
    for my $l7r (rs(VM_Runtime)->search({l7r_host => $this_host_id})) {
	$l7r->clear_l7r_all
	    unless $hkd->_check_l7r_process($l7r);
    }
}

sub _go_zombie_on_timeout {
    my ($hkd, $vm) = @_;
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
	    eval { $hkd->_move_vm_to_state($new_state => $vm) };
	    $@ and ERROR "Unable to move VM $id to state $new_state: $@";
	}
    }
}


# FIXME: implement a better port allocation strategy
my $port = 2000;
sub _allocate_port { $port++ }

sub _assign_vm_ports {
    my ($hkd, $vm) = @_;
    $vm->update({vm_address => $vm->host->address,
		 vm_vma_port => $hkd->_allocate_port,
		 vm_x_port => $hkd->_allocate_port,
		 vm_ssh_port => $hkd->_allocate_port,
		 vm_vnc_port => 5900 + $vm->vm_id });
}

# this method must always be called from inside a txn_eval block!!!
sub _move_vm_to_state {
    my ($hkd, $vm_state, $vm) = @_;
    my $old_vm_state = $vm->vm_state;
    my $id = $vm->id;
    DEBUG "move VM $id from state $old_vm_state to $vm_state";

    my $leave = $hkd->can("_leave_vm_state_$old_vm_state");
    # or DEBUG "method _leave_vm_state_$old_vm_state does not exist";
    my $enter = $hkd->can("_enter_vm_state_$vm_state");
    # or DEBUG "method _enter_vm_state_$vm_state does not exist";

    $leave->($hkd, $vm) if $leave;
    $enter->($hkd, $vm) if $enter;
    $vm->set_vm_state($vm_state);
}

sub _leave_vm_state_running {
    my ($hkd, $vm) = @_;
    $vm->clear_vma_ok_ts;
}

sub _enter_vm_state_stopping_1 {
    my ($hkd, $vm) = @_;
    $vm->send_user_abort if $vm->user_state eq 'connecting';
}

sub _enter_vm_state_stopped {
    my ($hkd, $vm) = @_;
    $vm->clear_host_id;
}

sub _enter_vm_state_zombie_1 {
    my ($hkd, $vm) = @_;
    $vm->send_user_abort if $vm->user_state eq 'connecting';
}

sub _start_vm {
    my ($hkd, $vm) = @_;
    my $id = $vm->vm_id;
    my $vma_port = $vm->vm_vma_port;
    my $x_port = $vm->vm_x_port;
    my $ssh_port = $vm->vm_ssh_port;
    my $vnc_display = $vm->vm_vnc_port - 5900;
    my $osi = $vm->rel_vm_id->osi;

    INFO "starting VM $id";

    my @cmd = ($cmd{kvm},
               -m => $osi->memory.'M',
               -vnc => ":${vnc_display}",
               -redir => "tcp:${x_port}::5000",
               -redir => "tcp:${vma_port}::3030",
               -redir => "tcp:${ssh_port}::22");

    my $image = $hkd->_vm_image_path($vm, 1) //
	die "no disk image for vm $id";

    DEBUG "Using image $image for VM $id";
    push @cmd, -hda => $image;

    if (defined $osi->user_storage_size) {
        my $user_storage = $hkd->_vm_user_storage_path($vm, 1) //
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
    my ($hkd, $vm, $create_if_needed) = @_;
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
    my @cmd = ($cmd{kvm_img}, 'create',
               -f => 'qcow2',
               -b => $image,
               $overlay);

    DEBUG "Running @cmd";
    system(@cmd) == 0 and -f $overlay and return $overlay;
    ERROR "Unable to create overlay image $overlay for VM $id ($?)";
    return undef;
}

sub _vm_user_storage_path {
    my ($hkd, $vm, $create_if_needed) = @_;
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

    my @cmd = ($cmd{kvm_img}, 'create',
               -f => 'qcow2',
               $image, "${size}M");
    system(@cmd) == 0 and -f $image and return $image;

    ERROR "Unable to create user storage $image for VM $id";
    return undef;
}

sub _signal_vm {
    my ($hkd, $vm, $signal) = @_;
    my $pid = $vm->vm_pid;
    unless ($pid) {
	DEBUG "later detection of failed VM execution";
	return;
    }
    DEBUG "kill VM process $pid with signal $signal" if $signal;
    kill($signal, $pid);
}

sub _check_vm_process {
    my ($hkd, $vm) = @_;
    $hkd->_signal_vm($vm, 0);
}

sub _check_l7r_process {
    my ($hkd, $vm) = @_;
    my $pid = $vm->l7r_pid;
    unless ($pid) {
	ERROR "internal error, killing process " . ($pid // '<undef>');
	return;
    }
    # DEBUG "kill L7R process $pid with signal 0";
    kill(0, $pid);
}

1;

__END__
o


=head1 NAME

QVD::HKD - The QVD house keeping daemon

=head1 SYNOPSIS

TBD

=head1 DESCRIPTION

The house keeping daemon manages the virtual machines running on a host.

=head1 AUTHOR

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

