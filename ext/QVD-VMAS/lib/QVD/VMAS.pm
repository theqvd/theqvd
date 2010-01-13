package QVD::VMAS;

use warnings;
use strict;

use QVD::DB::Simple;
use QVD::VMAS::VMAClient;
use QVD::VMAS::RCClient;
use QVD::Config;
use File::Slurp qw(slurp);

use Log::Log4perl qw/:easy/;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    bless {}, $class;
}

sub _get_kvm_pid_file_path {
    my ($self, $id) = @_;
    # FIXME: no hard coded paths
    "/var/run/qvd/vm-$id.pid"
}

sub _signal_kvm {
    my ($self, $id, $signal) = @_;
    # FIXME: get the pid from the database!
    my $pid = eval { slurp $self->_get_kvm_pid_file_path($id) };
    return undef unless defined $pid;
    chomp $pid;
    kill($signal, $pid);
}

sub is_vm_running {
    my ($self, $vm) = @_;
    $self->_signal_kvm($vm->vm_id, 0)
}

sub _get_vma_client_for_vm {
    my ($self, $vm_runtime) = @_;
    QVD::VMAS::VMAClient->new($vm_runtime->vm_address, $vm_runtime->vm_vma_port)
}

sub get_vm_runtime_for_vm_id {
    my ($self, $vm_id) = @_;
    my $vms = rs(VM_Runtime)->search({vm_id => $vm_id})->first;
    return $vms;
}

sub get_vms_for_host {
    my ($self, $host_id) = @_;
    return rs(VM_Runtime)->search({host_id => $host_id});
}

sub get_vm_ids_for_host {
    my $self = shift;
    map $_->vm_id, $self->get_vms_for_host(@_);
}

sub get_vms_for_user {
    my ($self, $user_id) = @_;
    map {
	my $rt = $_->vm_runtime;
	ERROR "Corrupted database: virtual machine misses entry at vm_runtime"
	    unless defined $rt;
	$rt;
    } rs(VM)->search({'user_id' => $user_id});
}

sub _load_balance_random {
    my @hosts = rs(Host);
    $hosts[rand @hosts];
}

sub _get_free_host {
    my ($self, $vm) = @_;
    my $algorithm = QVD::Config->get('vmas_load_balance_algorithm');
    my $load_balancer = $self->can('_load_balance_'.$algorithm);
    unless ($load_balancer) {
	ERROR "Load balance algorithm '$algorithm' is not implemented";
	return undef;
    }
    $self->$load_balancer($vm)
}

sub assign_host_for_vm {
    my ($self, $vm, $preferred_host_id) = @_;
    my $vm_id = $vm->vm_id;
    my $host;
    $host = rs(Host)->find($preferred_host_id)
	if defined $preferred_host_id;
    $host //= $self->_get_free_host($vm) // die "Unable to assign VM $vm_id a host";
    # txn_do {
	# FIXME: this is the wrong place to start the transaction
	# as $vm has probably been already retrieved from the
	# database
	defined $vm->host_id
	    and die "VM $vm_id is already assigned to a host";
	$vm->update({host_id => $host->id, 
		     vm_address => $host->address,
		     vm_vma_port => QVD::Config->get('vm_vma_port')+$vm_id,
		     vm_x_port => QVD::Config->get('vm_x_port')+$vm_id,
		     vm_ssh_port => QVD::Config->get('vm_ssh_port')+$vm_id,
		     vm_vnc_port => QVD::Config->get('vm_vnc_port')+$vm_id });
    # };
}

sub push_vm_state {
    my ($self, $vm, $vm_state) = @_;
    $vm->update({ vm_state => $vm_state, vm_state_ts => time });
}

sub push_nx_state {
    my ($self, $vm, $x_state) = @_;
    $vm->update({ x_state => $x_state, x_state_ts => time });
}

sub push_user_state {
    my ($self, $vm, $state) = @_;
    $vm->update({ user_state => $state, user_state_ts => time });
}

