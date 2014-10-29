package QVD::Admin4::REST::Model;
use strict;
use warnings;
use Moo;
use QVD::Config::Network qw(nettop_n netstart_n net_aton net_ntoa);
use QVD::Config;
use File::Basename qw(basename);
use QVD::Admin4::DBConfigProvider;
use Clone qw(clone);

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

my $DBConfigProvider;

my $RELATED_VIEWS_IN_DB = 
{   
    list => { User => [qw(User_View)],
	      VM => [qw(VM_View)],
	      Host => [qw(Host_View)],
	      OSF => [qw(OSF_View)],
	      DI => [qw(DI_View)] },

    details => { User => [qw(User_View)],
		 VM => [qw(VM_View)],
		 Host => [qw(Host_View)],
		 OSF => [qw(OSF_View)],
		 DI => [qw(DI_View)] },		 
};

my $ACLS_FOR_FILTERS = 
{
    VM => { properties => [qw(vm.filter.properties)], # PROVISIONAL
	    name => [qw(vm.filter.name)],
	    user_id => [qw(vm.filter.user)],
	    user_name => [qw(vm.filter.user)],
	    osf_id => [qw(vm.filter.osf)],
	    osf_name => [qw(vm.filter.osf)],
	    state => [qw(vm.filter.state)],
	    host_id => [qw(vm.filter.host)],
	    host_name => [qw(vm.filter.host)]},

    User => { properties => [qw(user.filter.properties)], 
	      name => [qw(user.filter.name)]},

    Host => { properties => [qw(host.filter.properties)],
	      name => [qw(host.filter.name)],
	      vm_id => [qw(host.filter.vm)]},

    DI => { properties => [qw(di.filter.properties)],
	    disk_image => [qw(host.filter.disk-image)],
	    osf_id => [qw(host.filter.osf)],
	    osf_name => [qw(host.filter.osf)],

    OSF => { properties => [qw(osf.filter.properties)],
	     name => [qw(osf.filter.name)],
	     vm_id => [qw(osf.filter.vm)],
	     di_id => [qw(osf.filter.di)]},
};

my $ACLS_FOR_FIELDS = 
{
    OSF => { id => [qw(osf.see.id)],
	     creation_admin => [qw(osf.see.created-by)],
	     creation_date => [qw(osf.see.creation-date)],
	     name => [qw(osf.see.name)],
	     overlay => [qw(osf.see.overlay)],
	     user_storage => [qw(osf.see.user-storage)],
	     memory => [qw(osf.see.memory)],
	     number_of_vms => [qw(osf.see.vms-info osf.see.vm-list)], # quedan vm-list-block|default|default-update|expiration|head|state|tags
	     number_of_dis => [qw(osf.see.dis-info osf.see.di-list)],
	     properties => [qw(osf.see.properties)] },

    Role => { roles => [qw(role.see.acl-list role.see.acl-list-roles role.see.inherited-roles)],
	      acls => [qw(role.see.acl-list)],
	      id => [qw(role.see.id)],
	      number_of_acls => [qw(role.see.acl-list)] },

    DI => { id => [qw(di.see.id)],                      # di.see.vm-list-block|expiration|state
	    creation_admin => [qw(di.see.created-by)],
	    creation_date => [qw(di.see.creation-date)],
	    version => [qw(di.see.version)],
	    osf_id => [qw(di.see.osf)],
	    osf_name => [qw(di.see.osf)],
	    blocked => [qw(di.see.block)],
	    tags => [qw(di.see.default di.see.head di.see.tags)],
	    properties => [qw(di.see.properties)]  },

    VM => { id => [qw(vm.see.id)],
	    user_id => [qw(vm.see.user)],
	    user_name => [qw(vm.see.user)],
	    osf_id => [qw(vm.see.osf)],
	    osf_name => [qw(vm.see.osf)],
	    di_tag => [qw(vm.see.di-tag)],
	    blocked => [qw(vm.see.block)],
	    expiration_soft => [qw(vm.see.expiration)],
	    expiration_hard => [qw(vm.see.expiration)],
	    state => [qw(vm.see.state)],
	    host_id => [qw(vm.see.host)],
	    host_name => [qw(vm.see.host)],
	    di_id => [qw(vm.see.di)],
	    user_state => [qw(vm.see.user-state)],
	    ip => [qw(vm.see.ip)],
	    next_boot_ip => [qw(vm.see.next-boot-ip)],
	    ssh_port => [qw(vm.see.port-ssh)],
	    vnc_port => [qw(vm.see.port-vnc)],
	    serial_port => [qw(vm.see.port-serial)], 
	    creation_admin => [qw(vm.see.created-by)],
	    creation_date => [qw(vm.see.creation-date)],
	    di_version => [qw(vm.see.di-version)],
	    di_name => [qw(vm.see.di)],
	    di_id => [qw(vm.see.di)],
	    properties => [qw(vm-see-properties)] },
 
   Administrator => { roles => [qw(administrator.see.roles 
                                   administrator.see.acl-list 
                                   administrator.see.acl-list-roles)],
		       id => [qw(administrator.see.id)] },

    User => { id => [qw(user.see.id)],
	      blocked => [qw(user.see.block)],
	      creation_admin => [qw(user.see.created-by)],
	      creation_date => [qw(user.see.creation-date)],
	      number_of_vms => [qw(user.see.vm-list user.see.vms-info)], # user.see.vm-list-block|expiration|state
	      number_of_vms_connected => [qw(user.see.vm-list-state)],
	      properties => [qw(user.see.properties)] },

    Host => { id => [qw(host.see.id)],
	      address => [qw(host.see.address)],
	      blocked => [qw(host.see.block)],
	      state => [qw(host.see.state)],
	      creation_admin => [qw(host.see.created-by)],
	      creation_date => [qw(host.see.creation-date)],
	      number_of_vms_connected => [qw(host.see.vm-list host.see.vms-info)],
	      properties => [qw(host.see.properties)] },
};

my $ACLS_FOR_ARGUMENTS_IN_UPDATE = 
{ 
    User => { password => [qw(user.update.password)],
	      blocked => [qw(user.update.block)],
	      __properties_changes_set => [qw(user.update.properties-update user.update.properties-create)],
	      __properties_changes_delete => [qw(user.update.properties-delete)]},

    VM => { name => [qw(vm.update.name)],
	    blocked => [qw(vm.update.block)],
	    expiration_soft => [qw(vm.update.expiration)],
	    expiration_hard => [qw(vm.update.expiration)],
	    di_tag => [qw(vm.update.di-tag)],
	    __properties_changes__set => [qw(vm.update.properties-update vm.update.properties-create)],
	    __properties_changes__delete => [qw(vm.update.properties-delete)] },

    Host => { name => [qw(host.update.name)],
	      address => [qw(host.update.address)],
	      blocked => [qw(host.update.block)],
	      __properties_changes__set => [qw(host.update.properties-update host.update.properties-create)],
	      __properties_changes__delete => [qw(host.update.properties-delete)] },

    OSF => { name => [qw(osf.update.name)],
	     memory => [qw(osf.update.memory)],
	     user_storage => [qw(osf.update.user-storage)],
	     __properties_changes__set => [qw(osf.update.properties-update osf.update.properties-create)],
	     __properties_changes__delete => [qw(osf.update.properties-delete)] },

    DI => { blocked => [qw(di.update.block)],
	    __properties_changes__set => [qw(di.update.properties-update di.update.properties-create)],
	    __properties_changes__delete => [qw(di.update.properties-delete)],
	    __tags_changes__create => [qw(di.update.tags di.update.default)],
	    __tags_changes__delete => [qw(di.update.tags di.update.default)]},

    Role => { name => [qw(role.update.name)],
	      __acls_changes__assign_acls => [qw(role.update.assign-acl)],
	      __acls_changes__unassign_acls => [qw(role.update.assign-acl)],
	      __roles_changes__assign_roles => [qw(role.update.assign-role)],
	      __roles_changes__unassign_roles => [qw(role.update.assign-role)] },

    Administrator => { password => [qw(administrator.update.password)],
		       __roles_changes__assign_roles => [qw(administrator.update.assign-role)],
		       __roles_changes__unassign_roles => [qw(administrator.update.assign-role)] },

    Tenant_Views_Setup => { visible => [qw(views.update.columns)] },  
    Administrator_Views_Setup => { visible => [qw(views.update.columns)] }

};


my $ACLS_FOR_ARGUMENTS_IN_MASSIVE_UPDATE = 
{ 
    User => { '***delete***' => ['user.delete-massive.'], # MAYBE A NEW VARIABLE?
	      blocked => [qw(user.update-massive.block)],
	      __properties_changes__set => [qw(user.update-massive.properties-update 
                                               user.update-massive.properties-create)],
	      __properties_changes__delete => [qw(user.update-massive.properties-delete)]},

    VM => { '***delete***' => ['vm.delete-massive.'],
	    blocked => [qw(vm.update-massive.block)],
	    expiration_soft => [qw(vm.update-massive.expiration)],
	    expiration_hard => [qw(vm.update-massive.expiration)],
	    di_tag => [qw(vm.update-massive.di-tag)],
	    __properties_changes__set => [qw(vm.update-massive.properties-update 
                                             vm.update-massive.properties-create)],
	    __properties_changes__delete => [qw(vm.update-massive.properties-delete)] },

    Host => { '***delete***' => ['host.delete-massive.'],
	      blocked => [qw(host.update-massive.block)],
	      __properties_changes__set => [qw(host.update-massive.properties-update 
                                               host.update-massive.properties-create)],
	      __properties_changes__delete => [qw(host.update-massive.properties-delete)] },
	
    OSF => { '***delete***' => ['osf.delete-massive.'],
	     memory => [qw(osf.update-massive.memory)],
	     user_storage => [qw(osf.update-massive.user-storage)],
	     __properties_changes__set => [qw(osf.update-massive.properties-update 
                                              osf.update-massive.properties-create)],
	     __properties_changes__delete => [qw(osf.update-massive.properties-delete)] },
	
    DI => { '***delete***' => ['di.delete-massive.'],
	    blocked => [qw(di.update-massive.block)],
	    __properties_changes__set => [qw(di.update-massive.properties-update 
                                             di.update-massive.properties-create)],
	    __properties_changes__delete => [qw(di.update-massive.properties-delete)],
	    __tags_changes__create => [qw(di.update-massive.tags)],
	    __tags_changes__delete => [qw(di.update-massive.tags-delete)]},
	
    Tenant => { '***delete***' => ['tenant.delete-massive.']},

    Role => { '***delete***' => ['role.delete-massive.'] },

    Administrator => { '***delete***' => ['administrator.delete-massive.']}

};


my $ACLS_FOR_ARGUMENTS_IN_CREATION = 
{ 
    User => { __properties__ => [qw(user.create.properties)]},
    
    VM => { di_tag => [qw(vm.create.di-tag)],
	    __properties__ => [qw(vm.create.properties)] },
    
    Host => {__properties__ => [qw(host.create.properties)] },

    OSF => { memory => [qw(osf.create.memory)],
	     user_storage => [qw(osf.create.user-storage)],
	     __properties__ => [qw(osf.create.properties)]},

    DI => { version => [qw(di.create.version)],
	    __properties__ => [qw(di.create.properties)],
	    __tags__ => [qw(di.create.tags di.create.defaulr)]}

};

my $AVAILABLE_FILTERS = 
{ 
    list => { default => [],

	      VM => [qw(storage id name user_id user_name osf_id osf_name di_tag blocked 
                        expiration_soft expiration_hard state host_id host_name di_id 
                        user_state ip next_boot_ip ssh_port vnc_port serial_port tenant_id tenant_name 
                        creation_admin creation_date )],

	      DI_Tag => [qw(osf_id name id tenant_id tenant_name)],

	      User => [qw(id name blocked creation_admin creation_date tenant_id tenant_name )],

	      Host => [qw(id name address blocked frontend backend state vm_id creation_admin creation_date )],

	      DI => [qw(id disk_image version osf_id osf_name tenant_id blocked tenant_name tag)],

	      OSF => [qw(id name overlay user_storage memory vm_id di_id tenant_id tenant_name )],

	      ACL => [qw(id name role_id admin_id)],

	      Tenant => [qw(id name)],

	      Role => [qw(name id )],

	      Administrator => [qw(name tenant_id tenant_name id )],

	      Tenant_Views_Setup => [qw(id tenant_id tenant_name field visible view_type device_type qvd_object property)],

	      Administrator_Views_Setup => [qw(id admin_id admin_name field tenant_id tenant_name visible 
                                               view_type device_type qvd_object property)]},

    all_ids => { default => [],
		 VM => [qw(storage id name user_id user_name osf_id osf_name di_tag blocked expiration_soft 
                           expiration_hard state host_id host_name  di_id user_state ip next_boot_ip ssh_port 
                           vnc_port serial_port tenant_id tenant_name creation_admin creation_date )],

		 DI_Tag => [qw(osf_id name id tenant_id tenant_name)],

		 User => [qw(id name blocked creation_admin creation_date tenant_id tenant_name )],

		 Host => [qw(id name address blocked frontend backend state vm_id creation_admin creation_date )],

		 DI => [qw(id disk_image version osf_id osf_name tenant_id blocked tenant_name tag)],

		 OSF => [qw(id name overlay user_storage memory vm_id di_id tenant_id tenant_name )],

		 ACL => [qw(id name role_id admin_id )],

		 Role => [qw(name acl_id role_id nested_acl_name nested_role_name id admin_id admin_name )],

		 Tenant => [qw(id name)],

		 Administrator => [qw(name tenant_id tenant_name role_id acl_id id role_name acl_name )],

		 Tenant_Views_Setup => [qw(id tenant_id tenant_name field visible view_type device_type qvd_object property)],

		 Administrator_Views_Setup => [qw(id tenant_id tenant_name field admin_id admin_name visible view_type 
                                                  device_type qvd_object property)]},

    details => { default => [qw(id tenant_id)], Host => [qw(id)], Role => [qw(id)], ACL => [qw(id)], Tenant => [qw(id)] },
		
    tiny => { default => [qw(tenant_id)], Host => [qw()], Role => [qw()], ACL => [qw(name)], Tenant => [qw()], DI_Tag => [qw(tenant_id osf_id)]},

    delete => { default => [qw(id tenant_id)], Host => [qw(id)], ACL => [qw(id)], Role => [qw(id)], Tenant => [qw(id)]},

    update => { default => [qw(id tenant_id)], Host => [qw(id)], ACL => [qw(id)], Role => [qw(id)], Tenant => [qw(id)]},

    state => { default => [qw(id tenant_id)], Host => [qw(id)], ACL => [qw(id)], Role => [qw(id)], Tenant => [qw(id)]},
    
    'exec' => { default => [qw(id tenant_id)], Host => [qw(id)], ACL => [qw(id)], Role => [qw(id)], Tenant => [qw(id)]} 

};

my $AVAILABLE_FIELDS = 
{ 
    list => { default => [],

	      OSF => [qw(id name overlay user_storage memory  number_of_vms number_of_dis properties )],

	      Role => [qw(name roles acls id number_of_acls)],

	      DI => [qw(id disk_image version osf_id osf_name blocked tags  properties )],

	      VM => [qw(storage id name user_id user_name osf_id osf_name di_tag blocked expiration_soft expiration_hard 
                        state host_id host_name  di_id user_state ip next_boot_ip ssh_port vnc_port serial_port 
                        creation_admin creation_date di_version di_name di_id properties )],

	      ACL => [qw(id name)],

	      Administrator => [qw(name roles id )],

	      Tenant => [qw(id name)],
				   
	      User => [qw(id name  blocked creation_admin creation_date number_of_vms number_of_vms_connected  properties )],

	      Host => [qw(id name address blocked frontend backend state  load creation_admin creation_date number_of_vms_connected properties )],

	      DI_Tag => [qw(osf_id name id )],

	      Tenant_Views_Setup => [qw(id tenant_id tenant_name field visible view_type device_type qvd_object property)],

	      Administrator_Views_Setup => [qw(id tenant_id tenant_name admin_id admin_name field visible view_type 
                                               device_type qvd_object property)] },

    details => { default => [],
		 
		 OSF => [qw(id name overlay user_storage memory  number_of_vms number_of_dis properties )],
		 
		 Role => [qw(name acls roles id number_of_acls)],
		
		 DI => [qw(id disk_image version osf_id osf_name  blocked tags  properties )],
		
		 VM => [qw(storage id name user_id user_name osf_id osf_name di_tag blocked expiration_soft expiration_hard 
                           state host_id host_name  di_id user_state ip next_boot_ip ssh_port vnc_port serial_port 
                           creation_admin creation_date di_version di_name di_id properties )],

		 ACL => [qw(id name)],

		 Administrator => [qw(name roles id )],

		 Tenant => [qw(id name)],

		 User => [qw(id name  blocked creation_admin creation_date number_of_vms number_of_vms_connected  properties )],

		 Host => [qw(id name address blocked frontend backend state  load creation_admin creation_date 
                             number_of_vms_connected number_of_vms properties )],

		 DI_Tag => [qw(osf_id name id )],

		 Tenant_Views_Setup => [qw(id tenant_id tenant_name field visible view_type device_type qvd_object property)],

		 Administrator_Views_Setup => [qw(id admin_id admin_name tenant_id tenant_name field visible view_type 
                                                  device_type qvd_object property)] },

    tiny => { default => [qw(id name)],

	      DI => [qw(id disk_image)],

	      Tenant_Views_Setup => [qw(id)],

	      Administrator_Views_Setup => [qw(id)]},

    all_ids => { default => [qw(id)]},

    state => { User => [qw(number_of_vms_connected)],
	       
	       VM => [qw(state user_state)],
	       
	       Host => [qw(number_of_vms_connected)]},
    
    create => { 'default' => [qw(id)]}

};

my $MANDATORY_FILTERS = 
{ 
    list => { default => [qw(tenant_id)], Host => [qw()], ACL => [qw()], Role => [qw()], Tenant => [qw()]},

    details => { default => [qw(id tenant_id)], Host => [qw(id)], ACL => [qw(id)], Role => [qw(id)], Tenant => [qw(id)]}, 

    tiny => { default => [qw(tenant_id)], Host => [qw()], ACL => [qw()], Role => [qw()], Tenant => [qw()]},

    delete => { default => [qw(id tenant_id)], Host => [qw(id)], ACL => [qw(id)], Role => [qw(id)], Tenant => [qw(id)]},

    update=> { default => [qw(id tenant_id)], Host => [qw(id)], ACL => [qw(id)], Role => [qw(id)], Tenant => [qw(id)]}, 

    state => { default => [qw(id tenant_id)], Host => [qw(id)], ACL => [qw(id)], Role => [qw(id)], Tenant => [qw(id)]}, 

    all_ids => { default => [qw(tenant_id)], Host => [qw()], ACL => [qw()], Role => [qw()], Tenant => [qw()]}, 
    
    'exec' => { default => [qw(id tenant_id)], Host => [qw(id)], ACL => [qw(id)], Role => [qw(id)], Tenant => [qw(id)]}};

my $SUBCHAIN_FILTERS = 
{ 
    list => { default => [qw(name)],
	      DI => [qw(disk_image)],
	      Administrator => [qw(name role_name acl_name)],
	      Role => [qw(name nested_role_name acl_name)]}
};

my $COMMODIN_FILTERS = 
{ 
tiny => { ACL => [qw(name)]}
};

my $DEFAULT_ORDER_CRITERIA = 
{ 
    tiny => { default =>  [qw(name)],
	      DI => [qw(disk_image)],
	      Tenant_Views_Setup => [qw(field)],
	      Administrator_Views_Setup => [qw(field)] }
};

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
		Administrator_Views_Setup => [qw()]},

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
		Administrator_Views_Setup => [qw()]}
};



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
    Administrator_Views_Setup => {}
};

