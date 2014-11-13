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

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: session; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE session (
        sid          character varying(40) NOT NULL,
    	data         text,
    	expires      integer NOT NULL
);

ALTER TABLE public.session OWNER TO qvd;


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
    backend boolean NOT NULL,
    l7r_host integer
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
-- Name: ssl_configs; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE ssl_configs (
    key character varying(64) NOT NULL,
    value character varying(32768) NOT NULL
);


ALTER TABLE public.ssl_configs OWNER TO qvd;

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
    l7r_host_id integer, 
    vm_address character varying(127),
    vm_vma_port integer,
    vm_x_port integer,
    vm_ssh_port integer,
    vm_vnc_port integer,
    vm_mon_port integer,
    vm_serial_port integer,
    blocked boolean,
    vm_expiration_soft timestamp without time zone,
    vm_expiration_hard timestamp without time zone
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
-- Name: tenants; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE tenants (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.tenants OWNER TO qvd;

--
-- Name: tenants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE tenants_id_seq OWNED BY tenants.id;


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
-- Name: tenant_views_setups; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TYPE device_types_enum AS ENUM ('mobile', 'desktop');
CREATE TYPE qvd_objects_enum AS ENUM ('user', 'vm', 'host', 'osf', 'di', 'tenant', 'administrator', 'role');

CREATE TABLE tenant_views_setups (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    field varchar(64) NOT NULL,
    visible boolean NOT NULL,
    device_type device_types_enum NOT NULL,
    view_type varchar(64) NOT NULL,
    qvd_object  qvd_objects_enum NOT NULL,
    property  boolean NOT NULL
);


ALTER TABLE public.tenant_views_setups OWNER TO qvd;

--
-- Name: tenant_views_setups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE tenant_views_setups_id_seq OWNED BY tenant_views_setups.id;


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
-- Name: tenants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE administrators_id_seq OWNED BY administrators.id;


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
-- Name: administrator_views_setups; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE administrator_views_setups (
    id integer NOT NULL,
    administrator_id integer NOT NULL,
    field varchar(64) NOT NULL,
    visible boolean NOT NULL,
    device_type device_types_enum NOT NULL,
    view_type varchar(64) NOT NULL,
    qvd_object  qvd_objects_enum NOT NULL,
    property  boolean NOT NULL
);


ALTER TABLE public.administrator_views_setups OWNER TO qvd;

--
-- Name: administrators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE administrator_views_setups_id_seq OWNED BY administrator_views_setups.id;


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
-- Name: roles; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.roles OWNER TO qvd;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;

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
-- Name: acls; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE acls (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.acls OWNER TO qvd;

--
-- Name: acls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE acls_id_seq OWNED BY acls.id;

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
-- Name: role_administrator_relations; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE role_administrator_relations (
    id integer NOT NULL,
    role_id integer NOT NULL,
    administrator_id integer NOT NULL
);


ALTER TABLE public.role_administrator_relations OWNER TO qvd;

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
-- Name: role_role_relations; Type: TABLE; Schema: public; Owner: qvd; Tablespace: 
--

CREATE TABLE role_role_relations (
    id integer NOT NULL,
    inheritor_id integer NOT NULL,
    inherited_id integer NOT NULL
);


ALTER TABLE public.role_role_relations OWNER TO qvd;

--
-- Name: role_role_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE role_role_relations_id_seq OWNED BY role_role_relations.id;

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
-- Name: acl_role_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: qvd
--

ALTER SEQUENCE acl_role_relations_id_seq OWNED BY acl_role_relations.id;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY tenants ALTER COLUMN id SET DEFAULT nextval('tenants_id_seq'::regclass);

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY administrators ALTER COLUMN id SET DEFAULT nextval('administrators_id_seq'::regclass);

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY acls ALTER COLUMN id SET DEFAULT nextval('acls_id_seq'::regclass);

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

ALTER TABLE ONLY acl_role_relations ALTER COLUMN id SET DEFAULT nextval('acl_role_relations_id_seq'::regclass);


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

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vms ALTER COLUMN id SET DEFAULT nextval('vms_id_seq'::regclass);

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY tenant_views_setups ALTER COLUMN id SET DEFAULT nextval('tenant_views_setups_id_seq'::regclass);

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY administrator_views_setups ALTER COLUMN id SET DEFAULT nextval('administrator_views_setups_id_seq'::regclass);

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
\.


--
-- Name: di_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('di_tags_id_seq', 1, false);


--
-- Data for Name: dis; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY dis (id, osf_id, path, version) FROM stdin;
\.


--
-- Name: dis_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('dis_id_seq', 1, false);


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

SELECT pg_catalog.setval('hosts_id_seq', 1, false);


--
-- Data for Name: osf_properties; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY osf_properties (osf_id, key, value) FROM stdin;
\.


--
-- Data for Name: osfs; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY osfs (id, name, memory, use_overlay, user_storage_size) FROM stdin;
\.


--
-- Name: osfs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('osfs_id_seq', 1, false);


--
-- Data for Name: ssl_configs; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY ssl_configs (key, value) FROM stdin;
\.


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

COPY users (id, login, password) FROM stdin;
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('users_id_seq', 1, false);


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
\.


--
-- Data for Name: vm_properties; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY vm_properties (vm_id, key, value) FROM stdin;
\.


--
-- Data for Name: vm_runtimes; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY vm_runtimes (vm_id, host_id, current_osf_id, current_di_id, user_ip, real_user_id, vm_state, vm_state_ts, vm_cmd, vm_pid, user_state, user_state_ts, user_cmd, vma_ok_ts, l7r_host, l7r_pid, vm_address, vm_vma_port, vm_x_port, vm_ssh_port, vm_vnc_port, vm_mon_port, vm_serial_port, blocked, vm_expiration_soft, vm_expiration_hard) FROM stdin;
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
-- Data for Name: acls; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY tenants (id, name) FROM stdin;
0	*
\.

--
-- Data for Name: acls; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY administrators (id, name, password, tenant_id) FROM stdin;
1	superadmin	superadmin	0
\.


--
-- Data for Name: acls; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY roles (id, name) FROM stdin;
1	master
\.

--
-- Data for Name: acls; Type: TABLE DATA; Schema: public; Owner: qvd
--

COPY role_administrator_relations (role_id, administrator_id) FROM stdin;
1	1
\.


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
44	administrator.see.acl-list
45	administrator.see.roles
46	administrator.see.acl-list-roles
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
91	administrator.see.id
92	vm.see.expiration
93	administrator.create.
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
111	administrator.delete.
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
125	administrator.delete-massive.
126	administrator.see-details.
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
137	administrator.see-main.
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
153	host.stats.running-hosts
154	user.stats.summary
155	user.stats.blocked
156	host.stats.summary
157	host.stats.blocked
158	osf.stats.summary
38	osf.see.di-list-default
39	osf.see.di-list-default-update
40	osf.see.di-list-head
159	di.stats.summary
160	di.stats.blocked
161	administrator.update.password
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
197	administrator.update.assign-role
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
208	di.update-massive.tags-delete
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
235	my-admin-area.update.columns
236	my-admin-area.update.filters-desktop
237	my-admin-area.update.filters-mobile
238	my-admin-area.see-main.
239	my-admin-area.update.password
240	tenant.delete.
241	administrator.filter.name
242	role.filter.name
243	tenant.filter.name
37	osf.see.di-list-tags
244	osf.see.di-list-block
245	di.see.vm-list-user-state
246	host.see.vm-list-user-state
247	osf.see.vm-list-user-state
248	user.see.vm-list-user-state
\.

--
-- Data for Name: acls; Type: TABLE DATA; Schema: public; Owner: qvd
--


COPY acl_role_relations (acl_id, role_id) FROM stdin;
1	1
2	1
3	1
4	1
5	1
6	1
7	1
8	1
9	1
10	1
11	1
12	1
13	1
14	1
15	1
16	1
17	1
18	1
19	1
20	1
21	1
22	1
23	1
24	1
25	1
26	1
27	1
28	1
29	1
30	1
31	1
32	1
33	1
34	1
35	1
36	1
41	1
42	1
43	1
44	1
45	1
46	1
47	1
48	1
49	1
50	1
51	1
52	1
53	1
54	1
55	1
56	1
57	1
58	1
59	1
60	1
61	1
62	1
63	1
64	1
65	1
66	1
67	1
68	1
69	1
70	1
71	1
72	1
73	1
74	1
75	1
76	1
77	1
78	1
79	1
80	1
81	1
82	1
83	1
84	1
85	1
86	1
87	1
88	1
89	1
90	1
91	1
92	1
93	1
94	1
95	1
96	1
97	1
98	1
99	1
100	1
101	1
102	1
103	1
104	1
105	1
106	1
107	1
108	1
109	1
110	1
111	1
112	1
113	1
114	1
115	1
116	1
117	1
118	1
119	1
120	1
121	1
122	1
123	1
124	1
125	1
126	1
127	1
128	1
129	1
130	1
131	1
132	1
133	1
134	1
135	1
136	1
137	1
138	1
139	1
140	1
141	1
142	1
143	1
144	1
145	1
146	1
147	1
148	1
149	1
150	1
151	1
152	1
153	1
154	1
155	1
156	1
157	1
158	1
38	1
39	1
40	1
159	1
160	1
161	1
162	1
163	1
164	1
165	1
166	1
167	1
168	1
169	1
170	1
171	1
172	1
173	1
174	1
175	1
176	1
177	1
178	1
179	1
180	1
181	1
182	1
183	1
184	1
185	1
186	1
187	1
188	1
189	1
190	1
191	1
192	1
193	1
194	1
195	1
196	1
197	1
198	1
199	1
200	1
201	1
202	1
203	1
204	1
205	1
206	1
207	1
208	1
209	1
210	1
211	1
212	1
213	1
214	1
215	1
216	1
217	1
218	1
219	1
220	1
221	1
222	1
223	1
224	1
225	1
226	1
227	1
228	1
229	1
230	1
231	1
232	1
233	1
234	1
235	1
236	1
237	1
238	1
239	1
240	1
241	1
242	1
243	1
37	1
244	1
245	1
246	1
247	1
248	1
\.



--
-- Name: vms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: qvd
--

SELECT pg_catalog.setval('vms_id_seq', 1, false);

--
-- Name: session_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- Name: tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);

--
-- Name: administrators_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY administrators
    ADD CONSTRAINT administrators_pkey PRIMARY KEY (id);

--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);

