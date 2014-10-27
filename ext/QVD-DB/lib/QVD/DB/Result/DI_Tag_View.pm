package QVD::DB::Result::DI_Tag_View;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('dis_tags_view');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"SELECT me.id    as id, 
        tags.tag as tag_name, 
        tags.id  as tag_id, 

 FROM      dis me 
 LEFT JOIN di_tags tags ON(tags.di_id=me.id) 
 GROUP BY me.id, tags.tag, tags.id"

);

__PACKAGE__->add_columns(
    'id' => {
	data_type => 'integer'
    },

    'tag_name' => {
	data_type => 'varchar(64)',
    },

    'tag_id' => {
	data_type => 'integer',
    },
    );

1;
