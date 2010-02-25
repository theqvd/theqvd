package QVD::HKD;

use warnings;
use strict;

use QVD::Config;
use QVD::DB::Simple;
use QVD::VMAS;

use Sys::Hostname;
use POSIX ":sys_wait_h";

# FIXME: read nodename from configuration file!
my $host_id = rs(Host)->search(name => hostname)->first->id;

# FIXME: implement a better port allocation strategy
my $port = 2000;
sub _allocate_port { $port++ }

sub _reap_children { 1 while (waitpid(-1, WNOHANG) > 0) }

sub new {
    my ($class, %opts) = @_;
    my $self = {};
    bless $self, $class;
    $self;
}

sub run {
    my $self = shift;

    while (1) {
	my @vmrts = rs(VM_Runtime)->search({host_id => $host_id});

	my @vmrts_need_check = grep {
	    my $state = $_->vm_state;
	    $state ne 'stopped' and $state ne 'failed'
	} @vmrts;

	for my $vmrt (@vmrts) {
	    my $state = $vmrt->vm_state;

	    next if ($state eq 'failed' or $state eq 'stopped');

	    unless ($vmas->check_vm_process($vmrt)) {
		# the process has desappeared!
		my $new_state = ($state eq 'stopping' ? 'stopped' : 'failed');
		$self->_set_vm_state($new_state => $vmrt);
		next;
	    }

	    push @vmrts_need_check, $vmrt
		unless ($state eq 'zombie' or $state eq 'stopping');
	}

	my @vma_response = $vmas->vma_status_parallel(@vmrts_need_check);

	for my $ix (0.. $#vmrts_need_check) {
	    my $vmrt = $vmrts_need_check[$ix];
	    my $status = $vmrt->status;
	    my $vma_response = $vma_response[$ix];
	    my $vma_status = $vma_response->{status};

	    if ($vma_status eq 'ok') {
		my $old_x_state = $vmrt->x_state;
		my $new_x_state = $vma_response->{x_state} // 'disconnected';

		$self->_set_x_state($new_x_state, $vmrt)
		    if $old_x_state ne $new_x_state;

		if ($new_x_state eq 'starting') {
		    $self->_check_x_starting_timeout;
		}

		my $x_cmd = $vmrt->x_cmd;
		$self->_x_cmd($x_cmd => $vmrt) if $x_cmd;

		$self->_update_vm_timers($vrmt);

		# FIXME: anything else to do? (was x _do event in HKD)

		# FIXME: anything else to do? (was vm _do event in HKD)

		$self->_check_vm_timers($vrmt);
	    }
	    else {
		# FIXME: vm is not responding, do something, whatever!!!
	    }





		if ($vma_x_state eq 'disconnected' and
		    grep $old_x_state eq $_, qw(connecting listening connected)) {
		    $self->_set_x_state(disconnected => $vrmt)
		}
		elsif ($old_x_state eq 'connecting' and
		       $new_x_state eq 'listening') {
		    # FIXME, what to do, what to do!
		    $self->_set_x_state('listening');
		}
		elsif ($old_x_state eq '
	    }
	}


	for my $vmrt (@vmrts) {
	    my $state = $vmrt->vm_state;
	    
	    
	}
    }
}