--
-- Name: acls_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY acls
    ADD CONSTRAINT acls_pkey PRIMARY KEY (id);

--
-- Name: role_administrator_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_administrator_relations
    ADD CONSTRAINT role_administrator_relations_pkey PRIMARY KEY (id);

--
-- Name: role_role_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_role_relations
    ADD CONSTRAINT role_role_relations_pkey PRIMARY KEY (id);

--
-- Name: acl_role_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY acl_role_relations
    ADD CONSTRAINT acl_role_relations_pkey PRIMARY KEY (id);

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
-- Name: administrator_views_setups_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY administrator_views_setups
    ADD CONSTRAINT administrator_views_setups_pkey PRIMARY KEY (id);

--
-- Name: tenant_views_setups_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY tenant_views_setups
    ADD CONSTRAINT tenant_views_setups_pkey PRIMARY KEY (id);


--
-- Name: tenant_views_setups_tenant_id_field; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY tenant_views_setups
    ADD CONSTRAINT tenant_views_setups_unique UNIQUE (tenant_id, field, view_type, device_type, qvd_object, property);

--
-- Name: administrator_views_setups_administrator_id_field; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY administrator_views_setups
    ADD CONSTRAINT administrator_views_setups_unique UNIQUE (administrator_id, field, view_type, device_type, qvd_object, property);


