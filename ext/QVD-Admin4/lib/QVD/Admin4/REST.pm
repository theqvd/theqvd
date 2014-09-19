package QVD::Admin4::REST;
use strict;
use warnings;
use Moose;
use QVD::Admin4;
use QVD::Admin4::REST::Request;
use QVD::Admin4::REST::Request::VM;
use QVD::Admin4::REST::Request::DI;
use QVD::Admin4::REST::Request::OSF;
use QVD::Admin4::REST::Request::Host;
use QVD::Admin4::REST::Request::User;
use QVD::Admin4::REST::Request::DI_Tag;
use QVD::Admin4::REST::Request::Config_Field;
use QVD::Admin4::REST::Request::Administrator;
use QVD::Admin4::REST::Request::Tenant;
use QVD::Admin4::REST::Request::Role;
use QVD::Admin4::REST::Request::ACL;
use QVD::Admin4::REST::Response;
use QVD::Config::Core;
use QVD::Admin4::Exception;
use Moose::Meta::Class;

my ($QVD_ADMIN, $ACTIONS);

sub BUILD
{
    my $self = shift;
    $QVD_ADMIN = QVD::Admin4->new();
    $ACTIONS = $self->load_actions // 
	die "Unable to load actions";
}

sub load_user
{
    my ($self,%params) = @_;

    return undef unless 
	defined $params{tenant} && 
	defined $params{login};

    $params{name} = delete $params{login};
    $params{tenant_id} = delete $params{tenant};

    my $uid = 
	eval { $QVD_ADMIN->get_credentials(%params) } // undef;
}

sub validate_user
{
    my ($self,%params) = @_;

    return undef unless 
	defined $params{password} && 
	defined $params{login};

    $params{name} = delete $params{login};

    my $uid = 
	eval { $QVD_ADMIN->get_credentials(%params) } // undef;
}

sub _admin
{
   my ($self,$json) = @_;

   my $result = eval { $QVD_ADMIN->_exec($self->get_request($json)) } // {};
   print $@ if $@;
   my $status = ($@ && (( $@->can('code') && $@->code) || 1)) || 0;
   my $failures = ($@ && $@->can('failures')) ? $@->failures  : {};
   
   my $response = QVD::Admin4::REST::Response->new(status   => $status,
                                                   result   => $result,
                                                   failures => $failures);
   $response->json;
}

sub get_request 
{ 
    my ($self, $json) = @_;

    $ACTIONS->{$json->{action}} || QVD::Admin4::Exception->throw(code => 5);

    my $table = $ACTIONS->{$json->{action}}->{table};
    my $class = 'QVD::Admin4::REST::Request';
    $class .= "::$table" if $table;

    $class->new(administrator => $QVD_ADMIN->administrator,
		json => $json, 
		config => $ACTIONS->{$json->{action}}, 
		db => $QVD_ADMIN->_db );
}

sub load_actions
{
    my $self = shift;

    my $cfg=Config::Properties->new;
    $cfg->load(*DATA);

    my $actions = $cfg->splitToTree(qr/\./);

    while (my ($action, $params) = each %{$actions})
    {	
	$params->{filters} = { map { $_ => 1 } (split ',', $params->{filters})} 
	if $params->{filters};

	$params->{mandatory} = { map { $_ => 1 } (split ',', $params->{mandatory})} 
	if $params->{mandatory};

	$params->{free} = { map { $_ => 1 } (split ',', $params->{free})} 
	if $params->{free};
	
	$params->{arguments} = { map { $_ => 1 } (split ',', $params->{arguments})} 
	if $params->{arguments};
	
	$params->{acls} = { map { $_ => 1 } (split ',', $params->{acls})} 
	if $params->{acls};
	
	$params->{order_by} = [split ',', $params->{order_by}] 
	    if $params->{order_by};
	
	$actions->{$action} = $params;
    }

    $actions;
}

1;

__DATA__

user_get_list.type=list
user_get_list.roles=superadmin,admin,user
user_get_list.acls=see_user
user_get_list.table=User
user_get_list.filters=name,tenant
user_get_list.mandatory=tenant
user_get_list.free=name

user_tiny_list.type=tiny
user_tiny_list.roles=superadmin,admin,user
user_tiny_list.acls=see_user
user_tiny_list.table=User
user_tiny_list.order_by=name
user_tiny_list.filters=tenant
user_tiny_list.mandatory=tenant

user_all_ids.type=all_ids
user_all_ids.roles=superadmin,admin,user
user_all_ids.acls=see_user
user_all_ids.table=User
user_all_ids.filters=name,tenant
user_all_ids.mandatory=tenant
user_all_ids.free=name

user_get_details.type=details
user_get_details.roles=superadmin,admin,user
user_get_details.acls=see_user
user_get_details.table=User
user_get_details.filters=id,tenant
user_get_details.mandatory=id,tenant

