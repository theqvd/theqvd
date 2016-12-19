-- Modifications in old table
ALTER TABLE host_properties ADD COLUMN key character varying(1024);
UPDATE host_properties as hp SET key = (SELECT key FROM properties_list as pl WHERE pl.id=hp.property_id);
ALTER TABLE host_properties DROP CONSTRAINT host_properties_pkey;
ALTER TABLE ONLY host_properties
    ADD CONSTRAINT host_properties_pkey PRIMARY KEY (host_id, key);

ALTER TABLE vm_properties ADD COLUMN key character varying(1024);
UPDATE vm_properties as vp SET key = (SELECT key FROM properties_list as pl WHERE pl.id=vp.property_id);
ALTER TABLE vm_properties DROP CONSTRAINT vm_properties_pkey;
ALTER TABLE ONLY vm_properties
    ADD CONSTRAINT vm_properties_pkey PRIMARY KEY (vm_id, key);

ALTER TABLE user_properties ADD COLUMN key character varying(1024);
UPDATE user_properties as up SET key = (SELECT key FROM properties_list as pl WHERE pl.id=up.property_id);
ALTER TABLE user_properties DROP CONSTRAINT user_properties_pkey;
ALTER TABLE ONLY user_properties
    ADD CONSTRAINT user_properties_pkey PRIMARY KEY (user_id, key);

ALTER TABLE osf_properties ADD COLUMN key character varying(1024);
UPDATE osf_properties as op SET key = (SELECT key FROM properties_list as pl WHERE pl.id=op.property_id);
ALTER TABLE osf_properties DROP CONSTRAINT osf_properties_pkey;
ALTER TABLE ONLY osf_properties
    ADD CONSTRAINT osf_properties_pkey PRIMARY KEY (osf_id, key);

ALTER TABLE di_properties ADD COLUMN key character varying(1024);
UPDATE di_properties as dp SET key = (SELECT key FROM properties_list as pl WHERE pl.id=dp.property_id);
ALTER TABLE di_properties DROP CONSTRAINT di_properties_pkey;
ALTER TABLE ONLY di_properties
    ADD CONSTRAINT di_properties_pkey PRIMARY KEY (di_id, key);



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








-------------------------------------------------------------------------------------------------------
------- PROCEDURE TO DELETE ROWS IN tenant_views_setups WHEN DELETING A PROPERTY TO AN ELEMENT --------
-------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION delete_views_for_removed_property() RETURNS trigger AS $$

-- Flags for deleting views in involved tenant and tenant 0

DECLARE delete_in_tenant_n boolean;
DECLARE delete_in_tenant_zero boolean;

-- Variable for rows retrieved by queries

DECLARE i record;

-- Variable for tenant_id involved

DECLARE tid int;

-- Variable for qvd_object involved 

DECLARE qo qvd_objects_enum;
BEGIN
qo := TG_ARGV[0];


-- Hosts are not related to any tenant, so they have the following specific behaviour

IF qo = 'host' THEN

    IF EXISTS (SELECT 1 FROM host_properties p WHERE p.key=OLD.key) THEN                                          
    --                                                                                                                                                              
    ELSE

      EXECUTE 'DELETE FROM tenant_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3' USING OLD.key, qo, TRUE;
      RAISE NOTICE 'Deleted rows in tenant_views_setups by procedure delete_tenant_views_for_removed_property'; 

      EXECUTE 'DELETE FROM administrator_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3' USING OLD.key, qo, TRUE;
      RAISE NOTICE 'Deleted rows in administrator_views_setups by procedure delete_tenant_views_for_removed_property'; 

    END IF;

-- For the rest of qvd objects

ELSE                                                                                                            

