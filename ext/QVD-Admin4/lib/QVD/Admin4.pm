package QVD::Admin4;

use 5.010;
use strict;
use warnings;
use Moose;
use QVD::DB;
use QVD::Admin4::Utils;
use QVD::Admin4::Query;
use Config::Properties;

our $VERSION = '0.01';

has 'database', is => 'ro', isa => 'Str', required => 1;
has 'user', is => 'ro', isa => 'Str', required => 1;
has 'host', is => 'ro', isa => 'Str', required => 1;
has 'password', is => 'ro', isa => 'Str', required => 1;
has 'actions', is => 'ro', isa => 'QVD::Admin4::Actions';

my ($DB, $ACTIONS);

sub BUILD
{
    my $self = shift;

    $DB = QVD::DB->new(database => $self->database,
		       user     => $self->user,
		       host     => $self->host,
		       password => $self->password) // 
			   die "Unknown database account";

    $ACTIONS = $self->load_actions // die "Unable to load actions";
}

sub _get 
{ 
    my $action = shift;
    $ACTIONS->{$action} || die "Action $action non supported"; 
}

sub action
{ 
    my ($self, $table, $action,  $filters,$arguments) = @_; 
    $action //= die "No action specified";

    _get($action)->table($table);
    _get($action)->filters($filters);
    _get($action)->arguments($arguments);
    _get($action)->_exec;

    my @result = map { {$_->get_columns } } @{ _get($action)->result };

    _get($action)->reset;
    @result;
}

sub load_actions
{
    my $self = shift;

    my $cfg=Config::Properties->new;
    $cfg->load(*DATA);

    my $actions = $cfg->splitToTree(qr/\./);

    while (my ($action, $params) = each %{$actions})
    {	
 	$params->{database} = $DB;
	$params->{get_object} = \&{$params->{get_object}} if $params->{get_object};
	$params->{get_result} = \&{$params->{get_result}} if $params->{get_result};
	$actions->{$action} = QVD::Admin4::Query->new(%$params); 
    }

    $actions;
}

1;

__DATA__

select.transaction = 0
select.iterations = 1
select.get_object = select

update.transaction = 1
update.iterations = 1
update.get_object = select
update.get_result = update

add.transaction = 0
add.iterations = 1
add.get_result = add

delete.transaction = 1
delete.iterations = 1
delete.get_object = select
delete.get_result = delete

relation.transaction = 0
relation.iterations = 1
relation.get_object = select
relation.get_result = relation

property.transaction = 0
property.iterations = 1
property.get_object = select
property.get_result = property

start_vm.transaction = 0
start_vm.iterations = 5
start_vm.get_object = select
start_vm.get_result = start_vm

stop_vm.transaction = 0
stop_vm.iterations = 5
stop_vm.get_object = select
stop_vm.get_result = stop_vm
	       
block_vm.transaction = 0
block_vm.iterations = 1
block_vm.get_object = select
block_vm.get_result = block_vm

unblock_vm.transaction = 0
unblock_vm.iterations = 1
unblock_vm.get_object = select
unblock_vm.get_result = unblock_vm
	
block_host.transaction = 0
block_host.iterations = 1
block_host.get_object = select
block_host.get_result = block_host

unblock_host.transaction = 0
unblock_host.iterations = 1
unblock_host.get_object = select
unblock_host.get_result = unblock_host

diconnect_user.transaction = 0
diconnect_user.iterations = 1
diconnect_user.get_object = select
diconnect_user.get_result = diconnect_user

add_host.transaction = 1
add_host.iterations = 1
add_host.get_result = add_host

