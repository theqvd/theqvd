-- New table creation
CREATE TABLE properties_list (
    id integer NOT NULL,
    key character varying(1024) NOT NULL,
    description character varying(1024) NOT NULL,
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
CREATE TRIGGER delete_elements_for_removed_user_property_list AFTER DELETE ON user_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_elements_for_removed_property('user');
 
-- Modifications in old table

ALTER TABLE user_properties ADD COLUMN property_id integer;

-- Migration of properties inserting existing (DISTINCT) properties from properties table to properties list table 
INSERT INTO properties_list (key, description, tenant_id) (SELECT DISTINCT key, ' ' as description, t.id as tenant_id FROM user_properties as tenant_id CROSS JOIN tenants t WHERE t.id != -1) EXCEPT (SELECT key, description, tenant_id FROM properties_list);

-- Migration of properties list table ids to properties
UPDATE user_properties as up SET property_id = (SELECT id FROM properties_list as pl WHERE pl.key=up.key AND pl.tenant_id = (SELECT tenant_id FROM users as u WHERE u.id = up.user_id));
INSERT INTO user_properties_list (property_id) (SELECT DISTINCT property_id FROM user_properties);

-- Remove useless column from properties table
ALTER TABLE user_properties DROP COLUMN key;

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
CREATE TRIGGER delete_elements_for_removed_vm_property_list AFTER DELETE ON vm_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_elements_for_removed_property('vm');
 
-- Modifications in old table
ALTER TABLE vm_properties ADD COLUMN property_id integer;

-- Migration of properties inserting existing (DISTINCT) properties from properties table to properties list table 
INSERT INTO properties_list (key, description, tenant_id) (SELECT DISTINCT key, ' ' as description, t.id as tenant_id FROM vm_properties as tenant_id CROSS JOIN tenants t WHERE t.id != -1) EXCEPT (SELECT key, description, tenant_id FROM properties_list);

-- Migration of properties list table ids to properties
UPDATE vm_properties as vp SET property_id = (SELECT id FROM properties_list as pl WHERE pl.key=vp.key AND pl.tenant_id = (SELECT tenant_id FROM users as u JOIN vms as v ON v.user_id = u.id AND v.id = vp.vm_id));
INSERT INTO vm_properties_list (property_id) (SELECT DISTINCT property_id FROM vm_properties);

-- Remove useless column from properties table
ALTER TABLE vm_properties DROP COLUMN key;

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
CREATE TRIGGER delete_elements_for_removed_host_property_list AFTER DELETE ON host_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_elements_for_removed_property('host');
 
-- Modifications in old table

ALTER TABLE host_properties ADD COLUMN property_id integer;

-- Migration of properties inserting existing (DISTINCT) properties from properties table to properties list table 
INSERT INTO properties_list (key, description, tenant_id) (SELECT DISTINCT key, ' ' as description, t.id as tenant_id FROM host_properties as tenant_id CROSS JOIN tenants t WHERE t.id != -1) EXCEPT (SELECT key, description, tenant_id FROM properties_list);

-- Migration of properties list table ids to properties
UPDATE host_properties as hp SET property_id = (SELECT id FROM properties_list as pl WHERE pl.key=hp.key AND pl.tenant_id = 1);
INSERT INTO host_properties_list (property_id) (SELECT DISTINCT property_id FROM host_properties);

-- Remove useless column from properties table
ALTER TABLE host_properties DROP COLUMN key;

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
CREATE TRIGGER delete_elements_for_removed_osf_property_list AFTER DELETE ON osf_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_elements_for_removed_property('osf');
 
-- Modifications in old table

ALTER TABLE osf_properties ADD COLUMN property_id integer;

-- Migration of properties inserting existing (DISTINCT) properties from properties table to properties list table 
INSERT INTO properties_list (key, description, tenant_id) (SELECT DISTINCT key, ' ' as description, t.id as tenant_id FROM osf_properties as tenant_id CROSS JOIN tenants t WHERE t.id != -1) EXCEPT (SELECT key, description, tenant_id FROM properties_list);

-- Migration of properties list table ids to properties
UPDATE osf_properties as op SET property_id = (SELECT id FROM properties_list as pl WHERE pl.key=op.key AND pl.tenant_id = (SELECT tenant_id FROM osfs as o WHERE o.id = op.osf_id));
INSERT INTO osf_properties_list (property_id) (SELECT DISTINCT property_id FROM osf_properties);

-- Remove useless column from properties table
ALTER TABLE osf_properties DROP COLUMN key;

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
CREATE TRIGGER delete_elements_for_removed_di_property_list AFTER DELETE ON di_properties_list FOR EACH ROW EXECUTE PROCEDURE delete_elements_for_removed_property('di');
 
-- Modifications in old table
ALTER TABLE di_properties ADD COLUMN property_id integer;

-- Migration of properties inserting existing (DISTINCT) properties from properties table to properties list table 
INSERT INTO properties_list (key, description, tenant_id) (SELECT DISTINCT key, ' ' as description, t.id as tenant_id FROM di_properties as tenant_id CROSS JOIN tenants t WHERE t.id != -1) EXCEPT (SELECT key, description, tenant_id FROM properties_list);

-- Migration of properties list table ids to properties
UPDATE di_properties as dp SET property_id = (SELECT id FROM properties_list as pl WHERE pl.key=dp.key AND pl.tenant_id = (SELECT tenant_id FROM osfs as o JOIN dis as d ON d.osf_id = o.id AND d.id = dp.di_id));
INSERT INTO di_properties_list (property_id) (SELECT DISTINCT property_id FROM di_properties);


-- Remove useless column from properties table
ALTER TABLE di_properties DROP COLUMN key;

-- Create foreing key between old and new tables

ALTER TABLE ONLY di_properties
    ADD CONSTRAINT di_properties_property_id_fkey FOREIGN KEY (property_id) REFERENCES di_properties_list(property_id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;