sub _schedule_cmd {
    my ($self, $vm, $cmd_type, $cmd) = @_;
    txn_do {
	$vm->discard_changes;
	return undef if (defined $vm->$cmd_type and $vm->$cmd_type ne $cmd);
	$vm->update({$cmd_type => $cmd});
	DEBUG "Accepted command $cmd_type $cmd for VM " . $vm->vm_id;
	return 1;
    };
}

sub schedule_x_cmd {
    my ($self, $vm, $cmd) = @_;
    return $self->_schedule_cmd($vm, 'x_cmd', $cmd);
}

sub schedule_user_cmd {
    my ($self, $vm, $cmd) = @_;
    return $self->_schedule_cmd($vm, 'user_cmd', $cmd);
}

sub start_vm_listener {
    my ($self, $vm) = @_;
    my $id = $vm->vm_id;
    my $vma_client = $self->_get_vma_client_for_vm($vm);
    eval { $vma_client->start_vm_listener };
    if ($@) {
	return { request => 'error', 'error' => $@ };
    } else {
	my $agent_port = $vm->vm_x_port;
	return { request => 'success', host => 'localhost', 'port' => $agent_port };
    }
}

sub notify_hkd {
    my ($self, $vm) = @_;
    my $host = $vm->host->address;
    my $rc = QVD::VMAS::RCClient->new($host);
    my $r = eval { $rc->ping_hkd() };
    if (defined $r && $r->{request} eq 'success') {
	return 1;
    } else {
	my $err = $@ // $r->{error};
	die "Unable to notify hkd on ".$host
	." to start VM ".$vm->vm_id.": ".$err;
    }
}

sub schedule_start_vm {
    my ($self, $vm) = @_;
    txn_do {
	$vm->discard_changes;
	my $vm_id = $vm->vm_id;
	defined $vm->host_id
	    or die "Unable to schedule start command: VM $vm_id is not assigned to any host";
	$self->_schedule_cmd($vm, 'vm_cmd', 'start')
		or die "Unable to schedule start command";
    };
}

sub schedule_stop_vm {
    my ($self, $vm) = @_;
    $self->_schedule_cmd($vm, 'vm_cmd', 'stop')
	or die "Unable to schedule stop command";
}

sub _get_image_for_vm {
    my ($self, $vm) = @_;
    my $osi = $vm->rel_vm_id->osi;
    my $rw_dir = QVD::Config->get('rw_storage_path');
    my $ro_dir = QVD::Config->get('ro_storage_path');
    my $disk_image = undef;
    unless ($osi->use_overlay) {
	$disk_image = $ro_dir.'/'.$osi->disk_image;
    } else {
	$disk_image = $rw_dir.'/'.$osi->id.'-'.$vm->vm_id.'-overlay.qcow2';
    }
    $disk_image
}

sub _get_user_storage_for_vm {
    my ($self, $vm) = @_;
    my $osi = $vm->rel_vm_id->osi;
    my $disk_image = undef;
    if (defined $osi->user_storage_size) {
	my $home = QVD::Config->get('home_storage_path');
	$disk_image = $home.'/'.$vm->vm_id.'-data.qcow2';
    }
    $disk_image
}

sub _ensure_image_exists {
    my ($self, $vm) = @_;
    my $osi = $vm->rel_vm_id->osi;
    my $rw_dir = QVD::Config->get('rw_storage_path');
    my $ro_dir = QVD::Config->get('ro_storage_path');
    my $img_cmd = QVD::Config->get('kvm_img_command', 'kvm-img');
    my $disk_image = $self->_get_image_for_vm($vm);
    if ($osi->use_overlay and not -f $disk_image) {
	# If the overlay is created using a relative path
	# you can move the images around.
	use File::Spec qw/abs2rel curdir/;
	my $base_img_abs = $ro_dir.'/'.$osi->disk_image;
	my $base_img_rel = File::Spec->abs2rel($base_img_abs, $rw_dir);
	my $curdir = File::Spec->curdir;
	chdir $rw_dir or die "Unable to enter rw_storage_path: $!";
	my @cmd = ($img_cmd => ('create', 
				'-f' => 'qcow2',
				'-b' => $base_img_rel,
				$disk_image));
	system(@cmd) == 0 or die "Unable to create overlay image $disk_image: $^E";
	INFO "Created overlay image $disk_image for VM ".$vm->vm_id;
	chdir $curdir;
    }
    -f $disk_image
}

