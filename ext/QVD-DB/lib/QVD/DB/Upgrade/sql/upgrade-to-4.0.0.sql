-- New table creation
CREATE TABLE properties_list (
    id integer NOT NULL,
    key character varying(1024) NOT NULL,
    description character varying(1024),
    tenant_id integer NOT NULL
);

CREATE SEQUENCE properties_list_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE properties_list_id_seq OWNED BY properties_list.id;
ALTER TABLE ONLY properties_list ALTER COLUMN id SET DEFAULT nextval('properties_list_id_seq'::regclass);

ALTER TABLE ONLY properties_list
    ADD CONSTRAINT properties_list_pkey PRIMARY KEY (id);

-- Create index and constrains to tenants table

CREATE INDEX user_properties_list_idx_tenant_id ON properties_list USING btree (tenant_id);
 
ALTER TABLE ONLY properties_list
    ADD CONSTRAINT properties_list_key_tenant_id UNIQUE (key, tenant_id);
    
ALTER TABLE ONLY properties_list
    ADD CONSTRAINT properties_list_tenant_id_tenants_id_fkey FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

-- -----------------------------------------------------
-- USER PROPERTIES
-- -----------------------------------------------------

-- New table creation
CREATE TABLE user_properties_list (
    property_id integer NOT NULL
);
 
ALTER TABLE ONLY user_properties_list
    ADD CONSTRAINT user_properties_list_pkey PRIMARY KEY (property_id);

