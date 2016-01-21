package QVD::Admin4::CLI::Command;
use strict;
use warnings;
use base qw( CLI::Framework::Command::Meta );
use Text::SimpleTable::AutoWidth;
use Text::UnicodeTable::Simple;
use Mojo::JSON qw(encode_json decode_json j);
use Mojo::IOLoop;
use Mojo::Message::Response;
use Encode;
use File::Basename qw(basename dirname);
use Term::ReadKey;
use CLI::Framework::Exceptions;
use utf8::all;
use POSIX;

our $COMMON_USAGE_TEXT = "
======================================================================================================
                                             DEFAULT FILTERS
======================================================================================================

  The filter key 'name', and the operator '=' are consirered as defaults. So the following is a right 
  syntax: 
  
  <QVD OBJECT COMMAND> <QVD OBJECT NAME> <ACTION COMMAND>

  For example:
  vm myVM get (Equal to vm name=myVM get)  
  vm myVM set name=yourVM (Equal to vm name=myVM set name=yourVM)   

======================================================================================================
                                             COMPLEX FILTERS
======================================================================================================

  A filter is a key/value pair. Key and value can be related by means of different kinds of 
  IDENTITY OPERATORS (=, >, <, etc.). Different operators allow different kinds of values 
  (numeric, alphanumeric, arrays, ranges...). Morover, two or more filters can be joined by means 
  of LOGICAL OPERATORS (coordination, disjunction and negation operators).

  DIFFERENT IDENTITY OPERATORS:
  Supported operators:

  =  (equal)
  != (not equal)
  <  (less than)
  >  (greater that)
  <= (less or equal than)
  >= (greater or equal than)
  ~  (matches with a commodins expression: the SQL LIKE operator)

  For example:
  key1 = 1, 
  key1 < 3, 
  key1 > 3, 
  key1 <= 3, 
  key1 >= 3
  key1 = [1,2,3] (key1 must be in (1, 2, 3))
  key1 = [1:3] (key1 must be between 1 and 3)
  key1 = This_is_a_chain
  key1 = 'This is a chain' (A value with blanks must be quoted)
  key1 = \"This is a chain\" (A value with blanks must be quoted)
  key1 ~ %s_is_a_ch% (key1 must match the SQL commodins expression %s_is_a_ch%)
  key1 ~ '%s is a ch%' (key1 must match the SQL commodins expression %s_is_a_ch%)
  key1 ~ \"%s is a ch%\" (key1 must match the SQL commodins expression %s_is_a_ch%)

  LOGICAL OPERATORS
  Supported operators

  , (the AND operator)
  ; (the OR operator)
  ! (the NOT operator)

  (These operators have left precedence. In order to override this behaviour you must 
   grup filters with '(' and ')')

  For example:
  key1=value, key2=value, key3=value (key1 AND key2 AND key3)
  (key1=value; key2=value), key3=value ((key1 OR key2) AND key3))
  !key1=value (This expresion means: NOT key1)
  !key1=value, key2=value, key3=value (NOT ( key1 AND key2 AND key3))
  (! key1=value), key2=value, key3=value ((NOT key1) AND key2 AND key3))

======================================================================================================
";


###############
## VARIABLES ##
###############

# Filters available in CLI and translation into API format
# The typical translation is qvd-object => qvd-object_name
# (i.e., for vms: osf => osf_name)