my $AVAILABLE_ARGUMENTS = { User => [qw(name password blocked)],
                            VM => [qw(name ip blocked expiration_soft expiration_hard storage di_tag)],
                            Host => [qw(name address blocked)],
                            OSF => [qw(name memory user_storage overlay)],
                            DI => [qw(blocked disk_image)],
			    Tenant => [qw(name)],
			    Role => [qw(name)],
			    Administrator => [qw(name password)],
			    Tenant_Views_Setup => [qw(visible)],
			    Administrator_Views_Setup => [qw(visible)]};


my $MANDATORY_ARGUMENTS = { User => [qw(name password tenant_id blocked)],
			    VM => [qw(name user_id ip osf_id di_tag state user_state blocked)],
			    Host => [qw(name address frontend backend blocked state)],
			    OSF => [qw(name memory overlay user_storage tenant_id)],
                            DI => [qw(version disk_image osf_id blocked)],
			    Tenant => [qw(name)],
			    Role => [qw(name)],
                            Administrator => [qw(name password tenant_id)],
			    Tenant_Views_Setup => [qw(tenant_id field visible view_type device_type qvd_object property)],
			    Administrator_Views_Setup => [qw(admin_id field visible view_type device_type qvd_object property)]}; 

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

    DI => { blocked => 'false' },

    Tenant_Views_Setup => { visible => 0, property => 0 },

    Administrator_Views_Setup =>  { visible => 0, property => 0 }
};

