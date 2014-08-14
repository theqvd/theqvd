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


sub _map
{
    my ($self,$obj,$request,$result,@fields) = @_;

    for my $field (@fields)
    {
	my $mfield = $request->mapper->getProperty($field);
        my ($table,$column) = $mfield =~ /^(.+)\.(.+)$/;

	$result->{$field} = 
	    eval { $table eq "me" ? 
		       $obj->$column : 
		       $obj->$table->$column } // undef;
    }

    $result;
}

sub get_fields
{
    my ($self,$qvd_obj,$criterium) = @_;

    ( map { $_->name } $DB->resultset('Config_Field')->search(
	  {qvd_obj => $qvd_obj,
	   $criterium => 'true'})->all);
}

sub config_field_get_list
{
    my ($self,$request) = @_;

    my $result = $self->select($request);
    my @fields = qw(id qvd_obj name update get_list get_details filter_list filter_details);

    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};

    $result;

}


sub config_field_update
{
    my ($self,$request) = @_;

    my $result = $self->select($request);
    my $arguments = $request->arguments;
    $_->update({get_list => 0}) for @{$result->{rows}};

    $result->{rows} = [];
    $result;
}


###############################
########## QUERIES ############
###############################

sub user_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);
    my @fields = $self->get_fields(qw(user get_list));

    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) 
	for @{$result->{rows}};

    $result;
}

sub user_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub user_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = $self->get_fields(qw(user get_details));
    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) 
	for @{$result->{rows}};

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

    my @fields = qw(vms_connected);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};

    $result;
}

sub vm_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);
    my @fields = $self->get_fields(qw(vm get_list));
    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) 
	for @{$result->{rows}};

    $result;
}

sub vm_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);
    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub vm_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = $self->get_fields(qw(vm get_details));
    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) 
	for @{$result->{rows}};
   
    $result;
}

sub vm_get_state
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(state user_state);

    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};

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

    my @fields = $self->get_fields(qw(host get_list));
    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) 
	for @{$result->{rows}};
    $result;
}

sub host_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub host_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = $self->get_fields(qw(host get_details));
    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) 
	for @{$result->{rows}};

    $result;
}


sub host_get_state
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(state load vms);

    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};

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

    my @fields = $self->get_fields(qw(osf get_list));
    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) 
	for @{$result->{rows}};

    $result;
}

sub osf_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub tag_tiny_list
{
    my ($self,$request) = @_;

    my $result = $self->select($request);

    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};

    $result;
}


sub osf_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = $self->get_fields(qw(osf get_details));
    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) 
	for @{$result->{rows}};

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

    my @fields = $self->get_fields(qw(di get_list));
    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) 
	for @{$result->{rows}};

    $result;
}

sub di_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);
    my @fields = qw(id disk_image);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub di_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = $self->get_fields(qw(di get_details));

    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) for @{$result->{rows}};

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
    print $@ if $@;
    return $r;
}

sub select
{
    my ($self,$request) = @_;

    my $filters = $request->filters;
    my $modifiers = $request->modifiers;
    
    my $rs = eval { $DB->resultset($request->table)->search($filters, 
							    $modifiers) };

    QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->err || 4)) if $@;


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
				   QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->err || 4)) if $@;
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
    $ENV{QVD_ADMIN4_CUSTOM_JOIN_CONDITION} = undef;
    ( properties => { map {  $_->key => $_->value  } $obj->properties->all });
} 

sub update_related
{
    my($self,$request,$obj)=@_;

    my %tables = %{$request->arguments(related => 1)};

    for (keys %tables)
    {
	eval { $obj->$_->update($tables{$_}) }; 
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->err || 4)) if $@;
    }
    
}

sub update_custom
{
    my ($self,$request) = @_;
 
    my $result = $self->select($request);   
    my $failures = {};

    for my $obj (@{$result->{rows}})
    {
	my $props = $request->arguments(custom => 1);
	my $f = 
	    sub { $self->custom_update($props->{update},$obj);    
		  $self->custom_delete($props->{delete},$obj);    
		  $self->custom_create($props->{create},$obj);
		  
		  eval { $obj->update($request->arguments) };
		  QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->err || 4)) if $@;
	    
		  $self->update_related($request,$obj); };
	
	eval { $DB->txn_do($f)};

	if ($@) { $failures->{$obj->id} = ($@->can('code') ? $@->code : 4); }
    }

    $result->{rows} = [];
    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
    $result;

}

