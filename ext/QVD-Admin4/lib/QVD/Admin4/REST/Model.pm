package QVD::Admin4::REST::Model;
use strict;
use warnings;
use Moose;
use QVD::Config::Network qw(nettop_n netstart_n net_aton net_ntoa);
use QVD::Config;
use File::Basename qw(basename);
use QVD::Admin4::DBConfigProvider;

has 'current_qvd_administrator', is => 'ro', isa => 'QVD::DB::Result::Administrator', required => 1;
has 'qvd_object', is => 'ro', isa => 'Str', required => 1;
has 'type_of_action', is => 'ro', isa => 'Str', required => 1;

my $DBConfigProvider;

my $MODEL_INFO = { 
#available_filters => [],
#available_fields => [],
#available_arguments => [],
#subchain_filters => [],
#mandatory_arguments => [],
#mandatory_filters => [],
#default_argument_values => {},
#default_order_criteria => [],
#filters_to_dbix_format_mapper => {},
#arguments_to_dbix_format_mapper => {},
#fields_to_dbix_format_mapper => {},
#order_criteria_to_dbix_format_mapper => {},
#values_normalizator => {},
#dbix_join_value => {},
#dbix_has_one_relationships => [],
};


my $AVAILABLE_FILTERS = { list => { default => [],
				    VM => [qw(storage id name user_id user_name osf_id osf_name di_tag blocked 
                                              expiration_soft expiration_hard state host_id host_name host_name di_id 
                                              user_state ip next_boot_ip ssh_port vnc_port serial_port tenant_id tenant_name 
                                              creation_admin creation_date )],
				    DI_Tag => [qw(osf_id name id )],
				    User => [qw(id name blocked creation_admin creation_date tenant_id tenant_name )],
				    Host => [qw(id name address blocked frontend backend state vm_id creation_admin creation_date )],
				    DI => [qw(id disk_image version osf_id osf_name tenant_id blocked tenant_name )],
				    OSF => [qw(id name overlay user_storage memory vm_id di_id tenant_id tenant_name )],
				    ACL => [qw(id name role_id admin_id )],
				    Tenant => [qw(id name)],
				    Role => [qw(name acl_id role_id nested_acl_name nested_role_name id admin_id admin_name )],
				    Administrator => [qw(name tenant_id tenant_name role_id acl_id id role_name acl_name )]},

			  all_ids => { default => [],
				       VM => [qw(storage id name user_id user_name osf_id osf_name di_tag blocked expiration_soft 
                                              expiration_hard state host_id host_name host_name di_id user_state ip next_boot_ip ssh_port 
                                              vnc_port serial_port tenant_id tenant_name creation_admin creation_date )],
				       DI_Tag => [qw(osf_id name id )],
				       User => [qw(id name blocked creation_admin creation_date tenant_id tenant_name )],
				       Host => [qw(id name address blocked frontend backend state vm_id creation_admin creation_date )],
				       DI => [qw(id disk_image version osf_id osf_name tenant_id blocked tenant_name )],
				       OSF => [qw(id name overlay user_storage memory vm_id di_id tenant_id tenant_name )],
				       ACL => [qw(id name role_id admin_id )],
				       Role => [qw(name acl_id role_id nested_acl_name nested_role_name id admin_id admin_name )],
				       Tenant => [qw(id name)],
				       Administrator => [qw(name tenant_id tenant_name role_id acl_id id role_name acl_name )]},

			  details => { default => [qw(id tenant_id)],
                                       Host => [qw(id)],
				       Role => [qw(id)],
				       ACL => [qw(id)],
                                       Tenant => [qw(id)] },
			  tiny => { default => [qw(tenant_id)],
                                    Host => [qw()],
				    Role => [qw()],
				    ACL => [qw()],
                                    Tenant => [qw()]},
			  delete => { default => [qw(id tenant_id)],
				      Host => [qw(id)],
				      ACL => [qw(id)],
				      Role => [qw(id)],
				      Tenant => [qw(id)]},
			  update => { default => [qw(id tenant_id)],
				      Host => [qw()],
				      ACL => [qw()],
				      Role => [qw()],
				      Tenant => [qw()]},
			  state => { default => [qw(id tenant_id)],
				     Host => [qw(id)],
				     ACL => [qw(id)],
				     Role => [qw(id)],
				     Tenant => [qw(id)]},
			  'exec' => { default => [qw(id tenant_id)],
				      Host => [qw(id)],
				      ACL => [qw(id)],
				      Role => [qw(id)],
				      Tenant => [qw(id)]} };

