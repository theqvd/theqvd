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
use QVD::Admin4::REST::Response;
use QVD::Config::Core;
use QVD::Admin4::Exception;
use Moose::Meta::Class;
my ($QVD_ADMIN, $ACTIONS);

sub BUILD
{
    my $self = shift;
    $ACTIONS = $self->load_actions // 
	die "Unable to load actions";
}

sub _auth
{
    my ($self,$json) = @_;

    $QVD_ADMIN = QVD::Admin4->new(login => $json->{login}, 
				  password => $json->{password});

    my $result = eval { $QVD_ADMIN->get_credentials } // {};
    print $@ if $@;
    my $status = ($@ && (( $@->can('code') && $@->code) || 1)) || 0;
    my $failures = ($@ && $@->can('failures')) ? $@->failures  : {};
    my $response = QVD::Admin4::REST::Response->new(status   => $status,
						    result   => $result,
	                                            failures => $failures);
    $response->json;

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

    my $class = 'QVD::Admin4::REST::Request::'.$ACTIONS->{$json->{action}}->{table};

    $class->new(json => $json, 
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
	
	$params->{roles} = { map { $_ => 1 } (split ',', $params->{roles})} 
	if $params->{roles};
	
	$params->{order_by} = [split ',', $params->{order_by}] 
	    if $params->{order_by};
	
	$actions->{$action} = $params;
    }

    $actions;
}

1;

__DATA__

user_get_list.roles=superadmin,admin
user_get_list.table=User
user_get_list.order_by.field=id,name,blocked
user_get_list.filters=name,tenant
user_get_list.mandatory=tenant
user_get_list.free=name

user_tiny_list.roles=all
user_tiny_list.table=User
user_tiny_list.order_by=name
user_tiny_list.filters=tenant
user_tiny_list.mandatory=tenant

user_get_details.roles=all
user_get_details.table=User
user_get_details.filters=id,tenant
user_get_details.mandatory=id,tenant

user_get_state.roles=all
user_get_state.table=User
user_get_state.filters=id,tenant
user_get_state.mandatory=id,tenant

user_update.roles=admin,superadmin
user_update.table=User
user_update.arguments=name,password,blocked
user_update.filters=id,tenant
user_update.mandatory=id,tenant

user_block.roles=admin,superadmin
user_block.table=User
user_block.filters=id,tenant
user_block.mandatory=id,tenant
user_block.arguments=blocked
user_block.default.blocked=1

user_unblock.roles=admin,superadmin
user_unblock.table=User
user_unblock.filters=id,tenant
user_unblock.mandatory=id,tenant
user_unblock.arguments=blocked
user_unblock.default.blocked=0

user_update_custom.roles=admin,superadmin
user_update_custom.table=User
user_update_custom.arguments=name,password,blocked
user_update_custom.filters=id,tenant
user_update_custom.mandatory=id,tenant

user_create.roles=superadmin,admin
user_create.table=User
user_create.arguments=name,password,role,blocked,tenant
user_create.default.blocked=false
user_create.default.role=3

user_delete.roles=admin,superadmin
user_delete.table=User
user_delete.filters=id,tenant
user_delete.mandatory=id,tenant

vm_get_list.roles=all
vm_get_list.table=VM
vm_get_list.order_by=id,name,state,host_id,user_name,osf_name,blocked,host_name
vm_get_list.filters=name,user_id,osf_id,di_id,host_id,tenant,state
vm_get_list.mandatory=tenant
vm_get_list.free=name

vm_tiny_list.roles=all
vm_tiny_list.table=VM
vm_tiny_list.order_by=name
vm_tiny_list.filters=tenant
vm_tiny_list.mandatory=tenant

vm_get_details.roles=all
vm_get_details.table=VM
vm_get_details.filters=id,tenant
vm_get_details.mandatory=id,tenant

vm_get_state.roles=all
vm_get_state.table=VM
vm_get_state.filters=id,tenant
vm_get_state.mandatory=id,tenant

