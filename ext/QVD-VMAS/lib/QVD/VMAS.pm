package QVD::VMAS;

use warnings;
use strict;

use QVD::DB;
use QVD::VMAS::VMAClient;
use QVD::VMAS::RCClient;

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

sub txn_commit {
    my $self = shift;
    $self->{db}->txn_commit;
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
    chomp $pid;
    warn "killing process $pid with signal $signal\n";
# FIXME need to check if the process with this PID is actually KVM!
    return kill($signal, $pid) if defined $pid;
    undef
}

sub is_vm_running {
    my ($self, $vm) = @_;
    $self->_signal_kvm($vm->vm_id, 0)
}

sub _get_vma_client_for_vm {
    my ($self, $id) = @_;
    QVD::VMAS::VMAClient->new('localhost', 3030+$id)
}

sub get_vm_runtime_for_vm_id {
    my ($self, $vm_id) = @_;
    my $vms = $self->{db}->resultset('VM_Runtime')
    		->search({vm_id => $vm_id})->first;
    return $vms;
}

sub get_vms_for_host {
    my ($self, $host_id) = @_;
    my @vms = $self->{db}->resultset('VM_Runtime')
    		->search({host_id => $host_id});
    return @vms;
}

sub get_vm_ids_for_host_txn {
    my $self = shift;
    my @ids = map $_->vm_id, $self->get_vms_for_host(@_);
    $self->txn_commit;
    @ids
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
    my $r = $vm->update({ host_id => $host_id });
    $self->commit;
    return $r;
    
}

sub push_vm_state {
    my ($self, $vm, $vm_state) = @_;
    $vm->update({ vm_state => $vm_state, vm_state_ts => time });
    $self->commit;
}

sub push_user_state {
    my ($self, $vm, $state) = @_;
    $vm->update({ user_state => $state, user_state_ts => time });
    $self->commit;
}

sub commit {
    shift->{db}->txn_commit;
}

sub _schedule_cmd {
    my ($self, $vm, $cmd_type, $cmd) = @_;
    unless (defined $vm->$cmd_type && $vm->$cmd_type ne $cmd) {
	my $r = $vm->update({$cmd_type  => $cmd});
	$self->commit;
	return 1;
    }
    undef;
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
    my $vma_port = 3030+$id;
    my $agent_port = 5000+$id;
    my $vma_client = $self->_get_vma_client_for_vm($id);
    eval { $vma_client->start_vm_listener };
    if ($@) {
	$self->schedule_user_cmd($vm, 'Abort');
	return { request => 'error', 'error' => $@ };
    } else {
	$self->schedule_user_cmd($vm, 'Forward');
	return { request => 'success', host => 'localhost', 'port' => $agent_port };
    }
}

sub schedule_start_vm {
    my ($self, $vm) = @_;
    if ($self->_schedule_cmd($vm, 'vm_cmd', 'start')) {
	# FIXME Add host name or IP to the host table in database so we can
	# connect somewhere!
	my $host = 'localhost';
	my $rc = QVD::VMAS::RCClient->new($host);
	my $r = eval { $rc->ping_hkd() };
	if (defined $r && $r->{request} eq 'success') {
	    return 1;
	} else {
	    $self->clear_vm_cmd($vm);
	}
    }
    return undef;
}

sub start_vm {
    my ($self, $vm) = @_;
    my $id = $vm->vm_id;
    my $osi = $vm->rel_vm_id->osi;
    # FIXME: check the machine is not already running
    my $vma_port = 3030+$id;
    my $agent_port = 5000+$id;
    my $ssh_port = 2022+$id;
    my $vnc_port = 5900+$id;
    my @cmd = (kvm => (-m => '512M',
		       -vnc, "none",
		       -redir => "tcp:${agent_port}::5000",
		       -redir => "tcp:${vma_port}::3030",
                       -redir => "tcp:${ssh_port}::22",
		       -redir => "tcp:${vnc_port}::5900",
                       -hda => $osi->disk_image,
		       (-e $vm->rel_vm_id->storage
			? (-hdb => $vm->rel_vm_id->storage)
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

sub get_vma_status {
    my ($self, $vm) = @_;
    my $vma = $self->_get_vma_client_for_vm($vm->vm_id);
    eval { $vma->status() };
}

sub last_error {
    shift->{last_error}
}

sub _clear_cmd {
    my ($self, $vm, $cmd_type) = @_;
    $vm->update({$cmd_type => undef});
    $self->commit;
}

sub clear_vm_cmd {
    my ($self, $vm) = @_;
    $self->_clear_cmd($vm, 'vm_cmd');
}

sub clear_x_cmd {
    my ($self, $vm) = @_;
    $self->_clear_cmd($vm, 'x_cmd');
}

sub clear_user_cmd {
    my ($self, $vm) = @_;
    $self->_clear_cmd($vm, 'user_cmd');
}

sub disconnect_x {
    my ($self, $vm) = @_;
    $vm->update({x_state => 'disconnected'});
    $self->commit;
}

sub update_vma_ok_ts {
    my ($self, $vm) = @_;
    $vm->update({vma_ok_ts => time});
    $self->commit;
}

sub clear_vma_ok_ts {
    my ($self, $vm) = @_;
    $vm->update({vma_ok_ts => undef});
    $self->commit;
}

sub clear_vm_host {
    my ($self, $vm) = @_;
    $vm->update({host_id => undef});
    $self->commit;
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

