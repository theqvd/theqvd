--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: device_types_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE device_types_enum AS ENUM (
    'mobile',
    'desktop'
);


ALTER TYPE public.device_types_enum OWNER TO postgres;

--
-- Name: language_options_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE language_options_enum AS ENUM (
    'es',
    'en',
    'default',
    'auto'
);


ALTER TYPE public.language_options_enum OWNER TO postgres;

--
-- Name: qvd_objects_enum; Type: TYPE; Schema: public; Owner: qvd
--

CREATE TYPE qvd_objects_enum AS ENUM (
    'user',
    'vm',
    'host',
    'osf',
    'di',
    'role',
    'administrator',
    'tenant'
);


ALTER TYPE public.qvd_objects_enum OWNER TO qvd;

--
-- Name: view_types_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE view_types_enum AS ENUM (
    'filter',
    'list_column'
);


ALTER TYPE public.view_types_enum OWNER TO postgres;

--
-- Name: acls_in_role_recursive(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION acls_in_role_recursive(role_id integer) RETURNS TABLE(inheritor_id integer, inherited_id integer, inheritor_name text, inherited_name text, acl_id integer, acl_name text, acl_positive boolean, inheritor_fixed boolean, inheritor_internal boolean, inherited_fixed boolean, inherited_internal boolean)
    LANGUAGE sql
    AS $_$

      with recursive all_role_role_relations(inheritor_id, inherited_id) as ( 
        
          select inheritor_id, inherited_id 
          from role_role_relations 
          where inheritor_id in ( $1 ) 

          union 

          select p.inheritor_id, p.inherited_id 
          from all_role_role_relations pr, role_role_relations p 
          where pr.inherited_id=p.inheritor_id  ) 

      select a.inheritor_id as inheritor_id, a.inherited_id as inherited_id, d.name as inheritor_name, e.name as inherited_name, 
             b.acl_id as acl_id, c.name as acl_name, b.positive as acl_positive, d.fixed as inheritor_fixed, d.internal as inheritor_internal, 
             e.fixed as inherited_fixed, e.internal as inherited_internal 
      from all_role_role_relations a 
      left join acl_role_relations b on (a.inherited_id=b.role_id) 
      left join acls c on (c.id=b.acl_id) 
      join roles d on (d.id=a.inheritor_id) 
      join roles e on (e.id=a.inherited_id) 

      union 

      select f.id as inheritor_id, f.id as inherited_id, f.name as inheritor_name, f.name as inherited_name, g.acl_id as acl_id, h.name as acl_name, 
             g.positive as acl_positive, f.fixed as inheritor_fixed, f.internal as inheritor_internal, f.fixed as inherited_fixed, f.internal as inherited_internal  
      from roles f 
      join acl_role_relations g on (f.id=g.role_id) 
      join acls h on (h.id=g.acl_id) 

      where f.id in ( $1 )

$_$;


ALTER FUNCTION public.acls_in_role_recursive(role_id integer) OWNER TO postgres;

--
-- Name: delete_views_for_removed_property(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION delete_views_for_removed_property() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$

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
$_$;


ALTER FUNCTION public.delete_views_for_removed_property() OWNER TO postgres;

--
-- Name: di_blocked_or_unblocked_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION di_blocked_or_unblocked_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen di_blocked_or_unblocked; notify di_blocked_or_unblocked; RETURN NULL; END; $$;


ALTER FUNCTION public.di_blocked_or_unblocked_notify() OWNER TO postgres;

--
-- Name: di_created_or_removed_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION di_created_or_removed_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN notify di_created_or_removed; notify di_created_or_removed; RETURN NULL; END; $$;


ALTER FUNCTION public.di_created_or_removed_notify() OWNER TO postgres;

--
-- Name: host_blocked_or_unblocked_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION host_blocked_or_unblocked_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen host_blocked_or_unblocked; notify host_blocked_or_unblocked; RETURN NULL; END; $$;


ALTER FUNCTION public.host_blocked_or_unblocked_notify() OWNER TO postgres;

--
-- Name: host_created_or_removed_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION host_created_or_removed_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen host_created_or_removed; notify host_created_or_removed; RETURN NULL; END; $$;


ALTER FUNCTION public.host_created_or_removed_notify() OWNER TO postgres;

--
-- Name: host_state_changed_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION host_state_changed_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen host_state_changed; notify host_state_changed; RETURN NULL; END; $$;


ALTER FUNCTION public.host_state_changed_notify() OWNER TO postgres;

--
-- Name: osf_created_or_removed_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION osf_created_or_removed_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen osf_created_or_removed; notify osf_created_or_removed; RETURN NULL; END; $$;


ALTER FUNCTION public.osf_created_or_removed_notify() OWNER TO postgres;

--
-- Name: user_blocked_or_unblocked_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION user_blocked_or_unblocked_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen user_blocked_or_unblocked; notify user_blocked_or_unblocked; RETURN NULL; END; $$;


ALTER FUNCTION public.user_blocked_or_unblocked_notify() OWNER TO postgres;

--
-- Name: user_created_or_removed_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION user_created_or_removed_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen user_created_or_removed; notify user_created_or_removed; RETURN NULL; END; $$;


ALTER FUNCTION public.user_created_or_removed_notify() OWNER TO postgres;

--
-- Name: user_state_changed_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION user_state_changed_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen user_state_changed_trigger; notify user_state_changed_trigger; RETURN NULL; END; $$;


ALTER FUNCTION public.user_state_changed_notify() OWNER TO postgres;

--
-- Name: vm_blocked_or_unblocked_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION vm_blocked_or_unblocked_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen vm_blocked_or_unblocked; notify vm_blocked_or_unblocked; RETURN NULL; END; $$;


ALTER FUNCTION public.vm_blocked_or_unblocked_notify() OWNER TO postgres;

--
-- Name: vm_created_or_removed_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION vm_created_or_removed_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen vm_created_or_removed; notify vm_created_or_removed; RETURN NULL; END; $$;


ALTER FUNCTION public.vm_created_or_removed_notify() OWNER TO postgres;

--
-- Name: vm_expiration_date_changed_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION vm_expiration_date_changed_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen vm_expiration_date_changed; notify vm_expiration_date_changed; RETURN NULL; END; $$;


ALTER FUNCTION public.vm_expiration_date_changed_notify() OWNER TO postgres;

--
-- Name: vm_state_changed_notify(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION vm_state_changed_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ BEGIN listen vm_state_changed; notify vm_state_changed; RETURN NULL; END; $$;


ALTER FUNCTION public.vm_state_changed_notify() OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: acl_role_relations; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE acl_role_relations (
    id integer NOT NULL,
    acl_id integer NOT NULL,
    role_id integer NOT NULL,
    positive boolean DEFAULT true NOT NULL
);


ALTER TABLE public.acl_role_relations OWNER TO qvd;

--
-- Name: acl_role_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE acl_role_relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.acl_role_relations_id_seq OWNER TO qvd;

--
-- Name: acl_role_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE acl_role_relations_id_seq OWNED BY acl_role_relations.id;


--
-- Name: acls; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE acls (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.acls OWNER TO qvd;

--
-- Name: acls_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE acls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.acls_id_seq OWNER TO qvd;

--
-- Name: acls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE acls_id_seq OWNED BY acls.id;


--
-- Name: administrator_views_setups; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE administrator_views_setups (
    id integer NOT NULL,
    administrator_id integer NOT NULL,
    field character varying(64) NOT NULL,
    visible boolean NOT NULL,
    device_type device_types_enum NOT NULL,
    view_type view_types_enum NOT NULL,
    property boolean NOT NULL,
    qvd_object qvd_objects_enum NOT NULL
);


ALTER TABLE public.administrator_views_setups OWNER TO qvd;

--
-- Name: administrator_views_setups_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE administrator_views_setups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.administrator_views_setups_id_seq OWNER TO qvd;

--
-- Name: administrator_views_setups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE administrator_views_setups_id_seq OWNED BY administrator_views_setups.id;


--
-- Name: administrators; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE administrators (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    password character varying(64),
    tenant_id integer NOT NULL,
    language language_options_enum DEFAULT 'auto'::language_options_enum NOT NULL,
    block integer DEFAULT 0
);


ALTER TABLE public.administrators OWNER TO qvd;

--
-- Name: administrators_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE administrators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.administrators_id_seq OWNER TO qvd;

--
-- Name: administrators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE administrators_id_seq OWNED BY administrators.id;


--
-- Name: role_role_relations; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE role_role_relations (
    id integer NOT NULL,
    inheritor_id integer NOT NULL,
    inherited_id integer NOT NULL
);


ALTER TABLE public.role_role_relations OWNER TO qvd;

--
-- Name: all_acl_role_relations; Type: VIEW; Schema: public; Owner: qvd
--

CREATE VIEW all_acl_role_relations AS
 WITH RECURSIVE all_acls_role_relations(inheritor_id, inherited_id, acl_id) AS (
         SELECT a.inheritor_id,
            a.inherited_id,
            b.acl_id
           FROM (role_role_relations a
             JOIN acl_role_relations b ON ((b.role_id = a.inherited_id)))
          WHERE ((b.positive = true) AND (NOT (b.acl_id IN ( SELECT c.acl_id
                   FROM acl_role_relations c
                  WHERE ((c.positive = false) AND (c.role_id = a.inheritor_id))))))
        UNION
         SELECT d.inheritor_id,
            d.inherited_id,
            e.acl_id
           FROM (role_role_relations d
             JOIN all_acls_role_relations e ON ((d.inherited_id = e.inheritor_id)))
          WHERE (NOT (e.acl_id IN ( SELECT f.acl_id
                   FROM acl_role_relations f
                  WHERE ((f.positive = false) AND (f.role_id = d.inheritor_id)))))
        )
 SELECT all_acls_role_relations.inheritor_id,
    all_acls_role_relations.inherited_id,
    all_acls_role_relations.acl_id
   FROM all_acls_role_relations
UNION
 SELECT acl_role_relations.role_id AS inheritor_id,
    acl_role_relations.role_id AS inherited_id,
    acl_role_relations.acl_id
   FROM acl_role_relations
  WHERE (acl_role_relations.positive = true);


ALTER TABLE public.all_acl_role_relations OWNER TO qvd;

--
-- Name: all_role_role_relations; Type: VIEW; Schema: public; Owner: qvd
--

CREATE VIEW all_role_role_relations AS
 WITH RECURSIVE all_role_role_relations(inheritor_id, inherited_id) AS (
         SELECT role_role_relations.inheritor_id,
            role_role_relations.inherited_id
           FROM role_role_relations
        UNION
         SELECT p.inheritor_id,
            p.inherited_id
           FROM all_role_role_relations pr,
            role_role_relations p
          WHERE (pr.inherited_id = p.inheritor_id)
        )
 SELECT a.inheritor_id,
    a.inherited_id
   FROM all_role_role_relations a;


ALTER TABLE public.all_role_role_relations OWNER TO qvd;

--
-- Name: configs; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE configs (
    key character varying(64) NOT NULL,
    value character varying(4096) NOT NULL
);


ALTER TABLE public.configs OWNER TO qvd;

--
-- Name: di_properties; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE di_properties (
    di_id integer NOT NULL,
    key character varying(1024) NOT NULL,
    value character varying(32768) NOT NULL
);


ALTER TABLE public.di_properties OWNER TO qvd;

--
-- Name: di_tags; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE di_tags (
    id integer NOT NULL,
    di_id integer NOT NULL,
    tag character varying(1024) NOT NULL,
    fixed boolean DEFAULT false NOT NULL
);


ALTER TABLE public.di_tags OWNER TO qvd;

--
-- Name: di_tags_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE di_tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.di_tags_id_seq OWNER TO qvd;

--
-- Name: di_tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE di_tags_id_seq OWNED BY di_tags.id;


--
-- Name: dis; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE dis (
    id integer NOT NULL,
    osf_id integer NOT NULL,
    path character varying(4096) NOT NULL,
    blocked boolean NOT NULL,
    version character varying(64) NOT NULL
);


ALTER TABLE public.dis OWNER TO qvd;

--
-- Name: dis_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE dis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dis_id_seq OWNER TO qvd;

--
-- Name: dis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE dis_id_seq OWNED BY dis.id;


--
-- Name: host_cmds; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE host_cmds (
    name character varying(20) NOT NULL
);


ALTER TABLE public.host_cmds OWNER TO qvd;

--
-- Name: host_counters; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE host_counters (
    host_id integer DEFAULT 0 NOT NULL,
    http_requests integer DEFAULT 0 NOT NULL,
    auth_attempts integer DEFAULT 0 NOT NULL,
    auth_ok integer DEFAULT 0 NOT NULL,
    nx_attempts integer DEFAULT 0 NOT NULL,
    nx_ok integer DEFAULT 0 NOT NULL,
    short_sessions integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.host_counters OWNER TO qvd;

--
-- Name: host_properties; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE host_properties (
    host_id integer NOT NULL,
    key character varying(1024) NOT NULL,
    value character varying(32768) NOT NULL
);


ALTER TABLE public.host_properties OWNER TO qvd;

--
-- Name: host_runtimes; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE host_runtimes (
    host_id integer NOT NULL,
    pid integer,
    ok_ts timestamp without time zone,
    usable_ram numeric,
    usable_cpu numeric,
    state character varying(12) NOT NULL,
    blocked boolean NOT NULL,
    cmd character varying(12)
);


ALTER TABLE public.host_runtimes OWNER TO qvd;

--
-- Name: host_states; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE host_states (
    name character varying(20) NOT NULL
);


ALTER TABLE public.host_states OWNER TO qvd;

--
-- Name: hosts; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE hosts (
    id integer NOT NULL,
    name character varying(127) NOT NULL,
    address character varying(127) NOT NULL,
    frontend boolean NOT NULL,
    backend boolean NOT NULL
);


ALTER TABLE public.hosts OWNER TO qvd;

--
-- Name: hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hosts_id_seq OWNER TO qvd;

--
-- Name: hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE hosts_id_seq OWNED BY hosts.id;


--
-- Name: role_administrator_relations; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE role_administrator_relations (
    id integer NOT NULL,
    role_id integer NOT NULL,
    administrator_id integer NOT NULL
);


ALTER TABLE public.role_administrator_relations OWNER TO qvd;

--
-- Name: operative_acls_in_admins_basic; Type: VIEW; Schema: public; Owner: qvd
--

CREATE VIEW operative_acls_in_admins_basic AS
 SELECT DISTINCT ac.id AS acl_id,
    ad.id AS admin_id,
        CASE
            WHEN (j.inheritor_id IS NOT NULL) THEN true
            ELSE false
        END AS operative
   FROM ((acls ac
     CROSS JOIN administrators ad)
     LEFT JOIN all_acl_role_relations j ON (((j.acl_id = ac.id) AND (j.inheritor_id IN ( SELECT role_administrator_relations.role_id
           FROM role_administrator_relations
          WHERE (role_administrator_relations.administrator_id = ad.id))))));


ALTER TABLE public.operative_acls_in_admins_basic OWNER TO qvd;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    fixed boolean,
    internal boolean
);


ALTER TABLE public.roles OWNER TO qvd;

--
-- Name: operative_acls_in_roles_basic; Type: VIEW; Schema: public; Owner: qvd
--

CREATE VIEW operative_acls_in_roles_basic AS
 SELECT DISTINCT a.id AS acl_id,
    r.id AS role_id,
        CASE
            WHEN (j.inheritor_id IS NOT NULL) THEN true
            ELSE false
        END AS operative
   FROM ((acls a
     CROSS JOIN roles r)
     LEFT JOIN all_acl_role_relations j ON (((j.acl_id = a.id) AND (j.inheritor_id = r.id))));


ALTER TABLE public.operative_acls_in_roles_basic OWNER TO qvd;

--
-- Name: osf_properties; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE osf_properties (
    osf_id integer NOT NULL,
    key character varying(1024) NOT NULL,
    value character varying(32768) NOT NULL
);


ALTER TABLE public.osf_properties OWNER TO qvd;

--
-- Name: osfs; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE osfs (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    memory integer NOT NULL,
    use_overlay boolean NOT NULL,
    user_storage_size integer,
    tenant_id integer NOT NULL
);


ALTER TABLE public.osfs OWNER TO qvd;

--
-- Name: tenant_views_setups; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE tenant_views_setups (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    field character varying(64) NOT NULL,
    visible boolean NOT NULL,
    device_type device_types_enum NOT NULL,
    view_type view_types_enum NOT NULL,
    qvd_object qvd_objects_enum NOT NULL,
    property boolean NOT NULL
);


ALTER TABLE public.tenant_views_setups OWNER TO qvd;

--
-- Name: tenants; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE tenants (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    language language_options_enum DEFAULT 'default'::language_options_enum NOT NULL,
    block integer DEFAULT 10
);


ALTER TABLE public.tenants OWNER TO qvd;

--
-- Name: user_properties; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE user_properties (
    user_id integer NOT NULL,
    key character varying(1024) NOT NULL,
    value character varying(32768) NOT NULL
);


ALTER TABLE public.user_properties OWNER TO qvd;

--
-- Name: users; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    login character varying(64) NOT NULL,
    password character varying(64),
    blocked boolean NOT NULL,
    tenant_id integer NOT NULL
);


ALTER TABLE public.users OWNER TO qvd;

--
-- Name: vm_properties; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE vm_properties (
    vm_id integer NOT NULL,
    key character varying(1024) NOT NULL,
    value character varying(32768) NOT NULL
);


ALTER TABLE public.vm_properties OWNER TO qvd;

--
-- Name: vms; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE vms (
    id integer NOT NULL,
    name character varying(64) NOT NULL,
    user_id integer NOT NULL,
    osf_id integer NOT NULL,
    di_tag character varying(128) NOT NULL,
    ip character varying(15),
    storage character varying(4096)
);


ALTER TABLE public.vms OWNER TO qvd;

--
-- Name: operative_views_in_tenants; Type: VIEW; Schema: public; Owner: qvd
--

CREATE VIEW operative_views_in_tenants AS
 SELECT DISTINCT dt.dt AS device_type,
    vt.vt AS view_type,
    t.id AS tenant_id,
    p.key AS field,
        CASE
            WHEN (r.visible IS NULL) THEN false
            ELSE r.visible
        END AS visible,
    true AS property,
    'vm'::qvd_objects_enum AS qvd_object
   FROM ((((((unnest(enum_range(NULL::device_types_enum)) dt(dt)
     CROSS JOIN unnest(enum_range(NULL::view_types_enum)) vt(vt))
     CROSS JOIN ( SELECT tenants.id
           FROM tenants) t)
     CROSS JOIN ( SELECT vm_properties.key,
            vm_properties.vm_id
           FROM vm_properties) p)
     JOIN vms v ON ((p.vm_id = v.id)))
     JOIN users u ON (((u.id = v.user_id) AND ((u.tenant_id = t.id) OR (t.id = 0)))))
     LEFT JOIN tenant_views_setups r ON (((((((r.device_type = dt.dt) AND (r.view_type = vt.vt)) AND (r.tenant_id = t.id)) AND ((r.field)::text = (p.key)::text)) AND (r.property = true)) AND (r.qvd_object = 'vm'::qvd_objects_enum))))
UNION
 SELECT DISTINCT dt.dt AS device_type,
    vt.vt AS view_type,
    t.id AS tenant_id,
    p.key AS field,
        CASE
            WHEN (r.visible IS NULL) THEN false
            ELSE r.visible
        END AS visible,
    true AS property,
    'user'::qvd_objects_enum AS qvd_object
   FROM (((((unnest(enum_range(NULL::device_types_enum)) dt(dt)
     CROSS JOIN unnest(enum_range(NULL::view_types_enum)) vt(vt))
     CROSS JOIN ( SELECT tenants.id
           FROM tenants) t)
     CROSS JOIN ( SELECT user_properties.key,
            user_properties.user_id
           FROM user_properties) p)
     JOIN users u ON (((p.user_id = u.id) AND ((u.tenant_id = t.id) OR (t.id = 0)))))
     LEFT JOIN tenant_views_setups r ON (((((((r.device_type = dt.dt) AND (r.view_type = vt.vt)) AND (r.tenant_id = t.id)) AND ((r.field)::text = (p.key)::text)) AND (r.property = true)) AND (r.qvd_object = 'user'::qvd_objects_enum))))
UNION
 SELECT DISTINCT dt.dt AS device_type,
    vt.vt AS view_type,
    t.id AS tenant_id,
    p.key AS field,
        CASE
            WHEN (r.visible IS NULL) THEN false
            ELSE r.visible
        END AS visible,
    true AS property,
    'host'::qvd_objects_enum AS qvd_object
   FROM ((((unnest(enum_range(NULL::device_types_enum)) dt(dt)
     CROSS JOIN unnest(enum_range(NULL::view_types_enum)) vt(vt))
     CROSS JOIN ( SELECT tenants.id
           FROM tenants) t)
     CROSS JOIN ( SELECT host_properties.key
           FROM host_properties) p)
     LEFT JOIN tenant_views_setups r ON (((((((r.device_type = dt.dt) AND (r.view_type = vt.vt)) AND (r.tenant_id = t.id)) AND ((r.field)::text = (p.key)::text)) AND (r.property = true)) AND (r.qvd_object = 'host'::qvd_objects_enum))))
UNION
 SELECT DISTINCT dt.dt AS device_type,
    vt.vt AS view_type,
    t.id AS tenant_id,
    p.key AS field,
        CASE
            WHEN (r.visible IS NULL) THEN false
            ELSE r.visible
        END AS visible,
    true AS property,
    'osf'::qvd_objects_enum AS qvd_object
   FROM (((((unnest(enum_range(NULL::device_types_enum)) dt(dt)
     CROSS JOIN unnest(enum_range(NULL::view_types_enum)) vt(vt))
     CROSS JOIN ( SELECT tenants.id
           FROM tenants) t)
     CROSS JOIN ( SELECT osf_properties.key,
            osf_properties.osf_id
           FROM osf_properties) p)
     JOIN osfs o ON (((p.osf_id = o.id) AND ((o.tenant_id = t.id) OR (t.id = 0)))))
     LEFT JOIN tenant_views_setups r ON (((((((r.device_type = dt.dt) AND (r.view_type = vt.vt)) AND (r.tenant_id = t.id)) AND ((r.field)::text = (p.key)::text)) AND (r.property = true)) AND (r.qvd_object = 'osf'::qvd_objects_enum))))
UNION
 SELECT DISTINCT dt.dt AS device_type,
    vt.vt AS view_type,
    t.id AS tenant_id,
    p.key AS field,
        CASE
            WHEN (r.visible IS NULL) THEN false
            ELSE r.visible
        END AS visible,
    true AS property,
    'di'::qvd_objects_enum AS qvd_object
   FROM ((((((unnest(enum_range(NULL::device_types_enum)) dt(dt)
     CROSS JOIN unnest(enum_range(NULL::view_types_enum)) vt(vt))
     CROSS JOIN ( SELECT tenants.id
           FROM tenants) t)
     CROSS JOIN ( SELECT di_properties.key,
            di_properties.di_id
           FROM di_properties) p)
     JOIN dis d ON ((p.di_id = d.id)))
     JOIN osfs o ON (((o.id = d.osf_id) AND ((o.tenant_id = t.id) OR (t.id = 0)))))
     LEFT JOIN tenant_views_setups r ON (((((((r.device_type = dt.dt) AND (r.view_type = vt.vt)) AND (r.tenant_id = t.id)) AND ((r.field)::text = (p.key)::text)) AND (r.property = true)) AND (r.qvd_object = 'di'::qvd_objects_enum))))
UNION
 SELECT tenant_views_setups.device_type,
    tenant_views_setups.view_type,
    tenant_views_setups.tenant_id,
    tenant_views_setups.field,
    tenant_views_setups.visible,
    tenant_views_setups.property,
    tenant_views_setups.qvd_object
   FROM tenant_views_setups
  WHERE (tenant_views_setups.property = false);


ALTER TABLE public.operative_views_in_tenants OWNER TO qvd;

--
-- Name: osfs_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE osfs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.osfs_id_seq OWNER TO qvd;

--
-- Name: osfs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE osfs_id_seq OWNED BY osfs.id;


--
-- Name: role_administrator_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE role_administrator_relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_administrator_relations_id_seq OWNER TO qvd;

--
-- Name: role_administrator_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE role_administrator_relations_id_seq OWNED BY role_administrator_relations.id;


--
-- Name: role_role_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE role_role_relations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_role_relations_id_seq OWNER TO qvd;

--
-- Name: role_role_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE role_role_relations_id_seq OWNED BY role_role_relations.id;


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO qvd;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: session; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE session (
    sid character varying(40) NOT NULL,
    data text,
    expires integer NOT NULL
);


ALTER TABLE public.session OWNER TO qvd;

--
-- Name: ssl_configs; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE ssl_configs (
    key character varying(64) NOT NULL,
    value character varying(32768) NOT NULL
);


ALTER TABLE public.ssl_configs OWNER TO qvd;

--
-- Name: tenant_views_setups_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE tenant_views_setups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tenant_views_setups_id_seq OWNER TO qvd;

--
-- Name: tenant_views_setups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE tenant_views_setups_id_seq OWNED BY tenant_views_setups.id;


--
-- Name: tenants_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE tenants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tenants_id_seq OWNER TO qvd;

--
-- Name: tenants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE tenants_id_seq OWNED BY tenants.id;


--
-- Name: user_cmds; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE user_cmds (
    name character varying(20) NOT NULL
);


ALTER TABLE public.user_cmds OWNER TO qvd;

--
-- Name: user_states; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE user_states (
    name character varying(20) NOT NULL
);


ALTER TABLE public.user_states OWNER TO qvd;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO qvd;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE versions (
    component character varying(100) NOT NULL,
    version character varying(100) NOT NULL
);


ALTER TABLE public.versions OWNER TO qvd;

--
-- Name: vm_cmds; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE vm_cmds (
    name character varying(20) NOT NULL
);


ALTER TABLE public.vm_cmds OWNER TO qvd;

--
-- Name: vm_counters; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE vm_counters (
    vm_id integer DEFAULT 0 NOT NULL,
    run_attempts integer DEFAULT 0 NOT NULL,
    run_ok integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.vm_counters OWNER TO qvd;

--
-- Name: vm_runtimes; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE vm_runtimes (
    vm_id integer NOT NULL,
    host_id integer,
    current_osf_id integer,
    current_di_id integer,
    user_ip character varying(15),
    real_user_id integer,
    vm_state character varying(12) NOT NULL,
    vm_state_ts integer,
    vm_cmd character varying(12),
    vm_pid integer,
    user_state character varying(12) NOT NULL,
    user_state_ts integer,
    user_cmd character varying(12),
    vma_ok_ts integer,
    l7r_host integer,
    l7r_pid integer,
    vm_address character varying(127),
    vm_vma_port integer,
    vm_x_port integer,
    vm_ssh_port integer,
    vm_vnc_port integer,
    vm_mon_port integer,
    vm_serial_port integer,
    blocked boolean,
    vm_expiration_soft timestamp without time zone,
    vm_expiration_hard timestamp without time zone,
    l7r_host_id integer,
    CONSTRAINT vm_runtimes_consisten_expiration_dates CHECK ((vm_expiration_hard >= vm_expiration_soft))
);


ALTER TABLE public.vm_runtimes OWNER TO qvd;

--
-- Name: vm_states; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE vm_states (
    name character varying(12) NOT NULL
);


ALTER TABLE public.vm_states OWNER TO qvd;

--
-- Name: vms_id_seq; Type: SEQUENCE; Schema: public; Owner: qvd
--

CREATE SEQUENCE vms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.vms_id_seq OWNER TO qvd;

--
-- Name: vms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE vms_id_seq OWNED BY vms.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY acl_role_relations ALTER COLUMN id SET DEFAULT nextval('acl_role_relations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY acls ALTER COLUMN id SET DEFAULT nextval('acls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY administrator_views_setups ALTER COLUMN id SET DEFAULT nextval('administrator_views_setups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY administrators ALTER COLUMN id SET DEFAULT nextval('administrators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY di_tags ALTER COLUMN id SET DEFAULT nextval('di_tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY dis ALTER COLUMN id SET DEFAULT nextval('dis_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY hosts ALTER COLUMN id SET DEFAULT nextval('hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY osfs ALTER COLUMN id SET DEFAULT nextval('osfs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY role_administrator_relations ALTER COLUMN id SET DEFAULT nextval('role_administrator_relations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY role_role_relations ALTER COLUMN id SET DEFAULT nextval('role_role_relations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY tenant_views_setups ALTER COLUMN id SET DEFAULT nextval('tenant_views_setups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY tenants ALTER COLUMN id SET DEFAULT nextval('tenants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vms ALTER COLUMN id SET DEFAULT nextval('vms_id_seq'::regclass);


--
-- Data for Name: acl_role_relations; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY acl_role_relations (id, acl_id, role_id, positive) FROM stdin;
720	98	25	t
721	97	26	t
732	95	30	t
733	104	30	t
734	100	31	t
735	103	31	t
736	102	31	t
752	241	37	t
753	44	37	t
754	46	37	t
755	126	37	t
756	91	37	t
757	137	37	t
758	45	37	t
801	3	40	t
802	231	40	t
803	4	40	t
804	51	40	t
805	90	40	t
806	52	40	t
807	53	40	t
808	127	40	t
809	54	40	t
822	10	41	t
823	11	41	t
824	12	41	t
825	13	41	t
826	14	41	t
827	15	41	t
828	73	41	t
829	74	41	t
722	93	27	t
723	94	28	t
724	110	28	t
725	233	28	t
726	109	28	t
739	146	33	t
745	242	36	t
746	47	36	t
747	48	36	t
748	132	36	t
749	49	36	t
750	50	36	t
751	142	36	t
759	1	38	t
760	2	38	t
761	232	38	t
762	17	38	t
763	18	38	t
764	19	38	t
765	20	38	t
766	136	38	t
767	21	38	t
768	22	38	t
769	139	38	t
770	23	38	t
791	141	39	t
792	61	39	t
793	64	39	t
794	65	39	t
795	66	39	t
796	131	39	t
797	35	39	t
798	36	39	t
799	63	39	t
800	158	39	t
810	140	40	t
811	55	40	t
812	57	40	t
813	128	40	t
814	32	40	t
815	33	40	t
816	31	40	t
817	56	40	t
818	157	40	t
819	153	40	t
820	151	40	t
821	156	40	t
831	135	41	t
832	76	41	t
833	83	41	t
834	77	41	t
835	92	41	t
836	78	41	t
837	79	41	t
838	80	41	t
839	147	41	t
840	81	41	t
841	82	41	t
842	84	41	t
853	8	42	t
854	9	42	t
855	67	42	t
856	68	42	t
857	69	42	t
858	133	42	t
859	70	42	t
860	145	42	t
861	71	42	t
862	134	42	t
863	29	42	t
864	30	42	t
865	28	42	t
866	72	42	t
867	155	42	t
868	154	42	t
869	179	44	t
870	161	45	t
871	207	46	t
872	167	46	t
873	206	46	t
874	205	46	t
876	166	46	t
877	165	46	t
878	164	46	t
879	178	47	t
880	177	47	t
881	176	47	t
882	175	47	t
883	174	47	t
884	173	47	t
885	215	47	t
886	214	47	t
887	213	47	t
888	212	47	t
889	211	47	t
898	195	49	t
899	194	49	t
900	193	49	t
901	192	49	t
902	226	49	t
903	225	49	t
904	224	49	t
727	108	28	t
742	144	35	t
743	143	35	t
771	24	38	t
772	25	38	t
773	26	38	t
774	16	38	t
775	42	38	t
776	43	38	t
777	41	38	t
778	160	38	t
779	159	38	t
830	75	41	t
890	200	48	t
891	201	48	t
892	171	48	t
905	223	49	t
906	221	49	t
907	191	49	t
908	189	49	t
909	184	50	t
910	183	50	t
911	182	50	t
912	181	50	t
913	219	50	t
914	218	50	t
915	217	50	t
916	122	51	t
917	240	51	t
922	112	54	t
923	118	54	t
924	114	55	t
925	120	55	t
936	199	62	t
937	198	62	t
946	172	66	t
947	234	66	t
948	209	66	t
949	169	66	t
952	220	67	t
953	188	67	t
954	190	67	t
955	222	67	t
1015	247	39	t
1017	248	42	t
728	96	29	t
729	106	29	t
730	105	29	t
731	107	29	t
737	99	32	t
738	101	32	t
744	243	35	t
780	5	39	t
781	6	39	t
782	230	39	t
783	7	39	t
784	58	39	t
785	59	39	t
786	130	39	t
787	129	39	t
788	38	39	t
789	62	39	t
790	60	39	t
843	85	41	t
844	86	41	t
845	87	41	t
846	88	41	t
847	89	41	t
848	27	41	t
849	152	41	t
850	150	41	t
851	148	41	t
852	149	41	t
875	204	46	t
893	170	48	t
894	228	48	t
895	229	48	t
896	210	48	t
897	168	48	t
918	115	52	t
919	121	52	t
920	111	53	t
921	125	53	t
926	113	56	t
927	119	56	t
928	117	57	t
929	124	57	t
930	116	58	t
931	123	58	t
932	185	59	t
933	186	59	t
934	187	59	t
938	197	63	t
939	203	64	t
940	202	64	t
941	163	64	t
942	34	65	t
945	39	65	t
950	196	67	t
951	227	67	t
956	216	68	t
957	180	68	t
958	40	39	t
959	37	39	t
1008	244	39	t
1016	246	40	t
1018	245	38	t
1024	249	41	t
1032	251	42	t
1033	252	40	t
1034	250	41	t
1035	253	38	t
1036	254	40	t
1037	257	43	t
1038	258	43	t
1039	256	35	t
1040	255	35	t
1041	134	1	t
1042	257	1	t
1043	258	1	t
1044	162	78	t
1045	259	105	t
1060	260	35	t
1061	261	43	t
\.


--
-- Name: acl_role_relations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('acl_role_relations_id_seq', 1090, true);


--
-- Data for Name: acls; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY acls (id, name) FROM stdin;
1	di.filter.disk-image
2	di.filter.osf
3	host.filter.name
4	host.filter.vm
5	osf.filter.di
6	osf.filter.name
7	osf.filter.vm
8	user.filter.name
9	user.filter.properties
10	vm.filter.host
11	vm.filter.name
12	vm.filter.osf
13	vm.filter.properties
14	vm.filter.state
15	vm.filter.user
16	di.see.vm-list
17	di.see.block
18	di.see.created-by
19	di.see.creation-date
20	di.see.default
21	di.see.head
22	di.see.id
23	di.see.osf
24	di.see.properties
25	di.see.tags
26	di.see.version
27	vm.see.user-state
28	user.see.vm-list-state
29	user.see.vm-list-block
30	user.see.vm-list-expiration
31	host.see.vm-list-state
32	host.see.vm-list-block
33	host.see.vm-list-expiration
34	osf.see.vm-list-state
35	osf.see.vm-list-block
36	osf.see.vm-list-expiration
41	di.see.vm-list-state
42	di.see.vm-list-block
43	di.see.vm-list-expiration
47	role.see.acl-list
48	role.see.acl-list-roles
49	role.see.id
50	role.see.inherited-roles
51	host.see.address
52	host.see.created-by
53	host.see.creation-date
54	host.see.id
55	host.see.properties
56	host.see.vms-info
57	host.see.state
58	osf.see.created-by
59	osf.see.creation-date
60	osf.see.id
61	osf.see.memory
62	osf.see.dis-info
63	osf.see.vms-info
64	osf.see.overlay
65	osf.see.properties
66	osf.see.user-storage
67	user.see.block
68	user.see.created-by
69	user.see.creation-date
70	user.see.id
71	user.see.properties
72	user.see.vms-info
73	vm.see.block
74	vm.see.created-by
75	vm.see.creation-date
76	vm.see.di
77	vm.see.di-version
78	vm.see.host
79	vm.see.id
80	vm.see.ip
81	vm.see.next-boot-ip
82	vm.see.osf
83	vm.see.di-tag
84	vm.see.port-serial
85	vm.see.port-ssh
86	vm.see.port-vnc
87	vm.see.properties
88	vm.see.state
89	vm.see.user
90	host.see.block
92	vm.see.expiration
94	di.create.
95	host.create.
96	osf.create.
97	role.create.
98	tenant.create.
99	user.create.
100	vm.create.
101	user.create.properties
102	vm.create.properties
103	vm.create.di-tag
104	host.create.properties
105	osf.create.properties
106	osf.create.memory
107	osf.create.user-storage
108	di.create.version
109	di.create.tags
110	di.create.default
112	di.delete.
113	host.delete.
114	osf.delete.
115	role.delete.
116	user.delete.
117	vm.delete.
118	di.delete-massive.
119	host.delete-massive.
120	osf.delete-massive.
121	role.delete-massive.
122	tenant.delete-massive.
123	user.delete-massive.
124	vm.delete-massive.
127	host.see-details.
128	host.see.vm-list
129	osf.see.di-list
130	osf.see-details.
131	osf.see.vm-list
132	role.see-details.
133	user.see-details.
134	user.see.vm-list
135	vm.see-details.
136	di.see-details.
139	di.see-main.
140	host.see-main.
141	osf.see-main.
142	role.see-main.
143	tenant.see-main.
144	tenant.see.id
145	user.see-main.
146	views.see-main.
147	vm.see-main.
148	vm.stats.running-vms
149	vm.stats.summary
150	vm.stats.close-to-expire
151	host.stats.top-hosts-most-vms
152	vm.stats.blocked
40	osf.see.di-list-head
44	administrator.see.acl-list
38	osf.see.di-list-default
45	administrator.see.roles
46	administrator.see.acl-list-roles
91	administrator.see.id
93	administrator.create.
111	administrator.delete.
125	administrator.delete-massive.
126	administrator.see-details.
153	host.stats.running-hosts
154	user.stats.summary
155	user.stats.blocked
156	host.stats.summary
157	host.stats.blocked
158	osf.stats.summary
159	di.stats.summary
160	di.stats.blocked
163	di.update.block
164	di.update.properties-create
165	di.update.properties-delete
166	di.update.properties-update
167	di.update.tags
168	host.update.address
169	host.update.block
170	host.update.name
171	host.update.properties-create
172	host.update.stop-vms
173	osf.update.memory
174	osf.update.name
175	osf.update.properties-create
176	osf.update.properties-delete
177	osf.update.properties-update
178	osf.update.user-storage
179	role.update.name
180	user.update.block
181	user.update.password
182	user.update.properties-create
183	user.update.properties-delete
184	user.update.properties-update
185	views.update.columns
186	views.update.filters-desktop
187	views.update.filters-mobile
188	vm.update.block
189	vm.update.di-tag
190	vm.update.disconnect-user
191	vm.update.expiration
192	vm.update.name
193	vm.update.properties-create
194	vm.update.properties-delete
195	vm.update.properties-update
196	vm.update.state
198	role.update.assign-acl
199	role.update.assign-role
200	host.update.properties-update
201	host.update.properties-delete
202	di.update.default
203	di.update-massive.block
204	di.update-massive.properties-create
205	di.update-massive.properties-delete
206	di.update-massive.properties-update
207	di.update-massive.tags
209	host.update-massive.block
210	host.update-massive.properties-create
211	osf.update-massive.memory
212	osf.update-massive.properties-create
213	osf.update-massive.properties-delete
214	osf.update-massive.properties-update
215	osf.update-massive.user-storage
216	user.update-massive.block
217	user.update-massive.properties-create
218	user.update-massive.properties-delete
219	user.update-massive.properties-update
220	vm.update-massive.block
221	vm.update-massive.di-tag
222	vm.update-massive.disconnect-user
223	vm.update-massive.expiration
224	vm.update-massive.properties-create
225	vm.update-massive.properties-delete
226	vm.update-massive.properties-update
227	vm.update-massive.state
228	host.update-massive.properties-update
229	host.update-massive.properties-delete
230	osf.filter.properties
231	host.filter.properties
232	di.filter.properties
233	di.create.properties
234	host.update-massive.stop-vms
240	tenant.delete.
37	osf.see.di-list-tags
39	osf.see.di-list-default-update
137	administrator.see-main.
161	administrator.update.password
197	administrator.update.assign-role
241	administrator.filter.name
242	role.filter.name
243	tenant.filter.name
244	osf.see.di-list-block
245	di.see.vm-list-user-state
246	host.see.vm-list-user-state
247	osf.see.vm-list-user-state
248	user.see.vm-list-user-state
249	vm.see.mac
250	vm.filter.block
251	user.filter.block
252	host.filter.block
253	di.filter.block
254	host.filter.state
256	tenant.see.language
257	tenant.update.language
258	tenant.update.name
255	tenant.see-details.
259	config.wat.
162	config.qvd.
260	tenant.see.block
261	tenant.update.block
\.


--
-- Name: acls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('acls_id_seq', 1, false);


--
-- Data for Name: administrator_views_setups; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY administrator_views_setups (id, administrator_id, field, visible, device_type, view_type, property, qvd_object) FROM stdin;
55	1	host	f	desktop	filter	f	vm
56	1	host	t	mobile	filter	f	vm
\.


--
-- Name: administrator_views_setups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('administrator_views_setups_id_seq', 56, true);


--
-- Data for Name: administrators; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY administrators (id, name, password, tenant_id, language, block) FROM stdin;
0	batman	to the rescue	0	auto	0
1	superadmin	superadmin	0	en	0
60	admin	admin	19	auto	0
\.


--
-- Name: administrators_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('administrators_id_seq', 60, true);


--
-- Data for Name: configs; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY configs (key, value) FROM stdin;
vm.network.netmask	24
vm.network.gateway	10.3.15.1
vm.network.bridge	qvdnet0
vm.hypervisor	lxc
vm.lxc.unionfs.bind.ro	0
vm.lxc.unionfs.type	unionfs-fuse
log.devel	DEBUG
client.use_ssl	1
client.ssl.use_cert	1
vm.network.ip.start	10.3.15.50
command.unionfs-fuse	/bin/unionfs
l7r.use_ssl	1
log.level	ALL
admin.ssh.opt.StrictHostKeyChecking	no
wat.log.filename	/var/log/qvd-wat.log
wat.admin.login	admin
a.a	1
a.b	1
jjj	1
\.


--
-- Data for Name: di_properties; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY di_properties (di_id, key, value) FROM stdin;
\.


--
-- Data for Name: di_tags; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY di_tags (id, di_id, tag, fixed) FROM stdin;
\.


--
-- Name: di_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('di_tags_id_seq', 2343, true);


--
-- Data for Name: dis; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY dis (id, osf_id, path, blocked, version) FROM stdin;
\.


--
-- Name: dis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('dis_id_seq', 323, true);


--
-- Data for Name: host_cmds; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY host_cmds (name) FROM stdin;
stop
\.


--
-- Data for Name: host_counters; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY host_counters (host_id, http_requests, auth_attempts, auth_ok, nx_attempts, nx_ok, short_sessions) FROM stdin;
\.


--
-- Data for Name: host_properties; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY host_properties (host_id, key, value) FROM stdin;
\.


--
-- Data for Name: host_runtimes; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY host_runtimes (host_id, pid, ok_ts, usable_ram, usable_cpu, state, blocked, cmd) FROM stdin;
\.


--
-- Data for Name: host_states; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY host_states (name) FROM stdin;
stopped
starting
running
stopping
lost
\.


--
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY hosts (id, name, address, frontend, backend) FROM stdin;
\.


--
-- Name: hosts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('hosts_id_seq', 176, true);


--
-- Data for Name: osf_properties; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY osf_properties (osf_id, key, value) FROM stdin;
\.


--
-- Data for Name: osfs; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY osfs (id, name, memory, use_overlay, user_storage_size, tenant_id) FROM stdin;
\.


--
-- Name: osfs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('osfs_id_seq', 250, true);


--
-- Data for Name: role_administrator_relations; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY role_administrator_relations (id, role_id, administrator_id) FROM stdin;
1	1	1
80	1	60
\.


--
-- Name: role_administrator_relations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('role_administrator_relations_id_seq', 80, true);


--
-- Data for Name: role_role_relations; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY role_role_relations (id, inheritor_id, inherited_id) FROM stdin;
30	69	35
31	69	61
32	70	36
33	70	62
34	71	37
35	71	63
36	72	38
37	72	64
38	73	39
39	73	65
40	74	40
41	74	66
42	75	41
43	75	67
44	76	42
45	76	68
46	77	33
47	77	59
50	79	69
51	79	25
52	79	43
53	79	51
54	80	70
55	80	26
56	80	44
57	80	52
58	81	71
59	81	27
60	81	45
61	81	53
62	82	72
63	82	28
64	82	46
65	82	54
66	83	73
67	83	29
68	83	47
69	83	55
70	84	74
71	84	30
72	84	48
73	84	56
74	85	75
75	85	31
76	85	49
77	85	57
78	86	76
79	86	32
80	86	50
81	86	58
82	87	32
83	87	31
84	87	29
85	87	28
86	88	42
87	88	41
88	88	39
89	88	38
90	89	50
91	89	49
92	89	47
93	89	46
94	90	58
95	90	57
96	90	55
97	90	54
98	91	68
100	91	67
101	91	65
102	91	64
103	92	76
104	92	75
105	92	73
106	92	72
107	93	86
108	93	85
109	93	83
110	93	82
111	93	78
112	94	81
113	94	80
115	94	77
116	95	94
117	95	93
118	96	95
119	96	84
120	96	79
127	1	96
152	94	105
\.


--
-- Name: role_role_relations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('role_role_relations_id_seq', 172, true);


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY roles (id, name, fixed, internal) FROM stdin;
25	Tenants Creator	t	t
26	Roles Creator	t	t
27	Administrators Creator	t	t
28	Images Creator	t	t
29	OSFs Creator	t	t
30	Nodes Creator	t	t
31	VMs Creator	t	t
32	Users Creator	t	t
33	Views Reader	t	t
35	Tenants Reader	t	t
36	Roles Reader	t	t
37	Administrators Reader	t	t
38	Images Reader	t	t
39	OSFs Reader	t	t
40	Nodes Reader	t	t
41	VMs Reader	t	t
42	Users Reader	t	t
43	Tenants Updater	t	t
44	Roles Updater	t	t
45	Administrators Updater	t	t
46	Images Updater	t	t
47	OSFs Updater	t	t
48	Nodes Updater	t	t
49	VMs Updater	t	t
50	Users Updater	t	t
51	Tenants Eraser	t	t
52	Roles Eraser	t	t
53	Administrators Eraser	t	t
54	Images Eraser	t	t
55	OSFs Eraser	t	t
56	Nodes Eraser	t	t
57	VMs Eraser	t	t
58	Users Eraser	t	t
59	Views Performer	t	t
61	Tenants Performer	t	t
62	Roles Performer	t	t
63	Administrators Performer	t	t
64	Images Performer	t	t
65	OSFs Performer	t	t
66	Nodes Performer	t	t
67	VMs Performer	t	t
68	Users Performer	t	t
69	Tenants Operator	t	t
70	Roles Operator	t	t
71	Administrators Operator	t	t
72	Images Operator	t	t
73	OSFs Operator	t	t
74	Nodes Operator	t	t
75	VMs Operator	t	t
76	Users Operator	t	t
77	Views Manager	t	t
79	Tenants Manager	t	t
80	Roles Manager	t	t
81	Administrators Manager	t	t
82	Images Manager	t	t
83	OSFs Manager	t	t
84	Nodes Manager	t	t
85	VMs Manager	t	t
86	Users Manager	t	t
87	QVD Creator	t	t
88	QVD Reader	t	t
89	QVD Updater	t	t
90	QVD Eraser	t	t
91	QVD Performer	t	t
92	QVD Operator	t	t
93	QVD Manager	t	t
94	WAT Manager	t	t
95	Master	t	t
96	Total Master	t	t
1	Root	t	f
78	QVD Configuration Manager	t	t
105	WAT Configuration Manager	t	t
\.


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('roles_id_seq', 121, true);


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY session (sid, data, expires) FROM stdin;
\.


--
-- Data for Name: ssl_configs; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY ssl_configs (key, value) FROM stdin;
\.


--
-- Data for Name: tenant_views_setups; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY tenant_views_setups (id, tenant_id, field, visible, device_type, view_type, qvd_object, property) FROM stdin;
\.


--
-- Name: tenant_views_setups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('tenant_views_setups_id_seq', 7214, true);


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY tenants (id, name, language, block) FROM stdin;
0	*	en	10
16	Demo	default	10
19	qvd	default	10
\.


--
-- Name: tenants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('tenants_id_seq', 19, true);


--
-- Data for Name: user_cmds; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY user_cmds (name) FROM stdin;
abort
\.


--
-- Data for Name: user_properties; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY user_properties (user_id, key, value) FROM stdin;
\.


--
-- Data for Name: user_states; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY user_states (name) FROM stdin;
disconnected
connecting
connected
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY users (id, login, password, blocked, tenant_id) FROM stdin;
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('users_id_seq', 234, true);


--
-- Data for Name: versions; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY versions (component, version) FROM stdin;
schema	4.0.0
\.


--
-- Data for Name: vm_cmds; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY vm_cmds (name) FROM stdin;
start
stop
busy
\.


--
-- Data for Name: vm_counters; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY vm_counters (vm_id, run_attempts, run_ok) FROM stdin;
\.


--
-- Data for Name: vm_properties; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY vm_properties (vm_id, key, value) FROM stdin;
\.


--
-- Data for Name: vm_runtimes; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY vm_runtimes (vm_id, host_id, current_osf_id, current_di_id, user_ip, real_user_id, vm_state, vm_state_ts, vm_cmd, vm_pid, user_state, user_state_ts, user_cmd, vma_ok_ts, l7r_host, l7r_pid, vm_address, vm_vma_port, vm_x_port, vm_ssh_port, vm_vnc_port, vm_mon_port, vm_serial_port, blocked, vm_expiration_soft, vm_expiration_hard, l7r_host_id) FROM stdin;
\.


--
-- Data for Name: vm_states; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY vm_states (name) FROM stdin;
stopped
starting
running
stopping
zombie
debugging
\.


--
-- Data for Name: vms; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY vms (id, name, user_id, osf_id, di_tag, ip, storage) FROM stdin;
\.


--
-- Name: vms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('vms_id_seq', 187, true);


--
-- Name: acl_role_relations_acl_id_role_id; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY acl_role_relations
    ADD CONSTRAINT acl_role_relations_acl_id_role_id UNIQUE (acl_id, role_id);


--
-- Name: acl_role_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY acl_role_relations
    ADD CONSTRAINT acl_role_relations_pkey PRIMARY KEY (id);


--
-- Name: acls_name; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY acls
    ADD CONSTRAINT acls_name UNIQUE (name);


--
-- Name: acls_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY acls
    ADD CONSTRAINT acls_pkey PRIMARY KEY (id);


--
-- Name: administrator_views_setups_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY administrator_views_setups
    ADD CONSTRAINT administrator_views_setups_pkey PRIMARY KEY (id);


--
-- Name: administrator_views_setups_unique; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY administrator_views_setups
    ADD CONSTRAINT administrator_views_setups_unique UNIQUE (administrator_id, field, view_type, device_type, qvd_object, property);


--
-- Name: administrators_name_tenant_id; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY administrators
    ADD CONSTRAINT administrators_name_tenant_id UNIQUE (name, tenant_id);


--
-- Name: administrators_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY administrators
    ADD CONSTRAINT administrators_pkey PRIMARY KEY (id);


--
-- Name: configs_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY configs
    ADD CONSTRAINT configs_pkey PRIMARY KEY (key);


--
-- Name: di_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY di_properties
    ADD CONSTRAINT di_properties_pkey PRIMARY KEY (di_id, key);


--
-- Name: di_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY di_tags
    ADD CONSTRAINT di_tags_pkey PRIMARY KEY (id);


--
-- Name: dis_osf_id_version; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY dis
    ADD CONSTRAINT dis_osf_id_version UNIQUE (osf_id, version);


--
-- Name: dis_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY dis
    ADD CONSTRAINT dis_pkey PRIMARY KEY (id);


--
-- Name: host_cmds_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY host_cmds
    ADD CONSTRAINT host_cmds_pkey PRIMARY KEY (name);


--
-- Name: host_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY host_counters
    ADD CONSTRAINT host_counters_pkey PRIMARY KEY (host_id);


--
-- Name: host_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY host_properties
    ADD CONSTRAINT host_properties_pkey PRIMARY KEY (host_id, key);


--
-- Name: host_runtimes_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY host_runtimes
    ADD CONSTRAINT host_runtimes_pkey PRIMARY KEY (host_id);


--
-- Name: host_states_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY host_states
    ADD CONSTRAINT host_states_pkey PRIMARY KEY (name);


--
-- Name: hosts_address; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT hosts_address UNIQUE (address);


--
-- Name: hosts_name; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT hosts_name UNIQUE (name);


--
-- Name: hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: osf_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY osf_properties
    ADD CONSTRAINT osf_properties_pkey PRIMARY KEY (osf_id, key);


--
-- Name: osfs_name_tenant_id; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY osfs
    ADD CONSTRAINT osfs_name_tenant_id UNIQUE (name, tenant_id);


--
-- Name: osfs_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY osfs
    ADD CONSTRAINT osfs_pkey PRIMARY KEY (id);


--
-- Name: role_administrator_relations_administrator_id_role_id; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_administrator_relations
    ADD CONSTRAINT role_administrator_relations_administrator_id_role_id UNIQUE (administrator_id, role_id);


--
-- Name: role_administrator_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_administrator_relations
    ADD CONSTRAINT role_administrator_relations_pkey PRIMARY KEY (id);


--
-- Name: role_role_relations_inheritor_id_inherited_id; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_role_relations
    ADD CONSTRAINT role_role_relations_inheritor_id_inherited_id UNIQUE (inheritor_id, inherited_id);


--
-- Name: role_role_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_role_relations
    ADD CONSTRAINT role_role_relations_pkey PRIMARY KEY (id);


--
-- Name: roles_name; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_name UNIQUE (name);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: session_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- Name: ssl_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY ssl_configs
    ADD CONSTRAINT ssl_configs_pkey PRIMARY KEY (key);


--
-- Name: tenant_views_setups_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY tenant_views_setups
    ADD CONSTRAINT tenant_views_setups_pkey PRIMARY KEY (id);


--
-- Name: tenant_views_setups_unique; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY tenant_views_setups
    ADD CONSTRAINT tenant_views_setups_unique UNIQUE (tenant_id, field, view_type, device_type, qvd_object, property);


--
-- Name: tenants_name; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY tenants
    ADD CONSTRAINT tenants_name UNIQUE (name);


--
-- Name: tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: user_cmds_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY user_cmds
    ADD CONSTRAINT user_cmds_pkey PRIMARY KEY (name);


--
-- Name: user_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY user_properties
    ADD CONSTRAINT user_properties_pkey PRIMARY KEY (user_id, key);


--
-- Name: user_states_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY user_states
    ADD CONSTRAINT user_states_pkey PRIMARY KEY (name);


--
-- Name: users_login_tenant_id; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_login_tenant_id UNIQUE (login, tenant_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (component);


--
-- Name: vm_cmds_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY vm_cmds
    ADD CONSTRAINT vm_cmds_pkey PRIMARY KEY (name);


--
-- Name: vm_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY vm_counters
    ADD CONSTRAINT vm_counters_pkey PRIMARY KEY (vm_id);


--
-- Name: vm_properties_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY vm_properties
    ADD CONSTRAINT vm_properties_pkey PRIMARY KEY (vm_id, key);


--
-- Name: vm_runtimes_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_pkey PRIMARY KEY (vm_id);


--
-- Name: vm_states_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY vm_states
    ADD CONSTRAINT vm_states_pkey PRIMARY KEY (name);


--
-- Name: vms_ip; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY vms
    ADD CONSTRAINT vms_ip UNIQUE (ip);


--
-- Name: vms_name; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY vms
    ADD CONSTRAINT vms_name UNIQUE (name);


--
-- Name: vms_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY vms
    ADD CONSTRAINT vms_pkey PRIMARY KEY (id);


--
-- Name: acl_role_relations_idx_acl_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX acl_role_relations_idx_acl_id ON acl_role_relations USING btree (acl_id);


--
-- Name: acl_role_relations_idx_role_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX acl_role_relations_idx_role_id ON acl_role_relations USING btree (role_id);


--
-- Name: administrator_views_setups_idx_administrator_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX administrator_views_setups_idx_administrator_id ON administrator_views_setups USING btree (administrator_id);


--
-- Name: administrators_idx_tenant_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX administrators_idx_tenant_id ON administrators USING btree (tenant_id);


--
-- Name: di_properties_idx_di_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX di_properties_idx_di_id ON di_properties USING btree (di_id);


--
-- Name: di_tags_idx_di_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX di_tags_idx_di_id ON di_tags USING btree (di_id);


--
-- Name: dis_idx_osf_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX dis_idx_osf_id ON dis USING btree (osf_id);


--
-- Name: host_properties_idx_host_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX host_properties_idx_host_id ON host_properties USING btree (host_id);


--
-- Name: host_runtimes_idx_cmd; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX host_runtimes_idx_cmd ON host_runtimes USING btree (cmd);


--
-- Name: host_runtimes_idx_state; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX host_runtimes_idx_state ON host_runtimes USING btree (state);


--
-- Name: osf_properties_idx_osf_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX osf_properties_idx_osf_id ON osf_properties USING btree (osf_id);


--
-- Name: osfs_idx_tenant_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX osfs_idx_tenant_id ON osfs USING btree (tenant_id);


--
-- Name: role_administrator_relations_idx_administrator_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX role_administrator_relations_idx_administrator_id ON role_administrator_relations USING btree (administrator_id);


--
-- Name: role_administrator_relations_idx_role_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX role_administrator_relations_idx_role_id ON role_administrator_relations USING btree (role_id);


--
-- Name: role_role_relations_idx_inherited_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX role_role_relations_idx_inherited_id ON role_role_relations USING btree (inherited_id);


--
-- Name: role_role_relations_idx_inheritor_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX role_role_relations_idx_inheritor_id ON role_role_relations USING btree (inheritor_id);


--
-- Name: tenant_views_setups_idx_tenant_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX tenant_views_setups_idx_tenant_id ON tenant_views_setups USING btree (tenant_id);


--
-- Name: user_properties_idx_user_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX user_properties_idx_user_id ON user_properties USING btree (user_id);


--
-- Name: users_idx_tenant_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX users_idx_tenant_id ON users USING btree (tenant_id);


--
-- Name: vm_properties_idx_vm_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vm_properties_idx_vm_id ON vm_properties USING btree (vm_id);


--
-- Name: vm_runtimes_idx_current_di_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vm_runtimes_idx_current_di_id ON vm_runtimes USING btree (current_di_id);


--
-- Name: vm_runtimes_idx_current_osf_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vm_runtimes_idx_current_osf_id ON vm_runtimes USING btree (current_osf_id);


--
-- Name: vm_runtimes_idx_host_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vm_runtimes_idx_host_id ON vm_runtimes USING btree (host_id);


--
-- Name: vm_runtimes_idx_real_user_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vm_runtimes_idx_real_user_id ON vm_runtimes USING btree (real_user_id);


--
-- Name: vm_runtimes_idx_user_cmd; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vm_runtimes_idx_user_cmd ON vm_runtimes USING btree (user_cmd);


--
-- Name: vm_runtimes_idx_user_state; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vm_runtimes_idx_user_state ON vm_runtimes USING btree (user_state);


--
-- Name: vm_runtimes_idx_vm_cmd; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vm_runtimes_idx_vm_cmd ON vm_runtimes USING btree (vm_cmd);


--
-- Name: vm_runtimes_idx_vm_state; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vm_runtimes_idx_vm_state ON vm_runtimes USING btree (vm_state);


--
-- Name: vms_idx_osf_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vms_idx_osf_id ON vms USING btree (osf_id);


--
-- Name: vms_idx_user_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX vms_idx_user_id ON vms USING btree (user_id);


--
-- Name: delete_views_for_removed_di_property; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER delete_views_for_removed_di_property AFTER DELETE ON di_properties FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property('di');


--
-- Name: delete_views_for_removed_host_property; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER delete_views_for_removed_host_property AFTER DELETE ON host_properties FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property('host');


--
-- Name: delete_views_for_removed_osf_property; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER delete_views_for_removed_osf_property AFTER DELETE ON osf_properties FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property('osf');


--
-- Name: delete_views_for_removed_user_property; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER delete_views_for_removed_user_property AFTER DELETE ON user_properties FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property('user');


--
-- Name: delete_views_for_removed_vm_property; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER delete_views_for_removed_vm_property AFTER DELETE ON vm_properties FOR EACH ROW EXECUTE PROCEDURE delete_views_for_removed_property('vm');


--
-- Name: di_blocked_or_unblocked_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER di_blocked_or_unblocked_trigger AFTER UPDATE OF blocked ON dis FOR EACH STATEMENT EXECUTE PROCEDURE di_blocked_or_unblocked_notify();


--
-- Name: di_created_or_removed_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER di_created_or_removed_trigger AFTER INSERT OR DELETE ON dis FOR EACH STATEMENT EXECUTE PROCEDURE di_created_or_removed_notify();


--
-- Name: host_blocked_or_unblocked_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER host_blocked_or_unblocked_trigger AFTER UPDATE OF blocked ON host_runtimes FOR EACH STATEMENT EXECUTE PROCEDURE host_blocked_or_unblocked_notify();


--
-- Name: host_created_or_removed_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER host_created_or_removed_trigger AFTER INSERT OR DELETE ON hosts FOR EACH STATEMENT EXECUTE PROCEDURE host_created_or_removed_notify();


--
-- Name: host_state_changed_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER host_state_changed_trigger AFTER UPDATE OF state ON host_runtimes FOR EACH STATEMENT EXECUTE PROCEDURE host_state_changed_notify();


--
-- Name: osf_created_or_removed_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER osf_created_or_removed_trigger AFTER INSERT OR DELETE ON osfs FOR EACH STATEMENT EXECUTE PROCEDURE osf_created_or_removed_notify();


--
-- Name: user_blocked_or_unblocked_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER user_blocked_or_unblocked_trigger AFTER UPDATE OF blocked ON users FOR EACH STATEMENT EXECUTE PROCEDURE user_blocked_or_unblocked_notify();


--
-- Name: user_created_or_removed_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER user_created_or_removed_trigger AFTER INSERT OR DELETE ON users FOR EACH STATEMENT EXECUTE PROCEDURE user_created_or_removed_notify();


--
-- Name: user_state_changed_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER user_state_changed_trigger AFTER UPDATE OF user_state ON vm_runtimes FOR EACH STATEMENT EXECUTE PROCEDURE user_state_changed_notify();


--
-- Name: vm_blocked_or_unblocked_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER vm_blocked_or_unblocked_trigger AFTER UPDATE OF blocked ON vm_runtimes FOR EACH STATEMENT EXECUTE PROCEDURE vm_blocked_or_unblocked_notify();


--
-- Name: vm_created_or_removed_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER vm_created_or_removed_trigger AFTER INSERT OR DELETE ON vms FOR EACH STATEMENT EXECUTE PROCEDURE vm_created_or_removed_notify();


--
-- Name: vm_expiration_date_changed_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER vm_expiration_date_changed_trigger AFTER UPDATE OF vm_expiration_soft, vm_expiration_hard ON vm_runtimes FOR EACH STATEMENT EXECUTE PROCEDURE vm_expiration_date_changed_notify();


--
-- Name: vm_state_changed_trigger; Type: TRIGGER; Schema: public; Owner: qvd
--

CREATE TRIGGER vm_state_changed_trigger AFTER UPDATE OF vm_state ON vm_runtimes FOR EACH STATEMENT EXECUTE PROCEDURE vm_state_changed_notify();


--
-- Name: acl_role_relations_acl_id_acls_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY acl_role_relations
    ADD CONSTRAINT acl_role_relations_acl_id_acls_id_fkey FOREIGN KEY (acl_id) REFERENCES acls(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: acl_role_relations_acl_id_roles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY acl_role_relations
    ADD CONSTRAINT acl_role_relations_acl_id_roles_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: administrator_views_setups_administrator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY administrator_views_setups
    ADD CONSTRAINT administrator_views_setups_administrator_id_fkey FOREIGN KEY (administrator_id) REFERENCES administrators(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: administrators_tenant_id_tenants_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY administrators
    ADD CONSTRAINT administrators_tenant_id_tenants_id_fkey FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: di_properties_di_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY di_properties
    ADD CONSTRAINT di_properties_di_id_fkey FOREIGN KEY (di_id) REFERENCES dis(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: di_tags_di_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY di_tags
    ADD CONSTRAINT di_tags_di_id_fkey FOREIGN KEY (di_id) REFERENCES dis(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: dis_osf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY dis
    ADD CONSTRAINT dis_osf_id_fkey FOREIGN KEY (osf_id) REFERENCES osfs(id) ON UPDATE CASCADE DEFERRABLE;


--
-- Name: host_counters_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY host_counters
    ADD CONSTRAINT host_counters_host_id_fkey FOREIGN KEY (host_id) REFERENCES hosts(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: host_properties_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY host_properties
    ADD CONSTRAINT host_properties_host_id_fkey FOREIGN KEY (host_id) REFERENCES hosts(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: host_runtimes_cmd_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY host_runtimes
    ADD CONSTRAINT host_runtimes_cmd_fkey FOREIGN KEY (cmd) REFERENCES host_cmds(name) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: host_runtimes_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY host_runtimes
    ADD CONSTRAINT host_runtimes_host_id_fkey FOREIGN KEY (host_id) REFERENCES hosts(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: host_runtimes_state_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY host_runtimes
    ADD CONSTRAINT host_runtimes_state_fkey FOREIGN KEY (state) REFERENCES host_states(name) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: osf_properties_osf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY osf_properties
    ADD CONSTRAINT osf_properties_osf_id_fkey FOREIGN KEY (osf_id) REFERENCES osfs(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: osfs_tenant_id_tenants_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY osfs
    ADD CONSTRAINT osfs_tenant_id_tenants_id_fkey FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: role_administrator_relations_administrator_id_administrators_id; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY role_administrator_relations
    ADD CONSTRAINT role_administrator_relations_administrator_id_administrators_id FOREIGN KEY (administrator_id) REFERENCES administrators(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: role_administrator_relations_role_id_roles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY role_administrator_relations
    ADD CONSTRAINT role_administrator_relations_role_id_roles_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: role_role_relations_inherited_id_roles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY role_role_relations
    ADD CONSTRAINT role_role_relations_inherited_id_roles_id_fkey FOREIGN KEY (inherited_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: role_role_relations_inheritor_id_roles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY role_role_relations
    ADD CONSTRAINT role_role_relations_inheritor_id_roles_id_fkey FOREIGN KEY (inheritor_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: tenant_views_setups_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY tenant_views_setups
    ADD CONSTRAINT tenant_views_setups_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: user_properties_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY user_properties
    ADD CONSTRAINT user_properties_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: users_tenant_id_tenants_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_tenant_id_tenants_id_fkey FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: vm_counters_vm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_counters
    ADD CONSTRAINT vm_counters_vm_id_fkey FOREIGN KEY (vm_id) REFERENCES vms(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: vm_properties_vm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_properties
    ADD CONSTRAINT vm_properties_vm_id_fkey FOREIGN KEY (vm_id) REFERENCES vms(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: vm_runtimes_current_di_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_current_di_id_fkey FOREIGN KEY (current_di_id) REFERENCES dis(id) ON UPDATE CASCADE DEFERRABLE;


--
-- Name: vm_runtimes_current_osf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_current_osf_id_fkey FOREIGN KEY (current_osf_id) REFERENCES osfs(id) DEFERRABLE;


--
-- Name: vm_runtimes_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_host_id_fkey FOREIGN KEY (host_id) REFERENCES hosts(id) ON UPDATE CASCADE DEFERRABLE;


--
-- Name: vm_runtimes_real_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_real_user_id_fkey FOREIGN KEY (real_user_id) REFERENCES users(id) DEFERRABLE;


--
-- Name: vm_runtimes_user_cmd_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_user_cmd_fkey FOREIGN KEY (user_cmd) REFERENCES user_cmds(name) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: vm_runtimes_user_state_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_user_state_fkey FOREIGN KEY (user_state) REFERENCES user_states(name) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: vm_runtimes_vm_cmd_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_vm_cmd_fkey FOREIGN KEY (vm_cmd) REFERENCES vm_cmds(name) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: vm_runtimes_vm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_vm_id_fkey FOREIGN KEY (vm_id) REFERENCES vms(id) ON DELETE CASCADE DEFERRABLE;


--
-- Name: vm_runtimes_vm_state_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_vm_state_fkey FOREIGN KEY (vm_state) REFERENCES vm_states(name) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;


--
-- Name: vms_osf_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vms
    ADD CONSTRAINT vms_osf_id_fkey FOREIGN KEY (osf_id) REFERENCES osfs(id) ON UPDATE CASCADE DEFERRABLE;


--
-- Name: vms_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vms
    ADD CONSTRAINT vms_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE DEFERRABLE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

