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
use DateTime;
use List::Util qw(sum);

our $VERSION = '0.01';

has 'administrator', is => 'ro', isa => 'QVD::DB::Result::Administrator';

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
    my ($self,%params) = @_;

    my $admin = eval { $DB->resultset('Administrator')->find(\%params) };
    return undef unless $admin;

    $self->{administrator} = $admin;

    return { login => $admin->name,
	     tenant => $admin->tenant_id };
}

# Nombre genérico

sub _map
{
    my ($self,$obj,$request,$result,@fields) = @_;

    if ($self->administrator->is_superadmin)
    {
	if ($obj->can('tenant_id')) { $result->{tenant_id} = $obj->tenant_id; } 
	if ($obj->can('tenant_name')) { $result->{tenant_name} = $obj->tenant_name; }
    }

    for my $field (@fields)
    {
	my $mfield = $request->mapper->getProperty($field);
        my ($table,$column) = $mfield =~ /^(.+)\.(.+)$/;

	$result->{$field} = 
	    eval { $table eq "me" ? 
		       $obj->$column : 
		       $obj->$table->$column } // undef;
	print $@ if $@;
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


sub user_all_ids
{
    my ($self,$request) = @_;

    my $result = $self->select($request);

    my @fields = qw(id);
    $_ = $_->id for @{$result->{rows}};
    
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

sub vm_all_ids
{
    my ($self,$request) = @_;

    my $result = $self->select($request);

    my @fields = qw(id);
    $_ = $_->id for @{$result->{rows}};
    
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

sub host_all_ids
{
    my ($self,$request) = @_;

    my $result = $self->select($request);

    my @fields = qw(id);
    $_ = $_->id for @{$result->{rows}};
    
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

sub osf_all_ids
{
    my ($self,$request) = @_;

    my $result = $self->select($request);

    my @fields = qw(id);
    $_ = $_->id for @{$result->{rows}};
    
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

sub tag_all_ids
{
    my ($self,$request) = @_;

    my $result = $self->select($request);

    my @fields = qw(id);
    $_ = $_->id for @{$result->{rows}};
    
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

sub di_all_ids
{
    my ($self,$request) = @_;

    my $result = $self->select($request);

    my @fields = qw(id);

    $_ = $_->id for @{$result->{rows}};
    
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


   { total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count), 
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
# La excepción no tiene por qué ser un objeto!!

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
	sub { 
	      #$self->custom_update($props->{update},$obj);   
	      $self->custom_create($props->{set},$obj); 
	      $self->custom_delete($props->{delete},$obj);    
		  
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
	eval { $DB->resultset($t)->update_or_create($a) };

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
		       my $tags = $request->arguments(tags => 1);
		       $tags = exists $tags->{create} ? $tags->{create} : [];
		       $self->custom_create($request->arguments(custom => 1),$di);
                       $self->tags_create($tags,$di);});
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

##################################
## GENERAL STATISTICS FUNCTIONS ##
##################################

my $JSON_TO_DBIX = { User => { blocked => 'me.blocked',
                               tenant  => 'me.tenant_id'}, # FIX ME, PLEASE
                     VM   => { blocked => 'vm_runtime.blocked',
			       state   => 'vm_runtime.vm_state',
                               tenant => 'user.tenant_id' },
		     Host => { blocked => 'runtime.blocked',
			       state   => 'runtime.state' },
		     OSF  => { tenant => 'me.tenant_id' },
		     DI   => { blocked => 'me.blocked',
                               tenant => 'osf.tenant_id'}};

sub qvd_objects_statistics
{
    my $self = shift;
    my $STATISTICS = {};

    $STATISTICS->{$_}->{total} = 
	$self->get_total_number_of_qvd_objects($_)
	for qw(User VM Host OSF DI);

    $STATISTICS->{$_}->{blocked} = 
	$self->get_number_of_blocked_qvd_objects($_)
	for qw(User VM Host DI);

    $STATISTICS->{$_}->{running} = 
	$self->get_number_of_running_qvd_objects($_)
	for qw(VM Host);

    $STATISTICS->{VM}->{expiration} = 
	$self->get_vms_with_expitarion_date();

    $STATISTICS->{Host}->{population} = 
	$self->get_the_most_populated_hosts();

    $STATISTICS;
}

sub get_total_number_of_qvd_objects
{
    my ($self,$qvd_obj) = @_;
    $qvd_obj =~ /^User|VM|Host|OSF|DI$/ ||
	QVD::Admin4::Exception->throw(code=>'4');

    $DB->resultset($qvd_obj)->search(
	{  }, {})->count;
}

sub get_number_of_blocked_qvd_objects
{
    my ($self,$qvd_obj) = @_;
    $qvd_obj =~ /^User|VM|Host|DI$/ ||
	QVD::Admin4::Exception->throw(code=>'4');

    my $filter = $JSON_TO_DBIX->{$qvd_obj}->{blocked};
    my ($related_table) = $filter =~ /^(.+)\.(.+)$/;
    my $join = $related_table eq 'me' ? 
	[] : [$related_table];


    $DB->resultset($qvd_obj)->search(
	{ $filter => 'true' }, {join => $join})->count;
}

sub get_number_of_running_qvd_objects
{
    my ($self,$qvd_obj) = @_;
    $qvd_obj =~ /^VM|Host$/ ||
	QVD::Admin4::Exception->throw(code=>'4');
    my $filter = $JSON_TO_DBIX->{$qvd_obj}->{state};
    my ($related_table) = $filter =~ /^(.+)\.(.+)$/;
    my $join = $related_table eq 'me' ? 
	[] : [$related_table];

    $DB->resultset($qvd_obj)->search(
	{ $filter => 'running' },{join => $join})->count;
}

sub get_vms_with_expitarion_date
{
    my ($self) = @_;

    my $is_not_null = 'IS NOT NULL';
    my $rs = $DB->resultset('VM')->search(
	{ -or => [ { 'vm_runtime.vm_expiration_hard'  => \$is_not_null }, 
		   { 'vm_runtime.vm_expiration_soft'  => \$is_not_null } ] },
	{ join => [qw(vm_runtime)]});

    my $now = DateTime->now();

    [ sort { DateTime->compare($a->{expiration},$b->{expiration}) }
      grep { sum(values %{$_->{remaining_time}}) > 0 }
      map {{ name            => $_->name, 
	     id              => $_->id,
	     expiration      => $_->vm_runtime->vm_expiration_hard,
	     remaining_time  => $self->calculate_date_time_difference($now,
								      $_->vm_runtime->vm_expiration_hard) }}

      $rs->all ];
}

sub calculate_date_time_difference
{
    my ($self,$now,$then) = @_;
    my @time_units = qw(days hours minutes seconds);
    my %time_difference;

    @time_difference{@time_units} = $then->subtract_datetime($now)->in_units(@time_units);
    \%time_difference;
}

sub get_the_most_populated_hosts
{
    my ($self) = @_;

    my $rs = $DB->resultset('Host')->search({ 'vms.vm_state' => 'running'}, 
					    { distinct => 1, 
                                              join => [qw(vms)] });
    return [] unless $rs->count;

    my @hosts = sort { $b->{number_of_vms} <=> $a->{number_of_vms} }
                map {{ name          => $_->name, 
		       id            => $_->id,
		       number_of_vms => $_->vms_connected }} 
                $rs->all;
    my $array_limit = $#hosts > 5 ? 5 : $#hosts;    
    return [@hosts[0 .. $array_limit]];
}

###################
###################
# ADMIN FUNCTIONS
###################
###################

sub admin_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub admin_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name tenant_name tenant);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub admin_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name tenant_name tenant);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}


sub admin_delete {

    my ($self, $request) = @_;

    my $result = $self->select($request);
    $self->_delete($result);

   { total => undef, 
     rows => [] };
}

sub admin_update
{
    my ($self,$request) = @_;
    $self->update($request);
}

sub admin_create {
    my ($self, $request) = @_;

    unless ($self->administrator->is_superadmin)
    {
	$request->{json}->{arguments}->{straight}->{tenant_id} =
	    $self->administrator->tenant_id;
    }

    $DB->txn_do( sub { my $admin = $self->_create($request);
		       $self->_create_related($request,$admin);
		       $self->custom_create($request->arguments(custom => 1),$admin)});

   { total => undef, 
     rows => [] };
}

sub tenant_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub tenant_get_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub tenant_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub tenant_update
{
    my ($self,$request) = @_;
    $self->update($request);
}

sub tenant_create {
    my ($self, $request) = @_;

    
    $DB->txn_do( sub { my $admin = $self->_create($request);
		       $self->_create_related($request,$admin);
		       $self->custom_create($request->arguments(custom => 1),$admin)});


   { total => undef, 
     rows => [] };
}

sub tenant_delete {

    my ($self, $request) = @_;

    my $result = $self->select($request);
    $self->_delete($result);

   { total => undef, 
     rows => [] };
}

sub role_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}

sub role_get_details
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name roles all_acls
                    positive_acls negative_acls all_roles roles);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}


sub acl_tiny_list
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my @fields = qw(id name);
    $_ = $self->_map($_,$request,{},@fields) 
	for @{$result->{rows}};
    
    $result;
}


