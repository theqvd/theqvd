package QVD::DB::Result::Tenant_Views_Setups_View;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('tenant_views_setups_views');
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(

"

SELECT A.*, (CASE WHEN (B.visible IS NULL) THEN 'f' ELSE B.visible END) as visible FROM 
(
  SELECT tenant_id, field, view_type, device_type, qvd_object, property FROM virtual_vm_property_views
  UNION
  SELECT  tenant_id, field, view_type, device_type, qvd_object, property FROM virtual_user_property_views
  UNION
  SELECT tenant_id, field, view_type, device_type, qvd_object, property FROM virtual_host_property_views
  UNION
  SELECT  tenant_id, field, view_type, device_type, qvd_object, property FROM virtual_osf_property_views
  UNION
  SELECT  tenant_id, field, view_type, device_type, qvd_object, property FROM virtual_di_property_views
  UNION
  SELECT tenant_id, field, view_type, device_type, cast (qvd_object as text) as qvd_object, property FROM tenant_views_setups WHERE property='0'
) A LEFT JOIN tenant_views_setups B ON A.tenant_id=B.tenant_id AND A.field=B.field AND A.view_type=B.view_type AND A.device_type=B.device_type AND A.qvd_object=cast (B.qvd_object as text) AND A.property = B.property  
WHERE A.tenant_id = ? AND A.qvd_object= ?


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

1;

