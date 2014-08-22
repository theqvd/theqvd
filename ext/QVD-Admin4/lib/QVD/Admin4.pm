package QVD::Admin4;

use 5.010;
use strict;
use warnings;
use Moose;
use QVD::DB;
use QVD::DB::Simple;
use QVD::Admin4::Query;
use QVD::Config;
use File::Copy qw(copy move);
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
    
    $self->is_superadmin($user) ?
	return $self->superadmin_credentials($user) :
	return $self->normal_credentials($user);
}

sub is_superadmin
{
    my ($self,$user) = @_;
    $user->login eq 'superadmin' ?# FIX ME: Take from DB Config!!!
	return 1 : return 0;
}

sub superadmin_credentials
{
    my ($self,$user) = @_;
    { tenant => [ map { $_->id } $DB->resultset('Tenant')->all ],
      role => $user->role->name };
}

sub normal_credentials
{
    my ($self,$user) = @_;

    { tenant => $user->tenant_id, 
      role => $user->role->name };
}
sub _map
{
    my ($self,$obj,$request,$result,@fields) = @_;

    if ($request->json->{role} eq 'superadmin' &&
	$obj->can('tenant_id'))
    {
	$result->{tenant_id} = $obj->tenant_id;
	$result->{tenant_name} = $obj->tenant_name;
    }
    
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
    my @fields = qw(id qvd_obj name 
                    get_list get_details filter_list 
                    filter_details argument filter_options);

    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};

    $result;

}

sub config_field_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id qvd_obj name 
                    get_list get_details filter_list 
                    filter_details argument filter_options);

    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};

    $result;
}


sub config_field_update
{
    my ($self,$request) = @_;
    $self->update($request);
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

    $_ = $self->_map($_,$request,{$self->add_custom($request,$_)},@fields) 
	for @{$result->{rows}};

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
    $self->update_tags($request);
}

### BASIC SQL QUERIES

sub select
{
    my ($self,$request) = @_;
    
    my $rs = eval { $DB->resultset($request->table)->search($request->filters, 
							    $request->modifiers) };

    QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4,
				  message => "$@")) if $@;


   { total => ($rs->is_paged ? $rs->pager->total_entries : undef), 
     rows => [$rs->all] };
}

sub update
{
    my ($self,$request,@conditions) = @_;

    my $result = $self->select($request);
    my $failures = {};

    for my $obj (@{$result->{rows}})
    {
	eval { $self->$_($obj) for @conditions;
	       $DB->txn_do( sub { eval { $obj->update($request->arguments) };

				   QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
								 message => "$@") if $@;
				   $self->update_related($request,$obj); } ) };      
	 if ($@) { $failures->{$obj->id} = ($@->can('code') ? $@->code : 4); }
    }

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
    $result->{rows} = [];
    $result;
}

sub update_related
{
    my($self,$request,$obj)=@_;

    my %tables = %{$request->arguments(related => 1)};
    for (keys %tables)
    {
	eval { $obj->$_->update($tables{$_}) }; 
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
	                              message => "$@") if $@;
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
	      QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
					    message => "$@") if $@;
	    
	      $self->update_related($request,$obj); };
	
	eval { $DB->txn_do($f)};

	if ($@) { $failures->{$obj->id} = ($@->can('code') ? $@->code : 4); }
    }

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
    $result->{rows} = [];
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
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
                                      message => "$@") if $@;
    }
}

sub custom_update
{
    my ($self,$props,$obj) = @_;

    while ( my ($key,$value) = each %$props)
    {
	eval { $obj->search_related('properties', 
				    {key => $key})->update({value => $value}) };
		
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
                                      message => "$@") if $@;
    }		
}

sub custom_delete
{
    my ($self,$props,$obj) = @_;

    for my $key (@$props)
    {
	eval { $obj->search_related('properties', 
				    {key => $key})->delete };
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
                                      message => "$@") if $@;
    }		
}

################
# Tag/Untag dis
################

sub update_tags
{
    my ($self,$request) = @_;
 
    my $result = $self->select($request);   
    my $failures = {};

    for my $di (@{$result->{rows}})
    {
	my $tags = $request->arguments(tags => 1);
	my $f = 
	sub { $self->tags_delete($tags->{delete},$di);    
	      $self->tags_create($tags->{create},$di);};
	
	eval { $DB->txn_do($f)};

	if ($@) { $failures->{$di->id} = ($@->can('code') ? $@->code : 4); }
    }

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
    $result->{rows} = [];
    $result;
}