sub role_assign_acls
{
    my ($self,$request) = @_;
    my $result = $self->select($request);   
    my $failures = {};

    for my $role (@{$result->{rows}})
    {
	my $acls = $request->arguments(acls => 1);
	my $f = 
	sub { #$self->assing_roles($acls->{assign_roles},$role);    
	      #$self->unassing_roles($acls->{unassing_roles},$role);
	      $self->assign_acls($acls->{assign_acls},$role);    
	      $self->unassign_acls($acls->{unassign_acls},$role);};
	
	eval { $DB->txn_do($f)};

	if ($@) { $failures->{$role->id} = ($@->can('code') ? $@->code : 4); }
    }

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
    $result->{rows} = [];
    $result;
}


sub assign_acls
{
    my ($self,$acls,$role) = @_;

    for my $acl_id (@$acls)
    { 	
	next if $role->is_allowed_to($acl_id);
	my $negative_acl = $role->has_negative_acl($acl_id);
	if ($negative_acl) { $negative_acl->search_related('roles',
							   { role_id => $role->id, 
							     acl_id => $acl_id})->first->delete; 
			     next;}

	eval { $DB->resultset('ACL_Setting')->create({role_id => $role->id,
						      acl_id  => $acl_id,
						      positive => 1 }) };
	print $@ if $@;
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
				      message => "$@") if $@;
    }
}