user_get_state.type=state
user_get_state.roles=superadmin,admin,user
user_get_state.acls=see_user
user_get_state.table=User
user_get_state.filters=id,tenant
user_get_state.mandatory=id,tenant

user_update.type=update
user_update.roles=admin,superadmin
user_update.acls=update_user
user_update.table=User
user_update.arguments=name,password,blocked
user_update.filters=id,tenant
user_update.mandatory=id,tenant

user_update_custom.type=update_custom
user_update_custom.roles=admin,superadmin
user_update_custom.acls=update_user
user_update_custom.table=User
user_update_custom.arguments=name,password,blocked
user_update_custom.filters=id,tenant
user_update_custom.mandatory=id,tenant

user_create.type=create
user_create.roles=admin,superadmin
user_create.acls=create_user
user_create.table=User
user_create.arguments=name,password,role,blocked,tenant
user_create.default.blocked=false
user_create.default.role=3

user_delete.type=delete
user_delete.roles=admin,superadmin
user_delete.acls=delete_user
user_delete.table=User
user_delete.filters=id,tenant
user_delete.mandatory=id,tenant

vm_get_list.type=list
vm_get_list.roles=superadmin,admin,user
vm_get_list.table=VM
vm_get_list.filters=name,user_id,osf_id,di_id,host_id,tenant,state
vm_get_list.mandatory=tenant
vm_get_list.free=name

vm_all_ids.type=all_ids
vm_all_ids.roles=superadmin,admin,user
vm_all_ids.table=VM
vm_all_ids.filters=name,user_id,osf_id,di_id,host_id,tenant,state
vm_all_ids.mandatory=tenant
vm_all_ids.free=name

vm_tiny_list.type=tiny
vm_tiny_list.roles=superadmin,admin,user
vm_tiny_list.table=VM
vm_tiny_list.order_by=name
vm_tiny_list.filters=tenant
vm_tiny_list.mandatory=tenant

vm_get_details.type=details
vm_get_details.roles=superadmin,admin,user
vm_get_details.table=VM
vm_get_details.filters=id,tenant
vm_get_details.mandatory=id,tenant

vm_get_state.type=state
vm_get_state.roles=superadmin,admin,user
vm_get_state.table=VM
vm_get_state.filters=id,tenant
vm_get_state.mandatory=id,tenant

vm_update.type=update
vm_update.roles=admin,superadmin
vm_update.table=VM
vm_update.arguments=name,di_tag,blocked,expiration_soft,expiration_hard
vm_update.filters=id,tenant
vm_update.mandatory=id,tenant

vm_update_custom.type=update_custom
vm_update_custom.roles=admin,superadmin
vm_update_custom.table=VM
vm_update_custom.arguments=name,di_tag,blocked,expiration_soft,expiration_hard
vm_update_custom.filters=id,tenant
vm_update_custom.mandatory=id,tenant

vm_user_disconnect.type=exec
vm_user_disconnect.roles=admin,superadmin
vm_user_disconnect.table=VM
vm_user_disconnect.filters=id,tenant
vm_user_disconnect.mandatory=id,tenant

vm_start.type=exec
vm_start.roles=admin,superadmin
vm_start.table=VM
vm_start.filters=id,tenant
vm_start.mandatory=id,tenant

vm_stop.type=exec
vm_stop.roles=admin,superadmin
vm_stop.table=VM
vm_stop.filters=id,tenant
vm_stop.mandatory=id,tenant

vm_create.type=create
vm_create.roles=admin,superadmin
vm_create.table=VM
vm_create.arguments=name,user_id,osf_id,ip,storage,di_tag,state,user_state,blocked
vm_create.default.di_tag=default
vm_create.default.blocked=false
vm_create.default.user_state=disconnected
vm_create.default.state=stopped
vm_create.default.SYSTEM.ip=_get_free_ip

vm_delete.type=delete
vm_delete.roles=admin,superadmin
vm_delete.table=VM
vm_delete.filters=id,tenant
vm_delete.mandatory=id,tenant

host_get_list.type=list
host_get_list.roles=superadmin,admin,user
host_get_list.table=Host
host_get_list.filters=name,vm_id
host_get_list.free=name

host_all_ids.type=all_ids
host_all_ids.roles=superadmin,admin,user
host_all_ids.table=Host
host_all_ids.filters=name,vm_id
host_all_ids.free=name

host_tiny_list.type=tiny
host_tiny_list.roles=superadmin,admin,user
host_tiny_list.table=Host
host_tiny_list.order_by=name

host_get_details.type=details
host_get_details.roles=superadmin,admin,user
host_get_details.table=Host
host_get_details.filters=id

