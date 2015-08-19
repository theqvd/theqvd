package QVD::Admin4::REST::Model;
use strict;
use warnings;
use Moo;
use QVD::Config::Network qw(nettop_n netstart_n net_aton net_ntoa);
use QVD::Config;
use File::Basename qw(basename);
use QVD::DB::Simple qw(db);
use Clone qw(clone);

# This class implements a store with all the info needed about 
# an kind of action requested by the API. Kinds of action are 
# defined by means of two parameters: qvd_object and type of action.

# The class has many class variables with many info about filters, arguments
# order criteria, etc. available for all kinds of actions.

# The constructor of the class, according to the 'qvd_object' and 'type_of_action'
# parameters, takes the correspondant info from those class variables and creates
# a repository in 'model_info', with the info relative to the specific kind of action.

# Many accessor methods let you get that info of the action.

has 'current_qvd_administrator', is => 'ro', isa => 
    sub { die "Invalid type for attribute current_qvd_administrator" 
	      unless ref(+shift) eq 'QVD::DB::Result::Administrator'; }, required => 1;
has 'qvd_object', is => 'ro', isa => sub {die "Invalid type for attribute qvd_object" 
					      if ref(+shift);}, required => 1;
has 'type_of_action', is => 'ro', isa => sub {die "Invalid type for attribute type_of_action" 
						  if ref(+shift);}, required => 1;

has 'model_info', is => 'ro', isa => sub {die "Invalid type for attribute model_info" 
					      unless ref(+shift) eq 'HASH';}, 
    default => sub {{};};


my $DB;

# Mapper from kinds of QVD objects in this class to available values for 
# the 'qvd_object' column in the log table of DB

my $QVD_OBJECTS_TO_LOG_MAPPER = 
{ 
    Log => 'log', User => 'user', VM => 'vm', DI => 'di', OSF => 'osf', Host => 'host', 
    Administrator => 'administrator', Tenant => 'tenant', 
    Role => 'role', Config => 'config', Tenant_Views_Setup => 'tenant_view', 
    Administrator_Views_Setup => 'admin_view', User_Property_List => 'user', VM_Property_List => 'vm',
    Host_Property_List => 'host', OSF_Property_List => 'osf', DI_Property_List => 'di', Property_List => 'property',  
};

# Mapper from kinds of actions in this class to available values for 
# the 'type_of_action' column in the log table of DB

my $TYPES_OF_ACTION_TO_LOG_MAPPER = 
{ 
    list => 'see', details => 'see', tiny => 'see', delete => 'delete', update => 'update', 
    create_or_update => 'create_or_update', exec => 'exec', 
    state => 'see', create => 'create' 
};

# List of QVD objects directly assigned to a tenant.

my $DIRECTLY_TENANT_RELATED = [qw(User Administrator OSF Tenant_Views_Setup)];

# Mappers for identity operators between API and DBIx::Class
# The majority of operators are just the same

my $OPERATORS_MAPPER = 
{
    '~' => 'LIKE'
};

# For every kind of QVD object there must be one filter that 
# identifies the objects unambiguously (typically, the id)

my $UNAMBIGUOUS_FILTERS = 
{   
    list => { Operative_Acls_In_Role => [qw(role_id)],
	      Operative_Acls_In_Administrator => [qw(admin_id)] },

    details => { default => [qw(id)] },

    update => { default => [qw(id)] },

    delete => { default => [qw(id)] },
};


# Some QVD objects have complex info that system provides
# via a secondary request to DB. That secondary request
# uses a view. This var says the views related to the QVD objects

my $RELATED_VIEWS_IN_DB = 
{   
    list => { User => [qw(User_View)],
	      VM => [qw(VM_View)],
	      Host => [qw(Host_View)],
	      OSF => [qw(OSF_View)],
	      DI => [qw(DI_View)],
	      Role => [qw(Role_View)],},

    details => { User => [qw(User_View)],
		 VM => [qw(VM_View)],
		 Host => [qw(Host_View)],
		 OSF => [qw(OSF_View)],
		 DI => [qw(DI_View)],
		 Role => [qw(Role_View)],},		 
};

# Acls needed for using every filter in actions regarding
# a certain QVD object

my $ACLS_FOR_FILTERS = 
{
    VM => { properties => [qr/^vm\.filter\.properties$/], 
	    name => [qr/^vm\.filter\.name$/],
	    user_id => [qr/^vm\.filter\.user|user\.see\.vm-list$/],
	    user_name => [qr/^vm\.filter\.user$/],
	    user => [qr/^vm\.filter\.user$/],
	    osf_id => [qr/^vm\.filter\.osf|osf\.see\.vm-list$/],
	    osf_name => [qr/^vm\.filter\.osf$/],
	    osf => [qr/^vm\.filter\.osf$/],
	    di_id => [qr/^vm\.filter\.di|di\.see\.vm-list$/],
	    state => [qr/^vm\.filter\.state$/],
	    host_id => [qr/^vm\.filter\.host|host\.see\.vm-list$/],
	    host_name => [qr/^vm\.filter\.host$/],
	    host => [qr/^vm\.filter\.host$/]},

    User => { properties => [qr/^user\.filter\.properties$/], 
	      name => [qr/^user\.filter\.name$/]},

    Host => { properties => [qr/^host\.filter\.properties$/],
	      name => [qr/^host\.filter\.name$/],
	      vm_id => [qr/^host\.filter\.vm$/]},

    DI => { properties => [qr/^di\.filter\.properties$/],
	    disk_image => [qr/^di\.filter\.disk-image$/],
	    osf_id => [qr/^di\.filter\.osf|osf\.see\.di-list$/],
	    osf_name => [qr/^di\.filter\.osf$/],
	    osf => [qr/^di\.filter\.osf$/]},

    OSF => { properties => [qr/^osf\.filter\.properties$/],
	     name => [qr/^osf\.filter\.name$/],
	     vm_id => [qr/^osf\.filter\.vm$/],
	     di_id => [qr/^osf\.filter\.di$/]},

    Administrator => { name => [qr/^administrator\.filter\.name$/] },	    

    Role => { name => [qr/^role\.filter\.name$/] },	    

    Tenant => { name => [qr/^tenant\.filter\.name$/] }
};

# Acls needed for using a certain value of filters in actions regarding
# a certain QVD object

my $ACLS_FOR_FILTER_VALUES = 
{
    list => { Log => { qvd_object => { vm => [qr/^vm\.see-main\.$/],
					   user => [qr/^user\.see-main\.$/],
					   osf => [qr/^osf\.see-main\.$/],
					   di => [qr/^di\.see-main\.$/],
					   host => [qr/^host\.see-main\.$/],
					   tenant => [qr/^tenant\.see-main\.$/],
					   administrator => [qr/^administrator\.see-main\.$/], 
					   role => [qr/^role\.see-main\.$/],
					   acl => [qr/^administrator\.see\.acl-list$/],
					   config => [qr/^config\.qvd\.$/],
					   tenant_view => [qr/^views\.see-main\.$/],
					   admin_view => [qr/^views\.see-main\.$/],}}},
};

# Acls needed for retrieving every field in actions regarding
# a certain QVD object

my $ACLS_FOR_FIELDS = 
{
    OSF => { creation_admin_id => [qr/^osf\.see\.created-by$/],
	     creation_admin_name => [qr/^osf\.see\.created-by$/],
	     creation_date => [qr/^osf\.see\.creation-date$/],
	     overlay => [qr/^osf\.see\.overlay$/],
	     user_storage => [qr/^osf\.see\.user-storage$/],
	     memory => [qr/^osf\.see\.memory$/],
	     number_of_vms => [qr/^osf\.see\.vms-info$/],
	     number_of_dis => [qr/^osf\.see\.dis-info$/],
	     properties => [qr/^osf\.see\.properties$/],
	     description => [qr/^osf\.see\.description$/] },

    Role => { roles => [qr/^role\.see\.(acl-list|(acl-list|inherited)-roles)$/],
	      acls => [qr/^role\.see\.acl-list$/],
	      number_of_acls => [qr/^role\.see\.acl-list$/],
	      description => [qr/^role\.see\.description$/] },

    DI => { creation_admin_id => [qr/^di\.see\.created-by$/],
	    creation_admin_name => [qr/^di\.see\.created-by$/],
	    creation_date => [qr/^di\.see\.creation-date$/],
	    version => [qr/^di\.see\.version$/],
	    osf_id => [qr/^di\.see\.osf$/],
	    osf_name => [qr/^di\.see\.osf$/],
	    blocked => [qr/^di\.see\.block$/],
	    tags => [qr/^(di\.see\.|[^.]+\.see\.di-list-)(tags|default|head)$/],
	    properties => [qr/^di\.see\.properties$/],
	    description => [qr/^di\.see\.description$/] },

    VM => { user_id => [qr/^vm\.see\.user$/],
	    user_name => [qr/^vm\.see\.user$/],
	    osf_id => [qr/^vm\.see\.osf$/],
	    osf_name => [qr/^vm\.see\.osf$/],
	    di_tag => [qr/^vm\.see\.di-tag$/],
	    blocked => [qr/^(vm\.see\.|[^.]+\.see\.vm-list-)block$/],
	    expiration_soft => [qr/^(vm\.see\.|[^.]+\.see\.vm-list-)expiration$/],
	    expiration_hard => [qr/^(vm\.see\.|[^.]+\.see\.vm-list-)expiration$/],
	    state => [qr/^(vm\.see\.|[^.]+\.see\.vm-list-)state$/],
	    host_id => [qr/^vm\.see\.host$/],
	    host_name => [qr/^vm\.see\.host$/],
	    di_id => [qr/^vm\.see\.di$/],
	    user_state => [qr/^vm\.see\.user-state$/],
	    ip => [qr/^vm\.see\.ip$/],
	    mac => [qr/^vm\.see\.mac$/],
	    next_boot_ip => [qr/^vm\.see\.next-boot-ip$/],
	    ssh_port => [qr/^vm\.see\.port-ssh$/],
	    vnc_port => [qr/^vm\.see\.port-vnc$/],
	    serial_port => [qr/^vm\.see\.port-serial$/], 
	    creation_admin_id => [qr/^vm\.see\.created-by$/],
	    creation_admin_name => [qr/^vm\.see\.created-by$/],
	    creation_date => [qr/^vm\.see\.creation-date$/],
	    di_version => [qr/^vm\.see\.di-version$/],
	    di_name => [qr/^vm\.see\.di$/],
	    di_id => [qr/^vm\.see\.di$/],
	    properties => [qr/^vm\.see\.properties$/],
	    description => [qr/^vm\.see\.description$/] },
 
    Administrator => { roles => [qr/^administrator\.see\.roles$/],
	              description => [qr/^administrator\.see\.description$/] },

    User => { blocked => [qr/^user\.see\.block$/],
	      creation_admin_id => [qr/^user\.see\.created-by$/],
	      creation_admin_name => [qr/^user\.see\.created-by$/],
	      creation_date => [qr/^user\.see\.creation-date$/],
	      number_of_vms => [qr/^user\.see\.vms-info$/],
	      number_of_vms_connected => [qr/^user\.see\.vm-list-state$/],
	      properties => [qr/^user\.see\.properties$/],
	      description => [qr/^user\.see\.description$/] },

    Host => { address => [qr/^host\.see\.address$/],
	      blocked => [qr/^host\.see\.block$/],
	      state => [qr/^host\.see\.state$/],
	      creation_admin_id => [qr/^host\.see\.created-by$/],
	      creation_admin_name => [qr/^host\.see\.created-by$/],
	      creation_date => [qr/^host\.see\.creation-date$/],
	      number_of_vms_connected => [qr/^host\.see\.vms-info$/],
	      properties => [qr/^host\.see\.properties$/],
	      description => [qr/^host\.see\.description$/] },

    Tenant => { description => [qr/^tenant\.see\.description$/] ,
	      block => [qr/^tenant\.see\.blocksize$/],
	      language => [qr/^tenant\.see\.language$/] }
};