ALTER TABLE ONLY user_properties_list
    ADD CONSTRAINT user_properties_list_property_id_fkey FOREIGN KEY (property_id) REFERENCES properties_list(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

-- Change old trigger by new one in new table
DROP TRIGGER IF EXISTS delete_views_for_removed_user_property ON user_properties;
CREATE TRIGGER delete_elements_for_removed_user_property_list AFTER DELETE ON user_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property('user');
 
-- Modifications in old table

ALTER TABLE user_properties ADD COLUMN property_id integer;

-- Migration of properties inserting existing (DISTINCT) properties from properties table to properties list table 
INSERT INTO properties_list (key, description, tenant_id) (SELECT DISTINCT key, ' ' as description, t.id as tenant_id FROM user_properties as tenant_id CROSS JOIN tenants t WHERE t.id != -1) EXCEPT (SELECT key, description, tenant_id FROM properties_list);

-- Migration of properties list table ids to properties
UPDATE user_properties as up SET property_id = (SELECT id FROM properties_list as pl WHERE pl.key=up.key AND pl.tenant_id = (SELECT tenant_id FROM users as u WHERE u.id = up.user_id));
INSERT INTO user_properties_list (property_id) (SELECT DISTINCT property_id FROM user_properties);

-- Create foreing key between old and new tables

ALTER TABLE ONLY user_properties
    ADD CONSTRAINT user_properties_property_id_fkey FOREIGN KEY (property_id) REFERENCES user_properties_list(property_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


-- -----------------------------------------------------
-- VM PROPERTIES
-- -----------------------------------------------------

-- New table creation
CREATE TABLE vm_properties_list (
    property_id integer NOT NULL
);
 
ALTER TABLE ONLY vm_properties_list
    ADD CONSTRAINT vm_properties_list_pkey PRIMARY KEY (property_id);

ALTER TABLE ONLY vm_properties_list
    ADD CONSTRAINT vm_properties_list_property_id_fkey FOREIGN KEY (property_id) REFERENCES properties_list(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

-- Change old trigger by new one in new table
DROP TRIGGER IF EXISTS delete_views_for_removed_vm_property ON vm_properties;
CREATE TRIGGER delete_elements_for_removed_vm_property_list AFTER DELETE ON vm_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property('vm');
 
-- Modifications in old table
ALTER TABLE vm_properties ADD COLUMN property_id integer;

-- Migration of properties inserting existing (DISTINCT) properties from properties table to properties list table 
INSERT INTO properties_list (key, description, tenant_id) (SELECT DISTINCT key, ' ' as description, t.id as tenant_id FROM vm_properties as tenant_id CROSS JOIN tenants t WHERE t.id != -1) EXCEPT (SELECT key, description, tenant_id FROM properties_list);

-- Migration of properties list table ids to properties
UPDATE vm_properties as vp SET property_id = (SELECT id FROM properties_list as pl WHERE pl.key=vp.key AND pl.tenant_id = (SELECT tenant_id FROM users as u JOIN vms as v ON v.user_id = u.id AND v.id = vp.vm_id));
INSERT INTO vm_properties_list (property_id) (SELECT DISTINCT property_id FROM vm_properties);

-- Create foreing key between old and new tables
ALTER TABLE ONLY vm_properties
    ADD CONSTRAINT vm_properties_property_id_fkey FOREIGN KEY (property_id) REFERENCES vm_properties_list(property_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

-- -----------------------------------------------------
-- HOST PROPERTIES
-- -----------------------------------------------------

-- New table creation
CREATE TABLE host_properties_list (
    property_id integer NOT NULL
);
 
ALTER TABLE ONLY host_properties_list
    ADD CONSTRAINT host_properties_list_pkey PRIMARY KEY (property_id);

ALTER TABLE ONLY host_properties_list
    ADD CONSTRAINT host_properties_list_property_id_fkey FOREIGN KEY (property_id) REFERENCES properties_list(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

-- Change old trigger by new one in new table
DROP TRIGGER IF EXISTS delete_views_for_removed_host_property ON host_properties;
CREATE TRIGGER delete_elements_for_removed_host_property_list AFTER DELETE ON host_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property('host');
 
-- Modifications in old table

ALTER TABLE host_properties ADD COLUMN property_id integer;

-- Migration of properties inserting existing (DISTINCT) properties from properties table to properties list table 
INSERT INTO properties_list (key, description, tenant_id) (SELECT DISTINCT key, ' ' as description, t.id as tenant_id FROM host_properties as tenant_id CROSS JOIN tenants t WHERE t.id != -1) EXCEPT (SELECT key, description, tenant_id FROM properties_list);

-- Migration of properties list table ids to properties
UPDATE host_properties as hp SET property_id = (SELECT id FROM properties_list as pl WHERE pl.key=hp.key AND pl.tenant_id = 1);
INSERT INTO host_properties_list (property_id) (SELECT DISTINCT property_id FROM host_properties);

-- Create foreing key between old and new tables

ALTER TABLE ONLY host_properties
    ADD CONSTRAINT host_properties_property_id_fkey FOREIGN KEY (property_id) REFERENCES host_properties_list(property_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

-- -----------------------------------------------------
-- OSF PROPERTIES
-- -----------------------------------------------------

-- New table creation
CREATE TABLE osf_properties_list (
    property_id integer NOT NULL
);
 
ALTER TABLE ONLY osf_properties_list
    ADD CONSTRAINT osf_properties_list_pkey PRIMARY KEY (property_id);

ALTER TABLE ONLY osf_properties_list
    ADD CONSTRAINT osf_properties_list_property_id_fkey FOREIGN KEY (property_id) REFERENCES properties_list(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

-- Change old trigger by new one in new table
DROP TRIGGER IF EXISTS delete_views_for_removed_osf_property ON osf_properties;
CREATE TRIGGER delete_elements_for_removed_osf_property_list AFTER DELETE ON osf_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property('osf');
 
-- Modifications in old table

ALTER TABLE osf_properties ADD COLUMN property_id integer;

-- Migration of properties inserting existing (DISTINCT) properties from properties table to properties list table 
INSERT INTO properties_list (key, description, tenant_id) (SELECT DISTINCT key, ' ' as description, t.id as tenant_id FROM osf_properties as tenant_id CROSS JOIN tenants t WHERE t.id != -1) EXCEPT (SELECT key, description, tenant_id FROM properties_list);

-- Migration of properties list table ids to properties
UPDATE osf_properties as op SET property_id = (SELECT id FROM properties_list as pl WHERE pl.key=op.key AND pl.tenant_id = (SELECT tenant_id FROM osfs as o WHERE o.id = op.osf_id));
INSERT INTO osf_properties_list (property_id) (SELECT DISTINCT property_id FROM osf_properties);

-- Create foreing key between old and new tables

ALTER TABLE ONLY osf_properties
    ADD CONSTRAINT osf_properties_property_id_fkey FOREIGN KEY (property_id) REFERENCES osf_properties_list(property_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

-- -----------------------------------------------------
-- DI PROPERTIES
-- -----------------------------------------------------

-- New table creation
CREATE TABLE di_properties_list (
    property_id integer NOT NULL
);
 
ALTER TABLE ONLY di_properties_list
    ADD CONSTRAINT di_properties_list_pkey PRIMARY KEY (property_id);

ALTER TABLE ONLY di_properties_list
    ADD CONSTRAINT di_properties_list_property_id_fkey FOREIGN KEY (property_id) REFERENCES properties_list(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

-- Change old trigger by new one in new table
DROP TRIGGER IF EXISTS delete_views_for_removed_di_property ON di_properties;
CREATE TRIGGER delete_elements_for_removed_di_property_list AFTER DELETE ON di_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property('di');
 
-- Modifications in old table
ALTER TABLE di_properties ADD COLUMN property_id integer;

-- Migration of properties inserting existing (DISTINCT) properties from properties table to properties list table 
INSERT INTO properties_list (key, description, tenant_id) (SELECT DISTINCT key, ' ' as description, t.id as tenant_id FROM di_properties as tenant_id CROSS JOIN tenants t WHERE t.id != -1) EXCEPT (SELECT key, description, tenant_id FROM properties_list);

-- Migration of properties list table ids to properties
UPDATE di_properties as dp SET property_id = (SELECT id FROM properties_list as pl WHERE pl.key=dp.key AND pl.tenant_id = (SELECT tenant_id FROM osfs as o JOIN dis as d ON d.osf_id = o.id AND d.id = dp.di_id));
INSERT INTO di_properties_list (property_id) (SELECT DISTINCT property_id FROM di_properties);

-- Create foreing key between old and new tables

ALTER TABLE ONLY di_properties
    ADD CONSTRAINT di_properties_property_id_fkey FOREIGN KEY (property_id) REFERENCES di_properties_list(property_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

-- -----------------------------------------------------
-- CLEAN UNUSED PROPERTIES
-- -----------------------------------------------------

-- Delete not used properties migrated to general table

DELETE FROM properties_list WHERE id NOT IN (SELECT property_id from user_properties_list) and id NOT IN (SELECT property_id from vm_properties_list) and id NOT IN (SELECT property_id from host_properties_list) and id NOT IN (SELECT property_id from osf_properties_list) and id NOT IN (SELECT property_id from di_properties_list);

-- -----------------------------------------------------
-- VIEW
-- -----------------------------------------------------

-- Change view with envolved properties
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
     CROSS JOIN ( SELECT pl.key,
            vp.vm_id
           FROM vm_properties vp JOIN properties_list pl ON pl.id = vp.property_id ) p
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
           FROM user_properties up JOIN properties_list pl ON pl.id = up.property_id ) p
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
           FROM host_properties hp JOIN properties_list pl ON pl.id = hp.property_id ) p
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
           FROM osf_properties op JOIN properties_list pl ON pl.id = op.property_id ) p
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
           FROM di_properties dp JOIN properties_list pl ON pl.id = dp.property_id ) p
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

-- Drop old key column in properties table
ALTER TABLE user_properties DROP CONSTRAINT user_properties_pkey;
ALTER TABLE ONLY user_properties
    ADD CONSTRAINT user_properties_pkey PRIMARY KEY (user_id, property_id);
ALTER TABLE user_properties DROP COLUMN key;

ALTER TABLE vm_properties DROP CONSTRAINT vm_properties_pkey;
ALTER TABLE ONLY vm_properties
    ADD CONSTRAINT vm_properties_pkey PRIMARY KEY (vm_id, property_id);
ALTER TABLE vm_properties DROP COLUMN key;

ALTER TABLE host_properties DROP CONSTRAINT host_properties_pkey;
ALTER TABLE ONLY host_properties
    ADD CONSTRAINT host_properties_pkey PRIMARY KEY (host_id, property_id);
ALTER TABLE host_properties DROP COLUMN key;

ALTER TABLE di_properties DROP CONSTRAINT di_properties_pkey;
ALTER TABLE ONLY di_properties
    ADD CONSTRAINT di_properties_pkey PRIMARY KEY (di_id, property_id);
ALTER TABLE di_properties DROP COLUMN key;

ALTER TABLE osf_properties DROP CONSTRAINT osf_properties_pkey;
ALTER TABLE ONLY osf_properties
    ADD CONSTRAINT osf_properties_pkey PRIMARY KEY (osf_id, property_id);
ALTER TABLE osf_properties DROP COLUMN key;


-------------------------------------------------------------------------------------------------------
------ PROCEDURE TO DELETE ROWS IN tenant_views_setups WHEN DELETING A PROPERTY FROM PROPS LIST -------
-------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION delete_views_for_removed_property() RETURNS trigger AS $$

-- Flags for deleting views in involved tenant and tenant 0

DECLARE delete_in_tenant_n boolean;
DECLARE delete_in_tenant_zero boolean;

-- Variable for rows retrieved by queries

DECLARE i record;

-- Variable for tenant_id involved

DECLARE tid int;

-- Variable for property name

DECLARE pname varchar;

-- Variable for qvd_object involved 

DECLARE qo qvd_objects_enum;
BEGIN
qo := TG_ARGV[0];


IF qo = 'host' THEN     

    SELECT tenant_id, l.key INTO tid, pname FROM host_properties_list pl LEFT JOIN properties_list l ON pl.property_id=l.id WHERE l.id=OLD.property_id;

    IF EXISTS (SELECT 1 FROM host_properties_list pl WHERE pl.property_id=OLD.property_id) THEN
      delete_in_tenant_n := FALSE;
    ELSE
      delete_in_tenant_n := TRUE;
    END IF;

ELSIF qo = 'vm' THEN     
               
    SELECT tenant_id, l.key INTO tid, pname FROM vm_properties_list pl LEFT JOIN properties_list l ON pl.property_id=l.id WHERE l.id=OLD.property_id;

    IF EXISTS (SELECT 1 FROM vm_properties_list pl WHERE pl.property_id=OLD.property_id) THEN
      delete_in_tenant_n := FALSE;
    ELSE
      delete_in_tenant_n := TRUE;
    END IF;

ELSIF qo = 'user' THEN
               
    SELECT tenant_id, l.key INTO tid, pname FROM user_properties_list pl LEFT JOIN properties_list l ON pl.property_id=l.id WHERE l.id=OLD.property_id;

    IF EXISTS (SELECT 1 FROM user_properties_list pl WHERE pl.property_id=OLD.property_id) THEN
      delete_in_tenant_n := FALSE;
    ELSE
      delete_in_tenant_n := TRUE;
    END IF;
               
ELSIF qo = 'osf' THEN

    SELECT tenant_id, l.key INTO tid, pname FROM osf_properties_list pl LEFT JOIN properties_list l ON pl.property_id=l.id WHERE l.id=OLD.property_id;

    IF EXISTS (SELECT 1 FROM osf_properties_list pl WHERE pl.property_id=OLD.property_id) THEN
      delete_in_tenant_n := FALSE;
    ELSE
      delete_in_tenant_n := TRUE;
    END IF;

ELSIF qo = 'di' THEN

    SELECT tenant_id, l.key INTO tid, pname FROM di_properties_list pl LEFT JOIN properties_list l ON pl.property_id=l.id WHERE l.id=OLD.property_id;

    IF EXISTS (SELECT 1 FROM di_properties_list pl WHERE pl.property_id=OLD.property_id) THEN
      delete_in_tenant_n := FALSE;
    ELSE
      delete_in_tenant_n := TRUE;
    END IF;

ELSE                

    RAISE EXCEPTION 'Invalid qvd_object provided to delete_views_for_removed_property()';	

END IF;

-- Check if there is any other property with same name in any tenant
IF EXISTS (SELECT 1 FROM properties_list pl WHERE pl.key IN (SELECT key FROM properties_list WHERE id=OLD.property_id)) THEN
  delete_in_tenant_zero := FALSE;
ELSE
  delete_in_tenant_zero := TRUE;
END IF;
               

IF delete_in_tenant_n  THEN

    EXECUTE 'DELETE FROM tenant_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3 AND tenant_id=$4' USING pname, qo, TRUE, tid;
    RAISE NOTICE 'Deleted rows in tenant_views_setups by procedure delete_views_for_removed_property'; 

    FOR i IN SELECT a.id as administrator_id FROM administrators a WHERE a.tenant_id=tid LOOP
      EXECUTE 'DELETE FROM administrator_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3 AND administrator_id=$4' USING pname, qo, TRUE, i.administrator_id;
      RAISE NOTICE 'Deleted rows in tenant_views_setups by procedure delete_views_for_removed_property'; 
    END LOOP;

ELSE

END IF;

-- If there are not properties with same key as deleted in any tenant, delete it from tenant 0 too vecause tenant 0 have available all tenant properties in views

IF  delete_in_tenant_zero THEN

    EXECUTE 'DELETE FROM tenant_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3 AND tenant_id=$4' USING pname, qo, TRUE, 0;
    RAISE NOTICE 'Deleted rows in tenant_views_setups by procedure delete_views_for_removed_property'; 

    FOR i IN SELECT a.id as administrator_id FROM administrators a WHERE a.tenant_id='0' LOOP
      EXECUTE 'DELETE FROM administrator_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3 AND administrator_id=$4' USING pname, qo, TRUE, i.administrator_id;
      RAISE NOTICE 'Deleted rows in administrator_views_setups by procedure delete_views_for_removed_property'; 
    END LOOP;

ELSE

END IF;

RETURN OLD;
END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------------------------------------------------------
----- TRIGGERS TO TRIGGER THE CREATION/DELETION OF RELATED VIEWS WHEN CREATING/DELETING PROPERTIES -----
--------------------------------------------------------------------------------------------------------

DROP TRIGGER delete_views_for_removed_vm_property ON vm_properties;
DROP TRIGGER delete_views_for_removed_user_property ON user_properties;
DROP TRIGGER delete_views_for_removed_host_property ON host_properties;
DROP TRIGGER delete_views_for_removed_osf_property ON osf_properties;
DROP TRIGGER delete_views_for_removed_di_property ON di_properties;

CREATE TRIGGER delete_views_for_removed_vm_property AFTER DELETE ON vm_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property(vm);
CREATE TRIGGER delete_views_for_removed_user_property AFTER DELETE ON user_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property(user);
CREATE TRIGGER delete_views_for_removed_host_property AFTER DELETE ON host_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property(host);
CREATE TRIGGER delete_views_for_removed_osf_property AFTER DELETE ON osf_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property(osf);
CREATE TRIGGER delete_views_for_removed_di_property AFTER DELETE ON di_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property(di);