my $AVAILABLE_FIELDS = { list => { default => [],
				   OSF => [qw(id name overlay user_storage memory vm_id di_id  number_of_vms number_of_dis )],
				   Role => [qw(name own_acls inherited_acls inherited_roles id )],
				   DI => [qw(id disk_image version osf_id osf_name  blocked tags  properties )],
				   VM => [qw(storage id name user_id user_name osf_id osf_name di_tag blocked expiration_soft expiration_hard 
                                          state host_id host_name host_name di_id user_state ip next_boot_ip ssh_port vnc_port serial_port 
                                           creation_admin creation_date di_version di_name di_id properties )],
				   ACL => [qw(id name roles admins )],
				   Administrator => [qw(name  roles acls id )],
				   Tenant => [qw(id name)],
				   User => [qw(id name  blocked creation_admin creation_date number_of_vms number_of_vms_connected  properties )],
				   Host => [qw(id name address blocked frontend backend state vm_id load creation_admin creation_date number_of_vms_connected number_of_vms properties )],
				   DI_Tag => [qw(osf_id name id )] },
			 tiny => { default => [qw(id name)]},

			 all_ids_actions => { defauly => [],
					      OSF => [qw(id name overlay user_storage memory vm_id di_id  number_of_vms number_of_dis )],
					      Role => [qw(name own_acls inherited_acls inherited_roles id )],
					      DI => [qw(id disk_image version osf_id osf_name  blocked tags  properties )],
					      VM => [qw(storage id name user_id user_name osf_id osf_name di_tag blocked expiration_soft expiration_hard 
                                                     state host_id host_name host_name di_id user_state ip next_boot_ip ssh_port vnc_port serial_port 
                                                      creation_admin creation_date di_version di_name di_id properties )],
					      ACL => [qw(id name roles admins )],
					      Tenant => [qw(id name)],
					      Administrator => [qw(name roles acls id )],
					      User => [qw(id name  blocked creation_admin creation_date number_of_vms number_of_vms_connected  properties )],
					      Host => [qw(id name address blocked frontend backend state vm_id load creation_admin creation_date number_of_vms_connected number_of_vms properties )],
					      DI_Tag => [qw(osf_id name id )] },
			state => { User => [qw(number_of_vms_connected)],
				   VM => [qw(state user_state)],
				   Host => [qw(number_of_vms_connected)]}};

my $MANDATORY_FILTERS = { list => { default => [qw(tenant_id)],
				    Host => [qw()],
				    ACL => [qw()],
				    Role => [qw()],
				    Tenant => [qw()]},
			  details => { default => [qw(id tenant_id)],
				       Host => [qw(id)],
				       ACL => [qw(id)],
				       Role => [qw(id)],
				       Tenant => [qw(id)]}, 
			  tiny => { default => [qw(tenant_id)],
				    Host => [qw()],
				    ACL => [qw()],
				    Role => [qw()],
				    Tenant => [qw()]},
			  delete => { default => [qw(id tenant_id)],
				      Host => [qw(id)],
				      ACL => [qw(id)],
				      Role => [qw(id)],
				      Tenant => [qw(id)]}, 
			  update=> { default => [qw(id tenant_id)],
				     Host => [qw(id)],
				     ACL => [qw(id)],
				     Role => [qw(id)],
				     Tenant => [qw(id)]}, 
			  state => { default => [qw(id tenant_id)],
				     Host => [qw(id)],
				     ACL => [qw(id)],
				     Role => [qw(id)],
				     Tenant => [qw(id)]}, 
			  all_ids => { default => [qw(tenant_id)],
				       Host => [qw()],
				       ACL => [qw()],
				       Role => [qw()],
				       Tenant => [qw()]}, 
			  'exec' => { default => [qw(id tenant_id)],
				      Host => [qw(id)],
				      ACL => [qw(id)],
				      Role => [qw(id)],
				      Tenant => [qw(id)]}};

