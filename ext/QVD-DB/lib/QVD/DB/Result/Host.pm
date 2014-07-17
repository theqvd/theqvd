package QVD::DB::Result::Host;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('hosts');
__PACKAGE__->add_columns( id       => { data_type => 'integer',
                                       is_auto_increment => 1 },
                          name     => { data_type => 'varchar(127)' },
                          address  => { data_type => 'varchar(127)' },
			  frontend => { data_type => 'boolean' },
			  backend  => { data_type => 'boolean' } );

__PACKAGE__->set_primary_key('id');

__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->add_unique_constraint(['address']);

__PACKAGE__->has_many(properties => 'QVD::DB::Result::Host_Property', 'host_id');
__PACKAGE__->has_many(vms        => 'QVD::DB::Result::VM_Runtime',    'host_id', { cascade_delete => 0 });
#__PACKAGE__->has_many(vm_l7rs    => 'QVD::DB::Result::VM_Runtime',    'l7r_host_id', { cascade_delete => 0 }); #FIXME COMMENTED BECAUSE TRIGGERS ERROR WHEN ASKING DB
__PACKAGE__->has_one (runtime    => 'QVD::DB::Result::Host_Runtime',  'host_id');
__PACKAGE__->has_one (counters   => 'QVD::DB::Result::Host_Counter',  'host_id');

sub get_has_many { qw(vms properties); };
sub get_has_one { qw(runtime counters); };
sub get_belongs_to { qw(); };
sub get_required_cols { qw(name address frontend backend); };
sub get_defaults { {frontend => 1, backend => 1}; };
1;
