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
    view_type character varying(64) NOT NULL,
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
    tenant_id integer NOT NULL
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
-- Name: role_administrator_relations; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE role_administrator_relations (
    id integer NOT NULL,
    role_id integer NOT NULL,
    administrator_id integer NOT NULL
);


ALTER TABLE public.role_administrator_relations OWNER TO qvd;

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
-- Name: role_role_relations; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE role_role_relations (
    id integer NOT NULL,
    inheritor_id integer NOT NULL,
    inherited_id integer NOT NULL
);


ALTER TABLE public.role_role_relations OWNER TO qvd;

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
-- Name: tenant_views_setups; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE tenant_views_setups (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    field character varying(64) NOT NULL,
    visible boolean NOT NULL,
    device_type device_types_enum NOT NULL,
    view_type character varying(64) NOT NULL,
    qvd_object qvd_objects_enum NOT NULL,
    property boolean NOT NULL
);


ALTER TABLE public.tenant_views_setups OWNER TO qvd;

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
-- Name: tenants; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE tenants (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.tenants OWNER TO qvd;

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
-- Name: user_properties; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE user_properties (
    user_id integer NOT NULL,
    key character varying(1024) NOT NULL,
    value character varying(32768) NOT NULL
);


ALTER TABLE public.user_properties OWNER TO qvd;

--
-- Name: user_states; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE user_states (
    name character varying(20) NOT NULL
);


ALTER TABLE public.user_states OWNER TO qvd;

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
-- Name: vm_properties; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE vm_properties (
    vm_id integer NOT NULL,
    key character varying(1024) NOT NULL,
    value character varying(32768) NOT NULL
);


ALTER TABLE public.vm_properties OWNER TO qvd;

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
740	138	34	t
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
966	87	97	f
974	74	97	f
975	75	97	f
977	78	97	f
988	76	97	f
989	18	97	f
990	19	97	f
991	58	97	f
992	59	97	f
995	212	97	f
996	213	97	f
997	214	97	f
998	175	97	f
999	176	97	f
1000	177	97	f
1009	38	97	f
1010	244	97	f
1011	40	97	f
1012	37	97	f
1015	247	39	t
1017	248	42	t
1021	247	97	f
1023	35	97	f
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
935	162	60	t
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
967	224	97	f
968	225	97	f
969	226	97	f
970	193	97	f
971	194	97	f
972	195	97	f
973	188	97	t
976	81	97	f
978	92	97	t
979	14	97	t
981	84	97	f
982	85	97	f
983	86	97	f
984	88	97	t
985	192	97	f
986	15	97	f
987	89	97	f
994	65	97	f
1001	24	97	f
1003	39	97	t
1004	25	97	t
1008	244	39	t
1014	131	97	t
1016	246	40	t
1018	245	38	t
1022	36	97	f
1024	249	41	t
\.


--
-- Name: acl_role_relations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('acl_role_relations_id_seq', 1030, true);


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
138	config.see-main.
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
162	config.update.
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
\.


--
-- Name: acls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('acls_id_seq', 1, false);


--
-- Data for Name: administrator_views_setups; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY administrator_views_setups (id, administrator_id, field, visible, device_type, view_type, property, qvd_object) FROM stdin;
4	1	name	f	mobile	filter	f	vm
5	1	name	f	desktop	filter	f	vm
23	1	casa	f	desktop	list_column	t	user
24	1	calle	f	desktop	list_column	t	user
25	1	edificio	f	desktop	list_column	t	user
26	1	world	f	desktop	list_column	t	user
27	1	id	f	desktop	list_column	f	role
28	1	roles	t	desktop	list_column	f	role
29	18	osf	f	desktop	filter	f	vm
30	18	osf	f	mobile	filter	f	di
31	18	overlay	f	desktop	list_column	f	osf
32	18	ip	t	desktop	list_column	f	vm
33	1	id	f	desktop	list_column	f	user
35	1	next_boot_ip	f	desktop	list_column	f	vm
34	1	mac	f	desktop	list_column	f	vm
36	1	edificio	f	desktop	filter	t	user
37	1	casa	f	desktop	filter	t	user
39	1	creation_admin	f	desktop	list_column	f	user
40	1	prop3	t	desktop	list_column	t	user
38	1	propN	t	desktop	filter	t	user
42	1	serial_port	f	desktop	list_column	f	vm
41	1	ssh_port	f	desktop	list_column	f	vm
43	1	vnc_port	f	desktop	list_column	f	vm
\.


--
-- Name: administrator_views_setups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('administrator_views_setups_id_seq', 43, true);


--
-- Data for Name: administrators; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY administrators (id, name, password, tenant_id) FROM stdin;
3	ana	ana	1
10	maria_root	maria	1
11	manolo_op	manolo	1
12	gabriel_root	gabriel	7
13	gemma_op	gemma	7
14	super_root	root	0
15	super_operator	operator	0
16	super_qvd	qvd	0
17	super_vm	vm	0
18	truman	truman	1
19	bigbro	bigbro	0
1	superadmin	superadmin	0
\.


--
-- Name: administrators_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('administrators_id_seq', 19, true);


--
-- Data for Name: configs; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY configs (key, value) FROM stdin;
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
79	14	2014-11-04-000	t
82	15	2014-11-04-001	t
84	16	2014-11-04-000	t
1116	19	head	f
86	16	default	f
87	17	2014-11-04-001	t
89	18	2014-11-04-000	t
91	18	default	f
92	19	2014-11-04-001	t
94	20	2014-11-04-000	t
96	20	default	f
97	21	2014-11-04-001	t
99	14	v12	f
100	16	v12	f
101	15	v14	f
102	17	v14	f
103	19	v14	f
104	21	v14	f
105	18	v12	f
106	20	v12	f
1122	16	head	f
1376	21	head	f
590	14	default	f
1275	14	head	f
\.


--
-- Name: di_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('di_tags_id_seq', 1519, true);


--
-- Data for Name: dis; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY dis (id, osf_id, path, blocked, version) FROM stdin;
15	14	mUbuntu-14.tgz	f	2014-11-04-001
17	15	mSLES-14.tgz	f	2014-11-04-001
18	16	gUbuntu-12.tgz	f	2014-11-04-000
19	16	gUbuntu-14.tgz	f	2014-11-04-001
20	17	gSLES-12.tgz	f	2014-11-04-000
21	17	gSLES-14.tgz	f	2014-11-04-001
16	15	mSLES-12.tgz	f	2014-11-04-000
14	14	mUbuntu-12.tgz	t	2014-11-04-000
\.


--
-- Name: dis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('dis_id_seq', 225, true);


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
1	0	0	0	0	0	0
3	0	0	0	0	0	0
4	0	0	0	0	0	0
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
1	\N	\N	\N	\N	stopped	f	\N
4	\N	\N	\N	\N	stopped	f	\N
3	\N	\N	\N	\N	stopped	f	\N
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
1	Host 1	1.1.1.1	t	t
3	Host 2	2.2.2.2	t	t
4	Host 3	3.3.3.3	t	t
\.


--
-- Name: hosts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('hosts_id_seq', 121, true);


--
-- Data for Name: osf_properties; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY osf_properties (osf_id, key, value) FROM stdin;
\.


--
-- Data for Name: osfs; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY osfs (id, name, memory, use_overlay, user_storage_size, tenant_id) FROM stdin;
14	mUbuntu	37	t	35	1
15	mSLES	512	t	1024	1
16	gUbuntu	256	t	0	7
17	gSLES	256	t	0	7
\.


--
-- Name: osfs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('osfs_id_seq', 153, true);


--
-- Data for Name: role_administrator_relations; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY role_administrator_relations (id, role_id, administrator_id) FROM stdin;
1	1	1
3	1	3
19	97	18
37	1	14
38	101	15
39	100	16
40	102	17
41	99	10
42	101	11
43	99	12
44	101	13
\.


--
-- Name: role_administrator_relations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('role_administrator_relations_id_seq', 44, true);


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
48	78	34
49	78	60
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
122	97	49
123	97	39
124	97	47
125	97	75
126	97	72
127	1	96
128	99	95
129	100	93
130	100	84
131	101	92
132	102	86
133	102	85
136	103	85
137	103	82
138	103	80
139	103	77
140	103	89
141	103	91
143	103	63
144	103	45
145	103	61
146	103	43
\.


--
-- Name: role_role_relations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('role_role_relations_id_seq', 146, true);


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY roles (id, name, fixed, internal) FROM stdin;
1	Root	f	f
97	Operator L1	f	f
25	Tenants Creator	t	t
26	Roles Creator	t	t
27	Administrators Creator	t	t
28	Images Creator	t	t
29	OSFs Creator	t	t
30	Nodes Creator	t	t
31	VMs Creator	t	t
32	Users Creator	t	t
33	Views Reader	t	t
34	Configuration Reader	t	t
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
100	Root QVD	f	f
103	Operator L2	f	f
58	Users Eraser	t	t
59	Views Performer	t	t
60	Configuration Performer	t	t
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
78	Configuration Manager	t	t
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
101	Operator QVD	f	f
102	Root VMs	f	f
99	Root Tenant	f	f
\.


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('roles_id_seq', 103, true);


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY session (sid, data, expires) FROM stdin;
4033f5f4c721c31e9797489cf54fc73d6fbc6212	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506591
a139cd4f149896cdb4ab14baa26594826132b014	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506631
92d863b7b3de3668c1227e2dc7a93ef97b6e0ffb	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506665
d8f59702356dd375e89997f3910b1e748e09520b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506697
94213163b1a8ebcc372a5750a1bc8c5ff72b93bb	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506707
e3f6e506bb51563824ead2d4514ca6476199ad5e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506834
af079dd56b2c6ef0906b5dd5fc271332b467007d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506964
34b4858f6ca41a37f4ca40c2ba6a02614bbbc0e9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506967
ed63513424647796b00a77a9dc38d35062d0af8a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506968
1387c245bd28707389f68b8a971f528fc955e166	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506969
c860383090c62706585472f2758edee349df03d9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414506971
22cfda872a08f82ca49a6cb8d76d7a8aa4cf1cb0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414507331
07924d4923dbdb5a55929cd380e1cb6357496294	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414507539
1510edb564a6bc56e3e48261a9bf5fc507d7cc35	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414507541
594fcda64d96231b19cfabf09d16d19fb482b632	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414507549
16e3e89a4df3d831c14daf9d0d2659968f1fe4a0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414507657
10faf7192784bcca18dc96c1feb83a51dad45773	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414584397
eaf0cfd2d7c0d5ffd5f1dd294c94af51646cdde3	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414584399
4329e6a3f26ef0041fac44a38edb64f7a0d7b87e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414509577
c94060ec90110c74322d350bb7745fb456213908	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414509617
c4542296409d75825692330a2aed24859373eb49	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414584411
479c119a76d4ceeb52225e7e48caa3089da712d5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414584414
ba780d6db6d81afa21b093b707d96f100154df80	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414558841
d9021b34fd1df4dada4006c8b05ebe89a56c8aa9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414584457
7ec05937afd6057d968bf553adbdb87a6fa72ee0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414755775
320a4a05d4ece5101fb3eb229117621a2e101653	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414574399
45d1e9e339f0a26c03dec02001c366b0f3d3ff89	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414750869
3c48817b5f28c2de30be2ff4add53a7d4f318d3d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414513003
f3723a3fb7cae64807ba2ad4c6314cb6e0e1351f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414750880
bca7f32d29dbd0481633109f8d54c5f50b3427fd	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414599435
41349d7cb71c1f048a09e18121ef06d4caa5b9de	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414574782
5d7269ad7beedc2b864ce2dbbf01b118484717db	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414509423
31068bd08143bd5cc1007df4efa953b5e65de5f6	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414574786
66daf88e1b9c9dfd1e14e7e9e38d87a2eb25e3e7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414574807
3123dff4d69965903cbf905bed7bc17536f5bd76	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414509454
adda29186c135fee86093936475f7f2ad15f22b7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414509456
b97650f205d1f4618aa2787ba38cd502e7bf6352	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414509555
19ec93168e08091f097c1d5b041a8c316b039b89	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414573212
bee71457e4a8b4eabd3b921e30e6a9634dac3976	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414509560
1031abee47bb5af7af4a11b6315b81f10a20b5df	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414509572
7534ea58ca5502800f34672c4e118df20843c63d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414573221
56bec02328aca79adfa763cab7bcf826cd1228d0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414573223
530573aefe40154eae9c8934e22a1812d049c027	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414573240
12a7d7f55dca50a0270402da85a46aa52f03907c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414574816
a435b5d0842bc18dabf8d349d736e04083d98360	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414751103
2199184f8a8a3b9477f0ecf8505aeacf159d5cef	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414731646
ce238fd304f3f157da6db64a380a046de26f608d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414584256
51705ceb0c999a08d1ebbdf7342f8e20dd0b3ae7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414584272
1936404b9ce5cb7814976c6fbc765825a8ae9b10	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414584321
603ca44accda5a06e163d7038c2ee6d995e78200	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414751162
e9e671959f7b5e54783aa53bb9d8291c3719c0b2	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414584348
cff0ff566dbc25c5656a8286d9384fc686d7187d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414753382
274a1a6061a36126037a5d115636a1828d863efa	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414755869
f9282866790292bc97c100ed1fdf0019be9b3293	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1414754048
43fccedba5e1ca6291c5d2994276d15906eae6ab	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414684668
79e80d301c1561f26fe9f3f4f4a9bc4fbd81d7d4	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414684297
fa38e556ada978579a00788af04f76c01a8df9be	BQgDAAAAAQiCAAAACGFkbWluX2lk\n	1414753394
78f6d5a9152d2b5aecb938675810664c8138208a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414754094
3c0c0c121b5976ea3d4e424a84e1bd3413d4a5f1	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414756221
6a35f6dd446fe111648a7ad85cfa23e79de4f7ee	BQgDAAAAAQiFAAAACGFkbWluX2lk\n	1414758657
52b7470fb0a4e787ef5c98982f93346b2f9e5d0b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414754724
e0d6264d3a139c5c923577faa12a1bc1d60d8173	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1414754674
ca1d625f9c4d27485d94dbbdd7adf7143a03bcdd	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414755904
03ca345f85c9e144de2bdc3524b1d60814732eb1	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1414759178
a2e21a39b4e41f6bccd6d42effc20e9d8f4e768b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414759088
a83781e9580869ca33c45581d23aeb3fdb19ff03	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414758375
7f115e1152e5721be696452c481db7b6fd5ab842	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1414758390
a6bfee6496318db10c080f252e4f6426010d5fc0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414758413
1aeb76bc92d254ad0387fb88e076ed79f44f02df	BQgDAAAAAQiFAAAACGFkbWluX2lk\n	1414758510
bb231f40136b277eb2921726eecf0905cbafbc13	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1414758518
cddf47b0588b438f16c69eaf65a0211a55682415	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414758994
be6760958cf875ea28cc2af1dc84f668b7c89062	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222141
9af3913b8681c91441ad7e7c193145e7f7f15fe3	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414818048
435ec808e9e0e5d5e4b05043c683c4e4cf700b43	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415024569
2d5f0165425e50dcadd6cd7f3f888fb505f377ca	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1414760663
c2801c4c1753a94de5cbfd7afadb2c4dbf55f3e7	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1414758669
eb4d79eb424f31f0b2554b5532e0b55663075d02	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415015062
5216d9cf5e620ddf6c7b5116eb221f72cc4e7461	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415020359
ba65b6d47ff3ea73b803f67cb9950ace20cd4841	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415005687
7a82b195b6231f6ff5e334dfed154afa66f0c320	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415024627
b11448d8f25a7c172b72b76fc1e727007d543d5e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415024773
6f3dd7e029160f13e3411de5a0fb7fc7d75a10b0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415024842
dc8603051eeb01c3ad927b7f5f619728f52f13f1	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414763105
cab9c1f6a7a5f49a7ca1b52970b7d5b4eaf3258e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415024944
b9c8e55db8148fb54fa5a5eb4e3c3a7c7875202d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415006958
32eb1738d768f3bc1fb01d5988791bee05eb725f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415025004
6d68c3e03b3619a7ca650a9416d5fb61fd904dca	BQgDAAAAAQiFAAAACGFkbWluX2lk\n	1414759183
66c77613153f83b6999c7633411a995342f006f9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415025413
a72b1fc6e41390e1241d08070aa4cf39e9c032ee	BQgDAAAAAQiFAAAACGFkbWluX2lk\n	1414767899
d2fefd9065506b44ad6a7541d742cca91a6c0461	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1414759197
0536c0b42d39995a51737b46d2cb66bec2f98292	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415025501
9238f738e5b6d763d06b959c3a8cc47e90f2089c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415025541
62a5a5473a5604ffa134b9ffa69fbc54d2d9fc30	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1414759622
ff5b9fb838dd861d38e9774856aa3ae2b3d7a804	BQgDAAAAAQiFAAAACGFkbWluX2lk\n	1414759232
c6045dace26d5fde57a49931354d7821a56c8663	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415002777
213813b0c07a4296c55cb1c6bd554543a07d8c2d	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1414759240
62c30cf9181458ce7510ec5372e4b658a693ff98	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415005689
bda6a83afb05e173047a8925df2562198810e07f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415025587
c04994d45485edb533344b8033e81b0122e3e592	BQgDAAAAAQiFAAAACGFkbWluX2lk\n	1414759645
313b993b7f0bae6037790511304bcdb76c7da3ba	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415006937
efd0f30ee56e5514c97888d2c9d0ee89ed6e30db	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415019816
80c49eee72bc7c4e16eab70e5e8358c54ec93b60	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415019821
ff026e45d379b3bfec12f4120365f8084b9cabbc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415006960
ce22b6e370d88d2d6106ad456ea3156b0ef2b85c	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1414760187
0543dde2fd49d9a67e144ce750f616e83934e122	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415005543
3992f0aac16bdc696a69bf4bf7bbb8186b91af25	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415174523
0f4e4e56f1ee27d8109aabba195bd88a4a2efbab	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415015066
380ca3fc4b8cb475d9f1c9b6c08967deec4af307	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415007866
953b4f1601c9bb23520705903fa050c787b833ce	BQgDAAAAAQiFAAAACGFkbWluX2lk\n	1414760654
2779b322f9c2f15c8a47cfd6862abf894c8bb911	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415027078
123d5ce0a1870e2fc7ea2383d0d65ed917136159	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415007938
24f3fdff7e92c8fcfe9599f410ed480830639847	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415006942
ff6eaf18d00dac3f6076e964f060baec1ddb5bd6	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415027088
35916ec743c223a162c5ef34530e75b3c6bb22af	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415088260
923df71f3f57e4798957058899335b2bf48e5ab3	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415112791
aedb025fc70049031fe3c5b6cd2a6ce0356da873	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415108879
f780cb3d80a54fcee4cb99e22e08c6b3f49f634e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415108874
d1d2109bafc85dec42ae3f9a6afd2b8d6f7e9441	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415026634
7f8754ee8e7d31074db5a602e518343525ba8f76	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415024338
7a755c91b2a5e65c59077294c780cc0cd4efe297	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415024518
d8a561901fc5078fe64853cbd8a15defd6745060	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415197115
a1ea312682626114799f99735062dc72eda89f7d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415026682
f5935bda9415ecc060156cc30849baff509502fc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415026469
d562914d70eefcba3df8aeebefe74851a076436a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415026494
478e7130446f52d8c9b66aff41c3a18f94a164e1	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415026691
06047a6964b3f5cea99662cbeb0e5b46d91732fd	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415031299
a0c89cef9ddc8abc9884c99e828adb295cd84d14	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415202807
6a877994c0c053a8d6ad3c8cbfab8ce87ad315f7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415192452
33fa98eb014319a6431161deb3a9e86cf9ec31f6	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415117367
a8a4e0d1dce4ed715bddfde273947cc13968a693	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415192590
0ad0c3adb806bf5d4891e52cee8f07dccbe63064	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415109327
d7f63d2b5f79206084ba473775f785bb957b1b22	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415183647
4754c4b6fba72df39fa3d2f4fff36fe2f1f4f635	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415183651
89cacdb220f3be62bb2c65a1d4942f3f6a6aec9e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415192570
2eb2146d9cdb60e6268442cf0eba1d07b1a16b30	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415195343
a219da37e9528b3791fc6e965fb1e4ab70cc2e0e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415203052
894c6d129b1d6d883c1516ffdec5b3b5250cbfe5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415196972
6d66d89ed2830146f1eef23ff010a32101a0ada5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415261568
b697e80c4debccb9967777025c5ac9c3396c17be	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415271297
869650f4068676ccbab2e963aee481ea90483dc2	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415261995
f60d87af9843f2272cce5c2bda88d4e84c4e6a62	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415272208
f2b2223bb5b14d45a7bacac5b9072ddc384b8235	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415272224
fde0ed0c0d021beacab9d65c051936e9e777cb7e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415272229
deea8d725e975b790bd59a15d01a761be46aea97	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222142
8d2985275c854925c5382555cc303993fa3bb112	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415277691
53c481e643dcb014143d5ec65c0205ed75a21c5c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415366752
ece551cd941dd734f4c3566a0258c29346403ebc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415282312
130cf837208f5a24efecdb66a644d8a5ed197508	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415282324
a6160e1b0b769affd23a255c8bba6a021f8c63ee	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415282347
df755cb9cc94d3168c680b8b7366cdafd276afbc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415280555
88ef3c966cc545d917c48b958c85b0c7e286f9b4	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415281477
0aa2fbcc4061f316bc1b6dc0231022fcbe22ecdd	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415279191
16020b53a89bac4bbcb72c0724dd8bd688462301	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415348428
47508cafc0c4c44593fbf0aac60be0a8b252ca38	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415874046
23df914107f6395b30e2512ab5d93b2d2643612d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415273605
119564685179a6040f2bc01625ccb8131bbbccce	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415277635
00accaa2f41ba37012f00a5b959165bcf35a8229	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415281213
fa95e321831234d83c39b2660e6ae4236bbacdc6	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415272232
5a475dfb6cca046ba45545f9722dd94c5f117134	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415347606
0f5be454c5ec8b7caa250c0a5e32ede3e11152bd	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415869729
744ae6f7728d45b56f6b371598cfd033d46f758a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415280579
0dbb7ba2af6c3a25a96499ac12bdfb11c02fe6de	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415280034
42067f552bf758b4e62001d629527247d9883bbc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415272809
441a52a8d8d72fc246b62413adf393f1db655c68	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415277421
ed824b80cf4686f9993f1fe7c027b906c5b1cc01	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415278536
e5503f54468a52ae79d353bb2b48b5afc477d431	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415290395
0b5ed895312dfebd765ec8e7b778182e031739e8	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415278352
d30f96635f1c219aace4b29c8e33ef681b47957a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415273002
6286f88689b23666b1f2d61c0f3fd4bc1f226ba4	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415347488
23a0ef720fe4adb4cfd3694e264cb1dcd279a54f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415276704
8cdd33f6d39e688078aedda7adb79b85a0c4cdc9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415283254
bd7697c768510b0662c5ce444e3c284f3f1e5fbc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415283260
941b3a1fec8de977d1d8b8844e9460c598d0713c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415280236
0d80468de57ef67fe593616e4e696eb7265491ba	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415273609
50928eb0b840dc3130e5f94841238c56efabf515	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415273874
b9d6ab72281c195f4a7ac839e8626ceaa7743647	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415278063
0a8688eed434e3f3bad1e8296db1f6e43adb9a12	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415867528
6815226ff5eed1507e8c4227153c5fe3bfc3dd39	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415281594
98c59501b7150f9e34667ce8fce1caabaed4b7da	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415281166
3c8ef4088e631fc75d2554d43a4a6f9d8f06b84b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415280468
499183e82be3bea50800abca5015d1e18b44657c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415276400
2b1fbcddddb64c8a252eabc248c6dcd3707ead59	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415281309
8f383466a9be65d5bb0b295b45cfbd139aaee48b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415286375
9ab93427b11921c76b9c3849634ca1583694b2a0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415279134
1a9f58a0b496213dbcc0643e1acb50cd0ef4df1d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415291040
458c605320587aa8cd94ea10a513e753816ffa26	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415279977
f5d0ec0deba03aa1cccd60f47e7d566cfa90dfb5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415279018
c175ce4a447d0ee10dd06022d48640b7c8581bab	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415347599
568d3612a563a9c1548f33a28d314056573e606a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415288991
df2fbb438bfa410ce4f65a65da07e53380189238	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415280504
05fb0670f2ee764c6db8009830309d250d5e783e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415282000
78c633859b36ffe4ee409562cc12b41319e67d94	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415282024
5126fdebe7f6ad958a60334dc9b71fd49d11572e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415281197
3a5f85b3e3a599fe1b624011618ca3d0ab829e11	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415287115
ef77841fde5781bb145c8c36eb35ecececfe5b9b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415371687
29ea62b3be9ec0f1ed82f3c7818b8a945a9eda37	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415366756
f9e5c7c960b143c430fa89998cd13a8045492b28	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415349962
4fa6d880b955da0eb8876e17e4d26db88a9f5486	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415289951
208fa9862139f1e1873ee7eccd1c07576c916f06	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415336460
2d3bde3fac3023733ec6e16833bd88356c9a3e32	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415874698
d887274222ad5af8f1ca7d7429932c84e6f1aded	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415874354
764fe9f0b30e3f802885ecdccf82aac60be21709	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415350086
1210af9fa973e7bb6c281f40d7ef870d5fffe395	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415867539
940943a0d78903b79151ad63b18c241053b649c7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415422858
eea5b4ad257613f7d38a5dc3eef88e864eb790be	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415372162
935afa8c1da1b8e2f8b2bf5ce1ad20f886e78695	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875335
04fa115be74b1b302edfeaf72b270bf77387b26f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875344
aaf829cb83d3fcf9fc446be00774f2f6744e128e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415875314
83810fd0d876e093b8b63d9ddd115f30e04ace55	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875622
c3d814ae8e8e89b1daa21b377809e7226574a679	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875700
088dba538d84b439a40fc316dceaf1a497ac53b7	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875737
e49b7368d8bf3c53c995750628ebff2f007d338d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875750
54617ce44189bdb1ae67c6874f24ba4525383027	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875775
4045c6b69a641c3b7bd2c4a197ab6b7a9d98cbaf	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875806
b175891cfa5bbdaa2a6006488ba4728cb4cb61b0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875847
6dcd60cb88024c7293016ee39eaf15f831d57cd6	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416456058
6887d9cbf224cbb95ac0a9199aa77afe1e7dfe8d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415878052
a9da7ed02cc3deab51fd625531464b32fdd076ff	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415877935
fdf7c916f8fb90c04a17789c1c8359c804b67715	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884782
729672f8decf81b9ebe5490f6731cd75e8310226	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875918
6f438b0c0c61f011b01515f1d55372cfef6ecfdc	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875858
1f924e3e5040eed885d3377b45d0c7f4db16355f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415876416
983b96f44e54aedb07cfe8aca3fcb3d3f431a552	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884763
3229a90a1a303c6cc348e14eaeaa1d43f825cd87	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415876274
39ab906711ec2390457c484d24b3b2b7db2c95b8	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884517
5d4ff67cb63f2a3a87be0748a3347445afe5730b	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875868
cf3c9373d4515f3924766c952c6b55869eaa1f5e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875942
e8cf13891cf853d6962ec017949495e332d3631e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884251
7b5cd036b58e5e1aeb19270a7d277dee0b4b13ff	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415885740
efa27ac60116f2f3522ac3c6bd5708d73abc6c4c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415881402
d09c8522f80c757b692f4ff94557bfad7370d4f5	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415878918
b3e7e0b3140a2a9ece808e5740a17845b544daa8	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415876295
00bd759a64eb670df3ad94ab2bb4210ca068d36f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875876
cecc395cc244bce2b09cc4d6b4230dff24e3c3cd	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875966
f6b018e16ace4d23ead6478f496f17ed36ed0c1b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415883972
26a92cc4e0e622089093592ef98357bafd9e68b8	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415879642
256f21f3c8727a91dc3b3acb3b6cc331bc7b2ac4	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415878258
c8dc3e9f224bb0d0485efb89576bed943c00e2ea	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875883
028160d772fce127ee58b348955172e87fcd9a88	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415881847
3b301997c28505a9f7910627cd5f24f153a479cb	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875973
7563106db429eaf570cd8e6e4f0270a3eabaa4ba	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415878038
693b36b7247dc109eb6620067c18355e90acd3f3	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415876484
0828fbd9d583b4af54b85c24f134dedda2013c18	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875896
d615e8fc8ed736031cdb4b354ad1c9f78aee9bf2	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415878104
4b2263e0eda3b61e553330dc470f21f65d6a7bd5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415883944
d8b912ddff521848d8723170702acc86bd76879e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415883477
2e82af4b9d7266de2b0ee647eda495fe9aaf6854	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875989
79eae45b5c3eced62256b94763b7f019b2f18c75	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415879643
f2677b19edf539f69dfa3de6b1120bd75fcee5d4	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415875905
e599ea10bcba4700fd55d5cae76b4f10d8138502	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884468
7d72adffb26ed7b550d218775e74c173156ed355	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415878429
eb3babf5d9737788602905c8bee092088958b934	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884730
6f3418d491938a626f2301901322d4fccfddeab9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884730
b9171c4e96619f8b3fbfdecf05edcca8bf6cf3b3	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415878990
2d9954c527fa732e7374e6936a3f26c32fd5e96d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415876027
b603dd94d1eb1b5a9f6d0c02cca2c056b0d3ee4b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415885733
2fd7b5d87b4af5928e5aac4bb61516acfa6079c8	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884597
3f19c8154e907e6a10fec8b75df9108c864c546d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415879782
ece394aad67339f49111790b1b3ae24078f0a765	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415878549
de2aa9d12e7ec541cda0a6195fa3c66927685c55	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884931
abf5690b63ecb6acff11273c853bf1e5afd74ea5	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415881427
a49faae1a8e2a40adc53f924ece3e903f84423f9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415879143
5974ab7513d464e5e5f9bf7e1d5052d1861a07d4	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884497
b7f3bc08ac2a3ffd714d816a9569c12e95a1e6ef	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415883217
71fbdc7b57cbe4fc0e739a9cb096ce1c1a7279f4	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415883675
7a61ba596bdaaacfe071a9136fe2c812b8884585	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415892173
958bc6894d949b5f99c11c395561eddd5effbe86	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415883252
1bd7d83aeadf1033d7e2bd83ff2cace538486c05	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415883302
e3f2096376895edeff1f89a384e781bcb9b38ed4	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415885741
2af5740f7cc3bdccf17b1ab95e746b5355e1cc5e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415892011
11e17a2514c85c37a7e1168348965228b78486b7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415884789
1347743e82236b30d16c4d72ee2ecc577e91e11a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415889339
3a6af8f34fad25aa98ac8319d4f15a34229c9730	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415890175
1bdbc9db1f2e25e38cbced9b3827c79fb2edd893	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415889208
75befbb197d35516903b2d8683520d74c3a1b989	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415891716
e2c0a39db0bb3d4ade7d035def465cd6684f21f7	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415889405
62f47154bd7dcd261fe83be34f632f0e03ab0e55	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415889338
c274833b59fb3486c1712520320d72e0005393f8	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415890290
440ec7ba64d6e77747d88948ca6957fcf71a70c9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415890105
5f2e35c8b63fcd0b8b7ba3f2bad52f96d2ca6258	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415892200
44c836a8b712d84f443756d056d1e0430aabac5e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415892141
66c631c2f01d89dd40e911c5ba8a628ddabf2ecf	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415892223
7d79bb66823707c7a9ea4f84bce52754e9946934	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415892236
392ecbcefef2cbbd960adea0586794baf78829ea	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415892256
97fe8cf8a57fb673fdefe9b6c3f3dc39b2358b94	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415892412
764a21ac0a50e5219e103a32d45e1caa2e85e233	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415892825
ba27921c2cb2c21ac51253f23ed8ffa22bfd6022	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415892863
1cf5f0871010190fe00898c8bd82e61f23af838c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416456058
ff6f96aa6145216863e91e6fec1a173d715b353c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415969094
ca8a8396a731c1456efbfea033b5b99d415cddb9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415893555
0cae1b60ade8fc26425c8bcecd2052cb38608bec	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415952931
8ba5af633710295995f424392a7da7a4cdaecf8a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415893555
5df7355fc89e30d938da2c6faccfbe32fb35916a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415964496
6af2d65f837fb1545547270d405fe53ae3feefd9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415963127
f830df7ee71798c237301bcaaebc10875070a4d0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415966068
093ab3cdf924c69269ef05c4d311a310e113b951	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415953430
7774893233073e1d29aaa0b2b5fec211c6ee6767	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415964669
5e01ca9faaf48b1f318dfd42b7019ec9a449a60e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415893754
fb97e10ccf762392dff6ff27228bf463258c9025	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415963594
c03549c9e59ea7e7dcb9d4a223f4389127e6ec7c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415953000
25427cd79679d4c88c6538235a083bc4ab73701a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415894870
433b438720574b1b6a6fc2f8eb62b9bf6ea42548	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415894925
27f3f635208a71ed323a7e39819fdaec62ddeae7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415958233
0cad51801dd4f7980ea9cffe5f8869aa59881a59	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415893771
3a04130a20e5e1499bcf69b836a1d2e04ec22df0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415955381
868848734ad29e588f01966053962b6c973fe331	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415953071
65d0cb25cacac7f5bb98985fe428da02d3bce670	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415955402
0b6cc276c0e2752396b1435bc7ff8a6ab64023cb	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415893689
bc82854ca7763d0e37ed133e3f0c12c7694b69fe	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415955445
d7b1b8e53d04f2620071d478df196d642dfb6796	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415955480
40f3f17947bef209ef6137fdd5e1603ad3249a06	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415955503
3ab3078f8aabcd057c435c4761521870fbab252a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415955504
a5b99d69b27e0e24afdb6558172374841abc0abc	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415893968
03a48918e272a4e0e46e28ddcb8ecbdb517e55ef	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415955520
308e1a87f562009aaed74c63e6cf46e348c7281d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415952481
80192b3acb8602ec0148fa35b34b2f86bac4bbb2	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415955692
987a3bf429f3c87451abc75df976e79538f57ec7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415952783
4130498519295a62b848191b2c7608dd8a673837	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415955700
81433be29b3ff02c4801365c4e9a09d635ab39e1	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415955778
4b6a64b8ecb90db3415bdb408eab6731abfcfeef	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415953083
e4efd1468ebe0914e9d0b799639827a5df1f2d09	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415963274
ab5558e963ee40a0fb3deacaea4424de696b0549	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415952896
cc57c495245c6b63a69ef8da6814604cee48d679	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415965089
6885d9254ee672b661ef5072202cdb7627eca569	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415964895
479d3664bc02d5a001013d445f6d59d4bfb08bc9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415963981
8115a9d2cbc302b8367ef8d9f217893534855cb5	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415963500
3596504300c9066847c4bdcd27177d18765c49e1	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415963262
f11c7c0322617183040636c222b9ccd17d7ce54f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415961801
c14d57a9e80b880b9cfa7fc7210d34acbbd9658f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415961801
7b78511058af51fd0d1c204a4261d65d2ab54c87	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415961933
10c387125fc45d07eea19863957022d77166b9ba	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415961944
8269b12cd21a12fb7a3ba7ec9417f3a251bb182e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415961952
b813c09817cbe5b4a61912f033ec3f8c3124669f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415962170
f4400e51497b6704bd32f289e059ea4acf36c40d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415964954
a941e99e86326cd2e3e5edea9d8e51d59f52a4db	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415963876
295053181b0232b3ed5bb93f6c878c318a86f3fd	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415966066
489e80a611ff950cfffd24914bc1d95197ab232f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415966654
10a6230f79bc477969ebe2353c1e1b2281b879bf	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415963295
e62ba111b0fe7082e5f9275fe3c31c6111650501	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415966539
85f5912c7a496d098cd16270c65fd39594fac054	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415963833
73397f48c2981023d84451e4caa8df9309cf07fc	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415967498
2fe6b39f5914fa0a9b832fa9a1375f7982eca78a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415966368
719f1bdc1167ac0afe4b4c8ddcebdc04ae67bd4d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415964479
81fc8f503eb6af4c1950bd469dba3cf7593a1176	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415971015
08e7f164480c4c5117cefbb16e8ad1b0e0aa1207	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415967545
0da4d38290efe7d652a2e8a4f675a993a2df8ee6	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415970647
a5248be8ca85ff6106eb4eb134f157d0803d28e5	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415968240
f9141b1cc71e300b9d649dc130d2874d4d66cb30	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415968186
c16ddd6f888e939bcdbf479704778dd45c3003d5	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415966135
d0372edc8f47ce4f660cc12502d8bc72d21d649d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415970012
871d0b728c2f340349f8d4365d6b4328502564cd	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415968224
2861025ce4ff8901b31067d6a07e578470a5f2cc	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415967987
d4d8384c230cf5bcd04fe0f93bb762e944772024	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415970645
bc630ef2b2e6de26bbdf1efe8c71b1ac67b10cf2	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415971026
7758e188aa722b64b984b925654a7d1cabf2315c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415971097
a83d51ed321bd4db263b9ab9f0b5ae3b69786c7a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415971122
45ede6aa0af1a5f9e345a1f5f9449f6724e1ab26	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415971172
2b012bcc61bcddcb646200ea81745726cdcbf457	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415971243
4e9ebad229edd8c9ba18b8203e5712feed515c44	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415971287
e26f09a22c5e8a673e164791468f595d5b73d0ce	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416456058
3184739c17c4a728dd32035eeb202487709cd9f5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974498
1f34dc18f9b3d632c5767f8e612ed616ee88a263	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974908
527d46c3450a36756281ea0ce8745a2a5662952e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974298
b545f41e8654678598528fdb592218817a1c4231	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415973765
79da0cae83e92cca1ccbf60e702bc1f840623b83	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415973736
66be921bf2077404e4f4bcbcc4d527396ee0de80	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974254
92494540e05d1820e71c1e02300a55c224c90b37	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415971768
39bdffe6e373b743c5f1ad3d890cb28a5f877257	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415975124
4b72d5194f29fc3ae8d0d275417c9ff964a70105	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974884
a443b309863d5a9e55f815f53a9a6b654e0ab2c4	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415973795
715843b237cb505298fdf8d382d50aacfb12e53b	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415973587
4759df0f2cdff1ae481d7f678471d2c4b0250c5e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415973645
2889ed3292bf470189e3be526775b33b4092b66a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415971355
dbc45dd5b591be29bae9a65c82df3c426f9504ba	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415972801
28bca75b8c87e3eee34b999fbe16bf1572aa632e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415972071
456afcbea98b8469c75713bae49f7a4dadf5ea6d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974803
2f1385149e31cc805c13cb1906f2e30999474c32	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415973193
ddbf0a6fd09dcd59c5ce898a009ad3f818c4185d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974789
34c89cdd5bafde224b8ef9cc17aae9ea56f14380	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974469
199edfbc769346fd36bd3f35197a49b0accf7d22	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415971868
2cb974912c35cf5b932e13ee10133e57994e670f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415973757
25f2365d3bf9e525734fed8244ed8c1dcfea497d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415973678
eac5b41c7dda2759f53a2f0ea0a9b5df0d8a2351	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415975028
1d68be235736118dec9a738ad9d177e1878b7509	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974256
10481a73d5c3c4f57db7e5216f8c82689c207c2f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415973768
690675bad4306801b007b44586f2e8ca0d895728	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974789
cdc113d61cab44fac8221b5072a4928c2a6310ff	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415971544
85e166380674cb1265518d47a770daf9a077ffb8	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415972073
1b0e845a016c73be9e4895f6030928cc13774666	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974144
91799dc8ce4f23a245fd16ca360c911353f62134	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415973783
38277c1660e5412df7deda0dea7f8fca8996a23d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415973303
25de8761a668b68078962cf5425a33441a339a1c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415973150
1b138ecb8cdf6f925e7e955d40189ae064172cf2	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415973663
c9ff61c791acc83b8962cf3851bbb14f1a0ce14f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415973615
bd8f2a1298cb2d4759146ab35a06fbd8cebba5e5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415972793
7550177cd6e1b46fdb0e579bcd1c9a4ca69cf533	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415972057
eb66f8259758afc442ba1691c0a9eddd784239fd	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974776
131a166e3d96142ab94118ba08794d77f0eb6e1d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974888
d25ace7b50be6022244e37632c55d474d6bf0e1b	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974889
33f1d35e557732fd16e6d197ffcb895c9f055193	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974447
222e947669f4388ed44b016896c5cdc13076e6f8	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974856
752d91162ba3d048818498e78fc0de72f911bfdf	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974745
9f3d98251f69316c9ea9cf6a2af2d785b56ea7d0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974843
ba65f95301ba65a76b086e683d8dfaf84e07a7a1	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974091
3c8fd2638663d238764cc4bbc532c05861cc5e05	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974856
bfe66b45b9b212ebb8974f300fa7c6dc7fa54929	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974740
02bd4cf0abc2e3bc3676c1fb4f229153be03060f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415975135
9de01d804fa482f72545aacd22e8b92c49e5e1c9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974979
4e6a940cfe95a950bf5ffc0d21f141ec77ff9955	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975033
941e3d5bbcd684e7eb1970d3917666b369404b5c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974813
b547c33e2dbfb11f250f3144677a8c2dafbe6d48	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974869
eceff0e3c59dad5ca5adcfde89b2028ffd854fd2	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975059
cf2797fc0dfe1d714cba147395c49ba891d9384c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415974839
656b100223eca8683b65a5d4b18b99b08c7ed660	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415974869
233d29dfd58d806b34b19ea222a996ae0842c6d7	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975119
280e96d9a8268686b5667117eb6fd0dc3c640594	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975036
bb2ed13b8eb05ea2d6b3bcbd3fc02d833d7d94af	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975088
e5c6a5bd74aa113a9032e9e48e296c56812e2309	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975063
903a17c7a47d7a12c9e0036acfade86daa55abf0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415975043
266dcfa5ab4ba7b920be548c556affa25a30a5ec	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975024
9b9c5b8767fa41fcd572d4d751698367d390ab10	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975071
2782dabfcb3e0c80634880f4963588aa58b88290	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415975076
7c2789bfc0cdc75794dd1798c6e0ed9b958787fd	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975110
472c6eb79506caf0088866497bf3714f57363926	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975113
bb6f5939992c474869c0a275d4411cf56361a5fd	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975127
88e544a35901fdf266985aacff5ad17f19e4b234	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975131
6981cbac730295a98f1e438e90b2058f979c0161	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975140
930de355a9214641ae19d082c49065515f5379aa	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415975137
20740480463f26e29e7db59b4ff4f067011d9da7	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975143
a32ac3b004544349043f90f5532a296b317eea27	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416456058
ea2158c7f36ce0674c354ccd45c91f2d096d3b24	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975178
3e0ba615258c548539ee7f3570284cd7210e5a2a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975175
e0bcc44d38ab98d762033fc38024408669cd185e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975178
22855b0d439d19ad559c89633569b2edae07cf2e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977152
4eda3679ddd295245249f2bea6be79d88b234bc0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975179
66f57f00d738932ab6738b142f3cdefa7f8a791d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975179
0a2afea3f5e98c3f08d971caa44179906b34cd4c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416211791
85e6a78196b30e12b30b327a27c24e60f3fa2eda	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975179
6e0940ac539d57e0fcddf495edcaa084added101	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977153
61a79a6301f14f6fed14b126c427482ffa5292e7	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975200
6ca4091817ee8350a681e0bdd1ee8240e7db30f5	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977153
5abeebdff66c599ae2dd85a3af8cf72f9ea09167	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975208
5c3ac21a2c061db0a2c9f62ba3db9843b593d9ac	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977092
645cc9bec72d03d2243ef594e931858d722d74aa	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977093
24d5c8d61dba6343958239e0655149ade9c023a7	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975209
1fc5c02999bd3e93e4508b830d899ea6d147a987	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975209
31d7876215a074656a9a33cebfe4f5c169f7e746	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415977422
f0fad20a51b98a1472f287f41359cc24d9c07589	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975209
620385645cbfbb2f57ffb348332c357e61a6dc30	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977093
f35033efc799d0300b3590eb0e6bc8732d20068d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975209
b38876b3f868049073d775489c6147f8318e38c3	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975209
63e7a0c8513e073d6489c7615a0df6240f1a6d2c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975203
0a81b687c1176875b799b33d63dda4cc7dd83dd0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977153
beadfb46d43aac69252bed33eb6ba41871125fb5	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977093
4220e7416fae5142c0de9436700bfbf945a879d5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415975203
6080abd47856f54888a1ce9ebea43aa0bbf9063b	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975204
81196784d1b836a592d4e0737c14e11f3efa1c3a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415977149
830fac0cf70429de0493ca181e7de0e54ec9aee2	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975204
5c74b00fb51a861b523613d2dc348d80085291ba	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977093
1a2eb6bdad29925c3a480536882e80511beaa4bd	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975204
e8718bf35da07f8262efeeea34f1eed9ef3ef18f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975282
e89740ea6b7086a3ca332729fa77ac6c11815885	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415975204
c5ca193b9fde8840a7484e4a766333344356c951	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415976353
26886a713f3a1e5d5b93eb98dee0bbc5cc242478	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416213836
42ebb936e432bcd0ed1f1ebedb28ad6eae95c8d2	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415977029
ff25cfae198125bff739eebff70f31d0ba4b9197	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977097
a16161a38a885f156f0d2de941bdfbc1f1d505f1	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415977089
3d95ea0b8b57e2d02c3d9d94759378a3fa308f8e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977153
eb1282310d39ed9af9e12b343f125b83144ca908	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415977076
3e390c456539f003ada434280f725f2cb905abaf	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1415977449
da3c02dd94ae2d99ea2ffc7357578b90c4ea5cdd	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416213945
e9ed794ce7fdddcd2ac7e8144b7015646a88d76e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416213430
5d1f2316f8a3998dedd9e37c80a07fa32ca60f89	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416215744
a768212f6bcb6d1ad9d73bd913198832c29167dc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415976665
852ee2bb4e184db7274402c9c3b65699a26902b8	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415976712
8211b2d7f340db8bcfa0ac08a41e68bc859416a0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416212252
7cade541a14d2c722bcab9089a61437f12959f92	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416212078
cd732c2390209085c97583d4d8d63fc0692ef9de	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416211471
7e89a76880284f011dfb20006f7fba000f556201	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415977112
2ea105b458b6a48d90f321d2e7ec515032e9e9c1	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416214116
8bfb0819e330043f0f6971d9e6bf3ac6efecbe08	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416214122
633fde0b3104a8c60551e84e0689939b086c548d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416211473
23bb5e9d7ab5a05b345cdb9b0abfec6b18db9748	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416215782
f432628d598727b97f9c1af022a1720b1ed3cd9a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415977522
8507e0e62041833c4f2a3f3aa6b46e006a21e199	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415977551
ce8c661115b67235a9b788b57004813079e0a8dd	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416215832
06b1b459e8776191123c274142011c204b3ce38c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1415977544
0cb3d0def52f264143c23c2384c0710cf86b98da	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416213220
59642363fe5e748250b528b11cc0f7f27a31dc4b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416212251
92e8cb0d4e5db08b9b4b5f3a188cc30495d3bd75	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416213248
14a69bcbcf165927aa39a6a186c470e1cfa83ade	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416213927
ee1bf9233f5f1cd35efaf976c7d2775ddb573c50	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416216168
9332656465d65b0257c3b5ae2e5a45aa1161d0dd	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416216169
a2181683f8048c07794bea47aaaa0c2d8889ae13	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222086
e3c3f0e608db3b38b490faa7a2530399a38d748e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222086
e7a29781f2778cab2a7a72a6bcdbb288d626acb4	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222086
959fb2e1c9b3292d85dfd566094acd7e836064d6	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222087
efc4bd3d82693f77534316ea953980a54c1dd9f0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222087
cf002df5e2c17e90218a7e742ea5cf0c209b4a1a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222087
06708fbc02f9753fdbdd4269d55b28dfda73936f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222141
b5eb69f242a55eabda105e025383f4fa73106f88	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222141
25fca7d0a7d8ccbe5fa1ae5893c7ea6ba05b6f2f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222141
55491b85dd527c8029147026e08c65daf4cf8a21	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222141
95287903aee12e8bc8ed6380556c17963252407c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416232509
1377832a0cfccb0a0f016696e25896015c0118cc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416223963
fc3363a2472c880f11f4583189948259e867fab5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224378
08b1c58859b4f5d244ec60ef9bed1590368a469d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416232523
dde8905f328acc51d5b8a8465078cc9a7a334dd7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416223974
d6545aede2d73c26441cef29b4619e53040c87c4	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416393843
c1c3de8320044bc820aba21a10c872d41c102a5f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224408
77dcc5ec4f8932ca6611667ba6be05144f8ede13	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224084
8d28fdb9fb05a797814e9c97ffaada4b2437e01f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416232750
31843732e363e917562e0309097f4fba4bec46f0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416389117
8ad4b37b055b2f65936a6a3b8b1f136484c6e837	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224146
1063e429efa48f58c9ab672da2de776c13db5665	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224639
9763a73bd9c6e00933193c3f89fdfeb8b4e34fb3	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224499
d90178f3ba3b7cdb27b2a49c7245379866147559	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222176
44765970b19ae04553e7b1180dc5937e20d33f42	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222176
a270922414dcf3090e53945393d83030631acbcc	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222176
90519e801e91dbad4cc52e463a5a3eb370c32e4b	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222176
2b10aa455b08bc1b36fd84e6694f29232090502f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222176
90ff373f9616700821ca159452fcae918d673463	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222177
eca59a48fd57b2536310eafb8b1cbce44de0457d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222517
71596da0d90406206b1e884d484ce216a9e08668	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416222325
c9e519986f46afe0503444768eaa3e2d36de9c15	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222517
b2221465c0bacecddf6058f0b5f3ff601e873b78	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222517
351071e632495916f781da7fb0e47c8a3db3a645	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222517
d1006c31ed02c3e084016a8e22d089f03d145e41	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222517
284fd83cf0b910a6a2f09cb052c865dee6d75b6f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222518
872b248d5d7950b456e124bb41ede4828b036ba6	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224158
7cfb672d0d359fd01acfc4a43610e8bba491524e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224159
9feb419fb8770a893d5d8f2971e2e235e1fe0066	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416283259
1dbb4bea35b8d58cd8e2b09a206dad09fa4e6303	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222347
9394f6c84c203d983f80752c0f4ede4e0d7bb95f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222347
329b46f498e9e97363c0a0b2ae38e92f371994e0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222347
0adb21a472b8ab2bf5233196511b1ccff2a791c9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222348
774bbaf09fecb8bd93baf13ab84943f22f8f29ff	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222348
497122babaf3714522d25a30cd243da40d68581e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416222244
d00fffc378608a41c5fcd5109b1e9dd8fbcb2733	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416222348
da3be974dc8d697087bf6e4668b923f2c2b2b359	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224621
dc9e24c65f3a64ee5b29e93281823fa2c8b91fcb	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416222514
3955d19797bc66e87563cb9c6b2907eb3e047640	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416283259
1998b2f2a1f0f29aeb1cb744d422c3b1c4541db8	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416283260
2db0aa4c6a76826a5f9e247013a4a623880ea4c9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224633
84626ccf9677d0cf8172f1c2ad7a82c0db05208f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416283260
c3e5f6c97c1ac0f961acf374f0e1089c66a97563	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416223738
e60e4282a1a91cdadb5565e7fbf8182aa674e8f6	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224336
7161752334233c3993588c60b7ba551635840505	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416283260
a20ed139623250345255c40630d93752c74326b8	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416224336
d900e99a995dd8a239b4f0a1b56ca987c894d235	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416223908
fc29caff818f95a660c7acbf98b8a45a2b9a3268	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416225846
21d915ca59ea9d4addfdc2d078edd83b0c4df47b	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416283260
d40a1777eb86f36afaf27406e73ddf883f517d63	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416240062
b7a5270647826f8eeb47bec256e47cadbcecc34d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416386320
ae81fdbfe1c39befc31c71dbcd1b6ff41853dede	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416240214
5249e79edb64cee90aa42bfd7ad4dffe1e3baaac	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416327277
eb8c6d6fd30b66bdc715114089e9cbb7a7fe1122	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416240420
257453bfae4610650c3a5460232eb468685c6576	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416298105
7ae41f4c8eae9c76d784df70c0327ac0f793bb96	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416396274
20e2d4000af97b1d89ebd916cacab0366d4de103	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416396156
51f3f8465c16f0cee0f7c15e93f7ff20b7bd7b2d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416303089
562e8c541f356360e32f3dc96bdb522262446ff3	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416388539
be79f96e322211266308ff567293d02d8b528931	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416390225
dfbf5a01515b7c8ce13c0e4c4dabf3f35af60d52	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416386313
38d878c7f55a42887f9a7aeb0891c5a803a675ec	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416408874
e6cbeeb176f0aeeee428057d85b98187a4a072da	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416396930
9d9a9fb6d80e4145dad30827c2b7cf32657d108f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416399804
18db422d3c3345f19d5ed89ab5e9dd3f00663894	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416399930
4c34d3b1203cb90db02e6f0a0d80585a309e3452	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416412860
ee5f72fbd95375d1bfaafd521de65aab94b42e58	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416408888
f5bfcb8be3490c4301b5f295028ff21bc28f7c22	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416413604
8b5275d925e7854339d701d8adb73f0a33b88ef2	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416413079
7be8d71187649b94e04da18073590fb3105dba04	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416413292
c66f59e9b69cf6299a78a4650928e5b10d924b5c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416456057
fc9f6aca4dd053b2193ddef8e46ea0612ab4c48f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416456057
118191ded1c472bdc77370a562637c6e42338664	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416473402
bbc439f3b61d37f155ed792878af7883158b6dbe	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488640
5f104852d75ec60cacc4abad9b0f8e282d69c967	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416486871
51d3ef245b7737f8a6e047e38b6236281aea358c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488663
96d96050f984de52ace5972354e15c7711de1671	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488668
b31c7759c310c99eebaf0b9e67a1bbe6169a2645	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416486922
2e19913ffae9b8cc8f06994a657de94c3e1a2e9d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416486941
5092eaf7e138ac23fd7bae9c600eed9891fbf17b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416486948
b4dc0ade48898bff4320c8fb1012222635bef50d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416486956
03d8bddf0322fcf2ceb560e2a3d778027b030c1e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416486980
6bdb87ccb3188f124b85a295ce3cec2ca769e60f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416486990
6be085bdaba9d7859316e4be02ca25b70fc98879	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416481654
aeb448105934dfb124bc213b6178b82c923394e8	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416472068
80a358f10193064cd1270b2f8acecede17df9058	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416487016
4cb99805c72eb061042769461e4811fed67eb2bf	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416472090
9d0f89b31ff845bbb28592d6cb60efe485075026	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416487028
7f0c577e2b9b91cb543fcd859b924e6432f7b15b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416487060
294563c8ba473569bcf687adc6251fd1c5e11aed	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488679
17d0ad5e84bb32b0943af6b52ef1be230beadb83	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416472133
e1fe3a55fb6a3d57d67755c315d4d65b814ea452	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488695
c82947af574a8579afe91fa510230e6e87d0f36e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416472142
6caef754ca8b1ea3ed5bbc4d4441ffe0d04634fc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416487081
858c2227f3ff15da91c5704c3f8b19ba0c91960b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416472187
e78f9f93afd6f5ddd91a5862670c2586284e9b52	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488698
fbe65c9b8d754c37e5eb1a7989cd40fb7589d717	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416472219
7cee112f4f5ff31a9f4ed3a7d7c78a2d747d521c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488741
c6e8e44faf692b7ef981ebd096aa0d4b4df374d5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416500119
e56a8048a2c06f9ab111ed626744278777f9329c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416561813
be580af5fa12b1b3757445b07456920553a1cfdc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416560986
f69f4b49c6b3f67c2ffb7d116c45a1e4ae440729	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416560999
cd171c90dd8854fdb2b33ab5c04edd5cd689242e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416561054
b3aab67393fb9f512b4da23636b0a536d0303912	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488240
2b27f596ac13ed6c507b2c0e554b9ee2832937dc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416473368
f1cf1f47daefab429952d2a681d9ae2930a5d4d4	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416473374
750e17da076e326421dbb070646b12064ab21822	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416473391
2fd02bb50bd46f62e0e68605378887dfed2d7e13	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488258
81f1fe031bd436f866d523715a7cac95cd1c6c2b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416486822
7c68d47e2e239b5386dd889fde39ab277a19119c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488406
b80a88b8628079dc021f36db17556371cabcb172	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488437
fed2485f3cb1bf62d86d15734fa3952a1dcd11d4	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416486854
fcc930907e8e2bc77f9343d1a83a98016e4f1375	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488443
0bd8e4d941ce77623cd4cad9324629e036b6e1fa	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416561056
c3033eaa634a4a421307d0e3f08888372d1d4117	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488450
a5b0981ffff720e0bb56629d792f5d31d038a98d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488463
8b9c2be461f3b81bd1061dbc6c246d2cc156a660	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488472
ad491c9a311144cab7b3d94fbfd827678cadd955	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488623
bcba10afd863fae1099b519a6e3f60956aba8708	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416488630
521898a251b16b5cbc8a8012837f4211c7f036b9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416558023
33f6180500b5d1970dd01035c4cb221863057d15	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416558082
b42746d493be4693a97ee999eacb2913d198c50f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416561058
708477de7677a98d04755a311a4ea933264dd8e2	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416561138
3c0f7ed1cdf769dbbf466d1d666b162a1300c424	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416561382
96895828dd2f6a0d40944b8a6550568ce0a08965	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416561399
51bf4c4c8c62301d6d3453dd1c19c7a6eb9e7d11	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416561480
e6272a5db52cbe6d8e72bf79a02519e5eda96587	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416561926
5a9a228532a9d087360bc6d596fcb661c9979117	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416562521
e11fe29cdcdd237bd4078874ab8910eba264b268	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416562567
b87767d599ee97d9d36e4a12792f7a93b0f807f5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416562570
2a50c8474c49186c2632f5ece83b5cba194bc042	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416562571
c458515eb90a872ea873830fc36d498aa69c44ec	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416562571
00b296c08ce1bdee1088f5148e6294d812529b0b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416562572
b622b55ca7faae44ad7eadd159c914e979bc99c8	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416562572
114b680f1c72d1dc4d39a584f67a0042913db86e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416562573
9bf21aac9f42735f2cdd020ae9d59018f20240c1	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416563104
65e084bc4c93811655f80d96dd26100d98e3e0a1	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416563131
58fd6719b78d638d8eed5a733c19e6ff8b99d403	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416563169
e94dee3419398e5216e76f53013e8b9698221ba9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416563179
233642491c55a64303e7a6e2864852ba1931bb37	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416563213
23bae24ca2c07bd080a022848a10793e37c26431	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416563456
3e7fb5228f1a4dc67ca8f456fe8d12df78512abb	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416563848
8b1a6560c978fc827497aba378d432f181a32f5b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416563950
4c7e6ff12ef19e8a04e714858a1068d0f42c47a7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416564014
88a119de6d0b73386b9d0de5e121fad063ee3579	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416564070
9cd0d24bdaf017f778ffc9a0e6e33f2f321b65ed	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416564071
880757c60a63825a5ae6f101af2cd0607522dfae	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416564071
976e8cbcad249b639dbcebfabbb7a9a7a02be680	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416564117
f27fb7b55b6e320fb28eed26650a03f8523b0079	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416564118
087de958675a0fde6d45609f86b61fc79d433a35	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416564118
f3342b3a3e4f41d40469b6a93f7468f55f593b7e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416564214
933a3d0863b0746480235f88d32b77611b715508	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416905112
adfb752b954779a553669859d3858165ab495a8a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416845524
3ffae4389bad516376622f6d078bf36094de5fdb	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416904951
0b3c32aa58889ce59b4d8e671066626b58d9e5c5	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416888059
96a5c9b2fc4b2183494b7927af5a5adb13d57271	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416819612
df033f4bb45e34bdfad372499ff059510e6ca842	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416845542
81a359d4bfc82ede69d528f3887933b4ad60eedb	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416888060
a43fd0649342257a6e073f488b9f2378f128b765	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416581427
ec97caedec8cae0fcd57c01b07fcb2a4d11cd1b0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416818912
c471480193bb6958d9d1d27044bf7c37297dfa6c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416581428
899bb4011d9b4dc3ad82d1f2e9092d2ba5677c44	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416581414
54e8a3755ab01d306f6172bfb98817fb5bdc25b4	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816462
1db9cf9dfcb3b9dcb1151946d87e0d45829258fa	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816463
2b56db5bcf12fb47b9a3bfe23ac06bc1ba95cbfc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416818921
a4a171f5c90c4775505b5f83c125171dbbcdfac3	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816463
b21d3ffcf003a8bbc44571fc349ffd19b82067f8	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816464
fff2a3242f2666dafb88c1a3b68d353b16d929a1	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416628862
8e09b7b353c43dd15bf91f841904afbd9ed833f7	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416628862
a6ea481f44abbcc81738846ba37770ea07c7ec74	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416628863
c473422e9650a21acfd7c881686ee8d1200f7df0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416628863
5fa03a838ffd591b7965ae96946166dc90eb5fa4	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416628863
166c2d2980d9345908dfb961f881d5e005ca9206	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416628863
e821e8c6cbca328d870cd63e1f191972738e5501	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416581431
e5a5477d8d35d2185e36dcacbdc5e2c32ba5d102	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816464
fa8f1a5bb01d0f05becf8b86c5a99836299ec125	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416581431
e7a1ed88790a70b5d410a500ff7bd51e7dd962de	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416581432
7d034afa22610ed88d7ac3430ed016555603f0ba	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816823
5feb922af160da589018ba05cf7e6ed43ec30de6	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416581432
b53f34a0e6a47462140d11a5068e4c2f6bd68f52	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416581432
be5191041b92070dbc6ab84e1bc2d5575d4c2658	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416818951
eedbb9e3e932cf1cbca4235a3540e18d30e2e194	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416581432
1a5b9a6ec656c51d607d9ca032d32a66cfca0896	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816713
f4b2eade8884107cb8a61eab508e3daae086af33	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816812
7fede66f470a280738e5b75779a7bdebcb80773d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416888060
14fe03e7fbc4e82c13eb980473241cbf07f22391	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816813
f9688d9d05443c20cfee7a65e4bcefbccbdc1983	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416585667
ec76ed147c79bf05048e51f4a9124b35a3764b8e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816782
94b867d74465b47433814ec56ba279a8dcabfa97	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816813
85e361b6636d9d0aeb3b3a9cadf4dda015105e37	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416845349
fc71029475bdbf45a22fb2efb8e7a9e7ff11fb70	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816813
24fba1659db6ccaefa080cc7e302ac102666557a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416819030
2c62d686a72c738d887b78f06816e992c4da76a1	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816813
12b2654dd14c80741271b2cec84df9c880ff6c4c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416816813
c50d9841203baa067c13a7caf5f38850c82662f7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416819075
f25511e3bbd4abff863723d2360cfde354fd5f1f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416819116
e0365fe8e2b670084899d36d133bb0833a439506	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416819533
45cf813b660e7907fbdb40406fec30a8ea3cd04e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416888060
4a958a8e29767aa1fa134c977df77145111d7e29	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416845360
07f4ea345fd5c76c22b6d8d41aff269c7f1e2645	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416826149
1d4d759495e7c23f6c3477110da41cc16d6cd371	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416888060
ddcbe9166b74402876dac1b1c855ab844543b4c9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416888060
fe6a906c149f88539f4310ae213091f7bb0b7c53	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416904582
e645b5076d4679e0d963ff0e2898bfe2c69caa21	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416904875
3805f4089d47055ae42100b07ed55cd57a255e5d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416905094
f64079fc37b947b526136ab0cb92f51b501ef492	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416905058
f322965bff8ed957c6b4109415b1c673778be5a6	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416904898
c624281306a067aaf30e501530363d6b48be71f5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416905252
1554e7d94c4dc4f136dc3b710048d25aae216176	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416905278
ed0cb35f37fdcc2292fd6e7e17b76719ff92444c	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416905320
a8b10e9765a298dac842ecd04dc8ca0864e0fe9e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416905340
838c8f55e59d8165e177b6428977167c2ae7367f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416905942
fecd3d181b6960deab1287e2eff3158b9fe356f7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416905998
897ba8bba6fe9879435e882c4322cbb350198205	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416906049
2b4b0524eb88c593cbb3cde5129ae5900f329c1f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416906078
9fc56c7136b23bf984b5ef373f50077662433b60	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416906095
0996fed95ac7b55fc2ca83e14749a0d2adee8a55	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416906101
a9bbe6c5da41a095fa2d9f34d698c4d74f85e9f5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416906108
5c3a4495c0423db144f4093f8f7f79a24d9e175e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416910908
84e0479d2c61ec40547260e190b0db094d5f5234	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078411
57f70f363452aa5c63756909ca0915d4d68f76df	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416906169
2c161b07aa19bf6fc2e794ad2e1f2bc9e4ff2704	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416906176
04d6bc2715e69f0874503abe8def19761ee098b2	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416914949
7c121950addd76e9d8f0c064b7c6aa2e5b2d7b50	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416916407
2487755bd86131181622697e800f7ced315f4c17	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416916484
e0d734bfda56dafe7dd7b3d97a915842006ed390	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416916521
5042c090411cf83000bb3026476e749bb0fead96	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1416908701
b453699a4123a31cfbc70c489bdeda920b62543b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416908834
7f645c02430fe87486e3ecde30f7bac629e9f8df	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416908860
a77405960fbb50939cac625bd84a460a766b7c10	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416911007
ca9e1f7dac1d3e91363f13381ef585275ce2f49d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416916538
bba333777d0acf793b894aaf1a60d61dfa9d180f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416911080
aada2811692fb2c66e47e6da0478a15cedda70b0	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416906627
f465977516f8a4d283320bcc7bc79c3c3a254d02	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1416909312
729fbf3488ba8c02e999ddfdeab6fdde7d462c48	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416906650
78b04ceea0b223a263c61ebf79315afcfb64201f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416909393
ae4dd1a32d24022e0a9235e0e3dd9855debf08de	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416911091
b8b3d227175cc8f97f6eaeddfaba707c9c309fb7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416906664
446402b65e630eb384130eb6e6a865b5c06e799b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416920298
54b30cdf04428b5f08abca31f593922f1f8357bf	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416916014
443d0d01d18190691604ce914bb4ce2f2a374479	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416907421
e8009af660eea4bbc74abb41c3ac593a2e55f2a9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416907514
295e90051d55ea916fb86b4f88eeac4b99da1197	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416911163
b6bc3b1eab9ccae4de3459c7af19bfd08cd326fc	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417003210
aa13bbc1186b1febe60454cfa1063079e85d0b18	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416911315
c94ea80926ee190dd3222a3beaa592dadfdcfa85	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417004449
44138f6a8338092b49af480e912347cb52e0b631	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416916083
ef5925e19d59fa396ffe4d7f2632b5355d9c018a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416907605
3f9f8eb5361cb637b9e119804b5c29b38e3be74e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416910585
928254ad82ea9c1b09c48853e4ad208eb2f9d298	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416974465
c83a67bbdcf9f7d00ee127f022d4dd369b149070	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416910691
c9e5880f44d2fb8b539fba4476b738b8ba289fb9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416974466
72827bc5813c4b47719ced23da9cbfe87e1891d2	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416910885
914d552c9b95b3f426633b945847f3b592f3cd71	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416974466
c2125bb5eb916a1262f64e32ae7b826f94aee436	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416910903
38dd2882dc247b8ad532c342d329afe331c68891	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1416916598
db7c66e9b4c5bec223c6e508930ec81f8e3952e6	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416915697
94bed77b9135e98fe5db0edd5a6db317060b3d1f	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416915785
22631ccf6f08dd01f3a597dc2d68856e87cb9ab4	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416914528
2ebecea060c23a666d9ff3b8a6ecef1cf2445a4a	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416915831
66423f532b70bfc78f8028116aeb3bca6261ba25	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416916748
3fa57203e14961cf7d80bdfda2c2010b504b6c3e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416916903
29a7cec757a64aa21bc427c5c78122860097e22b	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1416916776
3b944b146402435127533e341dc70cfb73ede295	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1416925618
25c2d89849e0b0ba2891661218584bae78594080	BQgDAAAAAQiDAAAACGFkbWluX2lk\n	1416916916
6be03c7f36ae3bf02b42bf82836b23e0d9f8df02	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416974466
6beb7fe5fd4ea0347e06edebe4a02d4513417e22	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416974466
60b9f80bf572ab2bd2a4d3908005c5bd2d72e5f5	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1416974466
303ce36efff562b0efb8aaa02e5d0f7f19f24817	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1416931267
8f8cf2015614815adb9a68a70a2ecc7a1f2aa7b1	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417077180
3fdc49b6283e331cefd757a4d32b1abf6fadf7b9	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078511
972a6d2cdb51b6f181ff9e6cbef67e335298c238	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078583
599b9eaaa2455081640d68ddd4777587f02516cb	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078583
fbb65b541f01f6b6abe327419aff4b754ebbbb33	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417015935
ac60ce57c96e9eda63c274db66793af28c7d97a7	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078872
727aea8a1d56c33d868217d8371bb66bb0239794	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078754
fb4abfcd9df0f13f4f01268d387cbc81a051807e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078925
08e6bb9a9ba68dbcab8e9c2f61e3e81cf3eb9a91	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078754
d1a3dab1eb614ccc96dc7a198e0348820867b2bf	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078872
7421b2e11121f0d7837b1adc21a6bb03e1cbba22	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417079511
0935b245f01b46a820aa9edda18be24baeb87a4d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078925
b255f80d3781d8fe60e3823e381333805919ca89	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417078981
09ce1f3c0cf9c89e2f36a7cba8a9e25751b7046b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417079027
1975b831e7da319e90f696608ee781a71fd9a7cf	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417079027
8b8d78699e0d1a2aed732d5898e5344e573ba682	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417079512
4000efcce685ed38051716946893e5a1f2d9980f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184308
5e4433bf57d6194b1b766d6fba7f87305a994575	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184158
8bdd8eb1a0ca4b22a6d39934b8920bdcf4681db6	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417169303
bd7014b70071067c69ebc022db717d493a1be95c	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184293
d3d45e46f7009cece9c88ec39274161938037046	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417183990
dcdaca2c4acd669b928b837cdd4c56a8e5968b73	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184048
19e4992c408b208b8297ef2593373dc92808c499	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417102912
1b33cbfa2cc1e87e59aefc978e8b59f1a921aa66	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417102915
a415043c06104469b9cf3f1ec0b558d2e7b88fcf	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417104671
6dbede12c883df8dc1bcdcc0590680a6f0fe85c9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184011
d1e12c61501f39d74bc19a920a37f6adde199d06	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417169923
d3e059ad6263556815647802218ddecc413c87d0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417183998
be27f247fc46f39dc7a7f8188eae18ef5fd951e4	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184086
1b31b40ec5a7bdedacd0c90b5ef3d31de90b1bb0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184050
4ae1ffa8785cf3b57ab0d7d3fe24386a579f3e69	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184182
0e6d075796a71f7b468ba25005f0dacd573bbf64	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184076
9e65f96254545705ed580a61cecca1b2dab8b69a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184570
52045553ef55cfc6302a2828192397be4b0a3523	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417169300
c80af87b6967932ab0a0561c0b771e590e05850e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184041
1bcdf8e9c497b9bbe113063dc722a5fbba8ebdd0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184007
edddd0173a3076bd02ac88ad185c32eabe084e85	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184293
87a4b101c64549affb66c7457a182f12d5819f42	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184069
657c4330aaabdefdc3eb2d7bcfc2302d5e7d99ce	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417169301
302b8c9d5dff9cbd7254c7f111559075dcf65819	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417169301
0318688dce349be9ca23516df52085499ae0f785	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417169237
0bd9db9dd6afa94fcf08cc0796958ac8fb98229d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184066
f0e54c2b6eec3afc6300c2aa0fa2378e409f4fc1	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184309
37f17c71a0166cb4917bec672339451ccd71359a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417183995
e25ce4911486ed0731669af89c84810077a48be7	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417183995
ccbed5637e5034238c94943278e296ed301febbd	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417086851
87b3811c68b07f3ec69c6481a3735d5f4708fe1d	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417086857
17a5426368861d94b5227ba35be88243321ad487	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417183984
7aaa0f94d2901e9be752440f9a91c20f1aaba45b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417086886
2f4eb073e9c1bb3499d2d4d2f51d693410a5b7c5	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417169302
ab789bdae9bdd4e7f428a725c960a3b612fae7d1	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417183995
02de893775dadf8e13fafa8ba81bfe7c00b833ee	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184020
0ed4c137594dd5df843bde32a15ec4700fb6de39	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417183995
67cc994bde323933fed199cc6b21ed8cca62f938	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417184510
0baba258e91b9c44bbb898d8c7663ffd545be8e3	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184301
f7c893e0cb17b80b54a147f54c3519283fd00cc2	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184091
65f5a2c713d8aa98e6f38efaa0922e435f60c060	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184103
942366057767974c8a90d58eebdd7d8f664aae96	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184107
572d53f8e3c9d39d14868e7c3792e941ca309c3e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184147
d5db23868ae404fd63a55087630fe8f23c53537a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184015
2ffd6895b87c57fae9898854f09280e666c44e20	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184113
97233460b120fcae56edd94d1ba2f996cb08ce16	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184060
57c932dcdc2ae12c0f2dc9ee2a62713aa33b0cca	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184122
97afaebfa74453ce6b1c4e5c0c31d5527c913461	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184132
ee53de6169ba289aa106903b2cfcfa5c659ecd71	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184162
cdb1f477f0499887c830c25ce7f988d92a3b5bc9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184195
e3cf24e653c81b26c1b4cdc5820c840b89c61277	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184317
08bb8679cce7fa9b608316f5e1e0ad0a638b27b1	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184322
e7b5954bc47ad3eba7a395dd220fcf9d5ec0a72f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184309
4a3f90126d1c02d4b02c2ed68375233ab44229d6	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184169
fac857de92e76108a55222ec674030bb76af18e4	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184207
7e4a73202fe59f1d63de8322c78c4e4cb9d1f335	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417184329
15120edbd8c1b9a2b22a052df181db4b1f455957	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184292
3a9a48b5b66ab5b7b43b7aea0aa2d043688c69c3	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417184294
1d0634c12efb24889f4b8f120d728b784fccd1a1	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184301
e0bcb5c0af2a04ed9115933ff7eccc7ff2ca54bd	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184309
8e00daf30c9c8d8fa8ad4e2f4a1cdd030a54326f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184316
f4bd16df21719255e07747f64c7248f559b580e5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417184377
412903a9ee3583fe86f4bed9de52ae40f685e46b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417184545
41b254353c954008b2d445688e52342004beef84	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417184530
cdfee4ac89984e99b14e4be632294d619cea4e6e	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417184569
207525f9c7a3003cd9a0162536c259752f0da950	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184574
68e956358313c51434b9b3ee3dbbf4609d7c79e1	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184574
c704b339d48ee4e888ac0c6f25276459f13dd1f0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184575
cb52c1f013aed6c141fd9124f3967a662ec7cbeb	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184575
2eb49069f709f1e68e6d3ed1f069f3480293ae21	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184575
29fb6e44977349a74101e3dfffc8b55e30245b9f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184607
71632befd960f65dd197101c5f73b2cf8e491f71	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417233667
78124fea479f5c9f49e0196c769c6eea61de5cbd	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417233667
f231877b8b9d1a4cf16d06771afb4f87949b6b24	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417233667
5d87b00930e623340e1da7a3f0ded809a07b6c25	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417430421
6b7506d23fbdeb8ff56e51a1afeba76d12bdb7a5	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417185863
fc3a9be21711c8c2dbfaa1583f5ca55cd186d841	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417509767
c3dfacfd8736c496af54fa01bfd9c9ed550e6110	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417185210
5ff6cdf1ff712695c5e6322d1e03e26cd5519e2e	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417492856
f2dd89c2de9863f7b45f39616b103223b72c2efe	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417492856
ff5c986ac1b7f344b7f1390edef387c9f8d5a072	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417186821
84be06548fc84d0b0837eb33fd9ff9cca45b7220	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417190472
cb05f699d25c239d21133fe62378824d4ed6e1d0	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417492856
f4ebc0d4dc6e767958d0abe5093485c80171f594	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184610
363b3acce73b0cbb731e0ae5572e26edce61d4e3	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417492856
3f76327e893165be5e0576ba2c555e018d6955ba	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184610
ef5172c89571c211d790a0fb160ba58e6289e85f	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417492856
a49f47f06648d82c4a7592def51fd349685953da	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184610
f796bad42a189c10f2cd5de695b95911a04e3e5d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417185707
181492f987769a55c9758d4cc02772b404400e20	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184610
ff59dcf72278a174566883ff8b000e323a020bde	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417184611
27e3bdf6ecbb2404c04346218107530e508811aa	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417449664
a098ee714cb239b33ed6d8b018f41efec0843e19	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417492856
47b500ed46be3202a35cbe8049acc2fbea28bb7d	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417186043
037311e5dfa4569b33e353d18dc9aed493f1650a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417185203
8dee11f4daf0bc74ab0eeae6ec0429acbe3acd35	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417185773
8a864d6af9f75dceb97d5289378e6dbb00d09495	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417435172
b845ab16ebb7c8232666fc5116e3aa8f9038b716	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417444668
21056b1c2a5a1db4f934d3dba2c9a7ccda3f4907	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417185203
c6b095ee56d93456b559f08746a2a7672e8586d8	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417445114
6577d9d3af97d0f3c8342ae24883797e33a125a7	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417185204
04d957bbe1cdf02ff5e40dc3d91499433f00b0d8	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417450845
2a2dfc8821842122392127d15f12a324ae107aa9	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417185204
ae7b431539a1d60696748e55740c777007f0a113	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417185204
1b9885c3987c9a7b96a49b4da54ff554bca47e4a	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417185205
eee8d0bd686e4e3129834262b401b5cc5571639b	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417446043
18c354905422035dd67746a045085ef95e8b5328	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417185823
7402ff1ec7ba87277bd701725403a0da8d317f09	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417233667
9d619d6e90ceb13477eea32588c01b9838081724	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417233667
ab617c7770c16ff8b5035c18adc33d6b4c253394	BQgDAAAAAQiSAAAACGFkbWluX2lk\n	1417233667
28f46de030635d9cbd72344f8b734962491135c2	BQgDAAAAAQiBAAAACGFkbWluX2lk\n	1417449525
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
100	0	id	f	desktop	list_column	tenant	f
60	0	edificio	f	mobile	filter	user	t
57	0	feeling	f	desktop	list_column	user	t
64	0	edificio	t	desktop	filter	user	t
67	0	sex	f	mobile	filter	user	t
83	0	gat	f	desktop	filter	user	t
84	0	chuches	f	mobile	filter	user	t
54	0	edificio	t	desktop	list_column	user	t
71	0	user	t	mobile	filter	vm	f
72	0	user	t	desktop	filter	vm	f
55	0	world	t	desktop	list_column	user	t
66	0	creation_date	f	desktop	list_column	user	f
51	0	creation_admin	f	desktop	list_column	user	f
53	0	casa	t	desktop	list_column	user	t
70	0	world	f	desktop	filter	user	t
68	0	sex	f	desktop	filter	user	t
65	0	feeling	f	desktop	filter	user	t
62	0	calle	f	desktop	filter	user	t
73	0	Service Pack	f	desktop	list_column	osf	t
74	0	Service Pack	t	mobile	filter	osf	t
75	0	Service Pack	f	desktop	filter	osf	t
76	1	id	t	desktop	list_column	host	f
77	1	state	t	desktop	list_column	host	f
78	1	creation_date	t	desktop	list_column	host	f
79	1	creation_admin	t	desktop	list_column	host	f
63	0	casa	t	desktop	filter	user	t
58	0	calle	f	mobile	filter	user	t
86	0	state	t	mobile	filter	vm	f
87	0	name	t	desktop	filter	vm	f
88	0	next_boot_ip	t	desktop	list_column	vm	f
82	0	chuches	f	desktop	list_column	user	t
69	0	world	t	mobile	filter	user	t
61	0	feeling	f	mobile	filter	user	t
59	0	casa	f	mobile	filter	user	t
89	0	connected_vms	t	desktop	list_column	user	f
81	0	name	t	desktop	filter	user	f
52	0	calle	t	desktop	list_column	user	t
90	0	info	t	desktop	list_column	user	f
80	0	name	t	mobile	filter	user	f
91	1	name	f	mobile	filter	user	f
92	1	calle	f	desktop	list_column	user	t
93	1	id	f	desktop	list_column	user	f
94	1	vms_connected	f	desktop	list_column	host	f
95	1	dis	f	desktop	list_column	osf	f
96	1	vms	f	desktop	list_column	osf	f
97	1	overlay	t	desktop	list_column	osf	f
85	0	gat	f	desktop	list_column	user	t
98	1	id	f	desktop	list_column	vm	f
99	1	id	f	desktop	list_column	tenant	f
101	0	name	f	mobile	filter	tenant	f
\.


--
-- Name: tenant_views_setups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('tenant_views_setups_id_seq', 101, true);


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY tenants (id, name) FROM stdin;
0	*
1	Madrid
7	Galicia
\.


--
-- Name: tenants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('tenants_id_seq', 7, true);


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
17	propN	ydgofo2mx6r
17	prop3	h4qhwf561or
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
18	muser002	pAMpLvAmf1aL9zpFjqUP0vmnW4pxP89QOOIsgk2F+AQ	f	1
19	guser001	GArnDd3T+Mp1VTk3KQN6YEw//taR757d6satfy5kjd0	f	7
20	guser002	CRVk1wSvZuGlKkGHjMSarRcrKfiCJcQlLmJTI8RohHA	f	7
17	muser001	9j0tRxRV5KhGECSSSUDLWb7To6OZ0qkHGqdmUokAlnk	t	1
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('users_id_seq', 152, true);


--
-- Data for Name: versions; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY versions (component, version) FROM stdin;
schema	3.3.0
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
3	0	0
4	0	0
5	0	0
6	0	0
7	0	0
8	0	0
9	0	0
10	0	0
102	0	0
103	0	0
104	0	0
105	0	0
106	0	0
107	0	0
108	0	0
\.


--
-- Data for Name: vm_properties; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY vm_properties (vm_id, key, value) FROM stdin;
3	test1	t
3	test2	tt
7	test3	ttt
\.


--
-- Data for Name: vm_runtimes; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY vm_runtimes (vm_id, host_id, current_osf_id, current_di_id, user_ip, real_user_id, vm_state, vm_state_ts, vm_cmd, vm_pid, user_state, user_state_ts, user_cmd, vma_ok_ts, l7r_host, l7r_pid, vm_address, vm_vma_port, vm_x_port, vm_ssh_port, vm_vnc_port, vm_mon_port, vm_serial_port, blocked, vm_expiration_soft, vm_expiration_hard, l7r_host_id) FROM stdin;
6	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
7	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
8	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
9	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
10	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
3	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	\N	\N
4	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	2014-12-02 12:22:00	\N
5	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	2014-11-30 12:22:00	\N
102	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
103	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
104	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
105	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
106	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
107	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
108	\N	\N	\N	\N	\N	stopped	\N	\N	\N	disconnected	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N
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
4	mVM-1-S	17	15	v12	10.0.255.251	\N
5	mVM-2-U	18	14	v14	10.0.255.250	\N
6	mVM-2-S	18	15	v14	10.0.255.249	\N
7	gVM-1-U	19	16	v12	10.0.255.248	\N
8	gVM-1-S	19	17	v12	10.0.255.247	\N
9	gVM-2-U	20	16	v14	10.0.255.246	\N
10	gVM-2-S	20	17	v14	10.0.255.245	\N
3	mVM-1-U	17	14	default	10.0.255.252	\N
102	a	19	17	default	10.0.255.254	\N
103	b	19	17	default	10.0.255.253	\N
104	c	19	17	default	10.0.255.244	\N
105	aaa	17	15	2014-11-04-000	10.0.255.243	\N
106	aaaa	17	15	2014-11-04-000	10.0.255.242	\N
107	aaaaaaa	17	15	2014-11-04-000	10.0.255.241	\N
108	aaaaaaaaaaad	17	15	2014-11-04-000	10.0.255.240	\N
\.


--
-- Name: vms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('vms_id_seq', 109, true);


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
-- Name: administrators_name; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY administrators
    ADD CONSTRAINT administrators_name UNIQUE (name);


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