my $SUBCHAIN_FILTERS = { list => { default => [qw(name)],
				   Administrator => [qw(name role_name acl_name)],
				   Role => [qw(name nested_role_name acl_name)]}};

my $DEFAULT_ORDER_CRITERIA = { tiny => { default =>  [qw(name)] }};

my $AVAILABLE_ARGUMENTS = { User => [qw(name password blocked)],
                            VM => [qw(name di_tag ip blocked expiration_soft expiration_hard storage)],
                            Host => [qw(name address blocked)],
                            OSF => [qw(name memory user_storage)],
                            DI => [qw(update)],
			    Tenant => [qw(name)],
			    Role => [qw(name)],
			    Administrator => [qw(name password)]};

my $MANDATORY_ARGUMENTS = { User => [qw(name password tenant_id)],
			    VM => [qw(name user_id ip osf_id ip di_tag state user_state blocked)],
			    Host => [qw(name address frontend backend blocked state)],
			    OSF => [qw(name memory overlay user_storage tenant_id)],
                            DI => [qw(version disk_image osf_id blocked)],
			    Tenant => [qw(name)],
			    Role => [qw(name)],
                            Administrator => [qw(name password tenant_id)]}; 

my $DEFAULT_ARGUMENT_VALUES = { User => { blocked => 'false' },
                                VM => { di_tag => 'default',
                                        blocked => 'false',
				        user_state => 'stopped',
				        ip => \&get_free_ip},
                                Host => { backend => 'true',
					  frontend => 'true',
					  blocked => 'false',
					  state => 'stopped'},
                                OSF => { memory => \&get_default_memory,
				         overlay => \&get_default_memory,
				         storage => 0 },
				DI => { blocked => 'false' }};    