sub _ensure_user_storage_exists {
    my ($self, $vm) = @_;
    my $osi = $vm->rel_vm_id->osi;
    my $dir = QVD::Config->get('home_storage_path');
    my $img_cmd = QVD::Config->get('kvm_img_command', 'kvm-img');
    my $disk_image = $self->_get_user_storage_for_vm($vm);
    return 1 if -f $disk_image;
    my @cmd = ($img_cmd => ('create', 
			    '-f' => 'qcow2',
			    $disk_image,
			    $osi->user_storage_size.'M'));
    system(@cmd) == 0 or die "Unable to create image $disk_image for user data";
    INFO "Created overlay image $disk_image for VM ".$vm->vm_id;
}


sub start_vm {
    my ($self, $vm) = @_;

    if ($self->is_vm_running($vm)) {
	return {vm_status => 'started'};
    }

    my $home_base= QVD::Config->get('home_storage_path');

    my $id = $vm->vm_id;
    my $osi = $vm->rel_vm_id->osi;
    my $disk_image = $self->_get_image_for_vm($vm);
    $self->_ensure_image_exists($vm) 
    	or die "Disk image $disk_image doesn't exist";
    DEBUG "Using disk $disk_image for VM ".$id;

    my $user_storage = $self->_get_user_storage_for_vm($vm);
    if (defined $user_storage) {
	$self->_ensure_user_storage_exists($vm)
	    or die "Disk image $user_storage doesn't exist";
	DEBUG "Using user storage $user_storage for VM ".$id;
    }
    my $vma_port = $vm->vm_vma_port;
    my $x_port = $vm->vm_x_port;
    my $ssh_port = $vm->vm_ssh_port;
    my $vnc_display = $vm->vm_vnc_port - 5900;
    my @cmd = (kvm => (-m => $osi->memory.'M',
		       -vnc => ":${vnc_display}",
		       -redir => "tcp:${x_port}::5000",
		       -redir => "tcp:${vma_port}::3030",
                       -redir => "tcp:${ssh_port}::22",
                       -hda => $disk_image,
		       (defined $user_storage
			   ? (-hdb => $user_storage)
			   : ())));

    my $pid = fork;
    if (!$pid) {
	unless (defined $pid) {
	    die "unable to fork virtual machine process";
	}
	{ exec  @cmd };
	warn "exec @cmd failed\n";
	require POSIX;
	POSIX::_exit(1);
    }
    warn "kvm pid: $pid\n";
    open my $pfh, '>', $self->_get_kvm_pid_file_path($id) or die "unable to create pid file";
    print $pfh $pid;
    close $pfh;
    return { vm_status => 'starting' };
}

sub stop_vm {
    my ($self, $vm) = @_;

    my $vma_client = $self->_get_vma_client_for_vm($vm);
    unless ($vma_client->is_connected()) {
	return { request => 'error', error => "can't connect to agent" };
    }

    my $r = eval { $vma_client->poweroff() };
    if (defined $r) {
	if (defined $r->{poweroff}) {
	    return { request => 'success', vm_status => 'stopping' };
	} else {
	    return { request => 'error', error => "agent can't poweroff vm" };
	}
    } else {
	return { request => 'error', error => "rpc failed: $@" };
    }
}

sub get_vma_status {
    my ($self, $vm) = @_;
    my $vma = $self->_get_vma_client_for_vm($vm);
    eval { $vma->status() };
}

