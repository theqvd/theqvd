package QVD::VMAS;

use warnings;
use strict;

use QVD::DB;
use QVD::VMA::Client;


our $VERSION = '0.01';


package QVD::VMAS::Impl;

use parent 'QVD::SimpleRPC::Server';

sub _get_kvm_pid_file_path {
    my ($self, $id) = @_;
    "/var/run/qvd/vm-$id.pid"
}

sub _is_kvm_running {
    my ($self, $id) = @_;
    my $pidFile = $self->_get_kvm_pid_file_path($id);
    my $pid = `cat $pidFile` if -e $pidFile;
# FIXME need to check if the process with this PID is actually KVM!
    return kill(0, $pid) if defined $pid;
    0
}

sub _get_vma_client_for_vm {
    my ($self, $id) = @_;
    QVD::VMA::Client->new('localhost', 3030+$id)
}


sub SimpleRPC_start_vm_listener {
    my ($self, %params) = @_;
    my $id = $params{id};
    my $vma_port = 3030+$id;
    my $agent_port = 5000+$id;
    my $vma_client = $self->_get_vma_client_for_vm($id);
    if ($vma_client->start_vm_listener) {
	return { request => 'success', host => 'localhost', 'port' => $agent_port };
    }
}

sub SimpleRPC_start_vm {
    my ($self, %params) = @_;
    my $id = $params{id};

    return { vm_status => 'aborted', error => 'invalid id: '.$id } 
    	unless defined $id;
    
    my $schema = QVD::DB->new();
    my $vm = $schema->resultset('VM')->find({id => $id});
    return { vm_status => 'aborted', error => 'invalid id: '.$id } 
    	unless defined $vm;
    my $osi = $vm->osi;
    return { vm_status => 'aborted', error => 'no osi' }
    	unless defined $osi;
    
    #  Try to start the VM only if it's not already running
    return { vm_status => 'started' } if $self->_is_kvm_running($id);

    my $vma_port = 3030+$id;
    my $agent_port = 5000+$id;
    my $cmd = "kvm";
    $cmd .= " -redir tcp:".$agent_port."::5000";
    $cmd .= " -redir tcp:".$vma_port."::3030";
    # Next line activates SSH
    #$cmd .= " -redir tcp:2222::22";
    $cmd .= " -hda '".$osi->disk_image."'";
    $cmd .= " -hdb '".$vm->storage."'" if -e $vm->storage;
    $cmd .= " -pidfile '".$self->_get_kvm_pid_file_path($id)."'";
    $cmd .= " &";
# FIXME executing a program in background doesn't fail even if program doesn't exist
    system($cmd) == 0 or 
    	return { vm_status => 'aborted', error => "Couldn't exec kvm: $!" };
# Allow a timeout for generation of pid file
    sleep 2;
    if ($self->_is_kvm_running($id)) {
	my $cd = $schema->resultset('VM_Runtime')->update_or_create(
	{
		vm_id => $id,
		state => 'starting',
	}	
	);
	return { vm_status => 'starting' };
    } else {
# FIXME how to capture error message from kvm?
	my $cd = $schema->resultset('VM_Runtime')->update_or_create(
	{
		vm_id => $id,
		state => 'aborted',
	}	
	);
	return { vm_status => 'aborted', error => 'vm exited' };
    }
}

sub SimpleRPC_stop_vm {
    my ($self, %params) = @_;
    my $id = $params{id};
    unless (defined $id) {
	return { request => 'error', error => 'invalid id: '.$id };
    }
    
    my $schema = QVD::DB->new();
    my $vm = $schema->resultset('VM')->find({id => $id});
    unless (defined $vm) {
	return { request => 'error', error => 'invalid id: '.$id };
    }

    my $vma_client = $self->_get_vma_client_for_vm($id);
    unless ($vma_client->is_connected()) {
	return { request => 'error', error => "Can't connect to agent" };
    }

    my $r = $vma_client->poweroff();
    if (defined $r->{poweroff}) {
	my $cd = $schema->resultset('VM_Runtime')->update_or_create(
	{
		vm_id => $id,
		state => 'stopping',
	}	
	);
	return { request => 'success', vm_status => 'stopping' };
    } else {
	return { request => 'error', error => "agent can't poweroff vm" };
    }
}

sub SimpleRPC_get_vm_status {
    my ($self, %params) = @_;
    my $id = $params{id};
    unless (defined $id) {
	return { request => 'error', error => 'invalid id: '.$id };
    }

    my $schema = QVD::DB->new();
    my $vm = $schema->resultset('VM')->find({id => $id});
    unless (defined $vm) {
	return { request => 'error', error => 'invalid id: '.$id };
    }
    my $last_status = $vm->vm_runtime->state;

    if ($self->_is_kvm_running($id)) {
	my $vma = $self->_get_vma_client_for_vm($id);
	if ($vma->is_connected()) {
	    my $r = $vma->status();
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

1;

__END__

=head1 NAME

QVD::VMAS - QVD Virtual Machine Administration Services

=head1 SYNOPSIS

    use QVD::VMAS::Client;
    my $vmas_client = QVD::VMAS::Client->new();
    $vmas_client->start_vm(id => 42);
    $vmas_client->stop_vm(id => 21);
    ...

=head1 DESCRIPTION

This module implements the VMAS RPC server.

=head2 API

The following RPC calls are available.

=over

=item start_vm(id => $id)

Starts the virtual machine with the given id. Returns vm_status = starting on
success.

=item stop_vm(id => $id)

Asks the virtual machine with the given id to stop by connecting to its VMA.
Returns poweroff = 1 on success.

=item start_vm_listener(id => $id) 

Asks the virtual machine with the given id to start nxagent.

=item get_vm_status(id => $id)

Consults the status of the virtual machine with the given id. The status of the
virtual machine is returned as "vm_status". It is either started or stopped. If
the machine is started an attempt is made to get the status of the VMA. The VMA
status is returned as vma_status.

=back

=head1 AUTHOR

Salvador Fandiño, C<< <sfandino at yahoo.com> >>

Joni Salonen, C<< <jsalonen at qindel.es> >>.

=head1 COPYRIGHT & LICENSE

Copyright C<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