-- Tenant id and properties are found in different ways according to qvd objects

  IF qo = 'vm' THEN                                                                                                                                                            

    SELECT u.tenant_id INTO tid FROM users u JOIN vms vm ON vm.user_id=u.id WHERE vm.id=OLD.vm_id;
    IF EXISTS (SELECT 1 FROM vm_properties p JOIN vms vm ON p.vm_id=vm.id JOIN users u ON u.id=vm.user_id WHERE p.key=OLD.key AND u.tenant_id=tid) THEN
      delete_in_tenant_n := FALSE;
    ELSE
      delete_in_tenant_n := TRUE;
    END IF;

    IF EXISTS (SELECT 1 FROM vm_properties p WHERE p.key=OLD.key) THEN
      delete_in_tenant_zero := FALSE;
    ELSE
      delete_in_tenant_zero := TRUE;
    END IF;
                       
  ELSIF qo = 'user' THEN

    SELECT u.tenant_id INTO tid FROM users u WHERE u.id=OLD.user_id;                                                                                                                       
    IF EXISTS (SELECT 1 FROM user_properties p JOIN users u ON u.id=p.user_id WHERE p.key=OLD.key AND u.tenant_id=tid) THEN
      delete_in_tenant_n := FALSE;
    ELSE
      delete_in_tenant_n := TRUE;
    END IF;

    IF EXISTS (SELECT 1 FROM user_properties p WHERE p.key=OLD.key) THEN
      delete_in_tenant_zero := FALSE;
    ELSE
      delete_in_tenant_zero := TRUE;
    END IF;

  ELSIF qo = 'osf' THEN

    SELECT o.tenant_id INTO tid FROM osfs o WHERE o.id=OLD.osf_id;                                                                                                                       
    IF EXISTS (SELECT 1 FROM osf_properties p JOIN osfs o ON o.id=p.osf_id WHERE p.key=OLD.key AND o.tenant_id=tid) THEN
      delete_in_tenant_n := FALSE;
    ELSE
      delete_in_tenant_n := TRUE;
    END IF;

    IF EXISTS (SELECT 1 FROM osf_properties p WHERE p.key=OLD.key) THEN
      delete_in_tenant_zero := FALSE;
    ELSE
      delete_in_tenant_zero := TRUE;
    END IF;

  ELSIF qo = 'di' THEN

    SELECT o.tenant_id INTO tid FROM osfs o JOIN dis di ON di.osf_id=o.id WHERE di.id=OLD.di_id;
    IF EXISTS (SELECT 1 FROM di_properties p JOIN dis di ON p.di_id=di.id JOIN osfs o ON o.id=di.osf_id WHERE p.key=OLD.key AND o.tenant_id=tid) THEN
      delete_in_tenant_n := FALSE;
    ELSE
      delete_in_tenant_n := TRUE;
    END IF;

    IF EXISTS (SELECT 1 FROM di_properties p WHERE p.key=OLD.key) THEN
      delete_in_tenant_zero := FALSE;
    ELSE
      delete_in_tenant_zero := TRUE;
    END IF;
       
  ELSE                

  RAISE EXCEPTION 'Invalid qvd_object provided to delete_tenant_views_for_removed_property()';	

  END IF;

  IF delete_in_tenant_n  THEN
    
    EXECUTE 'DELETE FROM tenant_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3 AND tenant_id=$4' USING OLD.key, qo, TRUE, tid;
    RAISE NOTICE 'Deleted rows in tenant_views_setups by procedure delete_tenant_views_for_removed_property'; 

    FOR i IN SELECT a.id as administrator_id FROM administrators a WHERE a.tenant_id=tid LOOP
      EXECUTE 'DELETE FROM administrator_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3 AND administrator_id=$4' USING OLD.key, qo, TRUE, i.administrator_id;
      RAISE NOTICE 'Deleted rows in tenant_views_setups by procedure delete_tenant_views_for_removed_property'; 
    END LOOP;
  
  ELSE

  END IF;

  IF  delete_in_tenant_zero THEN

    EXECUTE 'DELETE FROM tenant_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3 AND tenant_id=$4' USING OLD.key, qo, TRUE, 0;
    RAISE NOTICE 'Deleted rows in tenant_views_setups by procedure delete_tenant_views_for_removed_property'; 

    FOR i IN SELECT a.id as administrator_id FROM administrators a WHERE a.tenant_id='0' LOOP
      EXECUTE 'DELETE FROM administrator_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3 AND administrator_id=$4' USING OLD.key, qo, TRUE, i.administrator_id;
      RAISE NOTICE 'Deleted rows in administrator_views_setups by procedure delete_tenant_views_for_removed_property'; 
    END LOOP;

  ELSE

  END IF;
END IF;

RETURN OLD;
END;
$$ LANGUAGE plpgsql;



DROP TRIGGER delete_views_for_removed_vm_property ON vm_properties_list;
DROP TRIGGER delete_views_for_removed_user_property ON user_properties_list;
DROP TRIGGER delete_views_for_removed_host_property ON host_properties_list;
DROP TRIGGER delete_views_for_removed_osf_property ON osf_properties_list;
DROP TRIGGER delete_views_for_removed_di_property ON di_properties_list;

CREATE TRIGGER delete_views_for_removed_vm_property AFTER DELETE ON vm_properties FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property(vm);
CREATE TRIGGER delete_views_for_removed_user_property AFTER DELETE ON user_properties FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property(user);
CREATE TRIGGER delete_views_for_removed_host_property AFTER DELETE ON host_properties FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property(host);
CREATE TRIGGER delete_views_for_removed_osf_property AFTER DELETE ON osf_properties FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property(osf);
CREATE TRIGGER delete_views_for_removed_di_property AFTER DELETE ON di_properties FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property(di);