# Acls needed to update every field in actions regarding
# a certain QVD object

my $ACLS_FOR_ARGUMENTS_IN_UPDATE = 
{ 
    User => { password => [qr/^user\.update\.password$/],
	      blocked => [qr/^user\.update\.block$/],
	      description => [qr/^user\.update\.description$/],
	      __properties_changes_set => [qr/^user\.update\.properties-(cre|upd)ate$/],
	      __properties_changes_delete => [qr/^user\.update\.properties-delete$/]},

    VM => { '***start***' => [qr/^vm\.update\.state$/], 
	    '***stop***' => [qr/^(vm\.update\.state|host\.update\.stop-vms)$/],
	    '***disconnect***' => [qr/^vm\.update\.disconnect-user$/], 
	    name => [qr/^vm\.update\.name$/],
	    blocked => [qr/^vm\.update\.block$/],
	    expiration_soft => [qr/^vm\.update\.expiration$/],
	    expiration_hard => [qr/^vm\.update\.expiration$/],
	    di_tag => [qr/^vm\.update\.di-tag$/],
	    description => [qr/^vm\.update\.description$/],
	    __properties_changes__set => [qr/^vm\.update\.properties-(cre|upd)ate$/],
	    __properties_changes__delete => [qr/^vm\.update\.properties-delete$/] },

    Host => { name => [qr/^host\.update\.name$/],
	      address => [qr/^host\.update\.address$/],
	      blocked => [qr/^host\.update\.block$/],
	      description => [qr/^host\.update\.description$/],
	      __properties_changes__set => [qr/^host\.update\.properties-(cre|upd)ate$/],
	      __properties_changes__delete => [qr/^host\.update\.properties-delete$/] },

    OSF => { name => [qr/^osf\.update\.name$/],
	     memory => [qr/^osf\.update\.memory$/],
	     user_storage => [qr/^osf\.update\.user-storage$/],
	     description => [qr/^osf\.update\.description$/],
	     __properties_changes__set => [qr/^osf\.update\.properties-(cre|upd)ate$/],
	     __properties_changes__delete => [qr/^osf\.update\.properties-delete$/] },

    DI => { blocked => [qr/^di\.update\.block$/],
	    description => [qr/^di\.update\.description$/],
	    __properties_changes__set => [qr/^di\.update\.properties-(cre|upd)ate$/],
	    __properties_changes__delete => [qr/^di\.update\.properties-delete$/],
	    __tags_changes__create => [qr/^(di\.update\.(tags|defaults)|osf\.see\.di-list-default-update)$/],
	    __tags_changes__delete => [qr/^(di\.update\.(tags|defaults)|osf\.see\.di-list-default-update)$/]},

    Role => { name => [qr/^role\.update\.name$/],
	      description => [qr/^role\.update\.description$/],
	      __acls_changes__assign_acls => [qr/^role\.update\.assign-acl$/],
	      __acls_changes__unassign_acls => [qr/^role\.update\.assign-acl$/],
	      __roles_changes__assign_roles => [qr/^role\.update\.assign-role$/],
	      __roles_changes__unassign_roles => [qr/^role\.update\.assign-role$/] },

    Administrator => { password => [qr/^administrator\.update\.password$/],
	               description => [qr/^administrator\.update\.description$/],
		       __roles_changes__assign_roles => [qr/^administrator\.update\.assign-role$/],
		       __roles_changes__unassign_roles => [qr/^administrator\.update\.assign-role$/] },

    Tenant => { description => [qr/^tenant\.update\.description$/],
	        block => [qr/^tenant\.update\.blocksize$/],
	        language => [qr/^tenant\.update\.language$/] },

    Tenant_Views_Setup => { visible => [qr/^views\.update\.columns$/] },  
    Operative_Views_In_Tenant => { visible => [qr/^views\.update\.columns$/] },  
    Administrator_Views_Setup => { visible => [qr/^views\.update\.columns$/] },
    Operative_Views_In_Administrator => { visible => [qr/^views\.update\.columns$/] }

};

# Acls needed to perform massive updates for every field in actions regarding
# a certain QVD object

my $ACLS_FOR_ARGUMENTS_IN_MASSIVE_UPDATE = 
{ 
    User => { '***delete***' => [qr/^user\.delete-massive\.$/], # MAYBE A NEW VARIABLE?
	      blocked => [qr/^user\.update-massive\.block$/],
	      description => [qr/^user\.update-massive\.description$/],
	      __properties_changes__set => [qr/^user\.update-massive\.properties-(cre|upd)ate$/],
	      __properties_changes__delete => [qr/^user\.update-massive\.properties-delete$/]},

    VM => { '***delete***' => [qr/^vm\.delete-massive\.$/],
	    '***start***' => [qr/^vm\.update-massive\.state$/], 
	    '***stop***' => [qr/^(vm\.update-massive\.state|host\.update-massive\.stop-vms)$/],
	    '***disconnect***' => [qr/^vm\.update-massive\.disconnect-user$/], 
	    blocked => [qr/^vm\.update-massive\.block$/],
	    expiration_soft => [qr/^vm\.update-massive\.expiration$/],
	    expiration_hard => [qr/^vm\.update-massive\.expiration$/],
	    di_tag => [qr/^vm\.update-massive\.di-tag$/],
	    description => [qr/^vm\.update-massive\.description$/],
	    __properties_changes__set => [qr/^vm\.update-massive\.properties-(cre|upd)ate$/],
	    __properties_changes__delete => [qr/^vm\.update-massive\.properties-delete$/] },

    Host => { '***delete***' => [qr/^host\.delete-massive\.$/],
	      blocked => [qr/^host\.update-massive\.block$/],
	      description => [qr/^host\.update-massive\.description$/],
	      __properties_changes__set => [qr/^host\.update-massive\.properties-(cre|upd)ate$/],
	      __properties_changes__delete => [qr/^host\.update-massive\.properties-delete$/] },
	
    OSF => { '***delete***' => [qr/^osf\.delete-massive\.$/],
	     memory => [qr/^osf\.update-massive\.memory$/],
	     user_storage => [qr/^osf\.update-massive\.user-storage$/],
	     description => [qr/^osf\.update-massive\.description$/],
	     __properties_changes__set => [qr/^osf\.update-massive\.properties-(cre|upd)ate$/],
	     __properties_changes__delete => [qr/^osf\.update-massive\.properties-delete$/] },
	
    DI => { '***delete***' => [qr/^di\.delete-massive\.$/],
	    blocked => [qr/^di\.update-massive\.block$/],
	    description => [qr/^di\.update-massive\.description$/],
	    __properties_changes__set => [qr/^di\.update-massive\.properties-(cre|upd)ate$/],
	    __properties_changes__delete => [qr/^di\.update-massive\.properties-delete$/],
	    __tags_changes__create => [qr/^di\.update-massive\.tags$/],
	    __tags_changes__delete => [qr/^di\.update-massive\.tags-delete$/]},
	
    Tenant => { '***delete***' => [qr/^tenant\.delete-massive\.$/],
	        block => [qr/^tenant\.update-massive\.blocksize$/],
	        description => [qr/^tenant\.update-massive\.description$/],
	        language => [qr/^tenant\.update-massive\.language$/] },

    Role => { '***delete***' => [qr/^role\.delete-massive\.$/],
	      description => [qr/^role\.update-massive\.description$/] },

    Administrator => { '***delete***' => [qr/^administrator\.delete-massive\.$/],
	               description => [qr/^administrator\.update-massive\.description$/] }

};

# Acls needed to set every field in creation for actions regarding
# a certain QVD object

my $ACLS_FOR_ARGUMENTS_IN_CREATION = 
{ 
    User => { __properties__ => [qr/^user\.create\.properties$/]},
    
    VM => { di_tag => [qr/^vm\.create\.di-tag$/],
	    __properties__ => [qr/^vm\.create\.properties$/] },
    
    Host => {__properties__ => [qr/^host\.create\.properties$/] },

    OSF => { memory => [qr/^osf\.create\.memory$/],
	     user_storage => [qr/^osf\.create\.user-storage$/],
	     __properties__ => [qr/^osf\.create\.properties$/]},

    DI => { version => [qr/^di\.create\.version$/],
	    __properties__ => [qr/^di\.create\.properties$/],
	    __tags__ => [qr/^di\.create\.(tags|default)$/]}

};



# Acls needed to execute nested queries 
# NOTE: nested queries are assignations to an object that
#       can be requested inside of create and update actions
#       for that object.

