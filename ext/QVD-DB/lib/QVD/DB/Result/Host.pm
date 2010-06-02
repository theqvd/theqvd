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
__PACKAGE__->has_many(properties => 'QVD::DB::Result::Host_Property', 
			'host_id', { join_type => 'INNER'});
__PACKAGE__->has_one(runtime => 'QVD::DB::Result::Host_Runtime', 'host_id');
__PACKAGE__->has_many(vms => 'QVD::DB::Result::VM_Runtime',
                      'host_id', { cascade_delete => 0 });

1;
