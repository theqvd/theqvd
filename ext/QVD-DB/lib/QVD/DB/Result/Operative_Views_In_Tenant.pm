package QVD::DB::Result::Operative_Views_In_Tenant;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_views_in_tenants');
__PACKAGE__->result_source_instance->is_virtual(0);
__PACKAGE__->result_source_instance->view_definition(

"
SELECT DISTINCT
  device_type,
  view_type,
  tenant_id,
  field,
        CASE
    WHEN visible IS NULL THEN false
    ELSE visible
  END,
  0 AS property,
  qvd_object
FROM views_setups_attributes_tenant attr_setup
UNION
  SELECT DISTINCT
    device_type,
    view_type,
    tenant_id,
    key AS field,
        CASE
      WHEN visible IS NULL THEN false
      ELSE visible
    END,
    properties_list.id AS property,
    qvd_object
  FROM
    views_setups_properties_tenant
    NATURAL INNER JOIN qvd_object_properties_list
    NATURAL INNER JOIN properties_list
"
);

__PACKAGE__->add_columns(
	device_type  => { data_type => 'administrator_and_tenant_views_setups_device_type_enum' },
	view_type  => { data_type => 'administrator_and_tenant_views_setups_view_type_enum' },
    tenant_id  => { data_type => 'integer' },
	field  => { data_type => 'varchar(64)' },
    visible  => { data_type => 'boolean' },
	property => { data_type => 'integer'},
	qvd_object => { data_type => 'administrator_and_tenant_views_setups_qvd_object_enum'},
);

1;

