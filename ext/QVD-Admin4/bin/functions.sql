-------------------------------------------------------------------------------------------------------------
------- PROCEDURE TO CREATE DEFAULT ROWS IN tenant_views_setups WHEN ADDING A PROPERTY TO AN ELEMENT --------
-------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_default_tenant_views_for_property() RETURNS trigger AS $$

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

  FOR i IN SELECT * FROM unnest(enum_range(NULL::device_types_enum)) device_type 
                    CROSS JOIN unnest(enum_range(NULL::view_types_enum)) view_type 
                    CROSS JOIN (SELECT id as tenant_id FROM tenants) tenant_id LOOP                                                                                                                                              
    IF EXISTS (SELECT 1 FROM tenant_views_setups v WHERE v.tenant_id=i.tenant_id     AND 
                                                         v.field=NEW.key             AND 
                                                         v.view_type=i.view_type     AND 
                                                         v.device_type=i.device_type AND 
                                                         v.qvd_object=qo             AND 
                                                         v.property='t') THEN                                                                                                                                                            
    --                                                                                                                                                              
    ELSE

    EXECUTE 'INSERT INTO tenant_views_setups (tenant_id,field,view_type,device_type,qvd_object,property,visible) VALUES ($1,$2,$3,$4,$5,$6,$7)' 
             USING i.tenant_id, NEW.key, i.view_type, i.device_type, qo, TRUE, FALSE;
    RAISE NOTICE 'Inserted row in tenant_views_setups by procedure insert_default_tenant_views_for_property'; END IF;

    END LOOP;

-- For the rest of qvd objects

ELSE                                                                                                            

-- Tenant id is found in different ways according to qvd objects

  IF qo = 'vm' THEN                                                                                                                                                            

  SELECT u.tenant_id INTO tid FROM users u JOIN vms vm ON vm.user_id=u.id WHERE vm.id=NEW.vm_id;                                                                                                                       
  ELSIF qo = 'user' THEN

  SELECT u.tenant_id INTO tid FROM users u WHERE u.id=NEW.user_id;                                                                                                                       

  ELSIF qo = 'osf' THEN

  SELECT o.tenant_id INTO tid FROM osfs o WHERE o.id=NEW.osf_id;                                                                                                                       

  ELSIF qo = 'di' THEN

  SELECT o.tenant_id INTO tid FROM osfs o JOIN dis di ON di.osf_id=o.id WHERE di.id=NEW.di_id;                                                                                                     
  ELSE                

  RAISE EXCEPTION 'Invalid qvd_object provided to insert_default_tenant_view_for_property()';	

  END IF;

-- Main process for qvd objects with tenant id for every possible kind of view

  FOR i IN SELECT * FROM unnest(enum_range(NULL::device_types_enum)) device_type CROSS JOIN unnest(enum_range(NULL::view_types_enum)) view_type LOOP                                  

-- Default views are created in qvd object's tenant

    IF EXISTS (SELECT 1 FROM tenant_views_setups v WHERE v.tenant_id=tid             AND 
                                                         v.field=NEW.key             AND 
                                                         v.view_type=i.view_type     AND 
                                                         v.device_type=i.device_type AND
                                                         v.qvd_object=qo             AND 
                                                         v.property='t') THEN                                                                                                                                                            
      --                                                                                                                                                              

    ELSE

      EXECUTE 'INSERT INTO tenant_views_setups (tenant_id,field,view_type,device_type,qvd_object,property,visible) VALUES ($1,$2,$3,$4,$5,$6,$7)' 
               USING tid, NEW.key, i.view_type, i.device_type, qo, TRUE, FALSE;
      RAISE NOTICE 'Inserted row in tenant_views_setups by procedure '; 
    END IF;

-- Default views are created in superadmin's tenant (0)

    IF EXISTS (SELECT 1 FROM tenant_views_setups v WHERE v.tenant_id='0'             AND 
                                                         v.field=NEW.key             AND 
                                                         v.view_type=i.view_type     AND 
                                                         v.device_type=i.device_type AND 
                                                         v.qvd_object=qo             AND 
                                                         v.property='t') THEN                                                                                                                                                            
      --                                                                                                                                                              

    ELSE

      EXECUTE 'INSERT INTO tenant_views_setups (tenant_id,field,view_type,device_type,qvd_object,property,visible) VALUES ($1,$2,$3,$4,$5,$6,$7)' 
               USING 0, NEW.key, i.view_type, i.device_type, qo, TRUE, FALSE;
      RAISE NOTICE 'Tenant View Inserted by procedure'; 
    END IF;

  END LOOP; 
END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-------------------------------------------------------------------------------------------------------
------- PROCEDURE TO DELETE ROWS IN tenant_views_setups WHEN DELETING A PROPERTY TO AN ELEMENT --------
-------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION delete_tenant_views_for_removed_property() RETURNS trigger AS $$

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

--------------------------------------------------------------------------------------------------------
----- TRIGGERS TO TRIGGER THE CREATION/DELETION OF RELATED VIEWS WHEN CREATING/DELETING PROPERTIES -----
--------------------------------------------------------------------------------------------------------

CREATE TRIGGER create_default_tenant_views_for_vm_property AFTER INSERT ON vm_properties FOR EACH ROW EXECUTE PROCEDURE insert_default_tenant_views_for_property(vm);
CREATE TRIGGER create_default_tenant_views_for_user_property AFTER INSERT ON user_properties FOR EACH ROW EXECUTE PROCEDURE insert_default_tenant_views_for_property(user);
CREATE TRIGGER create_default_tenant_views_for_host_property AFTER INSERT ON host_properties FOR EACH ROW EXECUTE PROCEDURE insert_default_tenant_views_for_property(host);
CREATE TRIGGER create_default_tenant_views_for_osf_property AFTER INSERT ON osf_properties FOR EACH ROW EXECUTE PROCEDURE insert_default_tenant_views_for_property(osf);
CREATE TRIGGER create_default_tenant_views_for_di_property AFTER INSERT ON di_properties FOR EACH ROW EXECUTE PROCEDURE insert_default_tenant_views_for_property(di);


CREATE TRIGGER delete_tenant_views_for_removed_vm_property AFTER DELETE ON vm_properties FOR EACH ROW EXECUTE PROCEDURE delete_tenant_views_for_removed_property(vm);
CREATE TRIGGER delete_tenant_views_for_removed_user_property AFTER DELETE ON user_properties FOR EACH ROW EXECUTE PROCEDURE delete_tenant_views_for_removed_property(user);
CREATE TRIGGER delete_tenant_views_for_removed_host_property AFTER DELETE ON host_properties FOR EACH ROW EXECUTE PROCEDURE delete_tenant_views_for_removed_property(host);
CREATE TRIGGER delete_tenant_views_for_removed_osf_property AFTER DELETE ON osf_properties FOR EACH ROW EXECUTE PROCEDURE delete_tenant_views_for_removed_property(osf);
CREATE TRIGGER delete_tenant_views_for_removed_di_property AFTER DELETE ON di_properties FOR EACH ROW EXECUTE PROCEDURE delete_tenant_views_for_removed_property(di);
