package QVD::Admin4;

use 5.010;
use strict;
use warnings;
use Moose;
use QVD::DB;
use QVD::Admin4::Query;
use Config::Properties;

our $VERSION = '0.01';

has 'login', is => 'ro', isa => 'Str', required => 1;
has 'password', is => 'ro', isa => 'Str', required => 1;

my $DB;

sub BUILD
{
    my $self = shift;

    $DB = QVD::DB->new() // 
	die "Unable to connect to database";
}

sub _db { $DB; }

sub _exec
{
    my ($self, $request) = @_;

    my $method = $request->action;
    $self->$method($request);
}

sub get_credentials
{
    my $self = shift;

    my $user = $DB->resultset('User')->find({ login => $self->login,
					      password => $self->password});

    { tenant => $user->tenant_id, role => $user->role->name };
}

###############################
########## QUERIES ############
###############################

sub user_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   login => $_->login, 
	   blocked => undef,
	   '#vms'  => $_->vms->count  } for @{$result->{rows}};
    
    $result;
}

sub user_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   login => $_->login, 
	   blocked => undef,
	   creation_admin => undef,
	   creation_date => undef,
	   $self->add_custom($request,$_) } for  @{$result->{rows}};

    $result;
}

sub user_get_state
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @query = ('vms',{'vm_runtime.vm_state' => 'running'},{join => [qw(vm_runtime)]});

    $_ = { '#vms' => $_->search_related(@query)->count } for @{$result->{rows}};
    $result;
}

sub vm_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->name,
	   host_id => $_->vm_runtime->host_id,
	   user_id => $_->user_id,
	   user_login => $self->_find('User','id',$_->user_id,'login'),
	   osf_id => $_->osf_id,
	   osf_name => $self->_find('OSF','id',$_->osf_id,'name'),
	   di_tag => $_->di_tag,
	   di_version => undef,
	   blocked => $_->vm_runtime->blocked,
	   expiration_soft => $_->vm_runtime->vm_expiration_soft,
	   expiration_hard => $_->vm_runtime->vm_expiration_hard } for @{$result->{rows}};

    $result;
}


sub vm_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->name,
	   osf_id => $_->osf_id,
	   osf_name => $self->_find('OSF','id',$_->osf_id,'name'),
	   di_tag => $_->di_tag,
	   di_version => $self->_find('DI','id',$_->vm_runtime->current_di_id,'version'),
	   di_name => $self->_find('DI','id',$_->vm_runtime->current_di_id,'path'),
	   di_id      => $_->vm_runtime->current_di_id,
	   blocked => $_->vm_runtime->blocked,
	   state => $_->vm_runtime->vm_state,
	   host_id => $_->vm_runtime->host_id,
	   host_name => $self->_find('Host','id',$_->vm_runtime->host_id,'name'),
	   ip => $_->ip,
	   expiration_soft => $_->vm_runtime->vm_expiration_soft,
	   expiration_hard => $_->vm_runtime->vm_expiration_hard,
	   creation_admin => undef,
	   creation_date => undef,
	   next_boot_ip => $_->vm_runtime->vm_address, 
	   ssh_port => $_->vm_runtime->vm_ssh_port,
	   vnc_port => $_->vm_runtime->vm_vnc_port,
	   serial_port => $_->vm_runtime->vm_serial_port,
           $self->add_custom($request,$_)} for @{$result->{rows}};

    $result;
}

sub vm_get_state
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { 'vm_state'   => $_->vm_runtime->vm_state,
           'user_state' => $_->vm_runtime->user_state } for @{$result->{rows}};
    $result;
}


sub host_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->name,
	   address => $_->address,
	   blocked => $_->runtime->blocked } for @{$result->{rows}};

    $result;
}

sub host_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->name,
	   state => $_->runtime->state,
	   address => $_->address,
	   load => undef,
	   creation_admin => undef,
	   creation_date => undef,
	   blocked => $_->runtime->blocked,
           $self->add_custom($request,$_) } for @{$result->{rows}};

    $result;
}