my $FILTERS_TO_DBIX_FORMAT_MAPPER = 
{
    ACL => {
	'id' => 'me.id',
	'name' => 'me.name',
	'role_id' => 'role.id',
	'admin_id' => 'admin.id',
    },

    DI_Tag => {
	'osf_id' => 'di.osf_id',
	'name' => 'me.tag',
	'tenant_id' => 'tenant.id',
	'tenant_name' => 'tenant.name',
	'id' => 'me.id',
    },
    
    Administrator => {
	'name' => 'me.name',
	'password' => 'me.password',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'role_id' => 'role.id',
	'acl_id' => 'acl.id',
	'role_name' => 'role.name',
	'acl_name' => 'acl.name',
	'id' => 'me.id',
    },

    OSF => {
	'id' => 'me.id',
	'name' => 'me.name',
	'overlay' => 'me.use_overlay',
	'user_storage' => 'me.user_storage_size',
	'memory' => 'me.memory',
	'vm_id' => 'vms.id',
	'di_id' => 'dis.id',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
    },

    Host => {
	'id' => 'me.id',
	'name' => 'me.name',
	'address' => 'me.address',
	'blocked' => 'runtime.blocked',
	'frontend' => 'me.frontend',
	'backend' => 'me.backend',
	'state' => 'runtime.state',
	'vm_id' => 'vms.vm_id',
	'creation_admin' => 'me.creation_admin',
	'creation_date' => 'me.creation_date',
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
	'tenant_name' => 'tenant.name',
    },
    User => {
	'id' => 'me.id',
	'name' => 'me.login',
	'password' => 'me.password',
	'blocked' => 'me.blocked',
	'creation_admin' => 'me.creation_admin',
	'creation_date' => 'me.creation_date',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
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
	'blocked' => 'vm_runtime.blocked',
	'expiration_soft' => 'vm_runtime.vm_expiration_soft',
	'expiration_hard' => 'vm_runtime.vm_expiration_hard',
	'state' => 'vm_runtime.vm_state',
	'host_id' => 'vm_runtime.host_id',
	'host_name' => 'host.name',
	'di_id' => 'di.id',
	'user_state' => 'vm_runtime.user_state',
	'ip' => 'me.ip',
	'next_boot_ip' => 'vm_runtime.vm_address',
	'ssh_port' => 'vm_runtime.vm_ssh_port',
	'vnc_port' => 'vm_runtime.vm_vnc_port',
	'serial_port' => 'vm_runtime.vm_serial_port',
	'tenant_id' => 'user.tenant_id',
	'tenant_name' => 'tenant.name',
	'creation_admin' => 'me.creation_admin',
	'creation_date' => 'me.creation_date',
    },

    Role => {
	'name' => 'me.name',
	'id' => 'me.id',
    },

    Tenant => {
	'name' => 'me.name',
	'id' => 'me.id'
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
 }

};