my $NESTED_QUERIES_TO_ADMIN4_MAPPER = 
{ 
    User => { __properties__ => 'custom_properties_set',
	      __properties_changes__set => 'custom_properties_set',
	      __properties_changes__delete => 'custom_properties_del'},
  
    VM => { __properties__ => 'custom_properties_set',
	    __properties_changes__set => 'custom_properties_set',
	    __properties_changes__delete => 'custom_properties_del'},
    
    Host => { __properties__ => 'custom_properties_set',
	      __properties_changes__set => 'custom_properties_set',
	      __properties_changes__delete => 'custom_properties_del' },
  
    OSF => { __properties__ => 'custom_properties_set',
	     __properties_changes__set => 'custom_properties_set',
	     __properties_changes__delete => 'custom_properties_del'},
  
    DI => { __properties__ => 'custom_properties_set',
	    __tags__ => 'tags_create',
	    __properties_changes__set => 'custom_properties_set',
	    __properties_changes__delete => 'custom_properties_del', 
	    __tags_changes__create => 'tags_create',
	    __tags_changes__delete => 'tags_delete'},
    Tenant => {},

    Role => { __acls__ => 'add_acls_to_role',
	      __roles__ => 'add_roles_to_role',
	      __acls_changes__assign_acls  => 'add_acls_to_role',
	      __acls_changes__unassign_acls => 'del_acls_to_role',
	      __roles_changes__assign_roles => 'add_roles_to_role', 
	      __roles_changes__unassign_roles => 'del_roles_to_role'},

    Administrator => { __roles__ => 'add_roles_to_admin',
		       __roles_changes__assign_roles => 'add_roles_to_admin',
		       __roles_changes__unassign_roles => 'del_roles_to_admin' },
    Tenant_Views_Setup => {},
    Operative_Views_In_Tenant => {},
    Administrator_Views_Setup => {},
    Operative_Views_In_Administrator => {},
};

# Available filters for every kind of action

my $AVAILABLE_FILTERS = 
{ 
    list => { default => [],

	      Log => [qw(id admin_id admin_name tenant_id tenant_name action arguments object_id object_name time status source ip type_of_action qvd_object superadmin)],
	      
	      Config => [qw(key value)],
	      
	      VM => [qw(storage id name description user_id user_name osf_id osf_name di_tag blocked 
                        expiration_soft expiration_hard state host host_id host_name di_name di_id 
                        user_state ip next_boot_ip ssh_port vnc_port serial_port tenant tenant_id tenant_name 
                        creation_date creation_admin_id creation_admin_name   ip_in_use di_id_in_use  )],

	      DI_Tag => [qw(osf_id di_id name id tenant_id tenant_name)],

	      User => [qw(id name description blocked creation_date creation_admin_id creation_admin_name tenant_id tenant_name)],

	      Host => [qw(id name description address blocked frontend backend state vm_id creation_date creation_admin_id creation_admin_name)],

	      DI => [qw(id disk_image description version  osf_id osf_name  tenant_id blocked tenant_name tag creation_date creation_admin_id creation_admin_name)],

	      OSF => [qw(id name description overlay user_storage memory vm_id di_id  tenant_id tenant_name creation_date creation_admin_id creation_admin_name)],

	      ACL => [qw(id name role_id admin_id description)],

	      Tenant => [qw(id name description language block creation_date creation_admin_id creation_admin_name)],

	      Role => [qw(name id description fixed internal admin_id inheritor_id tenant_id tenant_name creation_date creation_admin_id creation_admin_name)],

	      Administrator => [qw(name description tenant_id tenant_name id language block creation_date creation_admin_id creation_admin_name)],

	      Tenant_Views_Setup => [qw(id tenant_id tenant_name field visible view_type device_type qvd_object property)],

	      Operative_Acls_In_Role => [qw(acl_name role_id operative name id description)],

	      Operative_Acls_In_Administrator => [qw(acl_name admin_id operative name id description)],

	      Operative_Views_In_Tenant => [qw(tenant_id field visible view_type device_type qvd_object property)],

	      Operative_Views_In_Administrator => [qw(tenant_id field visible view_type device_type qvd_object property)],

	      User_Property_List => [qw(tenant_id)],

	      VM_Property_List => [qw(tenant_id)],

	      Host_Property_List => [qw(tenant_id)],

	      OSF_Property_List => [qw(tenant_id)],

	      DI_Property_List => [qw(tenant_id)],

	      Property_List => [qw(tenant_id)]},


    all_ids => { default => [],

		 Config => [qw(key value)],

		 VM => [qw(storage id name description user_id user_name  osf_id osf_name di_tag blocked expiration_soft 
                           expiration_hard state host_id host_name di_name di_id user_state ip next_boot_ip ssh_port 
                           vnc_port serial_port tenant_id tenant_name  creation_date creation_admin_id creation_admin_name ip_in_use di_id_in_use )],

		 DI_Tag => [qw(osf_id di_id name id tenant_id tenant_name)],

		 User => [qw(id name description blocked creation_date creation_admin_id creation_admin_name tenant_id tenant_name )],

		 Host => [qw(id name description address blocked frontend backend state vm_id creation_date creation_admin_id creation_admin_name)],

		 DI => [qw(id disk_image description version osf osf_id osf_name tenant_id blocked tenant_name tag creation_date creation_admin_id creation_admin_name)],

		 OSF => [qw(id name description overlay user_storage memory vm_id di_id  tenant_id tenant_name creation_date creation_admin_id creation_admin_name)],

		 ACL => [qw(id name description role_id admin_id description )],

		 Role => [qw(name id description fixed internal admin_id inheritor_id tenant_id tenant_name creation_date creation_admin_id creation_admin_name)],

		 Tenant => [qw(id name description language block creation_date creation_admin_id creation_admin_name)],

		 Administrator => [qw(name description tenant_id tenant_name role_id acl_id id role_name acl_name language block creation_date creation_admin_id creation_admin_name)],

		 Tenant_Views_Setup => [qw(id tenant_id tenant_name field visible view_type device_type qvd_object property)],

	         Operative_Acls_In_Role => [qw(acl_name role_id operative id name description)],
			   
	         Operative_Acls_In_Administrator => [qw(acl_name admin_id operative id name description)],

		 Operative_Views_In_Tenant => [qw(tenant_id field visible view_type device_type qvd_object property)],

		 Operative_Views_In_Administrator => [qw(tenant_id field visible view_type device_type qvd_object property)],},

    details => { Config => [qw(key value)], default => [qw(id tenant_id)], Host => [qw(id)], Role => [qw(id)], ACL => [qw(id)], Tenant => [qw(id)] },
		
    tiny => { default => [qw(tenant_id)], Host => [qw()], Role => [qw(internal fixed tenant_id)], ACL => [qw(name)], Tenant => [qw(id)], DI_Tag => [qw(tenant_id osf_id)]},

    delete => { default => [qw(id tenant_id)], Config => [qw(key value)], Host => [qw(id)], Role => [qw(id)],Tenant => [qw(id)],
                Tenant_Views_Setup => [qw(tenant_id qvd_object)],
                Administrator_Views_Setup => [qw(qvd_object)]}, # Every admin is able to delete just its own views, so you cannot filter by admin or id. Suitable admin_id forzed in Request.pm

    update => { default => [qw(id tenant_id)],Config => [qw(key value)],Host => [qw(id)],Role => [qw(id)],Tenant => [qw(id)]},

    create_or_update => { Tenant_Views_Setup => [qw(tenant_id)]},

    exec => { default => [qw(id tenant_id user_id host_id)]},

    state => { default => [qw(id tenant_id)], Host => [qw(id)], ACL => [qw(id)], Role => [qw(id)], Tenant => [qw(id)]},
};

# Available fields to retrieve for every kind of action