vm_update.roles=admin,superadmin
vm_update.table=VM
vm_update.arguments=name,di_tag,blocked,expiration_soft,expiration_hard
vm_update.filters=id,tenant
vm_update.mandatory=id,tenant

vm_update_custom.roles=admin,superadmin
vm_update_custom.table=VM
vm_update_custom.arguments=name,di_tag,blocked
vm_update_custom.filters=id,tenant
vm_update_custom.mandatory=id,tenant

vm_block.roles=admin,superadmin
vm_block.table=VM
vm_block.filters=id,tenant
vm_block.mandatory=id,tenant
vm_block.arguments=blocked
vm_block.default.blocked=1

vm_unblock.roles=admin,superadmin
vm_unblock.table=VM
vm_unblock.filters=id,tenant
vm_unblock.mandatory=id,tenant
vm_unblock.arguments=blocked
vm_unblock.default.blocked=0

vm_user_disconnect.roles=admin,superadmin
vm_user_disconnect.table=VM
vm_user_disconnect.filters=id,tenant
vm_user_disconnect.mandatory=id,tenant

vm_start.roles=admin,superadmin
vm_start.table=VM
vm_start.filters=id,tenant
vm_start.mandatory=id,tenant

vm_stop.roles=admin,superadmin
vm_stop.table=VM
vm_stop.filters=id,tenant
vm_stop.mandatory=id,tenant

vm_user_state_switch.roles=admin,superadmin
vm_user_state_switch.table=VM
vm_user_state_switch.arguments=blocked
vm_user_state_switch.filters=id,tenant
vm_user_state_switch.mandatory=id,tenant

vm_create.roles=superadmin,admin
vm_create.table=VM
vm_create.arguments=name,user_id,osf_id,ip,storage,di_tag,state,user_state,blocked,tenant
vm_create.default.di_tag=default
vm_create.default.blocked=false
vm_create.default.user_state=disconnected
vm_create.default.state=stopped
vm_create.default.SYSTEM.ip=_get_free_ip

vm_delete.roles=admin,superadmin
vm_delete.table=VM
vm_delete.filters=id,tenant
vm_delete.mandatory=id,tenant

host_get_list.roles=all
host_get_list.table=Host
host_get_list.order_by=id,name,state,address,blocked
host_get_list.filters=name,vm_id
host_get_list.free=name

host_tiny_list.roles=all
host_tiny_list.table=Host
host_tiny_list.order_by=name

host_get_details.roles=all
host_get_details.table=Host
host_get_details.filters=id

host_get_state.roles=all
host_get_state.table=Host
host_get_state.filters=id

host_update.roles=admin,superadmin
host_update.table=Host
host_update.arguments=name,address,blocked
host_update.filters=id
host_update.mandatory=id

host_block.roles=admin,superadmin
host_block.table=Host
host_block.filters=id
host_block.mandatory=id
host_block.arguments=blocked
host_block.default.blocked=1

host_unblock.roles=admin,superadmin
host_unblock.table=Host
host_unblock.filters=id
host_unblock.mandatory=id
host_unblock.arguments=blocked
host_unblock.default.blocked=0

host_update_custom.roles=admin,superadmin
host_update_custom.table=Host
host_update_custom.arguments=name,address,blocked
host_update_custom.filters=id
host_update_custom.mandatory=id

host_create.roles=admin,superadmin
host_create.table=Host
host_create.arguments=name,address,frontend,backend,blocked,state
host_create.default.backend=1
host_create.default.frontend=1
host_create.default.blocked=false
host_create.default.state=stopped

host_delete.roles=admin,superadmin
host_delete.table=Host
host_delete.filters=id
host_delete.mandatory=id

osf_get_list.roles=all
osf_get_list.table=OSF
osf_get_list.order_by=id,name,overlay,memory,user_storage
osf_get_list.filters=name,vm_id,di_id,tenant
osf_get_list.mandatory=tenant
osf_get_list.free=name