my $ARGUMENTS_TO_DBIX_FORMAT_MAPPER = 
    $FILTERS_TO_DBIX_FORMAT_MAPPER;

my $ORDER_CRITERIA_TO_DBIX_FORMAT_MAPPER = 
    $FILTERS_TO_DBIX_FORMAT_MAPPER;

my $FIELDS_TO_DBIX_FORMAT_MAPPER = 
{
    ACL => {
	'id' => 'me.id',
	'name' => 'me.name',
    },

    Host => {
	'id' => 'me.id',
	'name' => 'me.name',
	'address' => 'me.address',
	'blocked' => 'runtime.blocked',
	'frontend' => 'me.frontend',
	'backend' => 'me.backend',
	'state' => 'runtime.state',
	'load' => 'me.load',
	'creation_admin' => 'me.creation_admin',
	'creation_date' => 'me.creation_date',
	'number_of_vms_connected' => 'view.number_of_vms_connected',
	'properties' => 'view.properties',
    },

    Role => {
	'name' => 'me.name',
	'acls' => 'me.get_positive_and_negative_acls_info',
	'roles' => 'me.get_roles_with_its_acls_info',
	'id' => 'me.id',
	'number_of_acls' => 'me.number_of_acls'
    },

    User => {
	'id' => 'me.id',
	'name' => 'me.login',
	'password' => 'me.password',
	'blocked' => 'me.blocked',
	'creation_admin' => 'me.creation_admin',
	'creation_date' => 'me.creation_date',
	'number_of_vms' => 'view.number_of_vms',
	'number_of_vms_connected' => 'view.number_of_vms_connected',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'properties' => 'view.properties',
    },

    DI_Tag => {
	'osf_id' => 'di.osf_id',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'name' => 'me.tag',
	'id' => 'me.id',
    },

    OSF => {
	'id' => 'me.id',
	'name' => 'me.name',
	'overlay' => 'me.use_overlay',
	'user_storage' => 'me.user_storage_size',
	'memory' => 'me.memory',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'number_of_vms' => 'view.number_of_vms',
	'number_of_dis' => 'view.number_of_dis',
	'properties' => 'view.properties',
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
	'blocked' => 'vm_runtime.blocked',
	'expiration_soft' => 'vm_runtime.vm_expiration_soft',
	'expiration_hard' => 'vm_runtime.vm_expiration_hard',
	'state' => 'vm_runtime.vm_state',
	'host_id' => 'vm_runtime.host_id',
	'host_name' => 'me.host_name',
	'di_id' => 'di.id',
	'user_state' => 'vm_runtime.user_state',
	'ip' => 'me.ip',
	'next_boot_ip' => 'vm_runtime.vm_address',
	'ssh_port' => 'vm_runtime.vm_ssh_port',
	'vnc_port' => 'vm_runtime.vm_vnc_port',
	'serial_port' => 'vm_runtime.vm_serial_port',
	'tenant_id' => 'user.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'creation_admin' => 'me.creation_admin',
	'creation_date' => 'me.creation_date',
	'di_version' => 'me.di_version',
	'di_name' => 'me.di_name',
	'di_id' => 'me.di_id',
	'properties' => 'view.properties',
    },

    DI => {
	'id' => 'me.id',
	'disk_image' => 'me.path',
	'version' => 'me.version',
	'osf_id' => 'me.osf_id',
	'osf_name' => 'osf.name',
	'tenant_id' => 'osf.tenant_id',
	'blocked' => 'me.blocked',
	'tags' => 'view.tags',
	'tenant_name' => 'osf.tenant_name',
	'properties' => 'view.properties',
    },

    Administrator => {
	'name' => 'me.name',
	'password' => 'me.password',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'roles' => 'me.get_roles_info',
	'id' => 'me.id',
    },
    Tenant => {
	'name' => 'me.name',
	'id' => 'me.id'
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
 }
};