host_get_state.type=state
host_get_state.roles=superadmin,admin,user
host_get_state.table=Host
host_get_state.filters=id

host_update.type=update
host_update.roles=admin,superadmin
host_update.table=Host
host_update.arguments=name,address,blocked
host_update.filters=id
host_update.mandatory=id

host_update_custom=update_custom
host_update_custom.roles=admin,superadmin
host_update_custom.table=Host
host_update_custom.arguments=name,address,blocked
host_update_custom.filters=id
host_update_custom.mandatory=id

host_create.type=create
host_create.roles=admin,superadmin
host_create.table=Host
host_create.arguments=name,address,frontend,backend,blocked,state
host_create.default.backend=1
host_create.default.frontend=1
host_create.default.blocked=false
host_create.default.state=stopped

host_delete.type=delete
host_delete.roles=admin,superadmin
host_delete.table=Host
host_delete.filters=id
host_delete.mandatory=id

osf_get_list.type=list
osf_get_list.roles=superadmin,admin,user
osf_get_list.table=OSF
osf_get_list.filters=name,vm_id,di_id,tenant
osf_get_list.mandatory=tenant
osf_get_list.free=name

osf_all_ids.type=all_ids
osf_all_ids.roles=superadmin,admin,user
osf_all_ids.table=OSF
osf_all_ids.filters=name,vm_id,di_id,tenant
osf_all_ids.mandatory=tenant
osf_all_ids.free=name

osf_tiny_list.type=tiny
osf_tiny_list.roles=superadmin,admin,user
osf_tiny_list.table=OSF
osf_tiny_list.filters=tenant
osf_tiny_list.mandatory=tenant
osf_tiny_list.order_by=name

osf_get_details.type=details
osf_get_details.roles=superadmin,admin,user
osf_get_details.table=OSF
osf_get_details.filters=id,tenant
osf_get_details.mandatory=id,tenant

osf_update.type=update
osf_update.roles=admin,superadmin
osf_update.table=OSF
osf_update.arguments=name,memory,user_storage
osf_update.filters=id,tenant
osf_update.mandatory=id,tenant

osf_update_custom.type=update_custom
osf_update_custom.roles=admin,superadmin
osf_update_custom.table=OSF
osf_update_custom.arguments=name,memory,user_storage
osf_update_custom.filters=id,tenant
osf_update_custom.mandatory=id,tenant

osf_create.type=create
osf_create.roles=admin,superadmin
osf_create.table=OSF
osf_create.arguments=name,memory,overlay,user_storage,tenant
osf_create.default.SYSTEM.memory=get_default_memory
osf_create.default.SYSTEM.overlay=get_default_overlay
osf_create.default.user_storage=0

osf_delete.type=delete
osf_delete.roles=admin,superadmin
osf_delete.table=OSF
osf_delete.filters=id,tenant
osf_delete.mandatory=id,tenant

di_get_list.type=list
di_get_list.roles=superadmin,admin,user
di_get_list.table=DI
di_get_list.filters=disk_image,osf_id,tenant
di_get_list.mandatory=tenant
di_get_list.free=disk_image

di_all_ids.type=all_ids
di_all_ids.roles=superadmin,admin,user
di_all_ids.table=DI
di_all_ids.filters=disk_image,osf_id,tenant
di_all_ids.mandatory=tenant
di_all_ids.free=disk_image

di_tiny_list.type=tiny
di_tiny_list.roles=superadmin,admin,user
di_tiny_list.table=DI
di_tiny_list.filters=tenant,osf_id
di_tiny_list.mandatory=tenant
di_tiny_list.order_by=name

di_get_list.type=list
di_get_details.roles=superadmin,admin,user
di_get_details.table=DI
di_get_details.filters=id,tenant
di_get_details.mandatory=id,tenant

di_update.type=update
di_update.roles=admin,superadmin
di_update.table=DI
di_update.arguments=blocked
di_update.filters=id,tenant
di_update.mandatory=id,tenant

di_update_custom.type=update_custom
di_update_custom.roles=admin,superadmin
di_update_custom.table=DI
di_update_custom.arguments=blocked
di_update_custom.filters=id,tenant
di_update_custom.mandatory=id,tenant

di_create.type=create
di_create.roles=admin,superadmin
di_create.table=DI
di_create.arguments=version,disk_image,osf_id,blocked
di_create.default.SYSTEM.version=get_default_version

di_delete.type=delete
di_delete.roles=admin,superadmin
di_delete.table=DI
di_delete.filters=id,tenant
di_delete.mandatory=id,tenant

tag_tiny_list.type=tiny
tag_tiny_list.roles =superadmin,admin,user
tag_tiny_list.table=DI_Tag
tag_tiny_list.filters=osf_id
tag_tiny_list.order_by=name

