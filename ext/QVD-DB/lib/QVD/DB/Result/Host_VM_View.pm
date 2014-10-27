package QVD::DB::Result::Host_VM_View;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('hosts_vms_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(


"SELECT me.id              as id, 
        COUNT(vm_runtimes) as number_of_vms_connected, 

 FROM      hosts       me 
 LEFT JOIN vm_runtimes vm_runtimes ON(vm_runtimes.host_id=me.id and vm_runtimes.vm_state='running') 

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