--
-- Name: tenants_name; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY tenants
    ADD CONSTRAINT tenants_name UNIQUE (name);

--
-- Name: administrators_name; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY administrators
    ADD CONSTRAINT administrators_name UNIQUE (name);

--
-- Name: roles_name; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_name UNIQUE (name);

--
-- Name: acls_name; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY acls
    ADD CONSTRAINT acls_name UNIQUE (name);

--
-- Name: role_administrator_relations_administrator_id_role_id; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_administrator_relations
    ADD CONSTRAINT role_administrator_relations_administrator_id_role_id UNIQUE (administrator_id, role_id);

--
-- Name: role_role_relations_inheritor_id_inherited_id; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_role_relations
    ADD CONSTRAINT role_role_relations_inheritor_id_inherited_id UNIQUE (inheritor_id, inherited_id);

--
-- Name: acl_role_relations_acl_id_role_id; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY acl_role_relations
    ADD CONSTRAINT acl_role_relations_acl_id_role_id UNIQUE (acl_id, role_id);

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
-- Name: ssl_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY ssl_configs
    ADD CONSTRAINT ssl_configs_pkey PRIMARY KEY (key);


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
-- Name: users_idx_tenant_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX users_idx_tenant_id ON users USING btree (tenant_id);

--
-- Name: osfs_idx_tenant_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX osfs_idx_tenant_id ON osfs USING btree (tenant_id);

