package QVD::Admin4::REST::Model;
use strict;
use warnings;
use Moose;
use QVD::Config;
use File::Basename qw(basename);

has 'current_qvd_administrator', is => 'ro', isa => 'QVD::DB::Result::Administrator', required => 1;
has 'qvd_object', is => 'ro', isa => 'Str', required => 1;
has 'type_of_action', is => 'ro', isa => 'Str', required => 1;


my $MODEL_INFO = { avaliable_filters => [],
		   available_arguments => [],
		   available_fields => [],
		   subchain_filters => [],
		   mandatory_arguments => [],
		   mandatory_filters => [],
		   default_argument_values => {},
		   default_order_criteria => [],
		   filters_to_dbix_format_mapper => {},
		   arguments_to_dbix_format_mapper => {},
		   fields_to_dbix_format_mapper => {},
		   argument_values_normalizator => {},
		   dbix_join_value => {},
		   dbix_has_one_relationships => {},
};

my $AVAILABLE_FILTERS = { details => [qw(id tenant_id)],
			  tiny => [qw(tenant_id)],
			  delete => [qw(id tenant_id)],
			  update => [qw(id tenant_id)],
			  state => [qw(id tenant_id)],
			  'exec' => [qw(id tenant_id)] };

my $MANDATORY_FILTERS = { list => [qw(tenant_id)],
			  details => [qw(id tenant_id)], 
			  tiny => [qw(tenant_id)],
			  delete => [qw(id tenant_id)], 
			  update=> [qw(id tenant_id)], 
			  state => [qw(id tenant_id)], 
			  all_ids => [qw(tenant_id)], 
			  'exec' => [qw(id tenant_id)]};

my $SUBCHAIN_FILTERS = { list => [qw(name)] };

my $AVAILABLE_FIELDS = { tiny => [qw(id name)],
			 all_ids_actions => [qw(id)]};

my $DEFAULT_ORDER_CRITERIA = { tiny => [qw(name)]};

my $AVAILABLE_ARGUMENTS = { User => [qw(name password blocked)],
                            VM => [qw(name di_tag blocked expiration_soft expiration_hard storage)],
                            Host => [qw(name address blocked)],
                            OSF => [qw(name memory user_storage)],
                            DI => [qw(update)],
			    Tenant => [qw(name)],
			    Role => [qw(name)],
			    Administrator => [qw(name password)]};

my $MANDATORY_ARGUMENTS = { User => [qw(name password tenant_id)],
			    VM => [qw(name user_id osf_id ip di_tag state user_state blocked)],
			    Host => [qw(name address frontend backend blocked state)],
			    OSF => [qw(name memory overlay user_storage tenant_id)],
                            DI => [qw(version disk_image osf_id blocked)],
			    Tenant => [qw(name)],
			    Role => [qw(name)],
                            Administrator => [qw(name password tenant_id)]}; 

my $DEFAULT_ARGUMENT_VALUES = { User => { blocked => 'false' },
                                VM => { di_tag => 'default',
                                        blocked => 'false',
				        user_state => 'stopped' },
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
	'acl_id' => 'acls.acl_id',
	'nested_role_id' => 'roles.role_id',
	'acl_name' => 'acl.name',
	'nested_role_name' => 'role_2.name',
	'id' => 'me.id',
	'admin_id' => 'admins.admin_id',
	'admin_name' => 'admin.name',
    },
    Tenant => {
	'name' => 'me.name',
	'id' => 'me.id'
    }
};

my $ARGUMENTS_TO_DBIX_FORMAT_MAPPER = 
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
my $ARGUMENT_VALUES_NORMALIZATOR = { DI => { disk_image => \&basename_disk_image},
				     User => { name => \&normalize_name, 
					       password => \&password_to_token }};
my $DBIX_JOIN_VALUE = { User => [qw(tenant)],
                        VM => ['osf', { vm_runtime => 'host' }, { user => 'tenant' }],
			Host => ['runtime',{ vms => 'host'}],
			OSF => [ qw(tenant vms dis), { dis => 'tags' }],
			DI => [qw(vm_runtimes tags), {osf => 'tenant'}],
			DI_Tag => [qw(di)],
			Role => [{roles => 'inherited', acls => 'acl'}],
			Administrator => [qw(tenant), { roles => { role => { acls => 'acl' }}}],
			ACL => [{ roles => { role => { administrators => 'administrator' }}}]};

my $DBIX_HAS_ONE_RELATIONSHIPS = { VM => [qw(vm_runtime counters)],
                                   Host => [qw(runtime counters)]};
	      
sub BUILD
{
    my $self = shift;

    $self->set_avaliable_filters;
    $self->set_available_arguments;
    $self->set_available_fields;
    $self->subchain_filters;
    $self->set_mandatory_arguments;
    $self->set_mandatory_filters;
    $self->set_default_argument_values;
    $self->set_default_order_criteria;
    $self->set_filters_to_dbix_format_mapper;
    $self->set_arguments_to_dbix_format_mapper;
    $self->set_fields_to_dbix_format_mapper;
    $self->set_argument_values_normalizator;
    $self->set_dbix_join_value;
    $self->set_dbix_has_one_relationships;

};

