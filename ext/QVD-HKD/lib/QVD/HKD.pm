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
use QVD::Log;

my %cmd = ( kvm     => cfg('command.kvm'),
	    kvm_img => cfg('command.kvm-img') );

my %timeout = ( starting    => cfg('internal.hkd.timeout.vm.state.starting'),
	        stopping_1  => cfg('internal.hkd.timeout.vm.state.stopping_1'),
		stopping_2  => cfg('internal.hkd.timeout.vm.state.stopping_2'),
		zombie_1    => cfg('internal.hkd.timeout.vm.state.zombie_1'),
		vma         => cfg('internal.hkd.timeout.vm.state.running') );

my $parallel_net_timeout = cfg('internal.hkd.timeout.vm.vma');

my $pool_time       = cfg('internal.hkd.poll_time');
my $pool_all_mod    = cfg('internal.hkd.poll_all_mod');

my $images_path     = cfg('path.storage.images');
my $overlays_path   = cfg('path.storage.overlays');
my $homes_path      = cfg('path.storage.homes');
my $captures_path   = cfg('path.serial.captures');

my $vm_port_x       = cfg('internal.nxagent.display') + 4000;
my $vm_port_vma     = cfg('internal.vm.port.vma');
my $vm_port_ssh     = cfg('internal.vm.port.ssh');

my $ssh_redirect    = cfg('vm.ssh.redirect');

my $vnc_redirect    = cfg('vm.vnc.redirect');
my $vnc_opts        = cfg('vm.vnc.opts');

my $mon_redirect    = cfg('internal.vm.monitor.redirect');
my $serial_redirect = cfg('vm.serial.redirect');
my $serial_capture  = cfg('vm.serial.capture');

my $persistent_overlay = cfg('vm.overlay.persistent');

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

	$hkd->_check_vms($round++);

	$hkd->_check_l7rs;

	sleep $pool_time;
    }
}

sub _reap_children { 1 while (waitpid(-1, WNOHANG) > 0) }

sub _check_vms {
    my ($hkd, $round) = @_;

    my (@active_vms, @vmas);
    my $par = QVD::ParallelNet->new;

    for my $vm (rs(VM_Runtime)->search({host_id => this_host_id})) {
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
		    $vma_method = 'x_suspend';
		}
		elsif (($round + $id) % $pool_all_mod == 0) {
		    # this pings a few VMs on every round
		    $vma_method = 'ping';
		}
	    }
	    when('starting'  ) { $vma_method = 'ping' }
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

    $par->run(time => $parallel_net_timeout) if @active_vms;

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
    for my $l7r (rs(VM_Runtime)->search({l7r_host => this_host_id})) {
	unless ($hkd->_check_l7r_process($l7r)) {
	    WARN "clean dead L7R process for VM " . $l7r->id;
	    $l7r->clear_l7r_all;
	}
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

    my @ports = ( vm_vma_port => $hkd->_allocate_port,
		  vm_x_port   => $hkd->_allocate_port);

    push @ports, vm_ssh_port    => $hkd->_allocate_port if $ssh_redirect;
    push @ports, vm_vnc_port    => $hkd->_allocate_port if $vnc_redirect;
    push @ports, vm_serial_port => $hkd->_allocate_port if $serial_redirect;
    push @ports, vm_mon_port    => $hkd->_allocate_port if $mon_redirect;
    $vm->update({vm_address => $vm->host->address, @ports });
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
    $vm->unassign;
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
    my $vnc_port = $vm->vm_vnc_port;
    my $ssh_port = $vm->vm_ssh_port;
    my $serial_port = $vm->vm_serial_port;
    my $mon_port = $vm->vm_mon_port;
    my $osi = $vm->rel_vm_id->osi;
    my $address = $vm->vm_address;
    my $name = rs(VM)->find($vm->vm_id)->name;

    INFO "starting VM $id";

    my @cmd = ($cmd{kvm},
               -m => $osi->memory.'M',
               -redir => "tcp:${x_port}::${vm_port_x}",
               -redir => "tcp:${vma_port}::${vm_port_vma}",
               -redir => "tcp:${ssh_port}::${vm_port_ssh}");

    my $redirect_io = $serial_capture;
    if (defined $serial_port) {
        push @cmd, -serial => "telnet::$serial_port,server,nowait,nodelay";
        undef $redirect_io;
    }

    if ($redirect_io) {
        mkdir $captures_path, 0700;
        -d $captures_path or die "directory $captures_path does not exist\n";
        my @t = gmtime; $t[5] += 1900; $t[4] += 1;
        my $ts = sprintf("%04d-%02d-%02d-%02d:%02d:%2d-GMT0", @t[5,4,3,2,1,0]);
        push @cmd, -serial => "file:$captures_path/capture-$name-$ts.txt";
    }

    if ($vnc_port) {
        my $vnc_display = $vnc_port - 5900;
        $vnc_display .= ",$vnc_opts" if $vnc_opts =~ /\S/;
        push @cmd, -vnc => ":$vnc_display";
    }
    else {
        push @cmd, '-nographic';
    }

    if (defined $mon_port) {
	push @cmd, -monitor, "telnet::$mon_port,server,nowait,nodelay";
    }

    my $image = $hkd->_vm_image_path($vm) //
	die "no disk image for vm $id";

    DEBUG "Using image $image for VM $id";
    push @cmd, -hda => $image;

    if (defined $osi->user_storage_size) {
        my $user_storage = $hkd->_vm_user_storage_path($vm) //
            die "no user storage for vm $id";

	DEBUG "Using user storage $user_storage for VM $id";
        push @cmd, -hdb => $user_storage;
    }

    DEBUG "running @cmd";
    my $pid = fork;
    unless ($pid) {
	$pid // die "unable to fork virtual machine process";
        eval {
            open STDOUT, '>', '/dev/null' or die "can't redirect STDOUT to /dev/null\n";
            open STDERR, '>&', STDOUT or die "can't redirect STDERR to STDOUT\n";
            open STDIN, '<', '/dev/null' or die "can't open /dev/null\n";
            exec @cmd or die "exec failed\n";
        };
	ERROR "Unable to start VM: $@";
	POSIX::_exit(1);
    }
    DEBUG "kvm pid: $pid\n";
    $vm->set_vm_pid($pid);
}

sub _vm_image_path {
    my ($hkd, $vm) = @_;
    my $id = $vm->id;
    my $osi = $vm->rel_vm_id->osi;
    my $osiid = $osi->id;
    my $image = "$images_path/".$osi->disk_image;

    unless (-f $image) {
	ERROR "Image $image attached to VM $id does not exist on disk";
	return undef;
    }
    return $image unless $osi->use_overlay;

    # FIXME: use a better policy for overlay allocation
    my $overlay = "$overlays_path/$osiid-$id-overlay.qcow2";
    if (-f $overlay) {
        return $overlay if ($persistent_overlay);
        # FIXME: save old overlay for later inspection
        unlink $overlay;
    }

    # FIXME: use a relative path to the base image?
    #my $image_relative = File::Spec->abs2rel($image, $overlays_path);
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
    my ($hkd, $vm) = @_;
    my $id = $vm->id;
    my $osi = $vm->rel_vm_id->osi;
    my $size = $osi->user_storage_size // return undef;

    my $image = "$homes_path/$id-data.qcow2";
    return $image if -f $image;

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

FIXME write the synopsis

=head1 DESCRIPTION

The house keeping daemon manages the virtual machines running on a host.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