my $FILTERS = {
	vm => {
		storage => 'storage',
	    id => 'id', 
	    name => 'name', 
	    user => 'user_name', 
	    osf => 'osf_name', 
	    tag => 'di_tag', 
	    blocked => 'blocked', 
	    expiration_soft => 'expiration_soft', 
	    expiration_hard => 'expiration_hard', 
	    state => 'state', 
	    host =>  'host_name', 
	    di => 'di_name', 
	    user_state => 'user_state', 
	    ip => 'ip', 
	    ssh_port => 'ssh_port', 
	    vnc_port => 'vnv_port', 
	    serial_port => 'serial_port',
	    tenant =>  'tenant_name', 
	    ip_in_use => 'ip_in_use', 
	    di_in_use => 'di_name_in_use', 
	    creation_date => 'creation_date', 
	    creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	user => {
		id => 'id',
	      name => 'name', 
	      blocked => 'blocked', 
	      tenant => 'tenant_name', 
	      creation_date => 'creation_date',
	      creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	host => {
		id => 'id',
	      name => 'name', 
	      address => 'address', 
	      blocked => 'blocked', 
	      frontend => 'frontend', 
	      backend => 'backend', 
	      state => 'state',
	      creation_date => 'creation_date', 
	      creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	osf => {
		id => 'id',
	     name => 'name', 
	     overlay => 'overlay', 
	     user_storage => 'user_storage', 
	     memory => 'memory', 
	     tenant =>  'tenant_name',
	     creation_date => 'creation_date', 
	     creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	di => {
		id => 'id',
	    name => 'disk_image', 
	    version => 'version', 
	    osf => 'osf_name', 
	    tenant => 'tenant_name', 
	    blocked => 'blocked', 
	    tag => 'tag',
	    creation_date => 'creation_date', 
	    creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	tenant => {
		id => 'id',
		name => 'name', 
		language => 'language', 
		block => 'block',
		creation_date => 'creation_date', 
		creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	config => {
		tenant => 'tenant_id',
		key_re => 'key_re'
	},

	admin => {
		id => 'id',
	       name => 'name', 
	       tenant => 'tenant_name', 
	       language => 'language', 
	       block => 'block',
	       creation_date => 'creation_date', 
	       last_update_date => 'last_update_date', 
	       creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	role => {
		id => 'id',
	      name => 'name', 
	      fixed => 'fixed', 
	      internal => 'internal', 
	      creation_date => 'creation_date', 
	      creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	acl => {
		id => 'id',
	     name => 'name', 
	     role => 'role_id', 
	     admin => 'admin_id', 
		operative => 'operative'
	},

	log => {
		id => 'id',
	     admin_id => 'admin_id', 
	     admin_name => 'admin_name', 
	     tenant_id => 'tenant_id', 
	     tenant_name => 'tenant_name', 
	     action => 'action',  
	     arguments => 'arguments',  
	     object_id => 'object_id', 
	     object_name => 'object_name', 
	     time => 'time', 
	     status => 'status', 
	     source => 'source', 
	     ip => 'ip', 
	     type_of_action => 'type_of_action', 
	     qvd_object => 'qvd_object', 
		superadmin => 'superadmin'
	},

};

# Available order criteria in CLI and translation into
# API format

my $ORDER = {
	vm => {
		storage => 'storage',
	    id => 'id', 
	    name => 'name', 
	    user => 'user_name', 
	    osf => 'osf_name', 
	    tag => 'di_tag', 
	    blocked => 'blocked', 
	    expiration_soft => 'expiration_soft', 
	    expiration_hard => 'expiration_hard', 
	    state => 'state', 
	    host =>  'host_name', 
	    di => 'di_name', 
	    user_state => 'user_state', 
	    ip => 'ip', 
	    ssh_port => 'ssh_port', 
	    vnc_port => 'vnv_port', 
	    serial_port => 'serial_port',
	    tenant =>  'tenant_name', 
	    ip_in_use => 'ip_in_use', 
	    creation_date => 'creation_date', 
            creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	user => {
		id => 'id',
	      name => 'name', 
	      blocked => 'blocked', 
	      tenant => 'tenant_name', 
	      creation_date => 'creation_date', 
	      creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	host => {
		id => 'id',
	      name => 'name', 
	      address => 'address', 
	      blocked => 'blocked', 
	      frontend => 'frontend', 
	      backend => 'backend',
	      state => 'state',
	      creation_date => 'creation_date', 
	      creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	osf => {
		id => 'id',
	     name => 'name', 
	     overlay => 'overlay', 
	     user_storage => 'user_storage', 
	     memory => 'memory', 
	     tenant =>  'tenant_name',
	     creation_date => 'creation_date', 
	     creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	di => {
		id => 'id',
	    name => 'disk_image', 
	    version => 'version', 
	    osf => 'osf_name', 
	    tenant => ' tenant_name', 
	    blocked => 'blocked', 
	    tag => 'tag',
	    creation_date => 'creation_date', 
	    creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	tenant => {
		id => 'id',
		name => 'name', 
		language => 'language', 
		block => 'block', 
		creation_date => 'creation_date', 
		creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	admin => {
		id => 'id',
	       name => 'name', 
	       tenant => 'tenant_name', 
	       language => 'language', 
	       block => 'block',
	       creation_date => 'creation_date', 
	       creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	role => {
		id => 'id',
	      name => 'name', 
	      fixed => 'fixed', 
	      internal => 'internal', 
	      creation_date => 'creation_date', 
	      creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

    acl => { id => 'id', name => 'name' },

	log => {
		id => 'id',
	     admin_id => 'admin_id', 
	     admin_name => 'admin_name', 
	     tenant_id => 'tenant_id', 
	     tenant_name => 'tenant_name', 
	     action => 'action',  
	     arguments => 'arguments',  
	     object_id => 'object_id', 
	     object_name => 'object_name', 
	     time => 'time', 
	     status => 'status', 
	     source => 'source', 
	     ip => 'ip', 
	     type_of_action => 'type_of_action', 
	     qvd_object => 'qvd_object', 
		superadmin => 'superadmin'
	},
};

# Available fields to retrieve and translation into
# API format

my $FIELDS = {
	vm => {
		storage => 'storage',
	    id => 'id', 
	    name => 'name', 
	    user => 'user_name', 
	    osf => 'osf_name', 
	    tag => 'di_tag', 
	    blocked => 'blocked', 
	    expiration_soft => 'expiration_soft', 
	    expiration_hard => 'expiration_hard', 
	    state => 'state', 
	    host =>  'host_name', 
	    di => 'di_name', 
	    user_state => 'user_state', 
	    ip => 'ip', 
	    mac => 'mac', 
	    ssh_port => 'ssh_port', 
	    vnc_port => 'vnv_port', 
	    serial_port => 'serial_port', 
	    tenant =>  'tenant_name', 
	    ip_in_use => 'ip_in_use', 
	    di_in_use => 'di_name_in_use',
	    creation_date => 'creation_date', 
	    creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	user => {
		id => 'id',
	      name => 'name', 
	      tenant => 'tenant_name', 
	      blocked => 'blocked', 
	      number_of_vms => 'number_of_vms', 
	      number_of_vms_connected => 'number_of_vms_connected', 
	      creation_date => 'creation_date', 
	      creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	host => {
		id => 'id',
	      name => 'name', 
	      address => 'address', 
	      blocked => 'blocked', 
	      frontend => 'frontend', 
	      backend => 'backend', 
	      state => 'state', 
	      number_of_vms_connected => 'number_of_vms_connected', 
	      creation_date => 'creation_date', 
	      creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	osf => {
		id => 'id',
	     name => 'name', 
	     overlay => 'overlay', 
	     user_storage => 'user_storage', 
	     memory => 'memory', 
	     tenant =>  'tenant_name', 
	     number_of_vms => 'number_of_vms', 
	     number_of_dis => 'number_of_dis', 
	     creation_date => 'creation_date', 
	     creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	di => {
		id => 'id',
	    name => 'disk_image', 
	    tenant => 'tenant_name', 
	    version => 'version', 
	    osf => 'osf_name', 
	    blocked => 'blocked', 
	    tags => 'tags',
	    creation_date => 'creation_date', 
	    creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	tenant => {
		id => 'id',
		name => 'name', 
		language => 'language', 
		block => 'block', 
		creation_date => 'creation_date', 
		creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	config => {
		key => 'key',
		value => 'operative_value', 
		default => 'default_value'
	},

	admin => {
		id => 'id',
	       name => 'name', 
	       roles => 'roles', 
	       tenant => 'tenant_name', 
	       language => 'language', 
	       block => 'block',
	       creation_date => 'creation_date', 
	       creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

	role => {
		id => 'id',
	      name => 'name', 
	      fixed => 'fixed', 
	      internal => 'internal', 
	      roles => 'roles', 
	      acls => 'acls',
	      creation_date => 'creation_date', 
	      creation_admin_id => 'creation_admin_id', 
		creation_admin_name => 'creation_admin_name'
	},

    acl => { id => 'id', name => 'name' },

	log => {
		id => 'id',
	     admin_id => 'admin_id', 
	     admin_name => 'admin_name', 
	     tenant_id => 'tenant_id', 
	     tenant_name => 'tenant_name', 
	     action => 'action',  
	     arguments => 'arguments',  
	     object_id => 'object_id', 
	     object_name => 'object_name', 
	     time => 'time', 
	     status => 'status', 
	     source => 'source', 
	     ip => 'ip', 
	     type_of_action => 'type_of_action', 
	     qvd_object => 'qvd_object', 
	     deleted_object => 'deleted_object', 
	     deleted_admin => 'deleted_admin', 
		superadmin => 'superadmin'
	},
};

# For every field to retrieve, a callback can be specified.
# When the CLI returns that field, it executes the corresponding
# callback, that processes the original field retrieved by the API
# before it is printed in console

my $FIELDS_CBS = {
	di => {
		tags => sub {
			my $tags = shift;
			  my @tags = map { $_->{tag} } @$tags; 
			return join ', ', @tags;
		}
	},

	admin => {
		roles => sub {
			my $roles = shift;
			      my @roles =  values %$roles; 
			return join "\n", @roles;
		}
	},

	role => {
		roles => sub {
			my $roles = shift;
			     my @roles = map { $_->{name} } values %$roles; 
			return join "\n", @roles;
		},

		acls =>  sub {
			my $acls = shift;
			     my @acls = sort( (map { "$_ (+)" } @{$acls->{positive}}),
					       (map { "$_ (-)" } @{$acls->{negative}})); 
			return join "\n", @acls;
		}
	},
};

# Available arguments in CLI and translation into
# API format

my $ARGUMENTS = {
	vm => {
		name => 'name',
	    ip => 'ip', 
	    tenant => 'tenant_id', 
	    blocked => 'blocked', 
	    expiration_soft => 'expiration_soft',
	    expiration_hard => 'expiration_hard', 
	    storage => 'storage', 
	    tag => 'di_tag', 
	    user => 'user_id', 
	    osf => 'osf_id', 
		__properties_changes__ => '__properties_changes__'
	}, # For nested queries in API

	user => {
		name => 'name',
	      password => 'password', 
	      blocked => 'blocked', 
	      tenant => 'tenant_id',
		__properties_changes__ => '__properties_changes__', # For nested queries in API
	},

	host => {
		name => 'name',
	      address => 'address', 
	      frontend => 'frontend', 
	      backend => 'backend', 
	      blocked => 'blocked',
		__properties_changes__ => '__properties_changes__', # For nested queries in API
	},

	osf => {
		name => 'name',
	     memory => 'memory', 
	     user_storage => 'user_storage', 
	     overlay => 'overlay', 
	     tenant => 'tenant_id',
		__properties_changes__ => '__properties_changes__', # For nested queries in API
	},

	di => {
		blocked => 'blocked',
	    name => 'disk_image',  
	    version => 'version', 
	    osf => 'osf_id',
	    __properties_changes__ => '__properties_changes__', # For nested queries in API
		__tags_changes__ => '__tags_changes__',  # For nested queries in API
	},

	tenant => {
		name => 'name',
		language => 'language', 
		block => 'block'
	},

	config => {
		key => 'key',
		value => 'value',
		tenant => 'tenant_id',
	},

	admin => {
		name => 'name',
	       password => 'password', 
	       tenant => 'tenant_id', 
	       language => 'language', 
	       block => 'block',
		__roles_changes__ => '__roles_changes__', # For nested queries in API
	},

	role => {
		name => 'name',
	      fixed => 'fixed', 
	      internal => 'internal',
	      __roles_changes__ => '__roles_changes__', # For nested queries in API
		__acls_changes__ => '__acls_changes__', # For nested queries in API
	},
};


# These callbacks are intended to ask the API for
# the list of ids corresponding a certain set of objects.
# These cbs are intended to solve a problem regarding a general
# difference between CLI syntax and API syntax:
# A certain query to API about a QVD object can include
# references to related objects (i.e. vms have a related
# user and a related osf). These related objects are referenced
# in the API by id, but in the CLI syntax they are referenced
# by name. So these functions are intended to take a name, ask for the object
# id corresponding to that name in API and retrieve the id: are intended
# to switch from name to id.

my $related_tenant_cb = sub { 
    my ($self,$name) = @_; 
	$self->ask_api(
		{
			action => 'tenant_all_ids',
			filters =>  { name => $name }
		}
	)->json('/rows');
};

my $related_user_cb = sub { 
    my ($self,$name,$tenant_id) = @_; 
    my $filters = { name => $name };
    $filters->{tenant_id} = $tenant_id if $tenant_id;
	$self->ask_api(
		{
			action => 'user_all_ids',
			filters =>  $filters
		}
	)->json('/rows');
};

my $related_host_cb = sub { 
    my ($self,$name) = @_; 
	$self->ask_api(
		{
			action => 'host_all_ids',
			filters =>  { name => $name }
		}
	)->json('/rows');
};

my $related_osf_cb = sub { 
    my ($self,$name,$tenant_id) = @_; 
    my $filters = { name => $name };
    $filters->{tenant_id} = $tenant_id if $tenant_id;
	$self->ask_api(
		{
			action => 'osf_all_ids',
			filters =>  $filters
		}
	)->json('/rows');
};

my $related_di_cb = sub { 
    my ($self,$name,$tenant_id) = @_; 
    my $filters = { name => $name };
    $filters->{tenant_id} = $tenant_id if $tenant_id;
	$self->ask_api(
		{
			action => 'di_all_ids',
			filters =>  $filters
		}
	)->json('/rows');
};

my $related_admin_cb = sub { 
    my ($self,$name,$tenant_id) = @_; 
    my $filters = { name => $name };
    $filters->{tenant_id} = $tenant_id if $tenant_id;
	$self->ask_api(
		{
			action => 'administrator_all_ids',
			filters =>  $filters
		}
	)->json('/rows');
};

my $related_role_cb = sub { 
    my ($self,$name) = @_; 
	$self->ask_api(
		{
			action => 'role_all_ids',
			filters =>  { name => $name }
		}
	)->json('/rows');
};

# The previous callbacks are stored in this variable

my $CBS_TO_GET_RELATED_OBJECTS_IDS =
	{
		vm => {
			argument =>  {
				user => $related_user_cb,
			   host => $related_host_cb,
			   osf => $related_osf_cb, 
				di => $related_di_cb
			}
		},

		di => {
			argument => {
				osf => $related_osf_cb
			}
		}
	};

# This variable stores the relation between CLI queries
# and the corresponding actions in API

my $CLI_CMD2API_ACTION = {
	# qvd_object => kind_of_action => API action
	vm => {
		ids => 'vm_all_ids',
	    get => 'vm_get_list', 
	    update => 'vm_update', 
	    create => 'vm_create', 
	    delete => 'vm_delete', 
	    start => 'vm_start', 
	    stop => 'vm_stop', 
		disconnect => 'vm_user_disconnect'
	},

	user => {
		ids => 'user_all_ids',
	      get => 'user_get_list', 
	      update => 'user_update', 
	      create => 'user_create', 
		delete => 'user_delete'
	},

	host => {
		ids => 'host_all_ids',
	      get => 'host_get_list', 
	      update => 'host_update', 
	      create => 'host_create', 
		delete => 'host_delete'
	},

	osf => {
		ids => 'osf_all_ids',
	     get => 'osf_get_list', 
	     update => 'osf_update', 
	     create => 'osf_create', 
		delete => 'osf_delete'
	},

	di => {
		ids => 'di_all_ids',
	    get => 'di_get_list', 
	    update => 'di_update', 
	    create => 'di_create', 
		delete => 'di_delete'
	},

	tenant => {
		ids => 'tenant_all_ids',
		get => 'tenant_get_list', 
		update => 'tenant_update', 
		create => 'tenant_create', 
		delete => 'tenant_delete'
	},

	config => {
		get => 'config_get',
		update => 'config_set', 
		ssl     => 'config_ssl',
		delete => 'config_delete', 
		default => 'config_default',
	},

	admin => {
		ids => 'administrator_all_ids',
	       get => 'administrator_get_list', 
	       update => 'administrator_update', 
	       create => 'administrator_create', 
		delete => 'administrator_delete'
	},

	role => {
		ids => 'role_all_ids',
	      get => 'role_get_list', 
	      update => 'role_update', 
	      create => 'role_create', 
		delete => 'role_delete'
	},

    acl => { get => 'acl_get_list' }, 

    log => { get => 'log_get_list' },

};

# Default lists of fields that must be displayed
# in console for every kind of qvd object

my $DEFAULT_FIELDS = {

    vm => [ qw( id tenant name blocked user host di ip ip_in_use di_in_use state user_state ) ],

    user => [ qw( id tenant name blocked number_of_vms number_of_vms_connected ) ],

    host => [ qw( id name blocked address frontend backend state number_of_vms_connected ) ],

    osf => [ qw( id name overlay user_storage memory tenant number_of_vms number_of_dis ) ],

    di => [ qw( id tenant name version osf blocked tags ) ],

    tenant => [ qw( id name language block ) ],

    config => [ qw( key value default) ],

    admin => [ qw(id tenant name language block) ],

    role => [ qw(id name fixed internal) ],

    acl => [ qw(id name) ],

    log => [qw(time admin_name type_of_action qvd_object object_name status)]
};

##############################################################
## METHOD RUN (to be executed when a command is introduced) ##
##############################################################

sub run 
{
    my ($self, $opts, @args) = @_;

    my $parsing = $self->parse_string(@args); # It parses the input CLI query

    if ($parsing->command eq 'get')  # For display queries
    {
	$self->_get($parsing);
    }
    elsif ($parsing->command eq 'create') # For creation queries
    {
	$self->_create($parsing);
    }
    elsif ($parsing->command eq 'can') # For queries that check the acls of an admin or role
    {
	$self->_can($parsing);
    }
    else # For other queries (update/delete/...)
    {
	$self->_cmd($parsing);
    }
}

# Function used to execute a displaying query

sub _get 
{
    my ($self,$parsing) = @_;                       # Takes a parsed query
    my $query = $self->make_api_query($parsing);    # Creates a JSON query in API format 
	$self->execute_and_display_query($query,$parsing); # Ask the API and prints a table in pagination mode
}

# Function to execute a creation table

sub _create 
{
    my ($self,$parsing) = @_; # Takes parsed query

    # If needed, it switchs from tenant name to tenant id
    if (my $tenant_name = $parsing->arguments->{tenant})
    {
	my $tenant_ids = $related_tenant_cb->($self,$tenant_name);
	my $tenant_id = shift @$tenant_ids //
	    CLI::Framework::Exception->throw("Unknown related object tenant in filters");
	$self->tenant_scoop($tenant_id);
	$parsing->arguments->{tenant} = $self->tenant_scoop; 
    }
  
    my $query = $self->make_api_query($parsing);# Creates a JSON query in API format 
	my $res = $self->ask_api($query);
	$self->print_table($res,$parsing);
}

# Function executed for queries that check the acls of an admin or role

sub _can
{
    my ($self,$parsing) = @_;

    # It gets the id of the involved role or admin
	my $ids = $self->ask_api({
		action => $self->get_all_ids_action($parsing),
		filters => $self->get_filters($parsing)
	})->json('/rows');

    # It created an ad hoc JSON query
    my $acl_name = $parsing->parameters->{acl_name}; 
    my $id_key = $parsing->qvd_object eq 'admin' ? 'admin_id' : 'role_id';
    my $filters = { $id_key => $ids, operative => 1 }; 
    $filters->{acl_name} = { 'LIKE' => $acl_name } if defined $acl_name;
    my $action = $parsing->qvd_object eq 'admin' ? 'get_acls_in_admins' : 'get_acls_in_roles';
    my $query = { action => $action,filters => $filters,order_by => $self->get_order($parsing)};

    # It creates an ad hoc displaying query  
    $parsing = QVD::Admin4::CLI::Grammar::Response->new(
	response => { command => 'get', obj1 => { qvd_object => 'acl' }});

	$self->execute_and_display_query($query,$parsing); # Ask the API and prints a table in pagination mode
}

# Function intended to execute a query in pagination mode.
# It sets the console in pagination mode and asks the API and
# prints a new table for every new page.

sub execute_and_display_query
{
    my ($self,$query,$parsing) = @_;
	my $app = $self->get_app;

	my $is_pagination_mode_enabled = ($app->get_interactivity_mode() ? 1 : 0);

    ReadMode("cbreak"); # This sets the pagination mode in console

    # Current pagination parameters setted
	if($is_pagination_mode_enabled) {
		$query->{offset} = 1;
    $query->{block} =  $app->cache->get('block');
	}

	my ($pause_time, $char);
	do {

    # It asks the API for the first page and prints that first page
    my $res = $self->ask_api($query); 
    $self->print_table($res,$parsing); 

		if ($is_pagination_mode_enabled) {
			my $total_pages = ceil($res->json('/total') / $query->{block});
			print STDOUT "--- page $query->{offset} / $total_pages ('n' for next, 'b' for back, 'q' for quit) ---\n";

			$char = ReadKey($pause_time);
            
            # Pagination parameters updated
			$query->{offset}++ if ($char eq 'n' && $query->{offset} < $total_pages);
			$query->{offset}-- if ($char eq 'b' && $query->{offset} > 1);
    }

	} while ($is_pagination_mode_enabled && (defined($char)) && ($char ne 'q'));

    ReadMode(0); # Return to normal mode in console 
}


# Function intended to execute update, delete and the rest of actions.
# All these actions must include an id filter in API. So, firstly,
# the corresponding ids are requested to API, and then the update/delete
# request is performed

sub _cmd
{
    my ($self,$parsing) = @_;

	# It gets all the ids correspondig the objects that must
	# be deleted/updated

    my $ids = $self->ask_api(
		{
			action => $self->get_all_ids_action($parsing),
			filters => $self->get_filters($parsing)
		}
	)->json('/rows');
    
	# It performs the update/delete over the objects with those ids

    my $res = $self->ask_api(
		{
			action => $self->get_action($parsing),
	  filters => { id => { '=' => $ids }}, 
	  order_by => $self->get_order($parsing), 
			arguments => $self->get_arguments($parsing)
		}
	);

	# The API response is printed

    $self->print_table($res,$parsing);
}

# Regular function to create a JSON query in the API format

sub make_api_query
{
    my ($self,$parsing) = @_;

	return {
		action => $self->get_action($parsing),
	     filters => $self->get_filters($parsing), 
	     fields => $self->get_fields_for_api($parsing), 
	     order_by => $self->get_order($parsing), 
		arguments => $self->get_arguments($parsing)
	};
}


###############################################
## METHODS TO PRINT RESPONSES IN CONSOLE RUN ##
###############################################

# It prints the total number of objects retrieved 
# by the API

sub print_count
{
    my ($self,$res) = @_;
	my $total = $res->json('/total');
	print "Total: $total\n" if defined($total);
}

# It takes the response of the API and the original query
# According to fields asked in the query, it prints in a 
# table in console the info stored in the API response

sub getDisplayTableMode {
	my $self = shift;
	return ($self->get_app->cache->get('display_mode') // "TABLE");
}

sub print_table
{
	my ($self, $res, $parsing) = @_;

	my @fields = $self->get_fields($parsing, $res);

	unless (@fields) {
		$self->print_count($res);
		return;
	}

	my $n = 0;
	my @values = ();
    while (my $field = $res->json("/rows/$n")) 
    { 
		$values[$n] = [ map {
			$self->get_field_value($parsing, $field, $_) // ''
		} @fields ];
	$n++;
    }

	my $display_mode = $self->getDisplayTableMode();
	if ($display_mode eq "CSV") {
		print join(";", @fields) . "\n";
		for ($n = 0; $n < @values; $n++) {
			print join(";", @{$values[$n]} ) . "\n";
		}
	} else {
		my $tb = Text::UnicodeTable::Simple->new();

		$tb->set_header(@fields);
		for ($n = 0; $n < @values; $n++) {
			$tb->add_row( $values[$n] );
		}

    print STDOUT "$tb" . "Total: ".$res->json('/total')."\n";
	}
}

#######################################
## METHODS TO PARSE THE INPUT STRING ##
#######################################

sub parse_string
{
    my ($self,@args) = @_;
    my $req = join(' ',@args);
    my $app = $self->get_app;

    # This code gets the parsers from the CLI settings

    my ($tokenizer,$parser) = 
	($app->cache->get('tokenizer'), 
	 $app->cache->get('parser'));

    # First parsing stage, tokenization: 
    # from string to list of words
    my $tokenization = $tokenizer->parse($req);

    $self->unrecognized($tokenization) &&
	CLI::Framework::Exception->throw('Unable to tokenize request');

    # Second parsing stage, parsing:
    # syntactic analysis
    my $parsing = $parser->parse( shift @$tokenization ); # This is a list of analysis

    $self->unrecognized($parsing) &&
	CLI::Framework::Exception->throw('Unable to parse request');
    $self->ambiguous($parsing) &&
	CLI::Framework::Exception->throw('Ambiguos request');

    shift @$parsing; 
}

sub unrecognized
{
    my ($self,$response) = @_;
    scalar @$response < 1 ? return 1 : 0; 
}

sub ambiguous
{
    my ($self,$response) = @_;
    scalar @$response > 1 ? return 1 : 0; 
}

##################################################
## METHODS TO PERFORM A REQUEST AGAINST THE API ##
##################################################

# Main method

sub ask_api
{
    my ($self,$query) = @_;

	# Get arguments
    my $app = $self->get_app;

	my $login = $app->cache->get('login');
	my $password = $app->cache->get('password');
	my $tenant = $app->cache->get('tenant_name');
	my $sid = $app->cache->get('sid');

	my $user_agent = $app->cache->get('user_agent');

    # Added credentials to the JSON query

    my %credentials = defined $sid ? (sid => $sid) : 
	( login => $login, password => $password);
    $credentials{tenant} = $tenant if 
	defined $tenant && defined $credentials{login};
 
	# Ask API depending on the command
	my $res;
	if ($query->{action} eq 'di_create') {

		# TODO:
		# There is no way to select the kind of di creation system that
		# must be used. The API privides three different systems:
		# a) Copy an image from staging
		# b) Upload an inmage from local
		# c) Download an image from url

		# But here just one method can be used (di_upload):
		# This can be changed to 'ask_api_staging'.
		# One more method must be implemented: 'ask_api_di_download'

		my $url = $app->cache->get('api_staging_url');
		$res = $self->ask_api_staging($query, $user_agent, $url, \%credentials);

		#my $url = $app->cache->get('api_di_upload_url');
		#$res = $self->ask_api_di_upload($query, $user_agent, $url, \%credentials);

	} else {
		my $url = $app->cache->get('api_url');
		$res = $self->ask_api_standard($query, $user_agent, $url, \%credentials);
	}

	return $res;
}

# Method for standard queries to the API

sub ask_api_standard {
	my ($self, $query, $ua, $url, $credentials) = @_;

	my $res = $ua->post(
		"$url",
		json => {
			%$query, %$credentials, parameters => { source => 'CLI'}
		}
	)->res;

    CLI::Framework::Exception->throw('API returns bad status')
	unless $res->code;

    $self->check_api_result($res);

    return $res;
}

# Method to create a DI copying the image from the
# staging directory in API server

sub ask_api_staging
{
	my ($self, $query, $ua, $url, $credentials) = @_;

    for my $k (keys %$query)
    {
	my $v = $query->{$k};
		$query->{$k} = ref($v) ? encode_json($v) : $v;
    }

	$url->query(%$query, %$credentials, parameters => '{ "source" :  "CLI" }');

    my $res = {}; 
	my $on_message_cb = sub {

		my ($tx, $msg) = @_;
	     
		$res = $tx->res;
		my $msg_data = decode_json($msg);
		if ($msg_data->{status} eq 1000)
	     {  
			my $total = $msg_data->{total_size} // 0;
			my $partial = $msg_data->{copy_size} // 0;
		 my $percentage = ($partial * 100) / $total;
			#printf STDERR "\r%06.2f%%", $percentage;
		 $tx->send('Ale');
	     }
	     else
	     {
			print STDERR "Upload complete\n";
		 $tx->finish;
		}
	};

	$ua->websocket("$url" =>  sub {
		my ($ua, $tx) = @_;
		$tx->on(message => $on_message_cb);
		$tx->send('Ale');
	} );

    Mojo::IOLoop->start;

    CLI::Framework::Exception->throw('API returns bad status') 
	unless $res->code;

    $self->check_api_result($res);

	return $res;
}

# Method to create a DI uploading the image from local

sub ask_api_di_upload
{
	my ($self, $query, $ua, $url, $credentials) = @_;

    my $file = $query->{arguments}->{disk_image};
    $query->{arguments}->{disk_image} = basename($file);
    $query->{arguments} = encode_json($query->{arguments});
    $query->{parameters} = encode_json({ source => 'CLI' });
    delete $query->{filters};
    delete $query->{fields};
    delete $query->{order_by};
    
    my $res; 
    Mojo::IOLoop->delay(
		sub {
			my $delay = shift;
			$ua->post(
				"$url",
				form => {
					%$query, %$credentials, file => { file => $file }
				},
				$delay->begin
			);
		},
		sub {
			my ($delay,$tx) = @_; $res = $tx->res;
		}
	)->wait;
    
    return $res;
}


sub check_api_result
{
    my ($self,$res) = @_;

    return 1 unless $res->json('/status'); # Successful response

    # All API internal errors are translated to the same generic 
    # message in CLI responde

    my $API_INTERNAL_PROBLEMS_MSG = 'Internal problems in API';
    my %SERVER_INTERNAL_ERRORS = qw(1100 1 4100 1 4110 1 6100 1);

    CLI::Framework::Exception->throw($API_INTERNAL_PROBLEMS_MSG) if 
	$SERVER_INTERNAL_ERRORS{$res->json('/status')};

   # Well typified error messages in API are displayed via console
   # in CLI 

    CLI::Framework::Exception->throw($res->json('/message')) unless 
	$res->json('/status') eq 1200; 

  # For 1200 error in API (That means that one or more of the objects
  # involved in a query couldn't be edited because of some problem):

    my ($message,$failures) = ($res->json('/message') . ":\n",$res->json('/failures'));

    my %seen_msgs;

    while (my ($id,$failure) = each %$failures)
    {
	my $msg = $SERVER_INTERNAL_ERRORS{$failure->{status}} ? 
	    $API_INTERNAL_PROBLEMS_MSG : 
	    $failure->{message};
	next if exists $seen_msgs{$msg};
	$seen_msgs{$msg} = 1;
	$message .= "$msg\n"; 
    } 

    $message =~ s/\n$//;
    CLI::Framework::Exception->throw($message);
}


###################################################
## AUXILIAR METHODS TO CREATE THE JSON API QUERY ##
## FROM THE PARSING QUERY                        ##
###################################################

# Returns the corresponding action in API to the current
# request in CLI
sub get_action
{
    my ($self,$parsing) = @_;
    return eval { 
	$CLI_CMD2API_ACTION->{$parsing->qvd_object}->{$parsing->command} 
    } // CLI::Framework::Exception->throw("No API action available for request"); 
}

# Returns a function that asks the API for the id of an object
sub get_all_ids_action
{
    my ($self,$parsing) = @_;
    return eval { 
	$CLI_CMD2API_ACTION->{$parsing->qvd_object}->{'ids'} 
    } // CLI::Framework::Exception->throw("No API action available for getting related object"); 
}

# Normalizes the filters in a request according the
# info in the class variables of this class. Returns the
# hash of normalized  filters
sub get_filters
{
    my ($self,$parsing) = @_;
    my $filters = $parsing->filters // {};

    for my $k ($parsing->filters->list_filters)
    {
	my $normalized_k = $FILTERS->{$parsing->qvd_object}->{$k} // $k;

	for my $ref_v ($parsing->filters->get_filter_ref_value($k))
	{
	    my $op = $parsing->filters->get_operator($ref_v);
	    my $v = $parsing->filters->get_value($ref_v);
	    $v = $self->get_value($parsing,$k,$v,'filter');

	    $parsing->filters->set_filter($ref_v,$normalized_k, {$op => $v});
	}
    }
    $parsing->filters->hash;
}

# Normalizes the arguments in a request according the
# info in the class variables of this class. Returns the
# hash of normalized arguments
sub get_arguments
{
    my ($self,$parsing) = @_;
    my $arguments = $parsing->arguments // {};
    my $out = {};

    while (my ($k,$v) = each %$arguments)
    {
	my $normalized_k = $ARGUMENTS->{$parsing->qvd_object}->{$k} // $k;
	$v = $self->get_value($parsing,$k,$v,'argument');
	$out->{$normalized_k} = $v;
    }

    $out;
}

# Normalizes the ordering in a request according the
# info in the class variables of this class. Returns the
# hash of normalized ordering
sub get_order
{
    my ($self,$parsing) = @_;

    my $order = $parsing->order // {};
    my $out = [];
    my $criteria = $order->{field} // []; 

    for my $criteria (@$criteria)
    {
	$criteria = eval { $ORDER->{$parsing->qvd_object}->{$criteria} } // $criteria;
	push @$out, $criteria;
    }
    my $direction = $order->{order} // '-asc';

    { order => $direction, field => $out };
}

# It returns the list of fields that must be retrieved by 
# an action
sub get_fields
{
    my ($self,$parsing,$api_res) = @_;

    my $rows = $api_res->json('/rows') // return ();
    my $first = $$rows[0] // return ();
    return qw(id) if $parsing->command eq 'create';
    return qw() unless $parsing->command eq 'get';

    my @asked_fields = @{$parsing->fields} ? 
	@{$parsing->fields}  : @{$DEFAULT_FIELDS->{$parsing->qvd_object}};

    my @retrieved_fields;
    for my $asked_field (@asked_fields)
    {
	my $api_field = eval {
	    $FIELDS->{$parsing->qvd_object}->{$asked_field} 
	} // $asked_field;

	push @retrieved_fields, $asked_field
	    if exists $first->{$api_field};
    } 
    @retrieved_fields;
}

# Normalizes the fields to retrieve in a request according the
# info in the class variables of this class. Returns the
# hash of normalized fields
sub get_fields_for_api
{
    my ($self,$parsing,$api_res) = @_;

    my @asked_fields = @{$parsing->fields};
    for my $asked_field (@asked_fields)
    {
	$asked_field = eval {
	    $FIELDS->{$parsing->qvd_object}->{$asked_field} 
	} // $asked_field;
    } 
    \@asked_fields;
}

# For a certain field retrieved by the API, it may need to be
# normalized or processed before it is displayed. This function gets the
# normalized value of the field, or the callback intended to process it 
# (if any). And returns the normalized value, or the output of that callback 
# for the current field 
sub get_field_value
{
    my ($self,$parsing,$api_res_obj,$cli_field) = @_;

    my $api_field = eval { $FIELDS->{$parsing->qvd_object}->{$cli_field} } // $cli_field;
    my $v = $api_res_obj->{$api_field};

    if (ref($v)) 
    {
	my $cb = eval { $FIELDS_CBS->{$parsing->qvd_object}->{$cli_field} }
	// die "No method available to parse complex field in API output";
	$v = $cb->($v);
    }
    return $v;
}

# This function gets a filter or argument and normalizes it 
# according to a callback intended to normalize it (if any).
# Typically, that normalizations means switch from the name
# of an object provided by the CLI to the corresponding id that
# the API ask for. And that's for related objects (i.e., the user
# or osf of a vm)
sub get_value
{
    my ($self,$parsing,$key,$value,$filter_or_argument) = @_;

    if ( my $cb = eval { $CBS_TO_GET_RELATED_OBJECTS_IDS->{$parsing->qvd_object}->{$filter_or_argument}->{$key}})
    {
	$value = $cb->($self,$value,$self->tenant_scoop);
	CLI::Framework::Exception->throw("Unknown related object $key in filters") unless defined $$value[0];

	if ($filter_or_argument eq 'argument')
	{ 
			CLI::Framework::Exception->throw('Ambiguous reference to object in filters') if
		defined $$value[1];	    
	    $value = shift @$value;
	}
    }
    $value;
}

# Other auxiliar functions

sub tenant_scoop
{
    my ($self,$tenant_scoop) = @_;

    $self->{tenant_scoop} = $tenant_scoop
	if $tenant_scoop;

    unless ($self->{tenant_scoop})
    {
	my $app = $self->get_app;
	$self->{tenant_scoop} = $app->cache->get('tenant_id');
    }

    $self->{tenant_scoop};
}


sub read_password
{
    my $self = shift;
    print STDERR "Password: ";
    ReadMode 'noecho'; 
    my $pass = ReadLine 0; 
    chomp $pass;
    ReadMode 'normal';
    print STDERR "\n";
    $pass;
}


sub _read
{
    my ($self,$msg) = @_;
    print STDERR "$msg: ";
    my $read = <>; 
    chomp $read;
    print STDERR "\r";
    $read;
}


sub superadmin
{
    my $self = shift;
    my $app = $self->get_app;
    $app->cache->get('tenant_id') ? return 1 : return 0;
}

1;
