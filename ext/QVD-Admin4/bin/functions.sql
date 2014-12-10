CREATE FUNCTION insert_default_tenant_view_for_property() RETURNS trigger AS $$
DECLARE i record;
DECLARE tid int;
DECLARE qo qvd_objects_enum;
BEGIN
qo := TG_ARGV[0];

IF qo = 'vm'

THEN                                                                                                                                                            

SELECT u.tenant_id INTO tid FROM users u JOIN vms vm ON vm.user_id=u.id WHERE vm.id=NEW.vm_id;                                                                                                                       
ELSIF qo = 'user'

THEN

SELECT u.tenant_id INTO tid FROM users u WHERE u.id=NEW.user_id;                                                                                                                       

ELSIF qo = 'osf'

THEN

SELECT o.tenant_id INTO tid FROM osfs o WHERE o.id=NEW.osf_id;                                                                                                                       

ELSIF qo = 'di'

THEN

SELECT o.tenant_id INTO tid FROM osfs o JOIN dis di ON di.osf_id=o.id WHERE di.id=NEW.di_id;                                                                                                                     

ELSIF qo = 'host'

THEN
                             
ELSE

RAISE EXCEPTION 'Invalid qvd_object provided to insert_default_tenant_view_for_property()'; 

END IF;

FOR i IN SELECT * FROM unnest(enum_range(NULL::device_types_enum)) device_type CROSS JOIN unnest(enum_range(NULL::view_types_enum)) view_type LOOP                                                                                                                                              
IF EXISTS (SELECT 1 FROM tenant_views_setups v WHERE v.tenant_id=tid AND v.field=NEW.key AND v.view_type=i.view_type AND v.device_type=i.device_type AND v.qvd_object=qo AND v.property='t')
THEN                                                                                                                                                            
--                                                                                                                                                              
ELSE
EXECUTE 'INSERT INTO tenant_views_setups (tenant_id,field,view_type,device_type,qvd_object,property,visible) VALUES ($1,$2,$3,$4,$5,$6,$7)' USING tid, NEW.key, i.view_type, i.device_type, qo, TRUE, FALSE;
RAISE NOTICE 'Inserted row in tenant_views_setups by procedure '; END IF;

IF EXISTS (SELECT 1 FROM tenant_views_setups v WHERE v.tenant_id='0' AND v.field=NEW.key AND v.view_type=i.view_type AND v.device_type=i.device_type AND v.qvd_object=qo AND v.property='t')
THEN                                                                                                                                                            
--                                                                                                                                                              
ELSE
EXECUTE 'INSERT INTO tenant_views_setups (tenant_id,field,view_type,device_type,qvd_object,property,visible) VALUES ($1,$2,$3,$4,$5,$6,$7)' USING 0, NEW.key, i.view_type, i.device_type, qo, TRUE, FALSE;
RAISE NOTICE 'Tenant View Inserted by procedure'; END IF;

END LOOP; RETURN NEW;
END;
$$ LANGUAGE plpgsql;






CREATE FUNCTION insert_default_tenant_view_for_host_property() RETURNS trigger AS $$
DECLARE i record;
DECLARE qo qvd_objects_enum;
BEGIN
qo := 'host';

FOR i IN SELECT * FROM unnest(enum_range(NULL::device_types_enum)) device_type CROSS JOIN unnest(enum_range(NULL::view_types_enum)) view_type CROSS JOIN (SELECT id FROM tenants) tenant_id) LOOP                                                                                                                                              
IF EXISTS (SELECT 1 FROM tenant_views_setups v WHERE v.tenant_id=i.tenant_id AND v.field=NEW.key AND v.view_type=i.view_type AND v.device_type=i.device_type AND v.qvd_object=qo AND v.property='t')
THEN                                                                                                                                                            
--                                                                                                                                                              
ELSE
EXECUTE 'INSERT INTO tenant_views_setups (tenant_id,field,view_type,device_type,qvd_object,property,visible) VALUES ($1,$2,$3,$4,$5,$6,$7)' USING i.tenant_id, NEW.key, i.view_type, i.device_type, qo, TRUE, FALSE;
RAISE NOTICE 'Inserted row in tenant_views_setups by procedure '; END IF;

END LOOP; RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE FUNCTION delete_tenant_view_for_host_property() RETURNS trigger AS $$
DECLARE qo qvd_objects_enum;
DECLARE tid int;
BEGIN
qo := 'host';

IF EXISTS (SELECT 1 FROM host_properties WHERE key=OLD.key)
THEN                                                                                                                                                            
--                                                                                                                                                              
ELSE
EXECUTE 'DELETE FROM tenant_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3' USING OLD.key, qo, TRUE;
RAISE NOTICE 'Inserted row in tenant_views_setups by procedure '; 

END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION delete_tenant_view_for_vm_property() RETURNS trigger AS $$
DECLARE tid int;
DECLARE qo qvd_objects_enum;
BEGIN
qo := 'vm';

SELECT u.tenant_id INTO tid FROM users u JOIN vms vm ON vm.user_id=u.id WHERE vm.id=OLD.vm_id;                                                                                                                       
IF EXISTS (SELECT 1 FROM vm_properties p JOIN vms vm ON p.vm_id=vm.id JOIN users u ON u.id=vm.user_id WHERE p.key=OLD.key AND u.tenant_id=tid)
THEN                                                                                                                                                            
--                                                                                                                                                              
ELSE
EXECUTE 'DELETE FROM tenant_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3 AND tenant_id=$4' USING OLD.key, qo, TRUE, tid;
RAISE NOTICE 'Inserted row in tenant_views_setups by procedure '; 

END IF;

IF EXISTS (SELECT 1 FROM vm_properties p WHERE p.key=OLD.key)
THEN                                                                                                                                                            
--                                                                                                                                                              
ELSE
EXECUTE 'DELETE FROM tenant_views_setups WHERE field=$1 AND qvd_object=$2 AND property=$3 AND tenant_id=$4' USING OLD.key, qo, TRUE, 0;
RAISE NOTICE 'Inserted row in tenant_views_setups by procedure '; 

END IF;

RETURN NEW;
END;
$$ LANGUAGE plpgsql;
