package QVD::DB::Result::Operative_Views_In_Administrator;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_views_in_administrators');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"

SELECT T.device_type as device_type, 
       T.view_type as view_type, 
       T.qvd_object as qvd_object,
       T.field as field, 
       T.property as property, 
       T.tenant_id as tenant_id, 
       A.id as administrator_id,
       (CASE WHEN (AV.visible IS NOT NULL) THEN AV.visible ELSE T.visible END) as visible

FROM operative_views_in_tenants T 
CROSS JOIN (select id,tenant_id from administrators) A
LEFT JOIN administrator_views_setups AV 
ON T.device_type=AV.device_type AND 
   T.view_type=AV.view_type AND
   T.qvd_object=AV.qvd_object AND
   T.field=AV.field AND
   T.property=AV.property AND 
   A.id=AV.administrator_id

WHERE A.tenant_id=T.tenant_id


"

);

__PACKAGE__->add_columns(

    field  => { data_type => 'varchar(64)' },
    tenant_id  => { data_type => 'integer' },
    administrator_id => { data_type => 'integer',
			  is_nullable => 1},
    visible  => { data_type => 'boolean' },
    view_type  => { data_type => 'varchar(64)' },
    device_type  => { data_type => 'varchar(64)' },
    qvd_object => { data_type => 'varchar(64)'},
    property => { data_type => 'boolean'});

__PACKAGE__->set_primary_key( qw/ field tenant_id view_type device_type qvd_object property / );
1;