osf_tiny_list.roles=all
osf_tiny_list.table=OSF
osf_tiny_list.filters=tenant
osf_tiny_list.mandatory=tenant
osf_tiny_list.order_by=name

osf_get_details.roles=all
osf_get_details.table=OSF
osf_get_details.filters=id,tenant
osf_get_details.mandatory=id,tenant

osf_update.roles=admin,superadmin
osf_update.table=OSF
osf_update.arguments=name,memory,user_storage
osf_update.filters=id,tenant
osf_update.mandatory=id,tenant

osf_block.roles=admin,superadmin
osf_block.table=OSF
osf_block.filters=id,tenant
osf_block.mandatory=id,tenant
osf_block.arguments=blocked
osf_block.default.blocked=1

osf_unblock.roles=admin,superadmin
osf_unblock.table=OSF
osf_unblock.filters=id,tenant
osf_unblock.mandatory=id,tenant
osf_unblock.arguments=blocked
osf_unblock.default.blocked=0

osf_update_custom.roles=admin,superadmin
osf_update_custom.table=OSF
osf_update_custom.arguments=name,memory,user_storage
osf_update_custom.filters=id,tenant
osf_update_custom.mandatory=id,tenant

osf_create.roles=superadmin,admin
osf_create.table=OSF
osf_create.arguments=name,memory,overlay,tenant
osf_create.default.SYSTEM.memory=get_default_memory
osf_create.default.SYSTEM.overlay=get_default_overlay

osf_delete.roles=admin,superadmin
osf_delete.table=OSF
osf_delete.filters=id,tenant
osf_delete.mandatory=id,tenant

di_get_list.roles=all
di_get_list.table=DI
di_get_list.filters=disk_image,osf_id,tenant
di_get_list.mandatory=tenant
di_get_list.free=disk_image

di_tiny_list.roles=all
di_tiny_list.table=DI
di_tiny_list.filters=tenant,osf_id
di_tiny_list.mandatory=tenant,osf_id
di_tiny_list.order_by=name

di_get_details.roles=all
di_get_details.table=DI
di_get_details.filters=id,tenant
di_get_details.mandatory=id,tenant

di_update.roles=admin,superadmin
di_update.table=DI
di_update.arguments=blocked
di_update.filters=id,tenant
di_update.mandatory=id,tenant

di_block.roles=admin,superadmin
di_block.table=DI
di_block.filters=id,tenant
di_block.mandatory=id,tenant
di_block.arguments=blocked
di_block.default.blocked=1

di_unblock.roles=admin,superadmin
di_unblock.table=DI
di_unblock.filters=id,tenant
di_unblock.mandatory=id,tenant
di_unblock.arguments=blocked
di_unblock.default.blocked=0

di_update_custom.roles=admin,superadmin
di_update_custom.table=DI
di_update_custom.arguments=blocked
di_update_custom.filters=id,tenant
di_update_custom.mandatory=id,tenant

di_create.roles=superadmin,admin
di_create.table=DI
di_create.arguments=version,disk_image,osf_id
di_create.default.SYSTEM.version=get_default_version

di_delete.roles=admin,superadmin
di_delete.table=DI
di_delete.filters=id,tenant
di_delete.mandatory=id,tenant

tag_tiny_list.roles =all
tag_tiny_list.table=DI_Tag
tag_tiny_list.filters=osf_id
tag_tiny_list.mandatory=osf_id
tag_tiny_list.order_by=name
config_field_update.roles =admin,superadmin
config_field_update.table =Config_Field
config_field_update.filters=id,tenant
config_field_update.mandatory=id,tenant
config_field_update.arguments=update,get_list,get_details,filter_list,filter_details

config_field_get_list.roles =admin,superadmin
config_field_get_list.table =Config_Field
config_field_get_list.filters=qvd_obj,name,tenant
config_field_get_list.mandatory=tenant
config_field_get_list.free=name

config_field_get_details.roles =admin,superadmin
config_field_get_details.table =Config_Field
config_field_get_details.filters=id,tenant
config_field_get_details.mandatory=id,tenant
