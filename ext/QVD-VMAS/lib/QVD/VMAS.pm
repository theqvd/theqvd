package QVD::VMAS;

use warnings;
use strict;

use QVD::DB;
use QVD::VMA::Client;


our $VERSION = '0.01';


package QVD::VMAS::Impl;

use parent 'QVD::SimpleRPC::Server';

sub SimpleRPC_start_vm_listener {
    my ($self, %params) = @_;
    my $id = $params{id};
    my $vma_port = 3030+$id;
    my $agent_port = 5000+$id;
    my $vma_client = QVD::VMA::Client->new('localhost', $vma_port);
    if ($vma_client->start_vm_listener) {
	return { host => 'localhost', 'port' => $agent_port };
    }
}

sub SimpleRPC_start_vm {
    my ($self, %params) = @_;
    my $id = $params{id};

    unless (defined $id) {
	return { vm_status => 'aborted', error => 'invalid id: '.$id };
    }
    
    my $schema = QVD::DB->new();
    my $vm = $schema->resultset('VM')->find({id => $id});
    unless (defined $vm) {
	return { vm_status => 'aborted', error => 'invalid id: '.$id };
    }
    my $osi = $vm->osi;
    unless (defined $osi) {
	return { vm_status => 'aborted', error => 'no osi' };
    }
    
    my $vma_port = 3030+$id;
    my $agent_port = 5000+$id;
    my $cmd = "kvm";
    $cmd .= " -redir tcp:".$agent_port."::5000";
    $cmd .= " -redir tcp:".$vma_port."::3030";
    $cmd .= " -redir tcp:2222::22º";
    $cmd .= " -hda ".$osi->disk_image;
    $cmd .= " -hdb ".$vm->storage if -e $vm->storage;
    $cmd .= " -pidfile /var/run/qvd/vm-$id.pid";
    $cmd .= " &";
# FIXME executing a program in background doesn't fail even if program doesn't exist
    system($cmd) == 0 or 
    	return { vm_status => 'aborted', error => "Couldn't exec kvm: $!" };
# Allow 2 seconds for generation of pid file
    sleep 2;
    my $pid = `cat /var/run/qvd/vm-$id.pid`;
    if (kill 0, $pid) {
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
    my $vm = $schema->resultset('VM_Runtime')->find({id => $id});
    unless (defined $vm) {
	return { request => 'error', error => 'invalid id: '.$id };
    }

    my $vma_port = 3030+$id;

    my $vma_client = QVD::VMA::Client->new('localhost', $vma_port);
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

=back

=head1 AUTHOR

Salvador Fandiño, C<< <sfandino at yahoo.com> >>

Joni Salonen, C<< <jsalonen at qindel.es> >>.

=head1 COPYRIGHT & LICENSE

Copyright C<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

