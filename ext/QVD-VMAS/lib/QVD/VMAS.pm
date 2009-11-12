package QVD::VMAS;

use warnings;
use strict;

use QVD::DB;
use QVD::VMAS::VMAClient;
use QVD::VMAS::RCClient;
use QVD::Config;

use Log::Log4perl qw/:easy/;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $db = shift || QVD::DB->new();
    my $self = {
	db => $db,
    };
    bless $self, $class;
    $self;
}

sub txn_commit {
    my $self = shift;
    $self->{db}->txn_commit;
}

sub txn_do {
    my ($self, $coderef) = @_;
    $self->{db}->txn_do($coderef);
}

sub _get_kvm_pid_file_path {
    my ($self, $id) = @_;
    "/var/run/qvd/vm-$id.pid"
}

sub _signal_kvm {
    my ($self, $id, $signal) = @_;
    my $pidFile = $self->_get_kvm_pid_file_path($id);
    my $pid;
    $pid = `cat $pidFile` if -e $pidFile;
    if (defined $pid) {
	chomp $pid;
	# FIXME need to check if the process with this PID is actually KVM!
	return kill($signal, $pid) if defined $pid;
    }
    undef
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
    my $vms = $self->{db}->resultset('VM_Runtime')
    		->search({vm_id => $vm_id})->first;
    return $vms;
}

sub get_vms_for_host {
    my ($self, $host_id) = @_;
    return $self->{db}->resultset('VM_Runtime')
    		->search({host_id => $host_id});
}

sub get_vm_ids_for_host_txn {
    my $self = shift;
    my @ids = map $_->vm_id, $self->get_vms_for_host(@_);
    $self->{db}->txn_commit;
    @ids
}

sub get_vms_for_user {
    my ($self, $user_id) = @_;
    my @vms = $self->{db}->resultset('VM')
    		->search({'user_id' => $user_id});
    return map { $_->vm_runtime } @vms;
}

sub _load_balance_random {
    my $host_rs = shift->{db}->resultset('Host');
    my $host_id_col = $host_rs->get_column('id');
    my ($min, $max) = ($host_id_col->min, $host_id_col->max);
    my $host = undef;
    until (defined $host) {
	my $host_id = $min + int(rand($max-$min+1));
	$host = $host_rs->find($host_id);
    }
    $host
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
    my ($self, $vm) = @_;
    my $vm_id = $vm->vm_id;
    my $host = $self->_get_free_host($vm);
    return undef unless $host;
    my $r = $vm->update({ 
		host_id => $host->id, 
		vm_address => $host->address,
		vm_vma_port => QVD::Config->get('vm_vma_port')+$vm_id,
		vm_x_port => QVD::Config->get('vm_x_port')+$vm_id,
		vm_ssh_port => QVD::Config->get('vm_ssh_port')+$vm_id,
		vm_vnc_port => QVD::Config->get('vm_vnc_port')+$vm_id,
		});
    $r
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
    return $self->txn_do(sub {
	$vm->discard_changes;
	unless (defined $vm->$cmd_type && $vm->$cmd_type ne $cmd) {
	    my $r = $vm->update({$cmd_type  => $cmd});
	    DEBUG "Accepted command $cmd_type $cmd for VM ".$vm->vm_id;
	    return 1;
	}
	undef;
    });
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

sub schedule_start_vm {
    my ($self, $vm) = @_;
    if ($self->_schedule_cmd($vm, 'vm_cmd', 'start')) {
	my $host = $vm->host->address;
	my $rc = QVD::VMAS::RCClient->new($host);
	my $r = eval { $rc->ping_hkd() };
	if (defined $r && $r->{request} eq 'success') {
	    return 1;
	} else {
	    INFO "Couldn't notify hkd on ".$host." to start VM ".$vm->vm_id." error: ".$r->{error};
	    $self->clear_vm_cmd($vm);
	}
    }
    undef;
}

sub _get_disk_image_for_vm {
    my ($self, $vm) = @_;
    my $osi = $vm->rel_vm_id->osi;
    my $overlay_base = QVD::Config->get('rw_storage_path');
    my $image_base = QVD::Config->get('ro_storage_path');
    my $disk_image = undef;
    unless ($osi->use_overlay) {
	$disk_image = $image_base.'/'.$osi->disk_image;
    } else {
	$disk_image = $overlay_base.'/'.$osi->id.'-'.$vm->vm_id.'-overlay.qcow2';
	unless (-f $disk_image) {
	    my $base_image = $image_base.'/'.$osi->disk_image;
	    # FIXME use a relative path to base image for easier migration
	    my @cmd = (
	    	'qemu-img', 
		'create', 
		'-f' => 'qcow2',
		'-b' => $base_image,
		$disk_image);
	    system @cmd;
	    # FIXME handle overlay disk creation errors, e.g. no space left
	}
    }
    $disk_image
}

sub start_vm {
    my ($self, $vm) = @_;

    if ($self->is_vm_running($vm)) {
	return {vm_status => 'started'};
    }

    my $home_base= QVD::Config->get('home_storage_path');

    my $id = $vm->vm_id;
    my $osi = $vm->rel_vm_id->osi;
    my $disk_image = $self->_get_disk_image_for_vm($vm);
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
		       (-e $vm->rel_vm_id->storage
			? (-hdb => $home_base.'/'.$vm->rel_vm_id->storage)
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

sub DESTROY {
    my $self = shift;
    $self->{db}->txn_commit;
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

=item assign_host_for_vm($vm_runtime)

Assigns the given virtual machine runtime to a QVD host. This may use some kind
of a load balancing algorithm to determine the best host.

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

