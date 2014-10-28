package QVD::DB::Result::User_VM_View;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('users_vms_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(


"SELECT me.id              as id, 
        COUNT(vm_runtimes) as number_of_vms_connected, 
        COUNT(vms)         as number_of_vms

 FROM      users me 
 LEFT JOIN vms vms         ON(vms.user_id=me.id) 
 LEFT JOIN vm_runtimes vm_runtimes ON(vm_runtimes.vm_id=vms.id and vm_runtimes.user_state='connected') 

 GROUP BY me.id"

);

__PACKAGE__->add_columns(
    'id' => {
	data_type => 'integer'
    },

    'number_of_vms_connected' => {
	data_type => 'integer',
    },

    'number_of_vms' => {
	data_type => 'integer',
    },
    );

1;
