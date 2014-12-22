package QVD::DB::Result::VM_Runtime;

use strict;
use warnings;

use parent qw(DBIx::Class);
use QVD::Log;

# FIXME: rename rows and accessors:
#   user_* => l7r_*
#   user_ip => l7r_client_ip


__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('vm_runtimes');
__PACKAGE__->add_columns( vm_id          => { data_type   => 'integer' },
			  host_id        => { data_type   => 'integer',
					      is_nullable => 1 },
                          current_osf_id => { data_type   => 'integer',
                                              is_nullable => 1 },
                          current_di_id  => { data_type   => 'integer',
                                              is_nullable => 1 },
			  user_ip        => { data_type   => 'varchar(15)',
					      is_nullable => 1 },
			  real_user_id   => { data_type   => 'integer',
					      is_nullable => 1 },
			  vm_state       => { data_type   => 'varchar(12)',
					      is_enum     => 1,
					      extra       => { list => [qw(stopped starting running
									   stopping zombie debugging)] } },
			  vm_state_ts    => { data_type   => 'integer',
					      is_nullable => 1 },
			  vm_cmd         => { data_type   => 'varchar(12)',
					      is_nullable => 1,
					      is_enum     => 1,
					      extra       => { list => [qw/start stop busy/] } },
			  vm_pid         => { data_type   => 'integer',
					      is_nullable => 1	},
			  user_state     => { data_type   => 'varchar(12)',
					      extra       => { list => [qw/disconnected connecting connected/] } },
			  user_state_ts  => { data_type   => 'integer',
					      is_nullable => 1 },
			  user_cmd       => { data_type   => 'varchar(12)',
					      is_nullable => 1,
					      is_enum     => 1,
					      extra       => { list => [qw/abort/] } },
			  vma_ok_ts      => { data_type   => 'integer',
					      is_nullable => 1 },
			  l7r_host_id    => { data_type   => 'integer',
					      is_nullable => 1 },
			  l7r_pid        => { data_type   => 'integer',
					      is_nullable => 1 },
			  vm_address     => { data_type   => 'varchar(127)',
					      is_nullable => 1 },
			  vm_vma_port    => { data_type   => 'integer',
					      is_nullable => 1 },
			  vm_x_port      => { data_type   => 'integer',
					      is_nullable => 1 },
			  vm_ssh_port    => { data_type   => 'integer',
					      is_nullable => 1 },
			  vm_vnc_port    => { data_type   => 'integer',
					      is_nullable => 1 },
			  vm_mon_port    => { data_type   => 'integer',
					      is_nullable => 1 },
			  vm_serial_port => { data_type   => 'integer',
					      is_nullable => 1 },
			  blocked        => { data_type   => 'boolean',
					      is_nullable => 1 },
                          vm_expiration_soft => { data_type   => 'timestamp',
                                                  is_nullable => 1 },
                          vm_expiration_hard => { data_type   => 'timestamp',
                                                  is_nullable => 1 },
                        );

__PACKAGE__->set_primary_key('vm_id');

__PACKAGE__->belongs_to(host => 'QVD::DB::Result::Host', 'host_id', { join_type => 'LEFT' });
__PACKAGE__->belongs_to(l7r_host => 'QVD::DB::Result::Host', 'l7r_host_id', { join_type => 'LEFT' });
__PACKAGE__->belongs_to(vm   => 'QVD::DB::Result::VM', 	 'vm_id',   { cascade_delete => 1 });
__PACKAGE__->belongs_to(real_user => 'QVD::DB::Result::User', 'real_user_id', { cascade_delete => 0,
                                                                                join_type => 'LEFT' });

__PACKAGE__->belongs_to('rel_vm_state' => 'QVD::DB::Result::VM_State', 'vm_state');
__PACKAGE__->belongs_to('rel_user_state' => 'QVD::DB::Result::User_State', 'user_state');

__PACKAGE__->belongs_to('rel_vm_cmd' => 'QVD::DB::Result::VM_Cmd', 'vm_cmd');
__PACKAGE__->belongs_to('rel_user_cmd' => 'QVD::DB::Result::User_Cmd', 'user_cmd');