my $VALUES_NORMALIZATOR = 
{ 
    DI => { disk_image => \&basename_disk_image},

    User => { name => \&normalize_name, 
	      password => \&password_to_token }
};


my $DBIX_JOIN_VALUE = 
{ 
    User => [qw(tenant), { vms => 'vm_runtime'}],
 
    VM => ['di', 'osf', { vm_runtime => 'host' }, { user => 'tenant' }],
  
    Host => ['runtime', 'vms'],

    OSF => [ qw(tenant vms), { dis => 'tags' }],

    DI => [qw(vm_runtimes tags), {osf => 'tenant'}],

    DI_Tag => [{di => {osf => 'tenant'}}],

    Role => [{role_rels => 'inherited'}, { acl_rels => 'acl'}],
		
    Administrator => [qw(tenant), { role_rels => { role => { acl_rels => 'acl' }}}],
    
    ACL => [{ role_rels => { role => { admin_rels => 'admin' }}}],
    
    Tenant_Views_Setup => [ qw(tenant)],

    Administrator_Views_Setup => [ { administrator => 'tenant' }] 
};

my $DBIX_PREFETCH_VALUE = 
{ 
    list => { User => [qw(tenant)],
	      VM => ['di', 'osf', { vm_runtime => 'host' }, { user => 'tenant' }],
	      Host => ['runtime'],
	      OSF => [ qw(tenant)],
	      DI => [{osf => 'tenant'}],
	      DI_Tag => [{di => {osf => 'tenant'}}],
	      Role => [{role_rels => 'inherited'}, { acl_rels => 'acl'}],
	      Administrator => [qw(tenant), { role_rels => { role => { acl_rels => 'acl' }}}],
	      ACL => [{ role_rels => { role => { admin_rels => 'admin' }}}],
	      Tenant_Views_Setup => [ qw(tenant)],
	      Administrator_Views_Setup => [ { administrator => 'tenant' }] },

    details => {User => [qw(tenant)],
		VM => ['di', 'osf', { vm_runtime => 'host' }, { user => 'tenant' }],
		Host => ['runtime'],
		OSF => [ qw(tenant)],
		DI => [{osf => 'tenant'}],
		DI_Tag => [{di => {osf => 'tenant'}}],
		Role => [{role_rels => 'inherited'}, { acl_rels => 'acl'}],
		Administrator => [qw(tenant), { role_rels => { role => { acl_rels => 'acl' }}}],
		ACL => [{ role_rels => { role => { admin_rels => 'admin' }}}],
		Tenant_Views_Setup => [ qw(tenant)],
		Administrator_Views_Setup => [ { administrator => 'tenant' }]}
};