my $AVAILABLE_FIELDS = 
{ 
    list => { default => [],

	      Log => [qw(id admin_id admin_name tenant_id tenant_name action arguments object_id object_name time antiquity status source ip type_of_action qvd_object object_deleted admin_deleted superadmin)],

	      Config => [qw(key value)],

	      OSF => [qw(id name description overlay user_storage memory  number_of_vms number_of_dis properties creation_date creation_admin_id creation_admin_name)],

	      Role => [qw(name id description fixed internal acls roles creation_date creation_admin_id creation_admin_name)],

	      DI => [qw(id disk_image description version osf_id osf_name blocked tags  properties creation_date creation_admin_id creation_admin_name)],

	      VM => [qw(storage id name description user_id user_name osf_id osf_name di_tag blocked expiration_soft expiration_hard 
                        state host_id host_name  di_id user_state ip mac next_boot_ip ssh_port vnc_port serial_port 
                        creation_date creation_admin_id creation_admin_name di_version di_name di_id properties ip_in_use di_id_in_use di_name_in_use di_version_in_use )],

	      ACL => [qw(id name description)],

	      Administrator => [qw(name description roles id language block creation_date creation_admin_id creation_admin_name)],

	      Tenant => [qw(id name description language block creation_date creation_admin_id creation_admin_name)],
				   
	      User => [qw(id name description blocked creation_date creation_admin_id creation_admin_name number_of_vms number_of_vms_connected  properties )],

	      Host => [qw(id name description address blocked frontend backend state  load creation_date creation_admin_id creation_admin_name number_of_vms_connected properties )],

	      DI_Tag => [qw(osf_id di_id name id )],

	      Tenant_Views_Setup => [qw(id tenant_id tenant_name field visible view_type device_type qvd_object property)],

	      Operative_Acls_In_Role => [qw(id name roles operative description)],

	      Operative_Acls_In_Administrator => [qw(id name roles operative description)],

	      Operative_Views_In_Tenant => [qw(tenant_id field visible view_type device_type qvd_object property)],

	      Administrator_Views_Setup => [qw(id tenant_id tenant_name admin_id admin_name field visible view_type 
                                               device_type qvd_object property)],
	      Operative_Views_In_Administrator => [qw(tenant_id field visible view_type device_type qvd_object property)],

	      User_Property_List => [qw(property_id key description)],

	      VM_Property_List => [qw(property_id key description)],

	      Host_Property_List => [qw(property_id key description)],

	      OSF_Property_List => [qw(property_id key description)],

	      DI_Property_List => [qw(property_id key description)],

	      Property_List => [qw(id property_id key description in_user in_vm in_host in_osf in_di)] },

    details => { default => [],

		 Log => [qw(id admin_id admin_name tenant_id tenant_name action arguments object_id object_name time antiquity status source ip type_of_action qvd_object object_deleted admin_deleted superadmin)],
		 Config => [qw(key value)],

		 OSF => [qw(id name description overlay user_storage memory  number_of_vms number_of_dis properties creation_date creation_admin_id creation_admin_name)],
		 
		 Role => [qw(name description id fixed internal acls roles creation_date creation_admin_id creation_admin_name)],
		
		 DI => [qw(id disk_image description version osf_id osf_name  blocked tags  properties creation_date creation_admin_id creation_admin_name)],
		
		 VM => [qw(storage id name description user_id user_name osf_id osf_name di_tag blocked expiration_soft expiration_hard 
                           time_until_expiration_soft time_until_expiration_hard state host_id host_name  di_id user_state ip mac next_boot_ip ssh_port vnc_port serial_port 
                           creation_date creation_admin_id creation_admin_name di_version di_name di_id properties ip_in_use di_id_in_use di_name_in_use di_version_in_use )],

		 ACL => [qw(id name description)],

		 Administrator => [qw(name description roles id language block creation_date creation_admin_id creation_admin_name)],

		 Tenant => [qw(id name description language block creation_date creation_admin_id creation_admin_name)],

		 User => [qw(id name description blocked  creation_date creation_admin_id creation_admin_name number_of_vms number_of_vms_connected  properties )],

		 Host => [qw(id name description address blocked frontend backend state  load creation_admin_id creation_admin_name creation_date 
                             number_of_vms_connected properties )],

		 DI_Tag => [qw(di_id osf_id name id )],

		 Tenant_Views_Setup => [qw(id tenant_id tenant_name field visible view_type device_type qvd_object property)],

        	 Operative_Acls_In_Role => [qw(id name roles operative description)],

	         Operative_Acls_In_Administrator => [qw(id name roles operative description)],

		 Operative_Views_In_Tenant => [qw(tenant_id field visible view_type device_type qvd_object property)],

		 Administrator_Views_Setup => [qw(id admin_id admin_name tenant_id tenant_name field visible view_type 
                                                  device_type qvd_object property)],
		 Operative_Views_In_Administrators => [qw(tenant_id field visible view_type device_type qvd_object property)], },

    tiny => { default => [qw(id name)],

	      DI => [qw(id disk_image)],

	      Tenant_Views_Setup => [qw(id)],

	      Administrator_Views_Setup => [qw(id)]},

    all_ids => { default => [qw(id)]},

    state => { User => [qw(number_of_vms_connected)],
	       
	       VM => [qw(state user_state)],
	       
	       Host => [qw(number_of_vms_connected)]},
    
    create => { 'default' => [qw(id)], Config => [qw(key)]},

    create_or_update => { 'default' => [qw(id)], 'Config' => [qw(key)] }

};

# Mandatory filters to execute every kind of action

my $MANDATORY_FILTERS = 
{ 
    list => { default => [qw()],  
              Operative_Acls_In_Role => [qw(role_id)], 
	      Operative_Acls_In_Administrator => [qw()]}, # FIX ME. HAS DEFAULT VALUE IN Request.pm. DEFAULT SYSTEM FOR FILTERS NEEDED

    details => { default => [qw(id)], 
		 Operative_Acls_In_Role => [qw(role_id)], 
		 Operative_Acls_In_Administrator => [qw()]}, # FIX ME. HAS DEFAULT VALUE IN Request.pm. DEFAULT SYSTEM FOR FILTERS NEEDED

    tiny => { default => [qw()]},

    delete => { default => [qw(id)], Config => [qw(key)], Administrator_Views_Setup => [qw()], Tenant_Views_Setup => [qw()]},

    update=> { default => [qw(id)], Config => [qw(key)]}, 

    exec => { default => [qw()]}, 

    state => { default => [qw(id)]}, 

    all_ids => { default => [qw()],
		 Operative_Acls_In_Role => [qw(role_id)], 
		 Operative_Acls_In_Administrator => [qw()]}, # FIX ME. HAS DEFAULT VALUE IN Request.pm. DEFAULT SYSTEM FOR FILTERS NEEDED
};

# Default order criteria for every kind of action

my $DEFAULT_ORDER_CRITERIA = 
{ 
    tiny => { default =>  [qw(name)],
	      DI => [qw(disk_image)],
	      Tenant_Views_Setup => [qw(field)],
	      Administrator_Views_Setup => [qw(field)],
              Config => [qw(key)] },

    list => { default =>  [qw()],
	      Tenant_Views_Setup => [qw(field)],
	      Operative_Views_In_Tenant => [qw(field)],
	      Administrator_Views_Setup => [qw(field)],
	      Operative_Views_In_Administrator => [qw(field)],
              Config => [qw(key)] }

};


# Available nested queries for every type of action
# NOTE: nested queries are assignations to an object that
#       can be requested inside of create and update actions
#       for that object.

my $AVAILABLE_NESTED_QUERIES = 
{ 
    create => { User => [qw(__properties__)],
		VM => [qw(__properties__)],
		Host => [qw(__properties__)],
		OSF => [qw(__properties__)],
		DI => [qw(__properties__ __tags__)],
		Tenant => [qw()],
		Role => [qw(__acls__ __roles__)],
		Administrator => [qw(__roles__)],
		Tenant_Views_Setup => [qw()],
		Operative_Views_In_Tenant => [qw()],
		Administrator_Views_Setup => [qw()],
		Operative_Views_In_Administrator => [qw()]},

    update => { User => [qw(__properties_changes__set __properties_changes__delete)],
		VM => [qw(__properties_changes__set __properties_changes__delete)],
		Host => [qw(__properties_changes__set __properties_changes__delete)],
		OSF => [qw(__properties_changes__set __properties_changes__delete)],
		DI => [qw(__properties_changes__set __properties_changes__delete 
                          __tags_changes__create __tags_changes__delete)],
	        Tenant => [qw()],
		Role => [qw(__acls_changes__assign_acls 
                            __acls_changes__unassign_acls
			    __roles_changes__assign_roles 
                            __roles_changes__unassign_roles)],
		Administrator => [qw(__roles_changes__assign_roles __roles_changes__unassign_roles)],
		Tenant_Views_Setup => [qw()],
		Operative_Views_In_Tenant => [qw()],
		Administrator_Views_Setup => [qw()],
		Operative_Views_In_Administrator => [qw()]}
};

# Available arguments for update actions

my $AVAILABLE_ARGUMENTS = { Config => [qw(value)],
			    User => [qw(name password blocked description)],
                            VM => [qw(name ip blocked expiration_soft expiration_hard storage di_tag description ***start*** ***stop*** ***disconnect***)],
                            Host => [qw(name address blocked description)],
                            OSF => [qw(name memory user_storage overlay description)],
                            DI => [qw(blocked disk_image description)],
			    Tenant => [qw(name language block description)],
			    Role => [qw(name description)],
			    Administrator => [qw(name password language block description)],
			    Tenant_Views_Setup => [qw(visible)],
			    Administrator_Views_Setup => [qw(visible)],
	      		    Property_List => [qw(key description)] };

# Available arguments for creation actions

my $MANDATORY_ARGUMENTS = { Config => [qw(key value)],
			    User => [qw(tenant_id name password blocked description)],
			    VM => [qw(name user_id ip osf_id di_tag state user_state blocked description)],
			    Host => [qw(name address frontend backend blocked state description)],
			    OSF => [qw(tenant_id name memory overlay user_storage description)],
                            DI => [qw(version disk_image osf_id blocked description)],
			    Tenant => [qw(name language block description)],
			    Role => [qw(tenant_id name fixed internal description)],
                            Administrator => [qw(tenant_id name password language block description)],
			    Tenant_Views_Setup => [qw(tenant_id field visible view_type device_type qvd_object property)],
			    Administrator_Views_Setup => [qw(field visible view_type device_type qvd_object property)], # Every admin is able to set just its own views, 
                                                                                                                         # Suitable admin_id forzed in Request.pm
	      		    User_Property_List => [qw(property_id)],
	      		    VM_Property_List => [qw(property_id)],
	      		    Host_Property_List => [qw(property_id)],
	      		    OSF_Property_List => [qw(property_id)],
	      		    DI_Property_List => [qw(property_id)],
	      		    Property_List => [qw(tenant_id key)] };

# Default values for some mandatory arguments in creation

my $DEFAULT_ARGUMENT_VALUES = 
{
    User => { blocked => 'false' },

    VM => { di_tag => 'default',
	    blocked => 'false',
	    user_state => 'disconnected',
	    state => 'stopped',
	    ip => \&get_free_ip},

    Host => { backend => 'true',
	      frontend => 'true',
	      blocked => 'false',
	      state => 'stopped'},

    OSF => { memory => \&get_default_memory,
	     overlay => \&get_default_overlay,
	     user_storage => 0 },

    DI => { blocked => 'false', version => \&get_default_di_version },

    Role => { fixed => 'false', internal => 'false' },

    Tenant => { language => 'auto',block => '10'},

    Administrator => { language => 'auto',block => '10'},

    Tenant_Views_Setup => { visible => 0, property => 0 },

    Administrator_Views_Setup =>  { visible => 0, property => 0 }
};


# This will be  VM->mac value in $FILTERS_TO_DBIX_FORMAT_MAPPER
# cfg('vm.network.mac.prefix') should be refreshed, but it's not
# relevant for ordering purposes

my $ip2mac = "ip2mac(me.ip,'".cfg('vm.network.mac.prefix')."')";

# Mapper that changes filters from API format to DBIx::Class format
# the 'me' preffix depicts the main table in DB, other prefixes
# depict related tables to that one. The element after the prefix 
# depicts the column of the table.