sub custom_create
{
    my ($self,$props,$obj) = @_;

    my $class = ref($obj);     # FIX ME, PLEASE!!!!
    $class =~ s/^QVD::DB::Result::(.+)$/$1/;

    while (my ($key,$value) = each %$props)
    { 
	my $t = $class . "_Property";
	my $k = lc($class) . "_id";
	my $a = {key => $key, value => $value, $k => $obj->id};
	eval { $DB->resultset($t)->create($a) };

	print $@ if $@;
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->err || 4)) if $@;
    }
}

sub custom_update
{
    my ($self,$props,$obj) = @_;

    while ( my ($key,$value) = each %$props)
    {
	eval { $obj->search_related('properties', 
				    {key => $key})->update({value => $value}) };
		
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->err || 4)) if $@;
    }		
}

sub custom_delete
{
    my ($self,$props,$obj) = @_;

    for my $key (@$props)
    {
	eval { $obj->search_related('properties', 
				    {key => $key})->delete };
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->err || 4)) if $@;
    }		
}


#########################
## ADD/DELETE ELEMENTS ##
#########################

sub _delete
{
    my ($self,$result,@conditions) = @_;
    my $failures = {};

    for my $obj (@{$result->{rows}})
    {
         eval { $self->$_($obj) || 
		    QVD::Admin4::Exception->throw(code => 16)
		    for @conditions; 
		$obj->delete };
	 if ($@) { $failures->{$obj->id} = ($@->can('code') ? $@->code : 4); }
    }

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
}

sub _create
{
    my ($self,$request) = @_;

    my $arguments = $request->arguments(default => 1);
    my $host = eval { $DB->resultset($request->table)->create($arguments) };
    print $@ if $@;
    QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->err || 4)) if $@;
    $host;
}

sub _create_related
{
    my ($self,$request,$obj) = @_;
    my $related_args = $request->arguments(related => 1, default => 1);

    for my $table (keys %{$request->dependencies})
    {
	eval { $obj->create_related($table,($related_args->{$table} || {})) };
	print $@ if $@;
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->err || 4)) if $@;
    }
}

sub host_create {
    my ($self, $request) = @_;

    $DB->txn_do( sub { my $host = $self->_create($request);
		       $self->_create_related($request,$host);
		       $self->custom_create($request->arguments(custom => 1),$host)});

   { total => undef, 
     rows => [] };
}

sub host_delete {

    my ($self, $request) = @_;

    my $result = $self->select($request);
    $self->_delete($result);

   { total => undef, 
     rows => [] };
}


sub user_create {
    my ($self, $request) = @_;

    $request->{json}->{arguments}->{tenant} =
	$request->{json}->{tenant};

    $DB->txn_do( sub { my $host = $self->_create($request);
		       $self->_create_related($request,$host);
		       $self->custom_create($request->arguments(custom => 1),$host)});

   { total => undef, 
     rows => [] };
}

sub user_delete {

    my ($self, $request) = @_;

    my $result = $self->select($request);
    $self->_delete($result);

   { total => undef, 
     rows => [] };
}

sub osf_create
{
    my ($self,$request) = @_;

    $request->{json}->{arguments}->{tenant} =
	$request->{json}->{tenant};

    $DB->txn_do( sub { my $host = $self->_create($request);
		       $self->_create_related($request,$host);
		       $self->custom_create($request->arguments(custom => 1),$host)});

   { total => undef, 
     rows => [] };

}

sub osf_delete
{
    my ($self,$request) = @_;

    my $result = $self->select($request);

    $self->_delete($result);

   { total => undef, 
     rows => [] };
}

sub vm_create
{
    my ($self,$request) = @_;

    $request->{json}->{arguments}->{tenant} =
	$request->{json}->{tenant};

    $DB->txn_do( sub { my $host = $self->_create($request);
		       $self->_create_related($request,$host);
		       $self->custom_create($request->arguments(custom => 1),$host)});

   { total => undef, 
     rows => [] };
}

sub vm_delete
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    $self->_delete($result,qw(vm_is_stopped));

   { total => undef, 
     rows => [] };
}

##############
# CONDITIONS
##############


sub vm_is_stopped
{
    my ($self,$obj) = @_;
    $obj->vm_runtime->vm_state eq 'stopped' ? 
	return 1 : 
	return 0;
}


1;