my $DBIX_HAS_ONE_RELATIONSHIPS = 
{ 
    VM => [qw(vm_runtime counters)],
    Host => [qw(runtime counters)]
};

sub BUILD
{
    my $self = shift;

    $DBConfigProvider = QVD::Admin4::DBConfigProvider->new();

    $self->initialize_info_model;

    $self->set_info_by_type_of_action_and_qvd_object(
	'related_views_in_db',$RELATED_VIEWS_IN_DB);

    $self->set_info_by_type_of_action_and_qvd_object(
	'available_nested_queries',$AVAILABLE_NESTED_QUERIES);

    $self->set_info_by_type_of_action_and_qvd_object(
	'available_filters',$AVAILABLE_FILTERS);

    $self->set_info_by_type_of_action_and_qvd_object(
	'available_fields',$AVAILABLE_FIELDS,1);

    $self->set_info_by_type_of_action_and_qvd_object(
	'subchain_filters',$SUBCHAIN_FILTERS);

    $self->set_info_by_type_of_action_and_qvd_object(
	'commodin_filters',$COMMODIN_FILTERS);

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

    $self->set_tenant_fields;  # The last one. It depends on others
}

sub initialize_info_model 
{
    my $self = shift;
    $self->{model_info} =
{ 
    related_views_in_db => [],
    available_filters => [],                                                                 
    available_fields => [],                                                                  
    available_arguments => [],                                                               
    available_nested_queries => [],                                                               
    subchain_filters => [],                                                                 
    commodin_filters => [],                                                                  
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

sub set_info_by_qvd_object
{
    my ($self,$model_info_key,$INFO_REPO) = @_;

    $self->{model_info}->{$model_info_key} = 
	clone $INFO_REPO->{$self->qvd_object};
}

############
###########
##########

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

sub subchain_filters
{
    my $self = shift;
    my $filters = $self->{model_info}->{subchain_filters} // [];
    @$filters;
}

sub commodin_filters
{
    my $self = shift;

    my $filters = $self->{model_info}->{commodin_filters} // [];
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

#################
################
#################

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

sub subchain_filter
{
    my $self = shift;
    my $filter = shift;

    $_ eq $filter && return 1
	for $self->subchain_filters;
    return 0;
}

sub commodin_filter
{
    my $self = shift;
    my $filter = shift;

    $_ eq $filter && return 1
	for $self->commodin_filters;
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

    my $def = $self->default_argument_values->{$arg} // return; 
    return ref($def) ? $def->() : $def;
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
    defined $mapped_field
    || die "No mapping available for field $field";

    return $mapped_field;
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

    my $nettop = nettop_n;
    my $netstart = netstart_n;

    my %ips = map { net_aton($_->ip) => 1 } 
    $DBConfigProvider->db->resultset('VM')->all;

    while ($nettop-- > $netstart) {
        return net_ntoa($nettop) unless $ips{$nettop}
    }
    die "No free IP addresses";
}

##################
######## ACLS
##################

sub get_acls_for_filter
{
    my ($self,$filter) = @_;
    $self->get_acls($ACLS_FOR_FILTERS,$filter);
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
    my ($self,$REPO,$filter) = @_;
    return () unless defined $REPO->{$self->qvd_object};
    return () unless defined $REPO->{$self->qvd_object}->{$filter};
    my @acls = @{$REPO->{$self->qvd_object}->{$filter}};
}

1;