sub _clear_cmd {
    my ($self, $vm, $cmd_type) = @_;
    DEBUG "Clearing command $cmd_type for VM ".$vm->vm_id;
    $vm->update({$cmd_type => undef});
}

sub clear_vm_cmd {
    my ($self, $vm) = @_;
    $self->_clear_cmd($vm, 'vm_cmd');
}

sub clear_nx_cmd {
    my ($self, $vm) = @_;
    $self->_clear_cmd($vm, 'x_cmd');
}

sub clear_user_cmd {
    my ($self, $vm) = @_;
    $self->_clear_cmd($vm, 'user_cmd');
}

sub disconnect_nx {
    my ($self, $vm) = @_;
    my $vma = $self->_get_vma_client_for_vm($vm);
    eval { $vma->disconnect_session };
}

sub update_vma_ok_ts {
    my ($self, $vm) = @_;
    $vm->update({vma_ok_ts => time});
}

sub clear_vma_ok_ts {
    my ($self, $vm) = @_;
    $vm->update({vma_ok_ts => undef});
}

sub clear_vm_host {
    my ($self, $vm) = @_;
    $vm->update({
	host_id => undef,
	vm_address => undef,
	vm_vma_port => undef,
	vm_x_port => undef,
	vm_ssh_port => undef,
	vm_vnc_port => undef,
	});
}

sub terminate_vm {
    my ($self, $vm) = @_;
    $self->_signal_kvm($vm->vm_id, 15);
}

sub kill_vm {
    my ($self, $vm) = @_;
    $self->_signal_kvm($vm->vm_id, 9);
}

1;

__END__

=head1 NAME

QVD::VMAS - API to QVD Virtual Machine Administration Services

=head1 SYNOPSIS

    use QVD::VMAS;

    # Start the first VM of host 42 on this host
    my $vmas= QVD::VMAS->new();
    my @vms = $vmas->get_vms_for_host(42);
    $vmas->start_vm(@vms[0]);

    # Stop the user 31's first VM, assuming it is running on this host
    @vms = $vmas->get_vms_for_user(31);
    $vmas->stop_vm(@vms[0]);

=head1 DESCRIPTION

This module implements the VMAS API.

=head2 API

=over

=item assign_host_for_vm($vm_runtime, $preferred_host_id = undef)

Assigns the given virtual machine runtime to a QVD host. The machine is
assigned to the preferred host, if specified. Otherwise the 
load balancing algorithm specified by the configuration key
C<vmas_load_balance_algorithm> is used to determine the best host.

Returns true if a host could be assigned, false if no host was available.

=item schedule_start_vm($vm_runtime)

Sets the start command for the given virtual machine and pings the remote
control running on its host so that the VM starts.

Returns true if the command could be set and the RC pinged, false otherwise.
Note that at most one command can be set at a time.

=back

The methods below operate only on the virtual machines of the current host.

=over

=item start_vm($vm_runtime)

Starts the given virtual machine runtime on the current host. Returns vm_status
= starting on success.

=item stop_vm($vm_runtime)

Asks the virtual machine to stop by connecting to its VMA.  Returns a hash with
poweroff = 1 on success.

=item terminate_vm($vm_runtime) 

Asks the virtual machine process to terminate. This can be implemented by
sending SIGTERM to the process.

=item kill_vm($vm_runtime) 

Forces the virtual machine process to terminate.

=item start_vm_listener($vm_runtime) 

Asks the given virtual machine to start nxagent.

=item is_vm_running($vm_runtime)

Returns a true value if the VM process is running on the host.

=item get_vm_status($vm_runtime)

Consults the status of the virtual machine. The status of the virtual machine
is returned as "vm_status". It is either started or stopped. If the machine is
started an attempt is made to get the status of the VMA. The VMA status is
returned as vma_status.

=back

=head1 AUTHOR

Salvador Fandiño, C<< <sfandino at yahoo.com> >>

Joni Salonen, C<< <jsalonen at qindel.es> >>.

=head1 COPYRIGHT & LICENSE

Copyright C<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