tag_all_ids.type=all_ids
tag_all_ids.roles=superadmin,admin,user
tag_all_ids.table=DI_Tag
tag_all_ids.filters=osf_id
tag_all_ids.mandatory=osf_id

config_field_update.type=update
config_field_update.roles =admin,superadmin
config_field_update.table =Config_Field
config_field_update.filters=id,tenant
config_field_update.mandatory=id,tenant
config_field_update.arguments=update,get_list,get_details,filter_list,filter_details,filter_options

config_field_get_list.type=list
config_field_get_list.roles =superadmin,admin
config_field_get_list.table =Config_Field
config_field_get_list.filters=qvd_obj,name,tenant
config_field_get_list.mandatory=tenant
config_field_get_list.free=name

config_field_get_details.type=details
config_field_get_details.roles =superadmin,admin
config_field_get_details.table =Config_Field
config_field_get_details.filters=id,tenant
config_field_get_details.mandatory=id,tenant

admin_tiny_list.type=tiny
admin_tiny_list.roles =superadmin,admin
admin_tiny_list.table =Administrator
admin_tiny_list.filters=tenant
admin_tiny_list.order_by=name

admin_get_list.type=list
admin_get_list.roles =superadmin,admin
admin_get_list.table =Administrator
admin_get_list.filters=tenant,name,acl_id,acl_name,role_id,role_name
admin_get_list.free=name,acl_name,role_name
admin_get_list.order_by=name

admin_get_details.type=details
admin_get_details.roles =superadmin,admin
admin_get_details.table =Administrator
admin_get_details.filters=tenant,id
admin_get_details.mandatory=tenant,id
admin_get_details.order_by=name

admin_create.type=create
admin_create.roles =superadmin,admin
admin_create.table =Administrator
admin_create.arguments =name,password,tenant

admin_update.type=update
admin_update.roles =superadmin,admin
admin_update.table =Administrator
admin_update.filters=id,tenant
admin_update.mandatory=id,tenant
admin_update.arguments=name,password

admin_delete.type=delete
admin_delete.roles=admin,superadmin
admin_delete.table=Administrator
admin_delete.filters=id,tenant
admin_delete.mandatory=id,tenant

tenant_tiny_list.type=tiny
tenant_tiny_list.roles =superadmin
tenant_tiny_list.table =Tenant
tenant_tiny_list.filters=tenant
tenant_tiny_list.order_by=name

tenant_get_list.type=list
tenant_get_list.roles =superadmin
tenant_get_list.table =Tenant
tenant_get_list.filters=tenant,name
tenant_get_list.free=name
tenant_get_list.order_by=name

tenant_get_details.type=tdetails
tenant_get_details.roles =superadmin
tenant_get_details.table =Tenant
tenant_get_details.filters=tenant,id
tenant_get_details.mandatory=id

tenant_update.type=update
tenant_update.roles =superadmin
tenant_update.table =Tenant
tenant_update.filters=id,tenant
tenant_update.mandatory=id
tenant_update.arguments=name

tenant_create.type=create
tenant_create.roles =superadmin
tenant_create.table =Tenant
tenant_create.arguments =name

tenant_delete.type=delete
tenant_delete.roles=superadmin
tenant_delete.table=Tenant
tenant_delete.filters=id,tenant
tenant_delete.mandatory=id,tenant

role_tiny_list.type=tiny
role_tiny_list.roles =superadmin,admin
role_tiny_list.table =Role
role_tiny_list.order_by=name

role_get_list.type=tiny
role_get_list.roles =superadmin,admin
role_get_list.table =Role
role_get_list.filters=name,acl_id,acl_name,nested_role_id,nested_role_name
role_get_list.free=name,acl_name,nested_role_name

role_get_details.type=details
role_get_details.roles =superadmin,admin
role_get_details.table =Role
role_get_details.filters=id

acl_tiny_list.type=tiny
acl_tiny_list.roles =superadmin,admin
acl_tiny_list.table =ACL
acl_tiny_list.filters=name
acl_tiny_list.free=name
acl_tiny_list.order_by=name

acl_get_list.type=list
acl_get_list.roles =superadmin,admin
acl_get_list.table =ACL
acl_get_list.filters=name,role_id,admin_id

acl_create.type=create
acl_create.roles =superadmin,admin
acl_create.table =ACL
acl_create.arguments =name,password,tenant

role_update.type=update_custom
role_update.roles=admin,superadmin
role_update.table=Role
role_update.filters=id
role_update.mandatory=id

role_create.type=create
role_create.roles =superadmin,admin
role_create.table =Role
role_create.arguments =name

role_delete.type=delete
role_delete.roles=admin,superadmin
role_delete.table=Role
role_delete.filters=id
role_delete.mandatory=id

qvd_objects_statistics.type=general
