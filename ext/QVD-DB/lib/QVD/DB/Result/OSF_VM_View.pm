package QVD::DB::Result::OSF_VM_View;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('osfs_vms_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(


"SELECT me.id      as id, 
        COUNT(vms) as number_of_vms, 

 FROM      osfs me 
 LEFT JOIN vms vms ON(vms.osf_id=me.id) 

 GROUP BY me.id"

);

__PACKAGE__->add_columns(
    'id' => {
	data_type => 'integer'
    },

    'number_of_vms_connected' => {
	data_type => 'integer',
    },
    );

1;

