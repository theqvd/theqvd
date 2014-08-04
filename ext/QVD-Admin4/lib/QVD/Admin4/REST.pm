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
use QVD::Admin4::REST::Response;
use QVD::Config::Core;

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
				  password => $json->{password}) // 
				      die "Unable to create Admin4";

    $QVD_ADMIN->get_credentials;
}

sub _admin
{
   my ($self,$json) = @_;

   $QVD_ADMIN //= QVD::Admin4->new(login => $json->{login}, 
				  password => $json->{password});

   my $result = eval { $QVD_ADMIN->_exec($self->get_request($json)) } // {};
   my $response = QVD::Admin4::REST::Response->new(message    => ($@ ? "$@" : ""),
                                                   status     => ($@ ? 1 : 0),
                                                   result     => $result )->json;
}

sub get_request 
{ 
    my ($self, $json) = @_;

    $ACTIONS->{$json->{action}} || 
	die "Action ".$json->{action}." non supported"; 

    my $class = 'QVD::Admin4::REST::Request::'.$ACTIONS->{$json->{action}}->{table};
    return $class->new(json => $json, 
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

user_get_list.roles = all
user_get_list.table = User
user_get_list.order_by = id,login,blocked
user_get_list.filters = login,tenant
user_get_list.mandatory = tenant

user_get_details.roles = all
user_get_details.table = User
user_get_details.filters = id,tenant
user_get_details.mandatory = id,tenant

user_get_state.roles = all
user_get_state.table = User
user_get_state.filters = id,tenant
user_get_state.mandatory = id,tenant

vm_get_list.roles = all
vm_get_list.table = VM
vm_get_list.order_by = id,name,state,host_id,user_id,osf_id,blocked
vm_get_list.filters = name,user_id,osf_id,di_id,host_id,tenant
vm_get_list.mandatory = tenant

vm_get_details.roles = all
vm_get_details.table = VM
vm_get_details.filters = id,tenant
vm_get_details.mandatory = id,tenant

vm_get_state.roles = all
vm_get_state.table = VM
vm_get_state.filters = id,tenant
vm_get_state.mandatory = id,tenant

host_get_list.roles = all
host_get_list.table = Host
host_get_list.order_by = id,name,state,address,blocked
host_get_list.filters = name,vm_id

host_get_details.roles = all
host_get_details.table = Host
host_get_details.filters = id

host_get_state.roles = all
host_get_state.table = Host
host_get_state.filters = id

osf_get_list.roles = all
osf_get_list.table = OSF
osf_get_list.order_by = id,name,overlay,memory,user_storage
osf_get_list.filters = name,vm_id,di_id,tenant
osf_get_list.mandatory = tenant

osf_get_details.roles = all
osf_get_details.table = OSF
osf_get_details.filters = id,tenant
osf_get_details.mandatory = id,tenant

di_get_list.roles = all
di_get_list.table = DI
di_get_list.filters = disk_image,osf_id,tenant
di_get_list.mandatory = tenant

di_get_details.roles = all
di_get_details.table = DI
di_get_details.filters = id,tenant
di_get_details.mandatory = id,tenant
