package QVD::DB::Result::Host_Runtime;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('host_runtimes');
__PACKAGE__->add_columns( host_id    => { data_type   => 'integer' },
			  pid        => { data_type   => 'integer',
				          is_nullable => 1 },
			  ok_ts      => { data_type   => 'timestamp',
				          is_nullable => 1 },
			  # Memory available for VMs, in MBs
			  usable_ram => { data_type   => 'real',
					  is_nullable => 1 },
			  # CPU available for VMs, in bogomips
			  usable_cpu => { data_type   => 'real',
					  is_nullable => 1 },
			  state      => { data_type   => 'varchar(12)',
				          is_enum     => 1,
				          extra       => { list => [qw(stopped starting running stopping lost)] } },
			  blocked    => { data_type   => 'boolean' },
			  cmd        => { data_type   => 'varchar(12)',
				          is_nullable => 1,
				          is_enum     => 1,
				          extra       => { list => [qw(stop)] } } );

__PACKAGE__->set_primary_key('host_id');
__PACKAGE__->belongs_to('host'      => 'QVD::DB::Result::Host',       'host_id');
__PACKAGE__->belongs_to('rel_state' => 'QVD::DB::Result::Host_State', 'state'  );
__PACKAGE__->belongs_to('rel_cmd'   => 'QVD::DB::Result::Host_Cmd',   'cmd'    );

__PACKAGE__->has_many('vms'	    => 'QVD::DB::Result::VM_Runtime', 'host_id');

sub update_ok_ts {
    my ($rt, $time) = @_;
    $time //= time;
    shift->update({ok_ts => $time})
}

sub set_state {
    my ($rt, $state, $time) = @_;
    $time //= time;
    $rt->update({ state => $state, ok_ts => $time });
}

sub block   { shift->update({ blocked => 'true'  }) }
sub unblock { shift->update({ blocked => 'false' }) }

1;