sub host_get_state
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { state => $_->runtime->state,
           load => undef,
	   '#vms' => $_->vms->count } for @{$result->{rows}};

    $result;
}

sub osf_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id,
	   name => $_->name,
	   overlay => $_->use_overlay,
	   memory => $_->memory,
	   user_storage => $_->user_storage_size,
	   '#vms' => $_->vms->count,
           '#dis' => $_->dis->count } for @{$result->{rows}};

    $result;
}

sub osf_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id,
	   name => $_->name,
	   overlay => $_->use_overlay,
	   memory => $_->memory,
	   user_storage => $_->user_storage_size,
           $self->add_custom($request,$_) } for @{$result->{rows}};

    $result;
}


sub di_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id,
	   disk_image => $_->path,
	   version => $_->version,
	   osf_id => $_->osf_id,
	   osf_name => $self->_find('OSF','id',$_->osf_id,'name'),
	   blocked => undef,
	   tags => [ map { { $_->get_columns } } $_->tags ] } for @{$result->{rows}};

    $result;
}

sub di_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id,
	   disk_image => $_->path,
	   version => $_->version,
	   osf_id => $_->osf_id,
	   osf_name => $self->_find('OSF','id',$_->osf_id,'name'),
	   blocked => undef,
	   tags => [ map { { $_->get_columns } } $_->tags ],
           $self->add_custom($request,$_) } for @{$result->{rows}};

    $result;
}

###############################
########### ACTIONS  ##########
###############################

sub _find
{
    my ($self,$table,$arg,$val,$method) = @_;
    my $r = eval { $DB->resultset($table)->find({$arg => $val})->$method };
    return $r;
}

### BASIC SQL QUERIES

sub select
{
    my ($self,$request) = @_;
    my $rs = $DB->resultset($request->table)->search($request->filters,
						     $request->modifiers);

    { total => ($rs->is_paged ? $rs->pager->total_entries : undef), 
      rows => [$rs->all]} ;
}

sub update
{  
    my ($self,$request,$result) = @_;  

    my $rows = $result->{rows};
    $result->{rows} = [ map { {$_->update($request->arguments)->get_columns} } @$rows ]; 
    $result;
}

sub add
{
    my ($self,$request) = @_;  
     
    { total => 1, rows => [ $DB->resultset($request->table)->create($request->arguments) ]}; 
}

sub delete 
{  
    my ($self,$request,$result) = @_;  
    my $rows = $result->{rows};
    $result->{rows} = [ map { $_->delete }  @$rows ];
    $result;
}

### RELATIONS BETWEEN TABLES

sub relation     
{  
    my ($self,$request,$result) = @_;  
    my $relation = $request->arguments->{'relation'} // 
	die "No relation specified";
    my $rows = $result->{rows};
    $result->{rows} = [ map { {$_->$relation->get_columns} } @$rows ]; 
    $result;
}

### RETRIEVES THE VALUE OF AN SPECIFIC COLUMN

sub property    
{  
    my ($self,$request,$result) = @_;  
    my $property = $request->arguments->{'property'} // 
	die "No property specified";
    my $rows = $result->{rows};
    $result->{rows} = [ map { {$property => $_->$property} } @$rows ]; 
    $result;
}

sub empty
{
    [];
}

sub get_columns
{
    my ($self,$request,$result) = @_;
    my $rows = $result->{rows};
    $result->{rows} = [map { {$_->get_columns} } @$rows];

    $result;
}

sub count
{
    my ($self,$request,$result) = @_;
    $result->{rows} = [];
    $result;
}

sub get_customs
{
    my ($self,$request,$result) = @_;

    for my $row (@{$result->{rows}})
    {
	my $cols = {$row->get_columns};

	for my $custom (@{$request->customs})
	{
	    $cols->{$custom} = $row->properties->find({key => $custom})->value;
	}
	$row = $cols;
    }

    $result;
}


sub add_custom
{
    my ($self,$request,$obj) = @_;

    (map { $_ => $obj->properties->find({key => $_})->value } @{$request->customs});
} 


1;
