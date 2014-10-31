package QVD::DB::Result::OSF_Properties_List_View;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('osf_properties_list_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"SELECT array_remove(array_agg(distinct properties.key),NULL)   as properties,
        me.tenant_id as tenant_id
 FROM      osfs me 
 LEFT JOIN osf_properties properties ON(properties.osf_id=me.id) 
 GROUP BY me.tenant_id
"
);

__PACKAGE__->add_columns(
 
    'tenant_id' => {
	data_type => 'integer'
    },
    'properties' => {
	data_type => 'ARRAY',
    }
    );

1;

