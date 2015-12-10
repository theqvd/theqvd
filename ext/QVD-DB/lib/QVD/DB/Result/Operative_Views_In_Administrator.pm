package QVD::DB::Result::Operative_Views_In_Administrator;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_views_in_administrators');
__PACKAGE__->result_source_instance->deploy_depends_on(
    ["QVD::DB::Result::Operative_Views_In_Tenant"]
);
__PACKAGE__->result_source_instance->is_virtual(0);

my $query_operative_views_in_administrators_only = "
  (SELECT DISTINCT
    device_type,
    view_type,
    tenant_id,
    administrator_id,
    field,
    CASE
      WHEN visible IS NULL THEN false
      ELSE visible
    END,
    0 AS property,
    qvd_object
  FROM views_setups_attributes_administrator setups
    INNER JOIN administrators admins ON setups.administrator_id = admins.id
  UNION
    SELECT DISTINCT
      device_type,
      view_type,
      tenant_id,
      administrator_id,
      key AS field,
      CASE
        WHEN visible IS NULL THEN false
        ELSE visible
      END,
      Properties.id AS property,
      qvd_object
    FROM
      views_setups_properties_administrator AdminSetups
      INNER JOIN qvd_object_properties_list QvdObjProperties ON AdminSetups.qvd_obj_prop_id = QvdObjProperties.id
      INNER JOIN properties_list Properties ON QvdObjProperties.property_id = Properties.id)
";

__PACKAGE__->result_source_instance->view_definition(
"
SELECT
  field,
  tenant_id,
  administrator_id,
  CASE WHEN AdminSetup.visible IS NOT NULL THEN AdminSetup.visible ELSE TenantSetup.visible END AS visible,
  view_type,
  device_type,
  qvd_object,
  property
FROM ($query_operative_views_in_administrators_only) AS AdminSetup
  FULL JOIN operative_views_in_tenants AS TenantSetup
    USING (tenant_id, device_type, view_type, field, property, qvd_object)
"
);

__PACKAGE__->add_columns(
    field  => { data_type => 'varchar(64)' },
    tenant_id  => { data_type => 'integer' },
	administrator_id => { data_type => 'integer', is_nullable => 1},
    visible  => { data_type => 'boolean' },
	view_type   => { data_type => 'administrator_and_tenant_views_setups_view_type_enum' },
	device_type => { data_type => 'administrator_and_tenant_views_setups_device_type_enum' },
	qvd_object  => { data_type => 'administrator_and_tenant_views_setups_qvd_object_enum'},
	property    => { data_type => 'integer'}
);

__PACKAGE__->set_primary_key( qw/ field tenant_id view_type device_type qvd_object property / );

1;

