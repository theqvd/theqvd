-- Modifications in old table
ALTER TABLE host_properties ADD COLUMN key character varying(1024);
UPDATE host_properties as hp SET key = (SELECT key FROM properties_list as pl WHERE pl.id=hp.property_id);

ALTER TABLE vm_properties ADD COLUMN key character varying(1024);
UPDATE user_properties as vp SET key = (SELECT key FROM properties_list as pl WHERE pl.id=vp.property_id);

ALTER TABLE user_properties ADD COLUMN key character varying(1024);
UPDATE user_properties as up SET key = (SELECT key FROM properties_list as pl WHERE pl.id=up.property_id);

ALTER TABLE osf_properties ADD COLUMN key character varying(1024);
UPDATE osf_properties as op SET key = (SELECT key FROM properties_list as pl WHERE pl.id=op.property_id);

ALTER TABLE di_properties ADD COLUMN key character varying(1024);
UPDATE di_properties as dp SET key = (SELECT key FROM properties_list as pl WHERE pl.id=dp.property_id);



-- Restore operative views in tenants view
CREATE OR REPLACE VIEW operative_views_in_tenants AS 
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
     CROSS JOIN ( SELECT vm_properties.key,
            vm_properties.vm_id
           FROM vm_properties) p
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
     CROSS JOIN ( SELECT user_properties.key,
            user_properties.user_id
           FROM user_properties) p
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
     CROSS JOIN ( SELECT host_properties.key
           FROM host_properties) p
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
     CROSS JOIN ( SELECT osf_properties.key,
            osf_properties.osf_id
           FROM osf_properties) p
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
     CROSS JOIN ( SELECT di_properties.key,
            di_properties.di_id
           FROM di_properties) p
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
  WHERE tenant_views_setups.property = false;

ALTER TABLE operative_views_in_tenants
  OWNER TO qvd;


-- Restore properties 3.5 structure
ALTER TABLE di_properties DROP CONSTRAINT di_properties_property_id_fkey;
ALTER TABLE di_properties DROP property_id;
DROP TABLE di_properties_list;

ALTER TABLE vm_properties DROP CONSTRAINT vm_properties_property_id_fkey;
ALTER TABLE vm_properties DROP property_id;
DROP TABLE vm_properties_list;

ALTER TABLE user_properties DROP CONSTRAINT user_properties_property_id_fkey;
ALTER TABLE user_properties DROP property_id;
DROP TABLE user_properties_list;

ALTER TABLE osf_properties DROP CONSTRAINT osf_properties_property_id_fkey;
ALTER TABLE osf_properties DROP property_id;
DROP TABLE osf_properties_list;

ALTER TABLE host_properties DROP CONSTRAINT host_properties_property_id_fkey;
ALTER TABLE host_properties DROP property_id;
DROP TABLE host_properties_list;

DROP TABLE properties_list;
