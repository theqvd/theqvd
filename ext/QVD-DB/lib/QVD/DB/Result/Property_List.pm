package QVD::DB::Result::Property_List;
use base qw/DBIx::Class/;

__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('properties_list');
__PACKAGE__->add_columns( id   => { data_type => 'integer' },
			  key   => { data_type => 'varchar(1024)' },
			  tenant_id  => { data_type         => 'integer' },
                          description   => { data_type => 'varchar(1024)' } );

__PACKAGE__->set_primary_key('id');
__PACKAGE__->might_have(properties => 'QVD::DB::Result::Host_Property_List', 'property_id', { cascade_delete => 0 });
__PACKAGE__->might_have(properties => 'QVD::DB::Result::OSF_Property_List', 'property_id', { cascade_delete => 0 });
__PACKAGE__->might_have(properties => 'QVD::DB::Result::DI_Property_List', 'property_id', { cascade_delete => 0 });
__PACKAGE__->might_have(properties => 'QVD::DB::Result::User_Property_List', 'property_id', { cascade_delete => 0 });
__PACKAGE__->might_have(properties => 'QVD::DB::Result::VM_Property_List', 'property_id', { cascade_delete => 0 });
__PACKAGE__->belongs_to(tenant => 'QVD::DB::Result::Tenant',  'tenant_id', { cascade_delete => 0 });

1;
