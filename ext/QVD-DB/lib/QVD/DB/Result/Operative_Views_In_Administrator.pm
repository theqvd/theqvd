package QVD::DB::Result::Operative_Views_In_Administrator;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_views_in_administrators');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"


SELECT * FROM (SELECT (CASE WHEN (TV.device_type IS NOT NULL) THEN TV.device_type ELSE AV.device_type END) as device_type, 
       (CASE WHEN (TV.view_type IS NOT NULL) THEN TV.view_type ELSE AV.view_type END) as view_type, 
       (CASE WHEN (TV.qvd_object IS NOT NULL) THEN TV.qvd_object ELSE AV.qvd_object END) as qvd_object, 
       (CASE WHEN (TV.field IS NOT NULL) THEN TV.field ELSE AV.field END) as field, 
       (CASE WHEN (TV.property IS NOT NULL) THEN TV.property ELSE AV.property END) as property, 
       (CASE WHEN (TV.tenant_id IS NOT NULL) THEN TV.tenant_id ELSE AV.tenant_id END) as tenant_id, 
       (CASE WHEN (TV.administrator_id IS NOT NULL) THEN TV.administrator_id ELSE AV.administrator_id END) as administrator_id, 
       (CASE WHEN (AV.visible IS NOT NULL) THEN AV.visible ELSE TV.visible END) as visible
FROM (administrator_views_setups JOIN administrators ON administrators.id=administrator_views_setups.administrator_id) AV
     FULL OUTER JOIN
     (select T.*, A.id as administrator_id from operative_views_in_tenants T LEFT JOIN administrators A ON T.tenant_id=A.tenant_id) TV
     ON TV.device_type=AV.device_type AND 
     TV.view_type=AV.view_type AND
     TV.qvd_object=AV.qvd_object AND
     TV.field=AV.field AND
     TV.property=AV.property AND 
     TV.administrator_id=AV.administrator_id) M

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