sub set_avaliable_filters
{
    my $self = shift;

    $MODEL_INFO->{avaliable_filters} = 
	$AVAILABLE_FILTERS->{$self->qvd_object} //
	$AVAILABLE_FILTERS->{$self->type_of_action} // [];

}

sub set_subchain_filters
{
    my $self = shift;

    if ($self->qvd_object eq 'Administrator' && $self->type_of_action eq 'list') 
    { $MODEL_INFO->{subchain_filters} = [qw(name role_name acl_name)]; return;}

    if ($self->qvd_object eq 'Role' && $self->type_of_action eq 'list') 
    { $MODEL_INFO->{subchain_filters} = [qw(name nested_role_name acl_name)]; return;}

    $MODEL_INFO->{subchain_filters} = 
	$SUBCHAIN_FILTERS->{$self->qvd_object} // 
	$SUBCHAIN_FILTERS->{$self->type_of_action} // [];
}

sub set_default_order_criteria
{
    my $self = shift;
    $MODEL_INFO->{default_order_criteria} = 
	$DEFAULT_ORDER_CRITERIA->{$self->qvd_object} //
	$DEFAULT_ORDER_CRITERIA->{$self->type_of_action} // [];
}

sub set_available_arguments
{
    my $self = shift;

    $MODEL_INFO->{avaliable_arguments} = 
	$AVAILABLE_ARGUMENTS->{$self->qvd_object} //
	$AVAILABLE_ARGUMENTS->{$self->type_of_action} // [];

}

sub set_available_fields
{
    my $self = shift;
    
    if ($self->type_of_action eq 'state') 
    { $self->set_available_fields_for_state_action; return;}

    $MODEL_INFO->{avaliable_fields} = 
	$AVAILABLE_FIELDS->{$self->qvd_object} //
	$AVAILABLE_FIELDS->{$self->type_of_action} // [];
}

sub set_available_fields_for_state_action
{
    my $self = shift;

    if ($self->qvd_object eq 'User')
    {
	$MODEL_INFO->{avaliable_fields} = [qw(number_of_vms_connected)];
    }
    elsif ($self->qvd_object eq 'VM')
    {
	$MODEL_INFO->{avaliable_fields} = [qw(state user_state)];
    }
    elsif ($self->qvd_object eq 'Host')
    {
	$MODEL_INFO->{avaliable_fields} = [qw(number_of_vms_connected)];
    }
}

sub set_mandatory_arguments
{
    my $self = shift;
    $MODEL_INFO->{mandatory_arguments} = 
	$MANDATORY_ARGUMENTS->{$self->qvd_objects} // 
	$MANDATORY_ARGUMENTS->{$self->type_of_action} // [];
}

sub set_mandatory_filters
{
    my $self = shift;

    $MODEL_INFO->{mandatory_filters} = 
	$MANDATORY_FILTERS->{$self->qvd_objects} // 
	$MANDATORY_FILTERS->{$self->type_of_action} // [];
}

sub set_default_argument_values
{
    my $self = shift;
    $MODEL_INFO->{default_argument_values} = 
	$DEFAULT_ARGUMENT_VALUES->{$self->qvd_object} // 
	$DEFAULT_ARGUMENT_VALUES->{$self->type_of_action} // {};
}


sub set_filters_to_dbix_format_mapper
{
    my $self = shift;
    $MODEL_INFO->{filters_to_dbix_format_mapper} = 
	$FILTERS_TO_DBIX_FORMAT_MAPPER->{$self->qvd_object} // 
	$FILTERS_TO_DBIX_FORMAT_MAPPER->{$self->type_of_action} // {};

}

sub set_arguments_to_dbix_format_mapper
{
    my $self = shift;
    $MODEL_INFO->{arguments_to_dbix_format_mapper} = 
	$ARGUMENTS_TO_DBIX_FORMAT_MAPPER->{$self->qvd_object} //
	$ARGUMENTS_TO_DBIX_FORMAT_MAPPER->{$self->type_of_action} // {};

}

sub set_fields_to_dbix_format_mapper
{
    my $self = shift;
    $MODEL_INFO->{fields_to_dbix_format_mapper} = 
	$FIELDS_TO_DBIX_FORMAT_MAPPER->{$self->qvd_object} // 
	$FIELDS_TO_DBIX_FORMAT_MAPPER->{$self->type_of_action} // {};

}

sub set_argument_values_normalizator
{
    my $self = shift;
    $MODEL_INFO->{argument_values_normalizator} = 
	$ARGUMENT_VALUES_NORMALIZATOR->{$self->qvd_object} // 
	$ARGUMENT_VALUES_NORMALIZATOR->{$self->type_of_action} // {};

}