sub tags_create
{
    my ($self,$tags,$di) = @_;

    for my $tag (@$tags)
    { 	
	eval {  $di->osf->di_by_tag($tag,'1') && QVD::Admin4::Exception->throw(code => 16);
		$di->osf->delete_tag($tag);
		$DB->resultset('DI_Tag')->create({di_id => $di->id, tag => $tag}) };
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
                                      message => "$@") if $@;
    }
}

sub tags_delete
{
    my ($self,$tags,$di) = @_;

    for my $tag (@$tags)
    {
	$tag = eval { $di->search_related('tags',{tag => $tag})->first };
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
                                      message => "$@") if $@;
	$tag || next;
	$tag->fixed && QVD::Admin4::Exception->throw(code => 16);
	($tag->tag eq 'head' || $tag->tag eq 'default') && QVD::Admin4::Exception->throw(code => 16);
	eval { $tag->delete };
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
                                      message => "$@") if $@;
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
    my ($self,$request,@conditions) = @_;

    my $arguments = $request->arguments(default => 1);

    my $obj = eval { $self->$_($request) || 
			 QVD::Admin4::Exception->throw(code => 17)
			 for @conditions;
		     $DB->resultset($request->table)->create($arguments) };
    print $@ if $@;
    QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
                                  message => "$@") if $@;
    $obj;
}

