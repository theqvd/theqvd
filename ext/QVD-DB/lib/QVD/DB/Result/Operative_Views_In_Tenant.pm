package QVD::DB::Result::Operative_Views_In_Tenant;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('operative_views_in_tenants');
__PACKAGE__->result_source_instance->is_virtual(0);
__PACKAGE__->result_source_instance->view_definition(

"
 SELECT DISTINCT dt.dt AS device_type,
    vt.vt AS view_type,
    t.id AS tenant_id,
    p.key AS field,
        CASE
            WHEN r.visible IS NULL THEN false
            ELSE r.visible
        END AS visible,
    true AS property,
    'vm'::administrator_and_tenant_views_setups_qvd_object_enum AS qvd_object
   FROM unnest(enum_range(NULL::administrator_and_tenant_views_setups_device_type_enum)) dt(dt)
     CROSS JOIN unnest(enum_range(NULL::administrator_and_tenant_views_setups_view_type_enum)) vt(vt)
     CROSS JOIN ( SELECT tenants.id
           FROM tenants) t
     CROSS JOIN ( SELECT pl.key,
            vp.vm_id
           FROM vm_properties vp
             JOIN properties_list pl ON pl.id = vp.property_id) p
     JOIN vms v ON p.vm_id = v.id
     JOIN users u ON u.id = v.user_id AND (u.tenant_id = t.id OR t.id = 0)
     LEFT JOIN tenant_views_setups r ON r.device_type = dt.dt AND r.view_type = vt.vt AND r.tenant_id = t.id AND r.field::text = p.key::text AND r.property = true AND r.qvd_object = 'vm'::administrator_and_tenant_views_setups_qvd_object_enum
UNION
 SELECT DISTINCT dt.dt AS device_type,
    vt.vt AS view_type,
    t.id AS tenant_id,
    p.key AS field,
        CASE
            WHEN r.visible IS NULL THEN false
            ELSE r.visible
        END AS visible,
    true AS property,
    'user'::administrator_and_tenant_views_setups_qvd_object_enum AS qvd_object
   FROM unnest(enum_range(NULL::administrator_and_tenant_views_setups_device_type_enum)) dt(dt)
     CROSS JOIN unnest(enum_range(NULL::administrator_and_tenant_views_setups_view_type_enum)) vt(vt)
     CROSS JOIN ( SELECT tenants.id
           FROM tenants) t
     CROSS JOIN ( SELECT pl.key,
            up.user_id
           FROM user_properties up
             JOIN properties_list pl ON pl.id = up.property_id) p
     JOIN users u ON p.user_id = u.id AND (u.tenant_id = t.id OR t.id = 0)
     LEFT JOIN tenant_views_setups r ON r.device_type = dt.dt AND r.view_type = vt.vt AND r.tenant_id = t.id AND r.field::text = p.key::text AND r.property = true AND r.qvd_object = 'user'::administrator_and_tenant_views_setups_qvd_object_enum
UNION
 SELECT DISTINCT dt.dt AS device_type,
    vt.vt AS view_type,
    t.id AS tenant_id,
    p.key AS field,
        CASE
            WHEN r.visible IS NULL THEN false
            ELSE r.visible
        END AS visible,
    true AS property,
    'host'::administrator_and_tenant_views_setups_qvd_object_enum AS qvd_object
   FROM unnest(enum_range(NULL::administrator_and_tenant_views_setups_device_type_enum)) dt(dt)
     CROSS JOIN unnest(enum_range(NULL::administrator_and_tenant_views_setups_view_type_enum)) vt(vt)
     CROSS JOIN ( SELECT tenants.id
           FROM tenants) t
     CROSS JOIN ( SELECT pl.key,
            hp.host_id
           FROM host_properties hp
             JOIN properties_list pl ON pl.id = hp.property_id) p
     LEFT JOIN tenant_views_setups r ON r.device_type = dt.dt AND r.view_type = vt.vt AND r.tenant_id = t.id AND r.field::text = p.key::text AND r.property = true AND r.qvd_object = 'host'::administrator_and_tenant_views_setups_qvd_object_enum
UNION
 SELECT DISTINCT dt.dt AS device_type,
    vt.vt AS view_type,
    t.id AS tenant_id,
    p.key AS field,
        CASE
            WHEN r.visible IS NULL THEN false
            ELSE r.visible
        END AS visible,
    true AS property,
    'osf'::administrator_and_tenant_views_setups_qvd_object_enum AS qvd_object
   FROM unnest(enum_range(NULL::administrator_and_tenant_views_setups_device_type_enum)) dt(dt)
     CROSS JOIN unnest(enum_range(NULL::administrator_and_tenant_views_setups_view_type_enum)) vt(vt)
     CROSS JOIN ( SELECT tenants.id
           FROM tenants) t
     CROSS JOIN ( SELECT pl.key,
            op.osf_id
           FROM osf_properties op
             JOIN properties_list pl ON pl.id = op.property_id) p
     JOIN osfs o ON p.osf_id = o.id AND (o.tenant_id = t.id OR t.id = 0)
     LEFT JOIN tenant_views_setups r ON r.device_type = dt.dt AND r.view_type = vt.vt AND r.tenant_id = t.id AND r.field::text = p.key::text AND r.property = true AND r.qvd_object = 'osf'::administrator_and_tenant_views_setups_qvd_object_enum
UNION
 SELECT DISTINCT dt.dt AS device_type,
    vt.vt AS view_type,
    t.id AS tenant_id,
    p.key AS field,
        CASE
            WHEN r.visible IS NULL THEN false
            ELSE r.visible
        END AS visible,
    true AS property,
    'di'::administrator_and_tenant_views_setups_qvd_object_enum AS qvd_object
   FROM unnest(enum_range(NULL::administrator_and_tenant_views_setups_device_type_enum)) dt(dt)
     CROSS JOIN unnest(enum_range(NULL::administrator_and_tenant_views_setups_view_type_enum)) vt(vt)
     CROSS JOIN ( SELECT tenants.id
           FROM tenants) t
     CROSS JOIN ( SELECT pl.key,
            dp.di_id
           FROM di_properties dp
             JOIN properties_list pl ON pl.id = dp.property_id) p
     JOIN dis d ON p.di_id = d.id
     JOIN osfs o ON o.id = d.osf_id AND (o.tenant_id = t.id OR t.id = 0)
     LEFT JOIN tenant_views_setups r ON r.device_type = dt.dt AND r.view_type = vt.vt AND r.tenant_id = t.id AND r.field::text = p.key::text AND r.property = true AND r.qvd_object = 'di'::administrator_and_tenant_views_setups_qvd_object_enum
UNION
 SELECT tenant_views_setups.device_type,
    tenant_views_setups.view_type,
    tenant_views_setups.tenant_id,
    tenant_views_setups.field,
    tenant_views_setups.visible,
    tenant_views_setups.property,
    tenant_views_setups.qvd_object
   FROM tenant_views_setups
  WHERE tenant_views_setups.property = false
"
);

__PACKAGE__->add_columns(
	device_type  => { data_type => 'administrator_and_tenant_views_setups_device_type_enum' },
	view_type  => { data_type => 'administrator_and_tenant_views_setups_view_type_enum' },
    tenant_id  => { data_type => 'integer' },
	field  => { data_type => 'varchar(64)' },
    visible  => { data_type => 'boolean' },
	property => { data_type => 'boolean'},
	qvd_object => { data_type => 'administrator_and_tenant_views_setups_qvd_object_enum'},
);

1;