my $FILTERS_TO_DBIX_FORMAT_MAPPER = 
{

    ACL => {
	'id' => 'me.id',
	'name' => 'me.name',
	'role_id' => 'roles.id',
	'admin_id' => 'admins.id',
    },

    DI_Tag => {
	'osf_id' => 'di.osf_id',
	'name' => 'me.tag',
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
	'host_name' => 'me.host_name',
	'di_id' => 'vm_runtime.current_di_id',
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
	'acl_id' => 'acl_rels.acl_id',
	'nested_role_id' => 'role_rels.inherited_id',
	'acl_name' => 'acls.name',
#	'nested_role_name' => 'role_2.name',
	'id' => 'me.id',
	'admin_id' => 'admin_rels.admin_id',
	'admin_name' => 'admin.name',
    },
    Tenant => {
	'name' => 'me.name',
	'id' => 'me.id'
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
	'roles' => 'me.get_roles_info',
	'admins' => 'me.get_admins_info',
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
	'load' => 'me.load',
	'creation_admin' => 'me.creation_admin',
	'creation_date' => 'me.creation_date',
	'number_of_vms_connected' => 'me.vms_connected',
	'number_of_vms' => 'me.vms_count',
	'properties' => 'me.get_properties_key_value',
    },

    Role => {
	'name' => 'me.name',
	'own_acls' => 'me.get_own_acls_info',
	'inherited_acls' => 'me.get_inherited_acls_info',
	'inherited_roles' => 'me.get_inherited_roles_info_without_me',
	'id' => 'me.id',
    },

    User => {
	'id' => 'me.id',
	'name' => 'me.login',
	'password' => 'me.password',
	'blocked' => 'me.blocked',
	'creation_admin' => 'me.creation_admin',
	'creation_date' => 'me.creation_date',
	'number_of_vms' => 'me.vms_count',
	'number_of_vms_connected' => 'me.vms_connected_count',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'tenant.name',
	'properties' => 'me.get_properties_key_value',
    },

    DI_Tag => {
	'osf_id' => 'di.osf_id',
	'name' => 'me.tag',
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
	'number_of_vms' => 'me.vms_count',
	'number_of_dis' => 'me.dis_count',
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
	'host_name' => 'me.host_name',
	'di_id' => 'vm_runtime.current_di_id',
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
	'properties' => 'me.get_properties_key_value',
    },

    DI => {
	'id' => 'me.id',
	'disk_image' => 'me.path',
	'version' => 'me.version',
	'osf_id' => 'me.osf_id',
	'osf_name' => 'osf.name',
	'tenant_id' => 'osf.tenant_id',
	'blocked' => 'me.blocked',
	'tags' => 'me.tags_get_columns',
	'tenant_name' => 'tenant.name',
	'properties' => 'me.get_properties_key_value',
    },

    Administrator => {
	'name' => 'me.name',
	'password' => 'me.password',
	'tenant_id' => 'me.tenant_id',
	'tenant_name' => 'me.tenant_name',
	'roles' => 'me.get_roles_info',
	'acls' => 'me.get_acls_info',
	'id' => 'me.id',
    },
    Tenant => {
	'name' => 'me.name',
	'id' => 'me.id'
    }
};
my $VALUES_NORMALIZATOR = { DI => { disk_image => \&basename_disk_image},
				     User => { name => \&normalize_name, 
					       password => \&password_to_token }};
my $DBIX_JOIN_VALUE = { User => [qw(tenant)],
                        VM => ['osf', { vm_runtime => 'host' }, { user => 'tenant' }],
			Host => ['runtime', { vms => 'host'}],
			OSF => [ qw(tenant vms dis), { dis => 'tags' }],
			DI => [qw(vm_runtimes tags), {osf => 'tenant'}],
			DI_Tag => [qw(di)],
			Role => [{roles => 'inherited'}, { acl_rels => 'acls'}],
			Administrator => [qw(tenant), { role_rels => { roles => { acl_rels => 'acls' }}}],
			ACL => [{ role_rels => { roles => { admin_rels => 'adminis' }}}]};

my $DBIX_HAS_ONE_RELATIONSHIPS = { VM => [qw(vm_runtime counters)],
                                   Host => [qw(runtime counters)]};

sub BUILD
{
    my $self = shift;

    $DBConfigProvider = QVD::Admin4::DBConfigProvider->new();

    $self->set_info_by_type_of_action_and_qvd_object(
	'available_filters',$AVAILABLE_FILTERS);

    $self->set_info_by_type_of_action_and_qvd_object(
	'available_fields',$AVAILABLE_FIELDS);

    $self->set_tenant_fields
	if $self->current_qvd_administrator->is_superadmin;

    $self->set_info_by_type_of_action_and_qvd_object(
	'subchain_filters',$SUBCHAIN_FILTERS);

    $self->set_info_by_type_of_action_and_qvd_object(
	'default_order_criteria',$DEFAULT_ORDER_CRITERIA);

    $self->set_info_by_qvd_object(
	'available_arguments',$AVAILABLE_ARGUMENTS);

    $self->set_info_by_qvd_object(
	'mandatory_arguments',$MANDATORY_ARGUMENTS);

    $self->set_info_by_qvd_object(
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
	'values_normalizator',$VALUES_NORMALIZATOR);

    $self->set_info_by_qvd_object(
	'dbix_join_value',$DBIX_JOIN_VALUE);

    $self->set_info_by_qvd_object(
	'dbix_has_one_relationships',$DBIX_HAS_ONE_RELATIONSHIPS);
}

