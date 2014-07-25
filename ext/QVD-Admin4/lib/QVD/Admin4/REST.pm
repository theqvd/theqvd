package QVD::Admin4::REST;
use strict;
use warnings;
use Moose;
use QVD::Admin4;
use QVD::Admin4::REST::Request;
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

    my %creds = map { $_ => $json->{$_} } qw(user database host password);
    eval { $QVD_ADMIN = QVD::Admin4->new(%creds) };
    ($@ ? 0 : $self->get_role($json->{user}));
}

sub _admin
{
   my ($self,$json) = @_;

   my $request = QVD::Admin4::REST::Request->new(json => $json);
   my $result = eval { $QVD_ADMIN->_exec($self->get_query($request)) } // {};
   my $response = QVD::Admin4::REST::Response->new(message    => ($@ ? "$@" : ""),
                                                   status     => ($@ ? 1 : 0),
                                                   result     => $result )->json;
}

sub get_role
{
    my ($self, $user) = @_;
    my $role = core_cfg("role.$user") // 
	die "No role for this user";
}

sub get_query 
{ 
    my ($self, $request) = @_;
    $ACTIONS->{$request->action} || 
	die "Action ".$request->action." non supported"; 
    return QVD::Admin4::Query->new(%{$ACTIONS->{$request->action}}, request => $request); 
}

sub load_actions
{
    my $self = shift;

    my $cfg=Config::Properties->new;
    $cfg->load(*DATA);

    my $actions = $cfg->splitToTree(qr/\./);

    while (my ($action, $params) = each %{$actions})
    {	
	$params->{tenant} = [ split ',',  $params->{tenant} ];
	$actions->{$action} = $params;
    }

    $actions;
}

1;

__DATA__

select.tenant = all
select.filter = select
select.action = get_columns

user_get_list.tenant = all
user_get_list.filter = select
user_get_list.action = collapse

user_get_details.tenant = all
user_get_details.filter = select
user_get_details.action = collapse

user_update.tenant = all
user_update.filter = select
user_update.action = update

user_create.tenant = all
user_create.filter = add
user_create.action = get_columns

user_delete.tenant = all
user_delete.filter = select
user_delete.action = delete

user_get_state.tenant = all
user_get_state.filter = select
user_get_state.action = collapse

vm_get_list.tenant = all
vm_get_list.filter = select
vm_get_list.action = collapse

vm_get_details.tenant = all
vm_get_details.filter = select
vm_get_details.action = collapse

vm_get_state.tenant = all
vm_get_state.filter = select
vm_get_state.action = get_columns

vm_update.tenant = all
vm_update.filter = select
vm_update.action = update

vm_create.tenant = all
vm_create.filter = add
vm_create.action = get_columns

vm_delete.tenant = all
vm_delete.filter = select
vm_delete.action = delete

vm_running_stats.tenant = all
vm_running_stats.filter = select
vm_running_stats.action = count

host_get_list.tenant = all
host_get_list.filter = select
host_get_list.action = get_columns

host_get_details.tenant = all
host_get_details.filter = select
host_get_details.action = collapse

host_get_state.tenant = all
host_get_state.filter = select
host_get_state.action = collapse

host_update.tenant = all
host_update.filter = select
host_update.action = update

host_create.tenant = all
host_create.filter = add
host_create.action = get_columns
host_create.defaults.backend = 1
host_create.defaults.frontend = 1

host_delete.tenant = all
host_delete.filter = select
host_delete.action = delete

host_running_stats.tenant = all
host_running_stats.filter = select
host_running_stats.action = count

host_running_stats.tenant = all
host_running_stats.filter = select
host_running_stats.action = count

osf_get_list.tenant = all
osf_get_list.filter = select
osf_get_list.action = collapse

osf_get_details.tenant = all
osf_get_details.filter = select
osf_get_details.action = collapse

osf_create.tenant = all
osf_create.filter = add
osf_create.action = get_columns
osf_create.defaults.memory = 1
osf_create.defaults.use_overlay = 1
osf_create.defaults.user_storage_size = 1

osf_delete.tenant = all
osf_delete.filter = select
osf_delete.action = delete

osf_update.tenant = all
osf_update.filter = select
osf_update.action = update
