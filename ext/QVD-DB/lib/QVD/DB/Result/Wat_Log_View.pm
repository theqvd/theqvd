package QVD::DB::Result::Wat_Log_View;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('wat_log_views');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"

SELECT DISTINCT A.id, 
       CASE WHEN (B.id IS NULL) THEN false ELSE true END as object_deleted,
       CASE WHEN (C.id IS NULL) THEN true ELSE false END as administrator_deleted                                                                           
 FROM wat_log A
 LEFT JOIN wat_log B
 ON A.object_id=B.object_id AND A.qvd_object=B.qvd_object AND A.object_id IS NOT NULL AND B.type_of_action='delete'
 LEFT JOIN administrators C ON C.id=A.administrator_id

"

    );

__PACKAGE__->add_columns( id                      => { data_type => 'integer', 
						       is_auto_increment => 1 },
                          object_deleted          => { data_type => 'boolean' },
                          administrator_deleted   => { data_type => 'boolean' },
    );

__PACKAGE__->set_primary_key('id');

1;