sub set_tenant_fields
{
    my $self = shift;

    push @{$MODEL_INFO->{available_fields}},'tenant_id'
	if defined $FIELDS_TO_DBIX_FORMAT_MAPPER->{$self->qvd_object}->{tenant_id};

    push @{$MODEL_INFO->{available_fields}},'tenant_name'
	if defined $FIELDS_TO_DBIX_FORMAT_MAPPER->{$self->qvd_object}->{tenant_name};
}

sub set_info_by_type_of_action_and_qvd_object
{
    my ($self,$model_info_key,$INFO_REPO) = @_;

    if (defined $INFO_REPO->{$self->type_of_action} )
    {
	$MODEL_INFO->{$model_info_key} = 
	    $INFO_REPO->{$self->type_of_action}->{$self->qvd_object} //
	    $INFO_REPO->{$self->type_of_action}->{default};
    }
}

sub set_info_by_qvd_object
{
    my ($self,$model_info_key,$INFO_REPO) = @_;

    $MODEL_INFO->{$model_info_key} = 
	$INFO_REPO->{$self->qvd_object};
}

############
###########
##########

sub available_filters
{
    my $self = shift;
   my $filters =  $MODEL_INFO->{available_filters} // [];

    @$filters;
}

sub subchain_filters
{
    my $self = shift;

    my $filters = $MODEL_INFO->{subchain_filters} // [];
    @$filters;
}

sub default_order_criteria
{
    my $self = shift;

    my $order_criteria = $MODEL_INFO->{default_order_criteria} // [];
    @$order_criteria;
}

sub available_arguments
{
    my $self = shift;
    my $args = $MODEL_INFO->{available_arguments} // [];
    @$args;
}

sub available_fields
{
    my $self = shift;

    my $fields = $MODEL_INFO->{available_fields} // [];
    @$fields;
}

sub mandatory_arguments
{
    my $self = shift;
    my $args =  $MODEL_INFO->{mandatory_arguments} // [];
    @$args;
}

sub mandatory_filters
{
    my $self = shift;

    my $filters = $MODEL_INFO->{mandatory_filters} // [];
    @$filters;
}

sub default_argument_values
{
    my $self = shift;
    return $MODEL_INFO->{default_argument_values} || {};
}


sub filters_to_dbix_format_mapper
{
    my $self = shift;
    return $MODEL_INFO->{filters_to_dbix_format_mapper} || {};
}

sub order_criteria_to_dbix_format_mapper
{
    my $self = shift;
    return $MODEL_INFO->{order_criteria_to_dbix_format_mapper} || {};
}


sub arguments_to_dbix_format_mapper
{
    my $self = shift;
    return $MODEL_INFO->{arguments_to_dbix_format_mapper} || {};
}

sub fields_to_dbix_format_mapper
{
    my $self = shift;
    return $MODEL_INFO->{fields_to_dbix_format_mapper} || {};
}

sub values_normalizator
{
    my $self = shift;
    return $MODEL_INFO->{values_normalizator} || {};
}

sub dbix_join_value
{
    my $self = shift;
    return $MODEL_INFO->{dbix_join_value} || [];
}

sub dbix_has_one_relationships
{
    my $self = shift;
    my $rels = $MODEL_INFO->{dbix_has_one_relationships} // [];
    @$rels;
}

#################
################
#################


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

    $self->values_normalizator->{$self->qvd_object} || return $value;
    my $norm = $self->values_normalizator->{$self->qvd_object}->{$key} // 
	return $value; 
    return ref($norm) ? $self->$norm($value) : $norm;
}

sub get_default_memory { cfg('osf.default.memory'); }
sub get_default_overlay { cfg('osf.default.overlay'); }
sub basename_disk_image { basename(+shift); };

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
    
1;
