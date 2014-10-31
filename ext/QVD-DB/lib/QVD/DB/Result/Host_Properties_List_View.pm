package QVD::DB::Result::Host_Properties_List_View;

use base qw/DBIx::Class::Core/;
use Mojo::JSON qw(decode_json);

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('host_properties_list_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"SELECT array_remove(array_agg(distinct properties.key),NULL)   as properties
 FROM      hosts me 
 LEFT JOIN host_properties properties ON(properties.host_id=me.id) 
"
);

__PACKAGE__->add_columns(
 
    'properties' => {
	data_type => 'ARRAY',
    }
    );

1;

