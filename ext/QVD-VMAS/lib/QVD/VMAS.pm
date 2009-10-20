package QVD::VMAS;

use warnings;
use strict;

use QVD::DB;
use QVD::VMA::Client;

our $VERSION = '0.01';

sub new {
    my $class = shift;
    my $db = shift || QVD::DB->new();
    my $self = {
	db => $db,
	last_error => undef,
    };
    bless $self, $class;
    $self;
}

sub _get_kvm_pid_file_path {
    my ($self, $id) = @_;
    "/var/run/qvd/vm-$id.pid"
}

sub _signal_kvm {
    my ($self, $id, $signal) = @_;
    my $pidFile = $self->_get_kvm_pid_file_path($id);
    my $pid = `cat $pidFile` if -e $pidFile;
# FIXME need to check if the process with this PID is actually KVM!
    return kill($signal, $pid) if defined $pid;
    0
}

sub _is_kvm_running {
    my ($self, $id) = @_;
    $self->_signal_kvm($id, 0)
}

sub _get_vma_client_for_vm {
    my ($self, $id) = @_;
    QVD::VMA::Client->new('localhost', 3030+$id)
}

sub get_vms_for_host {
    my ($self, $host_id) = @_;
    my @vms = $self->{db}->resultset('VM_Runtime')
    		->search({host_id => $host_id});
    return @vms;
}

sub get_vms_for_user {
    my ($self, $user_id) = @_;
    my @vms = $self->{db}->resultset('VM')
    		->search({'user_id' => $user_id});
    return map { $_->vm_runtime } @vms;
}

sub _get_free_host {
    # FIXME Implement some kind of load balancing algorithm
    shift->{db}->resultset('Host')->first->id;
}

sub assign_host_for_vm {
    my ($self, $vm) = @_;
    my $host_id = $self->_get_free_host();
    $vm->update({ host_id => $host_id });
}

sub push_vm_state {
    my ($self, $vm, $vm_state) = @_;
    $vm->update({ vm_state => $vm_state, vm_state_ts => time });
}


sub start_vm_listener {
    my ($self, $vm) = @_;
    my $id = $vm->vm_id;
    my $vma_port = 3030+$id;
    my $agent_port = 5000+$id;
    my $vma_client = $self->_get_vma_client_for_vm($id);
    eval { $vma_client->start_vm_listener };
    if ($@) {
	return { request => 'error', 'error' => $@ };
    } else {
	return { request => 'success', host => 'localhost', 'port' => $agent_port };
    }
}

sub schedule_start_vm {
    my ($self, $vm) = @_;
    unless (defined $vm->vm_cmd && $vm->vm_cmd ne 'start') {
	my $r = $vm->update({vm_cmd => 'start'});
	$self->{db}->txn_commit;
	# FIXME Ping the RC running on remote host
	return $r;
    } else {
	return undef;
    }
}

sub start_vm {
    my ($self, $vm) = @_;
    my $id = $vm->vm_id;
    my $osi = $vm->rel_vm_id->osi;
    #  Try to start the VM only if it's not already running
    return { vm_status => 'started' } if $self->_is_kvm_running($id);

    my $vma_port = 3030+$id;
    my $agent_port = 5000+$id;
    my $cmd = "kvm";
    $cmd .= " -m 512M";
    $cmd .= " -redir tcp:".$agent_port."::5000";
    $cmd .= " -redir tcp:".$vma_port."::3030";
    # Next line activates SSH
    $cmd .= " -redir tcp:2222::22";
    $cmd .= " -hda '".$osi->disk_image."'";
    $cmd .= " -hdb '".$vm->rel_vm_id->storage."'" if -e $vm->rel_vm_id->storage;
    $cmd .= " -pidfile '".$self->_get_kvm_pid_file_path($id)."'";
    $cmd .= " -vnc none";
    $cmd .= " &";
# FIXME executing a program in background doesn't fail even if program doesn't exist
    system($cmd) == 0 or 
    	return { vm_status => 'stopped', error => "Couldn't exec kvm: $!" };
# Allow a timeout for generation of pid file
    sleep 2;
    if ($self->_is_kvm_running($id)) {
	return { vm_status => 'starting' };
    } else {
# FIXME how to capture error message from kvm?
	return { vm_status => 'stopped', error => 'vm exited' };
    }
}

sub stop_vm {
    my ($self, $vm) = @_;

    my $vma_client = $self->_get_vma_client_for_vm($vm->vm_id);
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

sub get_vm_status {
    my ($self, $vm) = @_;

    my $last_status = $vm->vm_state;

    if ($self->_is_kvm_running($vm->vm_id)) {
	my $vma = $self->_get_vma_client_for_vm($vm->vm_id);
	my $r;
	if ($vma->is_connected()) {
	    $r = eval { $vma->status() };
	}
	if (defined $r) {
	    return { request => 'success', vm_status => 'started',
	    last_vm_status => $last_status, vma_status => $r->{status}};
	} else {
	    return { request => 'success', vm_status => 'started',
	    last_vm_status => $last_status, vma_status => 'error', 
	    vma_error => "Can't connect to agent"};
	}
    } else {
	return { request => 'success', vm_status => 'stopped', 
	last_vm_status => $last_status};
    }
}

sub get_vma_status {
    my ($self, $id) = @_;
    my $vma = $self->_get_vma_client_for_vm($id);
    if ($vma->is_connected()) {
	my $r = $vma->status();
	return $r->{status};
    } else {
	$self->{last_error} = 'VMA not connected';
	return undef;
    }
}

sub last_error {
    shift->{last_error}
}

sub clear_vm_cmd {
    my ($self, $vm) = @_;
    $vm->update({vm_cmd => undef});
}

sub clear_x_cmd {
    my ($self, $vm) = @_;
    $vm->update({x_cmd => undef});
}

sub disconnect_x {
    my ($self, $vm) = @_;
    $vm->update({x_state => 'disconnected'});
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
    $vm->update({host_id => undef});
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

