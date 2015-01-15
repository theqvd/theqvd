package QVD::DB::Result::Refresh_Operative_Acls;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('refresh_operative_acls');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(


"
select 1 as success from refresh_operative_acls()

"
);

__PACKAGE__->add_columns(

    success  => { data_type => 'boolean' }
);

__PACKAGE__->set_primary_key( qw/ success / );


1;
