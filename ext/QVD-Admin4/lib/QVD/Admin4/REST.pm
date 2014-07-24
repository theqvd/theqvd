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

   my $rows = eval { $QVD_ADMIN->_exec($self->get_query($request)) } // [];

   my $response = QVD::Admin4::REST::Response->new(message    => ($@ ? "$@" : ""),
                                                   status     => ($@ ? 1 : 0),
                                                   rows       => $rows )->json;
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

collapse.tenant = all
collapse.filter = select
collapse.action = collapse

update.tenant = admin
update.filter = select
update.action = update

add.tenant = admin
add.action = add

delete.tenant = admin
delete.filter = select
delete.action = delete

relation.tenant = all
relation.filter = select
relation.action = relation

property.tenant = all
property.filter = select
property.action = property

start_vm.tenant = admin
start_vm.filter = select
start_vm.action = start_vm

stop_vm.tenant = admin
stop_vm.filter = select
stop_vm.action = stop_vm
	       
block_vm.tenant = admin
block_vm.filter = select
block_vm.action = block_vm

unblock_vm.tenant = admin
unblock_vm.filter = select
unblock_vm.action = unblock_vm

block_host.tenant = admin
block_host.filter = select
block_host.action = block_host

unblock_host.tenant = admin
unblock_host.filter = select
unblock_host.action = unblock_host

disconnect_user.tenant = admin
disconnect_user.filter = select
disconnect_user.action = diconnect_user
