package QVD::Admin4;

use 5.010;
use strict;
use warnings;
use Moose;
use QVD::DB;
use QVD::Admin4::Query;
use Config::Properties;
use QVD::Admin4::Exception;

our $VERSION = '0.01';

has 'login', is => 'ro', isa => 'Str', required => 1;
has 'password', is => 'ro', isa => 'Str', required => 1;

my $DB;

sub BUILD
{
    my $self = shift;

    $DB = QVD::DB->new() // 
	QVD::Admin4::Exception->throw(code=>'2');
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
					      password => $self->password}) // 
						  QVD::Admin4::Exception->throw(code=>'3');

    { tenant => $user->tenant_id, role => $user->role->name };
}

###############################
########## QUERIES ############
###############################

sub user_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @query = ('vms',{'vm_runtime.user_state' => 'connected'},{join => [qw(vm_runtime)]});

    $_ = { id => $_->id, 
	   name => $_->login, 
	   blocked => undef,
	   '#vms'  => $_->vms->count,
	   '#vms_connected' => $_->search_related(@query)->count,
	   $self->add_custom($request,$_)} for @{$result->{rows}};
    
    $result;
}

sub user_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->login } for @{$result->{rows}};
    
    $result;
}

sub user_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);
    my @query = ('vms',{'vm_runtime.user_state' => 'connected'},{join => [qw(vm_runtime)]});

    $_ = { id => $_->id, 
	   name => $_->login, 
	   blocked => undef,
	   creation_admin => undef,
	   creation_date => undef,
	   '#vms_connected' => $_->search_related(@query)->count,
	   $self->add_custom($request,$_) } for  @{$result->{rows}};

    $result;
}

sub user_update
{
    my ($self,$request) = @_;
    $self->update($request);
}

sub user_update_custom
{
    my ($self,$request) = @_;
    $self->update_custom($request);
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
	   user_name => $self->_find('User','id',$_->user_id,'login'),
	   osf_id => $_->osf_id,
	   osf_name => $self->_find('OSF','id',$_->osf_id,'name'),
	   di_tag => $_->di_tag,
	   di_version => undef,
	   state => $_->vm_runtime->vm_state,
	   blocked => $_->vm_runtime->blocked,
	   expiration_soft => $_->vm_runtime->vm_expiration_soft,
	   expiration_hard => $_->vm_runtime->vm_expiration_hard,
	   $self->add_custom($request,$_) } for @{$result->{rows}};

    $result;
}

sub vm_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->name } for @{$result->{rows}};
    
    $result;
}


sub vm_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->name,
	   user_id => $_->user_id,
	   user_name => $self->_find('User','id',$_->user_id,'login'),
	   osf_id => $_->osf_id,
	   osf_name => $self->_find('OSF','id',$_->osf_id,'name'),
	   di_tag => $_->di_tag,
	   di_version => $self->_find('DI','id',$_->vm_runtime->current_di_id,'version'),
	   di_name => 

	       $DB->resultset('DI')->search({'osf.id' => 6, 'tags.tag' => 'default'},{ join => [qw(osf tags)] })->first->path,

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

sub vm_update
{
    my ($self,$request) = @_;
    $self->update($request);
}

sub vm_update_custom
{
    my ($self,$request) = @_;
    $self->update_custom($request);
}

sub host_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->name,
	   address => $_->address,
	   blocked => $_->runtime->blocked,
	   $self->add_custom($request,$_) } for @{$result->{rows}};

    $result;
}

sub host_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->name } for @{$result->{rows}};
    
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

sub host_update
{
    my ($self,$request) = @_;
    $self->update($request);
}

sub host_update_custom
{
    my ($self,$request) = @_;
    $self->update_custom($request);
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
           '#dis' => $_->dis->count,
	   $self->add_custom($request,$_) } for @{$result->{rows}};

    $result;
}

sub osf_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->name } for @{$result->{rows}};
    
    $result;
}

sub tag_tiny_list
{
    my ($self,$request) = @_;

    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->tag } for @{$result->{rows}};

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

sub osf_update
{
    my ($self,$request) = @_;
    $self->update($request);
}

sub osf_update_custom
{
    my ($self,$request) = @_;
    $self->update_custom($request);
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
	   tags => [ map { { $_->get_columns } } $_->tags ],
	   $self->add_custom($request,$_)} for @{$result->{rows}};

    $result;
}

sub di_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $_ = { id => $_->id, 
	   name => $_->path } for @{$result->{rows}};
    
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

sub di_update
{
    my ($self,$request) = @_;
    $self->update($request);
}

sub di_update_custom
{
    my ($self,$request) = @_;
    $self->update_custom($request);
}

### BASIC SQL QUERIES

sub _find
{
    my ($self,$table,$arg,$val,$method) = @_;
    my $r = eval { $DB->resultset($table)->find({$arg => $val})->$method };
    return $r;
}

sub select
{
    my ($self,$request) = @_;

    my $filters = $request->filters;
    my $modifiers = $request->modifiers;
    $modifiers->{prefetch} = $modifiers->{join} // {};

    use Data::Dumper; print Dumper $filters,$modifiers;
    my $rs = eval { $DB->resultset($request->table)->search($filters, 
							    $modifiers) };
    print $@ if $@;

    QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4)) if $@;

    { total => ($rs->is_paged ? $rs->pager->total_entries : undef), 
      rows => [$rs->all] };
}


sub update
{
    my ($self,$request) = @_;
    my $result = $self->select($request);
    my $failures = {};

    my $arguments = $request->arguments;

    for my $obj (@{$result->{rows}})
    {
         eval { $DB->txn_do( sub { eval { $obj->update($arguments) };
				   QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4)) if $@;
				   $self->update_related($request,$obj); } ) };      
	 if ($@) { $failures->{$obj->id} = ($@->can('code') ? $@->code : 4); }
    }
    $result->{rows} = [];
    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
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

    ( properties => { map {  $_->key => $_->value  } $obj->properties->all });
} 

sub update_related
{
    my($self,$request,$obj)=@_;

    my %tables = %{$request->arguments(related => 1)};
    
    for (keys %tables)
    {
	eval { $obj->$_->update($tables{$_}) }; 
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4)) if $@;
    }
    
}

sub update_custom
{
    my ($self,$request) = @_;

    my $props = $request->arguments(custom => 1);
    my $result = $self->select($request);   
    my $failures = {};

    for my $obj (@{$result->{rows}})
    {
	eval { $DB->txn_do( sub { while ( my ($key,$value) = each %{$props->{update}})
				  {
				      eval { $obj->search_related('properties', 
								  {key => $key})->update({value => $value}) };
		
				      QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4)) if $@;
				  }		
	    
				  for my $key (@{$props->{delete}})
				  {
				      eval { $obj->search_related('properties', 
								  {key => $key})->delete };
				      QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4)) if $@;
				  }		
	    
				  while (my ($key,$value) = each %{$props->{create}})
				  { 
				      eval { $obj->create_related('properties',{key => $key, 
										value => $value}) };

				      QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4)) if $@;
				  }
	    
				  eval { $obj->update($request->arguments) };
				  QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4)) if $@;
	    
				  $self->update_related($request,$obj);       
			    })};
	 if ($@) { $failures->{$obj->id} = ($@->can('code') ? $@->code : 4); }

	}

    $result->{rows} = [];
    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
    $result;

}

1;