sub unassign_acls
{
    my ($self,$acls,$role) = @_;

    for my $acl_id (@$acls)
    { 	
	next unless $role->is_allowed_to($acl_id);
	my $positive_acl = $role->has_positive_acl($acl_id);
	if ($positive_acl) { $positive_acl->search_related('roles',
							   { role_id => $role->id, 
							     acl_id => $acl_id})->first->delete; 
			     next;}

	eval { $DB->resultset('ACL_Setting')->create({role_id => $role->id,
						      acl_id  => $acl_id,
						      positive => 0 }) };
	print $@ if $@;
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
				      message => "$@") if $@;
    }
}

sub assign_roles
{
    my ($self,$roles_to_assign,$this_role) = @_;

    for my $role_to_assign_id (@$roles_to_assign)
    { 	
	my $role_to_assign = $DB->resultset('Role')->search(
	    {id => $role_to_assign_id})->first;
	QVD::Admin4::Exception->throw(code => 20) 
	    unless $role_to_assign;
	QVD::Admin4::Exception->throw(code => 21)
	    if $this_role->overlaps_with_role($role_to_assign);

	my %acl_ids =  %{$role_to_assign->get_nested_acls};
	$DB->resultset('ACL_Setting')->search({role_id => $this_role->id,
					       acl_id  => [keys %acl_ids],
					       positive => 1})->delete_all;

	eval { $DB->resultset('Inheritance_Roles_Rel')->create(
		   {inherited_id => $roles_to_assign_id,
                    inheritor_id => $this_role->id}) };

	print $@ if $@;
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
				      message => "$@") if $@;
    }
}

sub unassign_roles
{
    my ($self,$roles_to_unassign,$this_role) = @_;

    for my $role_to_unassign_id (@$roles_to_unassign)
    { 	
	my $role_to_unassign = $DB->resultset('Role')->search(
	    {id => $role_to_unassign_id})->first;
	QVD::Admin4::Exception->throw(code => 20) 
	    unless $role_to_unassign;

	eval { $DB->resultset('Inheritance_Roles_Rel')->search(
		   {inherited_id => $roles_to_assign_id,
                    inheritor_id => $this_role->id})->delete_all };

	print $@ if $@;
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
				      message => "$@") if $@;
    }

    my %acl_ids =  %{$this_role->get_nested_acls(no_myself => 1)};
    
    defined $acl_ids{$_->acl_id} || $_->delete
	for $DB->resultset('ACL_Setting')->search({role_id => $this_role->id,
						   positive => 0})->all;

}


1;