#
#sub di_create
#{
#    my ($self,$request) = @_;
#
#    $request->{json}->{arguments}->{tenant} =
#	$request->{json}->{tenant};
#    require QVD::Config;
#    my $images_path = cfg('path.storage.images');
#
#    require File::Copy qw(copy move);
#    require File::Basename qw(basename);
#
#    mkdir $images_path, 0755;
#    -d $images_path or die "Directory $images_path does not exist";
#
#    my $src = $request->json->{disk_image};
#    my $file = basename($src);
#    my $tmp = "$images_path/$file.tmp-" . rand;
#    copy($src, $tmp) or die "Unable to copy $src to $tmp: $!\n";
#
#    my $osf_id = $request->json->{arguments}->{osf_id};
#    my $osf = $self->db->resultset('OSF')->search({id => $osf_id})->first;
#
#    my ($new_file,$id);
#
#    eval {
#    $DB->txn_do( sub { $osf->delete_tag('head');
#		       $osf->delete_tag($request->json->{arguments}->{osf_id});
#
#		       my $rs = $self->get_resultset('di');
#		       my $di = $rs->create({osf_id => $osf_id, path => '', version => $version});
#		       $id = $di->id;
#		       rs(DI_Tag)->create({di_id => $id, tag => $version, fixed => 1});
#		       rs(DI_Tag)->create({di_id => $id, tag => 'head'});
#		       rs(DI_Tag)->create({di_id => $id, tag => 'default'})
#			   unless $osf->di_by_tag('default'); 
#		       $new_file = "$id-$file";
#		       $di->update({path => $new_file});
#
#		       move($tmp, "$images_path/$new_file")
#			   or die "Unable to move '$tmp' to its final destination at '$images_path/$new_file': $!"; }) 
#	for (1 .. 5)
#    };
#
#    if ($@) { unlink $tmp;
#	      unlink "$images_path/$new_file" if defined $new_file;
#	      QVD::Admin4::Exception->throw(code => 17) if $@;};
#
#    { total => undef, 
#      rows => [] };
#}
#

#sub vm_get_list
#{
#    my ($self,$request) = @_;
#    my $result = $self->select($request);
#
#    $_ = { id => $_->id, 
#	   name => $_->name,
#	   host_id => $_->vm_runtime->host_id,
#	   user_id => $_->user_id,
#	   user_name => $self->_find('User','id',$_->user_id,'login'),
#	   osf_id => $_->osf_id,
#	   osf_name => $self->_find('OSF','id',$_->osf_id,'name'),
#	   di_tag => $_->di_tag,
#	   di_version => undef,
#	   state => $_->vm_runtime->vm_state,
#	   blocked => $_->vm_runtime->blocked,
#	   expiration_soft => $_->vm_runtime->vm_expiration_soft,
#	   expiration_hard => $_->vm_runtime->vm_expiration_hard,
#	   $self->add_custom($request,$_) } for @{$result->{rows}};
#
#    $result;
#}
#
#
#    $_ = { id => $_->id, 
#	   name => $_->name,
#	   user_id => $_->user_id,
#	   user_name => $self->_find('User','id',$_->user_id,'login'),
#	   osf_id => $_->osf_id,
#	   osf_name => $self->_find('OSF','id',$_->osf_id,'name'),
#	   di_tag => $_->di_tag,
#	   di_version => $self->_find('DI','id',$_->vm_runtime->current_di_id,'version'),
#	   di_name => 
#
#	       $DB->resultset('DI')->search({'osf.id' => $_->osf_id, 
#					     'tags.tag' => $_->di_tag},{ join => [qw(osf tags)] })->first->path,
#
#	   di_id => 
#
#	       $DB->resultset('DI')->search({'osf.id' => $_->osf_id, 
#					     'tags.tag' => $_->di_tag},{ join => [qw(osf tags)] })->first->id,
#
#	   blocked => $_->vm_runtime->blocked,
#	   state => $_->vm_runtime->vm_state,
#	   host_id => $_->vm_runtime->host_id,
#	   host_name => $self->_find('Host','id',$_->vm_runtime->host_id,'name'),
#	   ip => $_->ip,
#	   expiration_soft => $_->vm_runtime->vm_expiration_soft,
#	   expiration_hard => $_->vm_runtime->vm_expiration_hard,
#	   creation_admin => undef,
#	   creation_date => undef,
#	   next_boot_ip => $_->vm_runtime->vm_address, 
#	   ssh_port => $_->vm_runtime->vm_ssh_port,
#	   vnc_port => $_->vm_runtime->vm_vnc_port,
#	   serial_port => $_->vm_runtime->vm_serial_port,
#           $self->add_custom($request,$_)} for @{$result->{rows}};
#