sub _create_related
{
    my ($self,$request,$obj) = @_;
    my $related_args = $request->arguments(related => 1, default => 1);

    for my $table (keys %{$request->dependencies})
    {
	eval { $obj->create_related($table,($related_args->{$table} || {})) };
	print $@ if $@;
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
                                      message => "$@") if $@;
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

    $request->{json}->{arguments}->{straight}->{tenant_id} =
	$request->{json}->{tenant};

    $DB->txn_do( sub { my $user = $self->_create($request);
		       $self->_create_related($request,$user);
		       $self->custom_create($request->arguments(custom => 1),$user)});

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

    $request->{json}->{arguments}->{straight}->{tenant_id} =
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

    my $tenant_id = $request->{json}->{tenant};
    my $user_id = $request->{json}->{arguments}->{straight}->{user_id};
    my $osf_id = $request->{json}->{arguments}->{straight}->{osf_id};

    $DB->resultset('User')->search({ tenant_id => $tenant_id,
                                     id        => $user_id   })->count
					 || QVD::Admin4::Exception->throw(code=>'19');

    $DB->resultset('OSF')->search({ tenant_id => $tenant_id,
                                    id        => $osf_id   })->count
					 || QVD::Admin4::Exception->throw(code=>'19');

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

sub di_create
{
    my ($self,$request) = @_;

    my $tenant_id = $request->{json}->{tenant};
    my $osf_id = $request->{json}->{arguments}->{straight}->{osf_id};

    $DB->resultset('OSF')->search({ tenant_id => $tenant_id,
                                    id        => $osf_id   })->count
					 || QVD::Admin4::Exception->throw(code=>'19');


    $DB->txn_do( sub { my $di = $self->_create($request);
		       $di->update({path => $di->id .'-'.$di->path});
		       $di->osf->delete_tag('head');
		       $di->osf->delete_tag($di->version);
		       $DB->resultset('DI_Tag')->create({di_id => $di->id, tag => $di->version, fixed => 1});
		       $DB->resultset('DI_Tag')->create({di_id => $di->id, tag => 'head'});
		       $DB->resultset('DI_Tag')->create({di_id => $di->id, tag => 'default'})
			   unless $di->osf->di_by_tag('default');

		       $self->custom_create($request->arguments(custom => 1),$di);
                       $self->tags_create($request->arguments(tags => 1),$di);});
   { total => undef, 
     rows => [] };
}

sub di_delete {
    my ($self, $request) = @_;

    my $result = $self->select($request);
    $self->_delete($result,qw(no_vm_runtimes 
                              no_head_default_tags));

   { total => undef, 
     rows => [] };
}

####################
# AUXILIAR FUNCTIONS
####################

sub vm_is_stopped
{
    my ($self,$obj) = @_;
    $obj->vm_runtime->vm_state eq 'stopped' ? 
	return 1 : 
	return 0;
}

sub no_vm_runtimes
{
    my ($self,$obj) = @_;
    $obj->vm_runtimes->count == 0;
}

sub no_head_default_tags
{
    my ($self,$di) = @_;

    for my $tag (qw/default head/) 
    {
	next unless $di->has_tag($tag);
	my @potentials = grep { $_->id ne $di->id } $di->osf->dis;
	if (@potentials) {
	    my $new_di = $potentials[-1];
	    $DB->resultset('DI_Tag')->create({di_id => $new_di->id, tag => $tag});
	}
    }
    return 1;
}

sub add_custom
{
    my ($self,$request,$obj) = @_;
    $ENV{QVD_ADMIN4_CUSTOM_JOIN_CONDITION} = undef;
    ( properties => { map {  $_->key => $_->value  } $obj->properties->all });
} 

###############
## SWITCHERS ##
###############


sub user_block
{
    my ($self,$request) = @_;
    my @conditions = qw();

    $self->update($request,@conditions);
}

sub vm_block
{
    my ($self,$request) = @_;
    my @conditions = qw();

    $self->update($request,@conditions);
}


sub host_block
{
    my ($self,$request) = @_;
    my @conditions = qw();

    $self->update($request,@conditions);
}


sub vm_user_disconnect
{
    my ($self,$request) = @_;
    my $result = $self->select($request);
    my $failures = {};

    for my $obj (@{$result->{rows}})
    {
	eval { $obj->vm_runtime->send_user_abort  };      
	 if ($@) { $failures->{$obj->id} = 18; print $@; }
    }

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
    $result->{rows} = [];
    $result;
}

sub vm_start
{
    my ($self,$request) = @_;

    my $result = $self->select($request);
    my $failures = {};
    my %host;

    for my $vm (@{$result->{rows}})
    {
	eval { $DB->txn_do(sub {$vm->vm_runtime->can_send_vm_cmd('start') or die;
				$self->_assign_host($vm->vm_runtime);
				$vm->vm_runtime->send_vm_start;
				$host{$vm->vm_runtime->host_id}++;}); 
	       $@ or last } for (1 .. 5);

	if ($@) { $failures->{$vm->id} = 18; print $@; }
    }

    notify("qvd_cmd_for_vm_on_host$_") for keys %host;

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;    
    $result->{rows} = [];
    $result;
}

sub vm_stop
{
    my ($self,$request) = @_;

    my $result = $self->select($request);
    my $failures = {};
    my %host;

    for my $vm (@{$result->{rows}})
    {
	eval { $DB->txn_do(sub { if ($vm->vm_runtime->can_send_vm_cmd('stop')) 
				 {
				     $vm->vm_runtime->send_vm_stop;
				     $host{$vm->vm_runtime->host_id}++;
				 }
				 else 
				 {
				     if ($vm->vm_runtime->vm_state eq 'stopped' and
					 $vm->vm_runtime->vm_cmd eq 'start') 
				     {
					 $vm->vm_runtime->update({ vm_cmd => undef });
				     }
				 }
			   });
	       $@ or last } for (1 .. 5);

	if ($@) { $failures->{$vm->id} = 18; print $@; }
    }

    notify("qvd_cmd_for_vm_on_host$_") for keys %host;

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;    
    $result->{rows} = [];
    $result;
}


my $lb;
sub _assign_host {
    my ($self, $vmrt) = @_;
    if (!defined $vmrt->host_id) {
        $lb //= do {
            require QVD::L7R::LoadBalancer;
            QVD::L7R::LoadBalancer->new();
        };
        my $free_host = $lb->get_free_host($vmrt->vm) //
            die "Unable to start machine, no hosts available";

        $vmrt->set_host_id($free_host);
    }
}

sub osf_block
{
    my ($self,$request) = @_;
    my @conditions = qw();
    $self->update($request,@conditions);
}

sub di_block
{
    my ($self,$request) = @_;
    my @conditions = qw();
    $self->update($request,@conditions);
}


sub user_unblock
{
    my ($self,$request) = @_;
    my @conditions = qw();
    $self->update($request,@conditions);
}

sub vm_unblock
{
    my ($self,$request) = @_;
    my @conditions = qw();
    $self->update($request,@conditions);
}

sub host_unblock
{
    my ($self,$request) = @_;
    my @conditions = qw();
    $self->update($request,@conditions);
}

sub osf_unblock
{
    my ($self,$request) = @_;
    my @conditions = qw();
    $self->update($request,@conditions);
}

sub di_unblock
{
    my ($self,$request) = @_;
    my @conditions = qw();
    $self->update($request,@conditions);
}

1;
