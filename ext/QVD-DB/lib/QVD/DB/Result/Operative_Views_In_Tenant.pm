package QVD::DB::Result::Operative_Views_In_Tenant;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_views_in_tenants');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"
SELECT * FROM operative_views_in_tenants
"

);

__PACKAGE__->add_columns(

    field  => { data_type => 'varchar(64)' },
    tenant_id  => { data_type => 'integer' },
    visible  => { data_type => 'boolean' },
    view_type  => { data_type => 'varchar(64)' },
    device_type  => { data_type => 'varchar(64)' },
    qvd_object => { data_type => 'varchar(64)'},
    property => { data_type => 'boolean'});

__PACKAGE__->set_primary_key( qw/ field tenant_id view_type device_type qvd_object property / );
1;