my $FILTERS_TO_DBIX_FORMAT_MAPPER = 
{
    Log => { 
	id => 'me.id',
	admin_id => 'me.administrator_id',
	admin_name => 'me.administrator_name',
	tenant_id => 'me.tenant_id',
	tenant_name => 'me.tenant_name',
	action => 'me.action',
	arguments => 'me.arguments',
	object_id => 'me.object_id',
	object_name => 'me.object_name',
	time => 'me.time',
	status => 'me.status',
	source => 'me.source',
	ip => 'me.ip',
	type_of_action => 'me.type_of_action',
	qvd_object => 'me.qvd_object',
	superadmin => 'me.superadmin'
    },

    Config => {
	'key' => 'me.key',
	'value' => 'me.value'
    },

    ACL => {
	'id' => 'me.id',
	'name' => 'me.name',
	'role_id' => 'role.id',
	'admin_id' => 'admin.id',
	'description' => 'me.description',
    },

    DI_Tag => {
	'osf_id' => 'di.osf_id',
	'di_id' => 'me.di_id',
	'name' => 'me.tag',
	'tenant_id' => 'tenant.id',
	'tenant_name' => 'tenant.name',
	'id' => 'me.id',
    },
    
    Administrator => {
	'name' => 'me.name',
	'language' => 'wat_setups.language',
	'block' => 'wat_setups.block',
	'password' => 'me.password',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'role_id' => 'role.id',
	'acl_id' => 'acl.id',
	'role_name' => 'role.name',
	'acl_name' => 'acl.name',
	'id' => 'me.id',
	'description' => 'me.description',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    OSF => {
	'id' => 'me.id',
	'name' => 'me.name',
	'overlay' => 'me.use_overlay',
	'user_storage' => 'me.user_storage_size',
	'memory' => 'me.memory',
	'vm_id' => 'vms.id',
	'di_id' => 'dis.id',
	'description' => 'me.description',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    Host => {
	'id' => 'me.id',
	'name' => 'me.name',
	'address' => 'me.address',
	'blocked' => 'runtime.blocked',
	'frontend' => 'me.frontend',
	'backend' => 'me.backend',
	'description' => 'me.description',
	'state' => 'runtime.state',
	'vm_id' => 'vms.vm_id',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    DI => {
	'id' => 'me.id',
	'disk_image' => 'me.path',
	'version' => 'me.version',
	'osf_id' => 'me.osf_id',
	'osf_name' => 'osf.name',
	'tag' => 'tags.tag',
	'tenant_id' => 'osf.tenant_id',
	'blocked' => 'me.blocked',
	'description' => 'me.description',
	'tenant_name' => 'tenant.name',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },
    User => {
	'id' => 'me.id',
	'name' => 'me.login',
	'description' => 'me.description',
	'password' => 'me.password',
	'blocked' => 'me.blocked',
	'description' => 'me.description',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    VM => {
	'storage' => 'me.storage',
	'id' => 'me.id',
	'name' => 'me.name',
	'user_id' => 'me.user_id',
	'user_name' => 'user.login',
	'osf_id' => 'me.osf_id',
	'osf_name' => 'osf.name',
	'di_tag' => 'me.di_tag',
	'description' => 'me.description',
	'blocked' => 'vm_runtime.blocked',
	'expiration_soft' => 'vm_runtime.vm_expiration_soft',
	'expiration_hard' => 'vm_runtime.vm_expiration_hard',
	'state' => 'vm_runtime.vm_state',
	'host_id' => 'vm_runtime.host_id',
	'host_name' => 'host.name',
	'di_id' => 'di.id',
	'di_version' => 'di.version',
	'di_name' => 'di.path',
	'user_state' => 'vm_runtime.user_state',
	'ip' => 'me.ip',
	'mac' => \$ip2mac, # Only useful for ordering. Refs are not allowed as filter keys by dbic. mac must be forbidden in available_filtes
	'next_boot_ip' => 'vm_runtime.vm_address',
	'ssh_port' => 'vm_runtime.vm_ssh_port',
	'vnc_port' => 'vm_runtime.vm_vnc_port',
	'serial_port' => 'vm_runtime.vm_serial_port',
	'tenant_id' => 'user.tenant_id',
	'tenant_name' => 'tenant.name',
	'ip_in_use' => 'vm_runtime.vm_address',
	'di_id_in_use' => 'vm_runtime.current_di_id',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    Role => {
	'name' => 'me.name',
	'fixed' => 'me.fixed',
	'internal' => 'me.internal',
	'id' => 'me.id',
	'description' => 'me.description',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'admin_id' => 'admin_rels.administrator_id',
	'inheritor_id' => 'parent_role_rels.inheritor_id',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    Tenant => {
	'name' => 'me.name',
	'id' => 'me.id',
	'description' => 'me.description',
	'language' => 'wat_setups.language',
	'block' => 'wat_setups.block',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },
    
    Tenant_Views_Setup => { 	
	'id' => 'me.id', 
	'tenant_id' => 'me.tenant_id', 
	'field' => 'me.field', 
	'tenant_name' => 'tenant.name', 
	'visible' => 'me.visible',
	'view_type' => 'me.view_type',
	'device_type' => 'me.device_type',
	'qvd_object' => 'me.qvd_object',
	'property' => 'me.property'
    },
    
    Operative_Acls_In_Role => { 
	'acl_name' => 'me.acl_name',
	'id' => 'me.acl_id',
	'name' => 'me.acl_name',
        'role_id' =>  'me.role_id',
	'operative' => 'me.operative',
	'description' => 'me.acl_description',
    },

    Operative_Acls_In_Administrator => { 
	'acl_name' => 'me.acl_name',
	'name' => 'me.acl_name',
	'id' => 'me.acl_id',
        'admin_id' =>  'me.admin_id',
	'operative' => 'me.operative',
	'description' => 'me.acl_description',
    },

    Operative_Views_In_Tenant => { 	
	'tenant_id' => 'me.tenant_id', 
	'field' => 'me.field', 
	'visible' => 'me.visible',
	'view_type' => 'me.view_type',
	'device_type' => 'me.device_type',
	'qvd_object' => 'me.qvd_object',
	'property' => 'me.property'
    },

    Administrator_Views_Setup =>  {
	'id' => 'me.id',  
	'tenant_id' => 'tenant.id', 
	'tenant_name' => 'tenant.name', 
	'admin_id' => 'me.administrator_id', 
	'field' => 'me.field', 
	'admin_name' => 'administrator.name', 
	'visible' => 'me.visible',
	'view_type' => 'me.view_type',
	'device_type' => 'me.device_type',
	'qvd_object' => 'me.qvd_object',
	'property' => 'me.property' 
 },

    Operative_Views_In_Administrator => { 	
	'tenant_id' => 'me.tenant_id', 
	'field' => 'me.field', 
	'visible' => 'me.visible',
	'view_type' => 'me.view_type',
	'device_type' => 'me.device_type',
	'qvd_object' => 'me.qvd_object',
	'property' => 'me.property'
    },

    User_Property_List => {
    	'id' => 'me.property_id',
    	'property_id' => 'me.property_id',
	'tenant_id' => 'properties_list.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'description' => 'me.description',
	'key' => 'properties_list.key'
    },

    VM_Property_List => {
    	'id' => 'me.property_id',
    	'property_id' => 'me.property_id',
	'tenant_id' => 'properties_list.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'description' => 'me.description',
	'key' => 'properties_list.key'
    },

    Host_Property_List => {
    	'id' => 'me.property_id',
    	'property_id' => 'me.property_id',
	'tenant_id' => 'properties_list.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'description' => 'me.description',
	'key' => 'properties_list.key'
    },

    OSF_Property_List => {
    	'id' => 'me.property_id',
    	'property_id' => 'me.property_id',
	'tenant_id' => 'properties_list.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'description' => 'me.description',
	'key' => 'properties_list.key'
    },

    DI_Property_List => {
    	'id' => 'me.property_id',
    	'property_id' => 'me.property_id',
	'tenant_id' => 'properties_list.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'description' => 'me.description',
	'key' => 'properties_list.key'
    },

    Property_List => {
    	'id' => 'me.id',
    	'property_id' => 'me.id',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'key' => 'me.key',
	'description' => 'me.description',
	'in_user' => 'me.in_user',
	'in_vm' => 'me.in_vm',
	'in_host' => 'me.in_host',
	'in_osf' => 'me.in_osf',
	'in_di' => 'me.in_di'
    },
};

# Nowadays the mapper for arguments and order criteria
# is equal to the mapper for filters. That's for
# simplicity reasons, but it maybe shoult be changed

my $ARGUMENTS_TO_DBIX_FORMAT_MAPPER = 
    $FILTERS_TO_DBIX_FORMAT_MAPPER;

my $ORDER_CRITERIA_TO_DBIX_FORMAT_MAPPER = 
    $FILTERS_TO_DBIX_FORMAT_MAPPER;


# Mapper that changes fields to retrieve from API format to DBIx::Class format
# the 'me' preffix depicts the main table in DB, other prefixes
# depict related tables to that one. The element after the prefix 
# depicts the column of the table.

# The special prefic 'view' means that the field must be taken
# from a related view (See $RELATED_VIEWS_IN_DB).

my $FIELDS_TO_DBIX_FORMAT_MAPPER = 
{
    Log => { 
	id => 'me.id',
	admin_id => 'me.administrator_id',
	admin_name => 'me.administrator_name',
	tenant_id => 'me.tenant_id',
	tenant_name => 'me.tenant_name',
	action => 'me.action',
	arguments => 'me.arguments',
	object_id => 'me.object_id',
	object_name => 'me.object_name',
	time => 'me.time',
	antiquity => 'me.antiquity',
	status => 'me.status',
	source => 'me.source',
	ip => 'me.ip',
	type_of_action => 'me.type_of_action',
	qvd_object => 'me.qvd_object',
	object_deleted => 'me.object_deleted',
	admin_deleted => 'me.administrator_deleted',
    	superadmin => 'me.superadmin',
    },

    Config => {
	'key' => 'me.key',
	'value' => 'me.value'
    },

    ACL => {
	'id' => 'me.id',
	'name' => 'me.name',
	'description' => 'me.description',
    },

    Host => {
	'id' => 'me.id',
	'name' => 'me.name',
	'description' => 'me.description',
	'address' => 'me.address',
	'blocked' => 'runtime.blocked',
	'frontend' => 'me.frontend',
	'backend' => 'me.backend',
	'state' => 'runtime.state',
	'load' => 'me.load',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
	'number_of_vms_connected' => 'view.number_of_vms_connected',
	'properties' => 'view.properties',
    },

    Role => {
	'name' => 'me.name',
	'description' => 'me.description',
	'fixed' => 'me.fixed',
	'internal' => 'me.internal',
	'id' => 'me.id',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'acls' => 'view.acls',
	'roles' => 'view.roles',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    User => {
	'id' => 'me.id',
	'name' => 'me.login',
	'description' => 'me.description',
	'password' => 'me.password',
	'blocked' => 'me.blocked',
	'number_of_vms' => 'view.number_of_vms',
	'number_of_vms_connected' => 'view.number_of_vms_connected',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'properties' => 'view.properties',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    DI_Tag => {
	'osf_id' => 'di.osf_id',
	'di_id' => 'me.di_id',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'name' => 'me.tag',
	'id' => 'me.id',
    },

    OSF => {
	'id' => 'me.id',
	'name' => 'me.name',
	'description' => 'me.description',
	'overlay' => 'me.use_overlay',
	'user_storage' => 'me.user_storage_size',
	'memory' => 'me.memory',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'number_of_vms' => 'view.number_of_vms',
	'number_of_dis' => 'view.number_of_dis',
	'properties' => 'view.properties',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    VM => {
	'storage' => 'me.storage',
	'id' => 'me.id',
	'name' => 'me.name',
	'description' => 'me.description',
	'user_id' => 'me.user_id',
	'user_name' => 'user.login',
	'osf_id' => 'me.osf_id',
	'osf_name' => 'osf.name',
	'di_tag' => 'me.di_tag',
	'blocked' => 'vm_runtime.blocked',
	'expiration_soft' => 'vm_runtime.vm_expiration_soft',
	'expiration_hard' => 'vm_runtime.vm_expiration_hard',
	'time_until_expiration_soft' => 'me.remaining_time_until_expiration_soft',
	'time_until_expiration_hard' => 'me.remaining_time_until_expiration_hard',
	'state' => 'vm_runtime.vm_state',
	'host_id' => 'vm_runtime.host_id',
	'host_name' => 'me.host_name',
	'di_id' => 'di.id',
	'user_state' => 'vm_runtime.user_state',
	'ip' => 'me.ip',
	'mac' => 'me.vm_mac',
	'ip_in_use' => 'vm_runtime.vm_address',
	'next_boot_ip' => 'vm_runtime.vm_address',
	'ssh_port' => 'vm_runtime.vm_ssh_port',
	'vnc_port' => 'vm_runtime.vm_vnc_port',
	'serial_port' => 'vm_runtime.vm_serial_port',
	'tenant_id' => 'user.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'di_version' => 'di.version',
	'di_name' => 'di.path',
	'di_id' => 'di.id',
	'di_id_in_use' => 'vm_runtime.current_di_id',
	'di_name_in_use' => 'vm_runtime.current_di_name',
	'di_version_in_use' => 'vm_runtime.current_di_version',
	'properties' => 'view.properties',
    	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    DI => {
	'id' => 'me.id',
	'disk_image' => 'me.path',
	'description' => 'me.description',
	'version' => 'me.version',
	'osf_id' => 'me.osf_id',
	'osf_name' => 'osf.name',
	'tenant_id' => 'osf.tenant_id',
	'blocked' => 'me.blocked',
	'tags' => 'view.tags',
	'tenant_name' => 'osf.tenant_name',
	'properties' => 'view.properties',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    Administrator => {
	'name' => 'me.name',
	'description' => 'me.description',
	'language' => 'wat_setups.language',
	'block' => 'wat_setups.block',
	'password' => 'me.password',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'roles' => 'me.get_roles_info',
	'id' => 'me.id',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },
    Tenant => {
	'name' => 'me.name',
	'description' => 'me.description',
	'id' => 'me.id',
	'language' => 'wat_setups.language',
	'block' => 'wat_setups.block',
	'creation_date' => 'creation_log_entry.time',
	'creation_admin_id' => 'creation_log_entry.administrator_id',
	'creation_admin_name' => 'creation_log_entry.administrator_name',
    },

    Tenant_Views_Setup => { 	
	'id' => 'me.id', 
	'tenant_id' => 'me.tenant_id', 
	'field' => 'me.field', 
	'tenant_name' => 'tenant.name', 
	'visible' => 'me.visible',
	'view_type' => 'me.view_type',
	'device_type' => 'me.device_type',
	'qvd_object' => 'me.qvd_object',
	'property' => 'me.property'  
    },

    Operative_Views_In_Tenant => { 	
	'tenant_id' => 'me.tenant_id', 
	'field' => 'me.field', 
	'visible' => 'me.visible',
	'view_type' => 'me.view_type',
	'device_type' => 'me.device_type',
	'qvd_object' => 'me.qvd_object',
	'property' => 'me.property'  
    },

    Administrator_Views_Setup =>  {
	'id' => 'me.id',  
	'tenant_id' => 'administrator.tenant_id', 
	'tenant_name' => 'administrator.tenant_name', 
	'admin_id' => 'me.administrator_id', 
	'field' => 'me.field', 
	'admin_name' => 'administrator.name',
	'visible' => 'me.visible',
	'view_type' => 'me.view_type',
	'device_type' => 'me.device_type',
	'qvd_object' => 'me.qvd_object',
	'property' => 'me.property'  
 },

    Operative_Views_In_Administrator => { 	
	'tenant_id' => 'me.tenant_id', 
	'field' => 'me.field', 
	'visible' => 'me.visible',
	'view_type' => 'me.view_type',
	'device_type' => 'me.device_type',
	'qvd_object' => 'me.qvd_object',
	'property' => 'me.property'  
    },

    Operative_Acls_In_Role => { 
	'name' => 'me.acl_name',
        'id' =>  'me.acl_id',
        'roles' =>  'me.roles',
	'operative' => 'me.operative',
	'description' => 'me.acl_description',
    },

    Operative_Acls_In_Administrator => { 
	'name' => 'me.acl_name',
        'id' =>  'me.acl_id',
        'roles' =>  'me.roles',
	'operative' => 'me.operative',
	'description' => 'me.acl_description',
    },

    User_Property_List => {
    	'id' => 'me.property_id',
    	'property_id' => 'me.property_id',
	'tenant_id' => 'properties_list.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'description' => 'me.description',
	'key' => 'properties_list.key'
    },

    VM_Property_List => {
    	'id' => 'me.property_id',
    	'property_id' => 'me.property_id',
	'tenant_id' => 'properties_list.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'description' => 'me.description',
	'key' => 'properties_list.key'
    },

    Host_Property_List => {
    	'id' => 'me.property_id',
    	'property_id' => 'me.property_id',
	'tenant_id' => 'properties_list.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'description' => 'me.description',
	'key' => 'properties_list.key'
    },

    OSF_Property_List => {
    	'id' => 'me.property_id',
    	'id' => 'me.property_id',
    	'property_id' => 'me.property_id',
	'tenant_id' => 'properties_list.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'description' => 'me.description',
	'key' => 'properties_list.key'
    },

    DI_Property_List => {
    	'id' => 'me.property_id',
    	'property_id' => 'me.property_id',
	'tenant_id' => 'properties_list.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'description' => 'me.description',
	'key' => 'properties_list.key'
    },

    Property_List => {
    	'id' => 'me.property_id',
    	'property_id' => 'me.id',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'key' => 'me.key',
	'description' => 'me.description',
	'in_user' => 'me.in_user',
	'in_vm' => 'me.in_vm',
	'in_host' => 'me.in_host',
	'in_osf' => 'me.in_osf',
	'in_di' => 'me.in_di'
    },
};

# This var stores functions intended to 
# normalize tha value provided to API 
# for several filters/arguments/etc.
# that need it.  

my $VALUES_NORMALIZATOR = 
{ 
    DI => { disk_image => \&basename_disk_image},

    User => { name => \&normalize_name, 
	      password => \&password_to_token },

    Administrator => { name => \&normalize_name,
		       password => \&password_to_token },

    Tenant => { name => \&normalize_name }
};

# Joins of related tables needed in
# actions regarding every QVD object

my $DBIX_JOIN_VALUE = 
{ 
    Log => [qw(deletion_log_entry administrator)],

    User => [qw(tenant creation_log_entry)],
 
    VM => ['di', 'osf', { vm_runtime => qw(host) }, { user => 'tenant' }, qw(creation_log_entry) ],
  
    Host => ['runtime', 'vms', qw(creation_log_entry)],

    OSF => [ qw(tenant vms), { dis => 'tags' }, qw(creation_log_entry)],

    DI => [qw(vm_runtimes tags), {osf => 'tenant'}, qw(creation_log_entry)],

    DI_Tag => [{di => {osf => 'tenant'}}],

    Role => [ 'admin_rels', {role_rels => 'inherited'}, {parent_role_rels => 'inheritor'}, { acl_rels => 'acl'}, qw(tenant creation_log_entry)],
		
    Administrator => [qw(tenant wat_setups), { role_rels => { role => { acl_rels => 'acl' }}}, qw(creation_log_entry)],

    Tenant => [qw(wat_setups creation_log_entry)],
    
    ACL => [{ role_rels => { role => { admin_rels => 'admin' }}}],
    
    Tenant_Views_Setup => [ qw(tenant)],

    Administrator_Views_Setup => [ { administrator => 'tenant' }],

    User_Property_List => [ {properties_list => 'tenant'}],

    VM_Property_List => [ {properties_list => 'tenant'}],

    Host_Property_List => [ {properties_list => 'tenant'}],

    OSF_Property_List => [ {properties_list => 'tenant'}],

    DI_Property_List => [ {properties_list => 'tenant'}],

    Property_List => [ 'tenant'],
};


# Tables that must be prefetched (via the prefetch feature of DBIC).
# These are tables joined to the main table whose content must
# be feteched direclty in the first request to DB. Otherwise
# the info of those tables must be accesed by means of multiple requests
# That's all for performance.


my $DBIX_PREFETCH_VALUE = 
{ 
    list => { Log => [qw(deletion_log_entry administrator)],
	      Role => [qw(tenant creation_log_entry)],
	      User => [qw(tenant creation_log_entry)],
	      VM => ['di', 'osf', { vm_runtime => qw(host) }, { user => 'tenant' }, qw(creation_log_entry)],
	      Host => ['runtime', qw(creation_log_entry)],
	      OSF => [ qw(tenant creation_log_entry)],
	      DI => [{osf => 'tenant'}, qw(creation_log_entry)],
	      DI_Tag => [{di => {osf => 'tenant'}}],
	      Administrator => [qw(tenant wat_setups), qw(creation_log_entry)],
	      Tenant => [qw(wat_setups creation_log_entry)],
	      Tenant_Views_Setup => [ qw(tenant)],
	      Administrator_Views_Setup => [ { administrator => 'tenant' }] },

    details => {Log => [qw(deletion_log_entry administrator)],
		Role => [qw(tenant creation_log_entry)],
		User => [qw(tenant creation_log_entry)],
		VM => ['di', 'osf', { vm_runtime => qw(host) }, { user => 'tenant' }, qw(creation_log_entry)],
		Host => ['runtime', qw(creation_log_entry)],
		OSF => [ qw(tenant creation_log_entry)],
		DI => [{osf => 'tenant'}, qw(creation_log_entry)],
		DI_Tag => [{di => {osf => 'tenant'}}],
		Administrator => [qw(tenant wat_setups creation_log_entry)],
		Tenant => [qw(wat_setups creation_log_entry)],
		Tenant_Views_Setup => [ qw(tenant)],
		Administrator_Views_Setup => [ { administrator => 'tenant' }]}
};

# This is for creation actions. When creating
# an object in DVB, you may have to create related objects as well.
# These related objects are listed in here.

my $DBIX_HAS_ONE_RELATIONSHIPS = 
{ 
    VM => [qw(vm_runtime counters)],
    Host => [qw(runtime counters)],
    Tenant => [qw(wat_setups)],
    Administrator => [qw(wat_setups)],
};



##################################################
## METHODS TO CREATE THE REPOSITORY OF INFO FOR ##
## THE CURRENT ACTION                           ## 
##################################################

# The constructor of the class, according to the 'qvd_object' and 'type_of_action'
# parameters, takes the correspondant info from those class variables and creates
# a repository in 'model_info', with the info relative to the specific kind of action.
# All these methods are setting that info in 'model_info'.

sub BUILD
{
    my $self = shift;

    $DB = QVD::DB::Simple::db();

    $self->initialize_info_model; # Creates a new hash reference to allocate 'model_info'

    $self->custom_properties_keys; # Sets in $self->{custom_properties_keys} a list with all
                                   # custom properties related to the action requested to API
    $self->set_info_by_type_of_action_and_qvd_object(
	'unambiguous_filters',$UNAMBIGUOUS_FILTERS);

    $self->set_info_by_type_of_action_and_qvd_object(
	'related_views_in_db',$RELATED_VIEWS_IN_DB);

    $self->set_info_by_type_of_action_and_qvd_object(
	'available_nested_queries',$AVAILABLE_NESTED_QUERIES);

    $self->set_info_by_type_of_action_and_qvd_object(
	'available_filters',$AVAILABLE_FILTERS);

    $self->set_info_by_type_of_action_and_qvd_object(
	'available_fields',$AVAILABLE_FIELDS,1);

    $self->set_info_by_type_of_action_and_qvd_object(
	'default_order_criteria',$DEFAULT_ORDER_CRITERIA);

    $self->set_info_by_qvd_object(
	'available_arguments',$AVAILABLE_ARGUMENTS);

    $self->set_info_by_qvd_object(
	'mandatory_arguments',$MANDATORY_ARGUMENTS);

    $self->set_info_by_type_of_action_and_qvd_object(
	'mandatory_filters',$MANDATORY_FILTERS);

    $self->set_info_by_qvd_object(
	'default_argument_values',$DEFAULT_ARGUMENT_VALUES);

    $self->set_info_by_qvd_object(
	'filters_to_dbix_format_mapper',$FILTERS_TO_DBIX_FORMAT_MAPPER);

    $self->set_info_by_qvd_object(
	'arguments_to_dbix_format_mapper',$ARGUMENTS_TO_DBIX_FORMAT_MAPPER);

    $self->set_info_by_qvd_object(
	'fields_to_dbix_format_mapper',$FIELDS_TO_DBIX_FORMAT_MAPPER);

    $self->set_info_by_qvd_object(
	'order_criteria_to_dbix_format_mapper',$ORDER_CRITERIA_TO_DBIX_FORMAT_MAPPER);

    $self->set_info_by_qvd_object(
	'nested_queries_to_admin4_mapper',$NESTED_QUERIES_TO_ADMIN4_MAPPER);

    $self->set_info_by_qvd_object(
	'values_normalizator',$VALUES_NORMALIZATOR);

    $self->set_info_by_qvd_object(
	'dbix_join_value',$DBIX_JOIN_VALUE);

    $self->set_info_by_type_of_action_and_qvd_object(
	'dbix_prefetch_value',$DBIX_PREFETCH_VALUE);

    $self->set_info_by_qvd_object(
	'dbix_has_one_relationships',$DBIX_HAS_ONE_RELATIONSHIPS);


# For some actions, the fields tenant_id and tenant_name
# are available only in case the current admin in superadmin
# For that cases, these fields are added to the available_fields list
# in here 

    $self->set_tenant_fields;  # The last one. It depends on others
}

# Auxiliar methods for setting the info

sub initialize_info_model 
{
    my $self = shift;
    $self->{model_info} =
{ 
    unambiguous_filters => [],                                                                 
    related_views_in_db => [],
    available_filters => [],                                                                 
    available_fields => [],                                                                  
    available_arguments => [],                                                               
    available_nested_queries => [],                                                               
    mandatory_arguments => [],                                                               
    mandatory_filters => [],                                                                 
    default_argument_values => {},                                                           
    default_order_criteria => [],                                                            
    filters_to_dbix_format_mapper => {},                                                     
    arguments_to_dbix_format_mapper => {},                                                   
    fields_to_dbix_format_mapper => {},                                                      
    order_criteria_to_dbix_format_mapper => {},                                              
    nested_queries_to_admin4_mapper => {},                                              
    values_normalizator => {},                                                               
    dbix_join_value => [],                                                                   
    dbix_prefetch_value => [],                                                                   
    dbix_has_one_relationships => []
};
}

# It sets custom properties

sub custom_properties_keys
{
    my $self = shift;
    return @{$self->{custom_properties_keys}} 
    if defined $self->{custom_properties_keys}; 
    $self->{custom_properties_keys} =
	[ $self->get_custom_properties_keys ];
    @{$self->{custom_properties_keys}};
}

# Takes custom properties from DB

sub get_custom_properties_keys
{
    my $self = shift;
    my $qvd_object_table = $self->qvd_object;
    my $properties_table = $qvd_object_table."_Property";
    my @properties_keys;
    
    eval { my %properties_keys = map {$_->key => 1 } 
	   $self->db->resultset($properties_table)->search()->all;
	   @properties_keys = keys %properties_keys };

    @properties_keys;
}

# It sets info from variables that clasify
# info both by qvd_object and by type_of_action

sub set_info_by_type_of_action_and_qvd_object
{
    my ($self,$model_info_key,$INFO_REPO,$flag) = @_;

    return unless exists $INFO_REPO->{$self->type_of_action};

    if (exists $INFO_REPO->{$self->type_of_action}->{$self->qvd_object}) 
    {
	$self->{model_info}->{$model_info_key} = 
	    clone $INFO_REPO->{$self->type_of_action}->{$self->qvd_object};
    }
    elsif (exists $INFO_REPO->{$self->type_of_action}->{default})
    {
	$self->{model_info}->{$model_info_key} = 
	    clone $INFO_REPO->{$self->type_of_action}->{default};
    }
}

# It sets info from variables that clasify
# info only by qvd_object

sub set_info_by_qvd_object
{
    my ($self,$model_info_key,$INFO_REPO) = @_;

    $self->{model_info}->{$model_info_key} = 
	clone $INFO_REPO->{$self->qvd_object};
}

# For some actions, the fields tenant_id and tenant_name
# are available only in case the current admin in superadmin
# For that cases, these fields are added to the available_fields list
# in here 

sub set_tenant_fields
{
    my $self = shift;

    return unless $self->type_of_action =~ /^list|details$/;

    return unless $self->current_qvd_administrator->is_superadmin;

    push @{$self->{model_info}->{available_fields}},'tenant_id'
	if defined $self->fields_to_dbix_format_mapper->{tenant_id};

    push @{$self->{model_info}->{available_fields}},'tenant_name'
	if defined $self->fields_to_dbix_format_mapper->{tenant_name};
}

############################################################
## ACCESSORS TO PROVIDE THE INFO ABOUT THE CURRENT ACTION ##
############################################################

sub has_property
{
    my ($self,$prop) = @_;
    my %props = map { $_ => 1 } $self->custom_properties_keys;

    return exists $props{$prop} ? return 1 : return 0;
}

sub related_views_in_db
{
    my $self = shift;
    my $views = $self->{model_info}->{related_views_in_db} // [];
    @$views;
}

sub related_view
{
    my $self = shift;
    my $views = $self->{model_info}->{related_views_in_db} // [];
    my @views = @$views;
    return $views[0];
}

sub available_nested_queries
{
    my $self = shift;
    my $nq =  $self->{model_info}->{available_nested_queries} // [];
    @$nq;
}

sub available_filters
{
    my $self = shift;
    my $filters =  $self->{model_info}->{available_filters} // [];
    @$filters;
}

sub unambiguous_filters
{
    my $self = shift;
    my $filters =  $self->{model_info}->{unambiguous_filters} // [];
    @$filters;
}

sub default_order_criteria
{
    my $self = shift;

    my $order_criteria = $self->{model_info}->{default_order_criteria} // [];
    @$order_criteria;
}

sub available_arguments
{
    my $self = shift;
    my $args = $self->{model_info}->{available_arguments} // [];
    @$args;
}

sub available_fields
{
    my $self = shift;

    my $fields = $self->{model_info}->{available_fields} // [];
    @$fields;
}


sub mandatory_arguments
{
    my $self = shift;
    my $args =  $self->{model_info}->{mandatory_arguments} // [];
    @$args;
}

sub mandatory_filters
{
    my $self = shift;

    my $filters = $self->{model_info}->{mandatory_filters} // [];
    @$filters;
}

sub default_argument_values
{
    my $self = shift;
    return $self->{model_info}->{default_argument_values} || {};
}


sub nested_queries_to_admin4_mapper
{
    my $self = shift;
    return $self->{model_info}->{nested_queries_to_admin4_mapper} || {};
}

sub filters_to_dbix_format_mapper
{
    my $self = shift;

    return $self->{model_info}->{filters_to_dbix_format_mapper} || {};
}

sub order_criteria_to_dbix_format_mapper
{
    my $self = shift;
    return $self->{model_info}->{order_criteria_to_dbix_format_mapper} || {};
}


sub arguments_to_dbix_format_mapper
{
    my $self = shift;
    return $self->{model_info}->{arguments_to_dbix_format_mapper} || {};
}

sub fields_to_dbix_format_mapper
{
    my $self = shift;
    return $self->{model_info}->{fields_to_dbix_format_mapper} || {};
}

sub values_normalizator
{
    my $self = shift;
    return $self->{model_info}->{values_normalizator} || {};
}

sub dbix_join_value
{
    my $self = shift;
    return $self->{model_info}->{dbix_join_value} || [];
}

sub dbix_prefetch_value
{
    my $self = shift;
    return $self->{model_info}->{dbix_prefetch_value} || [];
}

sub dbix_has_one_relationships
{
    my $self = shift;
    my $rels = $self->{model_info}->{dbix_has_one_relationships} // [];
    @$rels;
}

sub related_view_in_db
{
    my $self = shift;
    my $view = shift;
    $_ eq $view && return 1
	for $self->related_views_in_db;
    return 0;
}


sub available_nested_query
{
    my $self = shift;
    my $nq = shift;
    $_ eq $nq && return 1
	for $self->available_nested_queries;

    return 0;
}

sub available_filter
{
    my $self = shift;
    my $filter = shift;

    $_ eq $filter && return 1
	for $self->available_filters;

    return 0;
}

sub directly_tenant_related
{
    my $self = shift;
    my $qvd_object = $self->qvd_object;

    $_ eq $qvd_object && return 1
	for @$DIRECTLY_TENANT_RELATED;

    return 0;
}

sub default_order_criterium
{
    my $self = shift;
    my $order_criterium = shift;
    $_ eq $order_criterium && return 1
	for $self->default_order_criteria;
    return 1;
}

sub available_argument
{
    my $self = shift;
    my $argument = shift;

    $_ eq $argument && return 1
	for $self->available_arguments;

    return 0;
}

sub available_field
{
    my $self = shift;
    my $field = shift;
    $_ eq $field && return 1
	for $self->available_fields;

    return 0;
}


sub mandatory_argument
{
    my $self = shift;
    my $argument = shift;

    $_ eq $argument && return 1
	for $self->mandatory_arguments;
    return 0;
}

sub mandatory_filter
{
    my $self = shift;
    my $filter = shift;
    $_ eq $filter && return 1
	for $self->mandatory_filters;
    return 0;
}

sub get_default_argument_value
{
    my $self = shift;
    my $arg = shift;
    my $json_wrapper = shift;

    my $def = $self->default_argument_values->{$arg} // return; 
    return ref($def) ? $self->$def($json_wrapper) : $def;
}

sub map_filter_to_dbix_format
{
    my $self = shift;
    my $filter = shift;

    my $mapped_filter = $self->filters_to_dbix_format_mapper->{$filter};
    defined $mapped_filter
    || die "No mapping available for filter $filter";
    return $mapped_filter;
}

sub map_argument_to_dbix_format
{
    my $self = shift;
    my $argument = shift;
    my $mapped_argument = $self->arguments_to_dbix_format_mapper->{$argument};
    defined $mapped_argument
    || die "No mapping available for argument $argument";
    $mapped_argument;
}

sub map_nested_query_to_admin4
{
    my $self = shift;
    my $nq = shift;
    my $mapped_nq = $self->nested_queries_to_admin4_mapper->{$nq};
    defined $mapped_nq
    || die "No mapping available for nested query $nq";
    $mapped_nq;
}

sub map_field_to_dbix_format
{
    my $self = shift;
    my $field = shift;

    my $mapped_field = $self->fields_to_dbix_format_mapper->{$field};
    return $mapped_field if defined $mapped_field;
    return 'view.properties#'.$field if $self->has_property($field);

    die "No mapping available for field $field";
}

sub map_order_criteria_to_dbix_format
{
    my $self = shift;
    my $oc = shift;
    my $mapped_oc = $self->order_criteria_to_dbix_format_mapper->{$oc};
    defined $mapped_oc ||  die "No mapping available for order_criteria $oc";

    return $mapped_oc;
}

sub normalize_value
{
    my $self = shift;
    my $key = shift;
    my $value = shift;

    $self->values_normalizator || return $value;
    my $norm = $self->values_normalizator->{$key} // 
	return $value; 

    return ref($norm) ? $self->$norm($value) : $norm;
}

sub normalize_operator
{
    my $self = shift;
    my $op = shift;

    my $nop = $OPERATORS_MAPPER->{$op} // $op;

    return $nop;
}

sub get_acls_for_filter
{
    my ($self,$filter) = @_;
    $self->get_acls($ACLS_FOR_FILTERS,$filter);
}

sub get_acls_for_filter_value
{
    my ($self,$filter,$value) = @_;
    $self->get_acls($ACLS_FOR_FILTER_VALUES,$filter,$value);
}

sub get_filters_with_acls_for_values
{
    my $self = shift;

    return () unless defined $ACLS_FOR_FILTER_VALUES->{$self->type_of_action};
    return () unless defined $ACLS_FOR_FILTER_VALUES->{$self->type_of_action}->{$self->qvd_object};
    return keys %{$ACLS_FOR_FILTER_VALUES->{$self->type_of_action}->{$self->qvd_object}}; 
}

sub get_filter_values_with_acls
{
    my ($self,$filter) = @_;
    return () unless defined $ACLS_FOR_FILTER_VALUES->{$self->type_of_action};
    return () unless defined $ACLS_FOR_FILTER_VALUES->{$self->type_of_action}->{$self->qvd_object};
    return keys %{$ACLS_FOR_FILTER_VALUES->{$self->type_of_action}->{$self->qvd_object}->{$filter}}; 
}

sub get_acls_for_field
{
    my ($self,$field) = @_;
    $self->get_acls($ACLS_FOR_FIELDS,$field);
}

sub get_acls_for_argument_in_creation
{
    my ($self,$arg) = @_;
    $self->get_acls($ACLS_FOR_ARGUMENTS_IN_CREATION,$arg);
}

sub get_acls_for_argument_in_update
{
    my ($self,$arg) = @_;
    $self->get_acls($ACLS_FOR_ARGUMENTS_IN_UPDATE,$arg);
}
    
sub get_acls_for_argument_in_massive_update
{
    my ($self,$arg) = @_;
    $self->get_acls(
	$ACLS_FOR_ARGUMENTS_IN_MASSIVE_UPDATE,$arg);
}

sub get_acls_for_nested_query_in_creation
{
    my ($self,$nq) = @_;
    $self->get_acls(
	$ACLS_FOR_ARGUMENTS_IN_CREATION,$nq);
}

sub get_acls_for_nested_query_in_update
{
    my ($self,$nq) = @_;
    $self->get_acls(
	$ACLS_FOR_ARGUMENTS_IN_UPDATE,$nq);
}
    
sub get_acls_for_nested_query_in_massive_update
{
    my ($self,$nq) = @_;
    $self->get_acls(
	$ACLS_FOR_ARGUMENTS_IN_MASSIVE_UPDATE,$nq);
}

sub get_acls_for_delete_massive
{
    my $self = shift;
    $self->get_acls(
	$ACLS_FOR_ARGUMENTS_IN_MASSIVE_UPDATE,'***delete***');
}

sub get_acls
{
    my ($self,$REPO,$filter,$value) = @_;

    my @acls;

    if (defined $value) 
    {
	return () unless defined $REPO->{$self->type_of_action}->{$self->qvd_object};
	return () unless defined $REPO->{$self->type_of_action}->{$self->qvd_object}->{$filter};
	return () unless defined $REPO->{$self->type_of_action}->{$self->qvd_object}->{$filter}->{$value};
	@acls = @{$REPO->{$self->type_of_action}->{$self->qvd_object}->{$filter}->{$value}};
    }
    else
    {
	return () unless defined $REPO->{$self->qvd_object};
	return () unless defined $REPO->{$self->qvd_object}->{$filter};
	@acls = @{$REPO->{$self->qvd_object}->{$filter}};
    }
    return @acls;
}

sub qvd_object_log_style
{
    my $self = shift;

    $QVD_OBJECTS_TO_LOG_MAPPER->{$self->qvd_object};    
}


sub type_of_action_log_style
{
    my $self = shift;
    $TYPES_OF_ACTION_TO_LOG_MAPPER->{$self->type_of_action};    
}

#########################################
## FUNCTIONS STORED IN CLASS VARIABLES ##
#########################################

sub get_default_memory { cfg('osf.default.memory'); }
sub get_default_overlay { cfg('osf.default.overlay'); }
sub basename_disk_image { my $self = shift; basename(+shift); };

sub password_to_token 
{
    my ($self, $password) = @_;
    require Digest::SHA;
    Digest::SHA::sha256_base64(cfg('l7r.auth.plugin.default.salt') . $password);
}

sub normalize_name
{
    my ($self,$login) = @_;
    $login =~ s/^\s*//; $login =~ s/\s*$//;
    $login = lc($login)  
	unless cfg('model.user.login.case-sensitive');
    $login;
}

sub get_free_ip {

    my $self = shift;
    my $nettop = nettop_n;
    my $netstart = netstart_n;

    my %ips = map { net_aton($_->ip) => 1 } 
    $DB->resultset('VM')->all;

    while ($nettop-- > $netstart) {
        return net_ntoa($nettop) unless $ips{$nettop}
    }
    die "No free IP addresses";
}

sub get_default_di_version
{
    my $self = shift;
    my $json_wrapper = shift;

    my $osf_id = $json_wrapper->get_argument_value('osf_id') // return;
    my ($y, $m, $d) = (localtime)[5, 4, 3]; $m ++; $y += 1900;
    my $osf = $DB->resultset('OSF')->search({id => $osf_id})->first;
    QVD::Admin4::Exception->throw(code => 7100, object => 'osf_id') unless $osf; 
    my $version;

    for (0..999) 
    {
	$version = sprintf("%04d-%02d-%02d-%03d", $y, $m, $d, $_);
	last unless $osf->di_by_tag($version);
    }
    
    $version;
}

1;