--
-- Name: administrators_idx_tenant_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX administrators_idx_tenant_id ON administrators USING btree (tenant_id);

--
-- Name: role_administrator_relations_idx_administrator_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX role_administrator_relations_idx_administrator_id ON role_administrator_relations  USING btree (administrator_id);

--
-- Name: role_administrator_relations_idx_role_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX role_administrator_relations_idx_role_id ON role_administrator_relations  USING btree (role_id);

--
-- Name: role_role_relations_idx_inheritor_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX role_role_relations_idx_inheritor_id ON role_role_relations  USING btree (inheritor_id);

--
-- Name: role_role_relations_idx_inherited_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX role_role_relations_idx_inherited_id ON role_role_relations  USING btree (inherited_id);

--
-- Name: acl_role_relations_idx_acl_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX acl_role_relations_idx_acl_id ON acl_role_relations  USING btree (acl_id);

--
-- Name: acl_role_relations_idx_role_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX acl_role_relations_idx_role_id ON acl_role_relations  USING btree (role_id);


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
-- Name: user_properties_idx_user_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX user_properties_idx_user_id ON user_properties USING btree (user_id);


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
-- Name: tenant_views_setups_idx_tenant_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX tenant_views_setups_idx_tenant_id ON tenant_views_setups USING btree (tenant_id);

--
-- Name: administrator_views_setups_idx_administrator_id; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

CREATE INDEX administrator_views_setups_idx_administrator_id ON administrator_views_setups USING btree (administrator_id);

--
-- Name: tenant_views_setups_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY tenant_views_setups
    ADD CONSTRAINT tenant_views_setups_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

--
-- Name: administrator_views_setups_administrator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY administrator_views_setups
    ADD CONSTRAINT administrator_views_setups_administrator_id_fkey FOREIGN KEY (administrator_id) REFERENCES administrators(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

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
-- Name: vm_runtimes_host_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY vm_runtimes
    ADD CONSTRAINT vm_runtimes_l7r_host_id_fkey FOREIGN KEY (l7r_host_id) REFERENCES hosts(id) ON UPDATE CASCADE DEFERRABLE;

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
-- Name: osfs_tenant_id_tenants_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY osfs
    ADD CONSTRAINT osfs_tenant_id_tenants_id_fkey FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

--
-- Name: administrators_tenant_id_tenants_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: qvd
--

ALTER TABLE ONLY administrators
    ADD CONSTRAINT administrators_tenant_id_tenants_id_fkey FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

--
-- Name: role_administrator_relations_administrator_id_administrators_id_fkey; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_administrator_relations
    ADD CONSTRAINT role_administrator_relations_administrator_id_administrators_id_fkey FOREIGN KEY (administrator_id) REFERENCES administrators(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

--
-- Name: role_administrator_relations_role_id_roles_id_fkey; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_administrator_relations
    ADD CONSTRAINT role_administrator_relations_role_id_roles_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

--
-- Name: role_role_relations_inheritor_id_roles_id_fkey; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_role_relations
    ADD CONSTRAINT role_role_relations_inheritor_id_roles_id_fkey FOREIGN KEY (inheritor_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

--
-- Name: role_role_relations_inherited_id_roles_id_fkey; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY role_role_relations
    ADD CONSTRAINT role_role_relations_inherited_id_roles_id_fkey FOREIGN KEY (inherited_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

--
-- Name: acl_role_relations_acl_id_acls_id_fkey; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY acl_role_relations
    ADD CONSTRAINT acl_role_relations_acl_id_acls_id_fkey FOREIGN KEY (acl_id) REFERENCES acls(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

--
-- Name: acl_role_relations_role_id_roles_id_fkey; Type: INDEX; Schema: public; Owner: qvd; Tablespace: 
--

ALTER TABLE ONLY acl_role_relations
    ADD CONSTRAINT acl_role_relations_acl_id_roles_id_fkey FOREIGN KEY (role_id) REFERENCES roles(id) ON UPDATE CASCADE ON DELETE CASCADE DEFERRABLE;

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