sub set_dbix_join_value
{
    my $self = shift;
    $MODEL_INFO->{dbix_join_value} = 
	$DBIX_JOIN_VALUE->{$self->qvd_object} // 
	$DBIX_JOIN_VALUE->{$self->type_of_action} // [];
}

sub set_dbix_has_one_relationships
{
    my $self = shift;
    $MODEL_INFO->{dbix_has_one_relationships} = 
	$DBIX_HAS_ONE_RELATIONSHIPS->{$self->qvd_object} // 
	$DBIX_HAS_ONE_RELATIONSHIPS->{$self->type_of_action} // [];

}

############
###########
##########

sub get_avaliable_filters
{
    my $self = shift;

   my $filters =  $MODEL_INFO->{avaliable_filters} // [];
    @$filters;
}

sub get_subchain_filters
{
    my $self = shift;

    my $filters = $MODEL_INFO->{subchain_filters} // [];
    @$filters;
}

sub get_default_order_criteria
{
    my $self = shift;
    my $order_criteria =  $MODEL_INFO->{default_order_criteria} // [];
    @$order_criteria;
}

sub get_available_arguments
{
    my $self = shift;
    my $args = $MODEL_INFO->{avaliable_arguments} // [];
    @$args;
}

sub get_available_fields
{
    my $self = shift;
    my $fields =  $MODEL_INFO->{avaliable_fields} // [];
    @$fields;
}

sub get_mandatory_arguments
{
    my $self = shift;
    my $args =  $MODEL_INFO->{mandatory_arguments} // [];
    @$args;
}

sub get_mandatory_filters
{
    my $self = shift;

    my $filters = $MODEL_INFO->{mandatory_filters} // [];
    @$filters;
}

sub get_default_argument_values
{
    my $self = shift;
    return $MODEL_INFO->{default_argument_values} || {};
}


sub get_filters_to_dbix_format_mapper
{
    my $self = shift;
    return $MODEL_INFO->{filters_to_dbix_format_mapper} || {};
}

sub get_arguments_to_dbix_format_mapper
{
    my $self = shift;
    return $MODEL_INFO->{arguments_to_dbix_format_mapper} || {};
}

sub get_fields_to_dbix_format_mapper
{
    my $self = shift;
    return $MODEL_INFO->{fields_to_dbix_format_mapper} || {};
}

sub get_argument_values_normalizator
{
    my $self = shift;
    return $MODEL_INFO->{argument_values_normalizator} || {};
}

sub get_dbix_join_value
{
    my $self = shift;
    return $MODEL_INFO->{dbix_join_value} || [];
}

sub get_dbix_has_one_relationships
{
    my $self = shift;
    my $rels = $MODEL_INFO->{dbix_has_one_relationships} // [];
    @$rels;
}

#################
################
#################


sub is_avaliable_filter
{
    my $self = shift;
    my $filter = shift;
    $_ eq $filter && return 1
	for $self->get_avaliable_filters;

    return 0;
}

sub is_subchain_filter
{
    my $self = shift;
    my $filter = shift;

    $_ eq $filter && return 1
	for $self->get_subchain_filters;
    return 0;
}

sub is_default_order_criterium
{
    my $self = shift;
    my $order_criterium = shift;
    $_ eq $order_criterium && return 1
	for $self->get_default_order_criteria;
    return 1;
}

sub is_available_argument
{
    my $self = shift;
    my $argument = shift;

    $_ eq $argument && return 1
	for $self->get_available_arguments;

    return 0;
}

sub is_available_field
{
    my $self = shift;
    my $field = shift;
    $_ eq $field && return 1
	for $self->get_available_fields;

    return 0;
}

sub is_mandatory_argument
{
    my $self = shift;
    my $argument = shift;

    $_ eq $argument && return 1
	for $self->get_mandatory_arguments;
    return 0;
}

sub is_mandatory_filter
{
    my $self = shift;
    my $filter = shift;
    $_ eq $filter && return 1
	for $self->get_mandatory_filters;
    return 0;
}

sub get_default_argument_value
{
    my $self = shift;
    my $arg = shift;

    return $self->get_default_argument_values->{$arg};
}


sub map_filter_to_dbix_format
{
    my $self = shift;
    my $filter = shift;

    return $self->get_filters_to_dbix_format_mapper->{$filter};
}

sub map_argument_to_dbix_format
{
    my $self = shift;
    my $argument = shift;

    return $self->get_arguments_to_dbix_format_mapper->{$argument};
}

sub map_field_to_dbix_format
{
    my $self = shift;
    my $field = shift;

    return $self->get_fields_to_dbix_format_mapper->{$field};
}

sub map_argument_value_normalized
{
    my $self = shift;
    my $argument = shift;

    return $self->get_argument_values_normalizator->{$argument};
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
    
1;