__PACKAGE__->belongs_to(current_di => 'QVD::DB::Result::DI', 'current_di_id');
__PACKAGE__->belongs_to(current_osf => 'QVD::DB::Result::OSF', 'current_osf_id');

sub set_vm_state {
    my $vm = shift;
    my $state = shift;
    $vm->update({ vm_state => $state, vm_state_ts => time, @_ });
}

sub set_user_state {
    my $vm = shift;
    my $state = shift;
    $vm->update({ user_state => $state, user_state_ts => time, @_ });
}

sub _clear_cmd {
    my ($vm, $type) = @_;
    # DEBUG "Clearing $type command for VM ".$vm->vm_id;
    $vm->update({"${type}_cmd" => undef});
}

sub clear_vm_cmd { shift->_clear_cmd('vm') }
sub clear_user_cmd { shift->_clear_cmd('user') }

my %valid_vm_cmd = ( start => { stopped    => 1 },
		     stop  => { starting   => 1,
				running    => 1,
                                debugging  => 1 } );

sub can_send_vm_cmd {
    my ($vm, $cmd) = @_;
    $valid_vm_cmd{$cmd}{$vm->vm_state};
}

sub send_vm_cmd {
    my ($vm, $cmd) = @_;
    my $id = $vm->vm_id;
    my $state = $vm->vm_state;
    $valid_vm_cmd{$cmd}{$state} or
	die "Can't send command $cmd to VM $id in state $state";
    defined $vm->host_id or
	die "Can't send command $cmd to VM $id until it has a host assigned";
    $vm->update({vm_cmd => $cmd});
}

sub send_vm_start { shift->send_vm_cmd('start') }
sub send_vm_stop { shift->send_vm_cmd('stop') }

my %valid_user_cmd = ( abort => { connecting => 1,
				  connected  => 1 } );

sub send_user_cmd {
    my ($vm, $cmd) = @_;
    my $id = $vm->id;
    my $state = $vm->user_state;
    $valid_user_cmd{$cmd}{$state} or
	die "Can't send command $cmd to L7R in state $state for VM $id";
    $vm->update({user_cmd => $cmd});
}

sub send_user_abort { shift->send_user_cmd('abort') }

sub update_vma_ok_ts { shift->update({vma_ok_ts => time}) }
sub clear_vma_ok_ts { shift->update({vma_ok_ts => undef}) }

sub unassign {
    shift->update({host_id        => undef,
                   vm_vma_port    => undef,
                   vm_x_port      => undef,
                   vm_vnc_port    => undef,
                   vm_ssh_port    => undef,
                   vm_serial_port => undef,
		   vm_mon_port    => undef,
                   vm_address     => undef,
                   vma_ok_ts      => undef});
}

sub set_vm_pid {
    my ($vm, $pid) = @_;
    $vm->update({vm_pid => $pid })
}

sub set_host_id {
    my ($vm, $host_id) = @_;
    $vm->update({host_id => $host_id});
}

sub set_current_osf_id {
    my ($vm, $current_osf_id) = @_;
    $vm->update({current_osf_id => $current_osf_id});
}

sub set_current_di_id {
    my ($vm, $current_di_id) = @_;
    $vm->update({current_di_id => $current_di_id});
}

sub clear_l7r_all {
    shift->update({ user_state => 'disconnected',
                    user_cmd => undef,
                    l7r_host_id => undef,
                    l7r_pid => undef })
}

sub block { shift->update({ blocked => 1 }) }
sub unblock { shift->update({ blocked => 0 }) }

sub vma_url {
    my $vm = shift;
    sprintf("http://%s:%d/vma", $vm->vm_address, $vm->vm_vma_port);
}

sub combined_properties { shift->vm->combined_properties }

sub is_ephemeral {
    # FIXME add a database field to mark ephemeral VMs
    my ($vm) = @_;
    return $vm->real_user_id != $vm->vm->user_id;
}

1;
