package QVD::VMAS;

use warnings;
use strict;

use QVD::DB;
use QVD::VMA::Client;

=head1 NAME

QVD::VMAS - The great new QVD::VMAS!

=head1 VERSION

Version 0.01

=cut

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
	return { vm_status => 'starting' };
    } else {
# FIXME how to capture error message from kvm?
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

    my $vma_port = 3030+$id;

    my $vma_client = QVD::VMA::Client->new('localhost', $vma_port);
    unless ($vma_client->is_connected()) {
	return { request => 'error', error => "Can't connect to agent" };
    }

    my $r = $vma_client->poweroff();
    if (defined $r->{poweroff}) {
	return { request => 'success', vm_status => 'stopping' };
    } else {
	return { request => 'error', error => "agent can't poweroff vm" };
    }
}


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::VMAS;

    my $foo = QVD::VMAS->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Salvador Fandiño, C<< <sfandino at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-vmas at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-VMAS>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::VMAS


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-VMAS>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/QVD-VMAS>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/QVD-VMAS>

=item * Search CPAN

L<http://search.cpan.org/dist/QVD-VMAS>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Salvador Fandiño, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of QVD::VMAS
