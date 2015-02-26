package QVD::Admin4;

use 5.010;
use strict;
use warnings;
use Moo;
use QVD::DB;
use QVD::DB::Simple;
use QVD::Config;
use QVD::Config::Core;
use File::Copy qw(copy move);
use Config::Properties;
use QVD::Admin4::Exception;
use DateTime;
use List::Util qw(sum);
use File::Basename qw(basename dirname);
use QVD::Admin4::REST::Model;
use QVD::Admin4::REST::Request;
use DBIx::Error;
use TryCatch;
use Data::Page;
use Clone qw(clone);
use QVD::Admin4::AclsOverwriteList;
our $VERSION = '0.01';

my $DB;

#########################
## STARTING THE OBJECT ##
#########################

sub BUILD
{
    my $self = shift;

    $DB = eval { QVD::DB->new() }; 
    QVD::Admin4::Exception->throw(code=>'2100') if $@;

    $DB->exception_action( DBIx::Error->exception_action );
}

sub _db { $DB; }

#####################
### GENERIC FUNCTIONS
#####################

sub select
{
    my ($self,$request) = @_;

    my @rows;
    my $rs;

    eval { $rs = $DB->resultset($request->table)->search($request->filters,$request->modifiers);
	   @rows = $rs->all };

    QVD::Admin4::Exception->throw(exception => $@, query => 'select') if $@;

    { total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count), 
      rows => \@rows,
      extra => $self->get_extra_info_from_related_views($request) };
}

sub get_extra_info_from_related_views
{
    my ($self,$request) = @_;
    my $extra = {};
    
    my $view_name = $request->related_view;
    return $extra unless $view_name;

    my $vrs = $DB->resultset($view_name)->search();
    $extra->{$_->id} = $_ for $vrs->all;

    $extra;
}

sub update
{
    my ($self,$request,%modifiers) = @_;
    my $result = $self->select($request);
    QVD::Admin4::Exception->throw(code => 1300) unless $result->{total};
    my $conditions = $modifiers{conditions} // [];

    my $failures;
    for my $obj (@{$result->{rows}})
    {
	eval { $DB->txn_do( sub { $self->$_($obj) for @$conditions;
				  $obj->update($request->arguments);
				  $self->update_related_objects($request,$obj);
				  $self->exec_nested_queries($request,$obj);} ) };
	$failures->{$obj->id} = QVD::Admin4::Exception->new(exception => $@, query => 'update')->json if $@; 
    }

    QVD::Admin4::Exception->throw(failures => $failures) 
	if defined $failures; 
    $result->{rows} = [];
    $result;
}


sub delete
{
    my ($self,$request,%modifiers) = @_;
    my $result = $self->select($request);
    QVD::Admin4::Exception->throw(code => 1300) unless $result->{total};

    my $conditions = $modifiers{conditions} // [];
    my $failures;
    for my $obj (@{$result->{rows}})
    {
	eval { $self->$_($obj) for @$conditions; 
	       $obj->delete };

	$failures->{$obj->id} = QVD::Admin4::Exception->new(exception => $@,query => 'delete')->json if $@;
    }
    QVD::Admin4::Exception->throw(failures => $failures) 
	if defined $failures; 

    $result->{rows} = [];
    $result;
}

sub create
{
    my ($self,$request,%modifiers) = @_;
    my $result;
    my $conditions = $modifiers{conditions} // [];

    eval 
    {
	$DB->txn_do( sub { $self->$_($request) for @$conditions;
			   my $obj = $DB->resultset($request->table)->create($request->arguments); 
			   $self->create_related_objects($request,$obj);
			   $self->exec_nested_queries($request,$obj);
			   $result->{rows} = [ $obj ] } )
    };
    
    QVD::Admin4::Exception->throw(exception => $@, query => 'create') if $@;

    $result->{total} = 1;
    $result->{extra} = {};
    $result;
}

sub create_or_update
{
    my ($self,$request) = @_;
    my $result;

    use Data::Dumper; print Dumper $request->arguments;

    eval
    {
	$DB->txn_do( sub { my $obj = $DB->resultset($request->table)->update_or_create($request->arguments);
			   $result->{rows} = [ $obj ] } )
    };

    QVD::Admin4::Exception->throw(exception => $@, query => 'set') if $@;

    $result->{total} = 1;
    $result->{extra} = {};
    $result;
}

###################################################
#### NESTED QUERIES WHEN CREATING AND UPDATING ####
###################################################

sub update_related_objects
{
    my($self,$request,$obj)=@_;

    my %tables = %{$request->related_objects_arguments};
    for (keys %tables)
    {
	$obj->$_->update($tables{$_}); 
    }    
}

sub create_related_objects
{
    my ($self,$request,$obj) = @_;
    my $related_args = $request->related_objects_arguments;

    for my $table ($request->dependencies)
    {
	$obj->create_related($table,($related_args->{$table} || {}));
    }
}

sub exec_nested_queries
{
    my($self,$request,$obj)=@_;

    my %nq = %{$request->nested_queries};
    for (keys %nq)
    {
	$self->$_($nq{$_},$obj); 
    }    
}


#########################
##### NESTED QUERIES ####
#########################

sub custom_properties_set
{
    my ($self,$props,$obj) = @_;

    my $class = ref($obj);     # FIX ME, PLEASE!!!!
    $class =~ s/^QVD::DB::Result::(.+)$/$1/;

    while (my ($key,$value) = each %$props)
    { 
	$key = undef if defined $key && $key eq ''; # FIX ME
	$value = undef if defined $value && $value eq '';
	my $t = $class . "_Property";
	my $k = lc($class) . "_id";
	my $a = {key => $key, value => $value, $k => $obj->id};

	eval { $DB->resultset($t)->update_or_create($a) };
	QVD::Admin4::Exception->throw(exception => $@, 
				      query => 'properties') if $@;
    }
}

sub custom_properties_del
{
    my ($self,$props,$obj) = @_;

    for my $key (@$props)
    {
	$key = undef if defined $key && $key eq ''; # FIX ME
	eval { $obj->search_related('properties', 
				    {key => $key})->delete_all };
	QVD::Admin4::Exception->throw(exception => $@, 
				      query => 'properties') if $@;	
    }
}

sub tags_create
{
    my ($self,$tags,$di) = @_;

    for my $tag (@$tags)
    { 	
	$tag = undef if defined $tag && $tag eq ''; # FIX ME	
	eval
	{
	    my $old_tag = $DB->resultset('DI_Tag')->search({'me.tag' => $tag,
							    'osf.id' => $di->osf_id},
							   {join => [{ di => 'osf' }]})->first;
	    $old_tag->fixed ? 
		QVD::Admin4::Exception->throw(code => 7330) : 
		$old_tag->delete if $old_tag;

	    $DB->resultset('DI_Tag')->create({di_id => $di->id, tag => $tag});
	};

	QVD::Admin4::Exception->throw(exception => $@, 
				      query => 'tags') if $@;
    }
}

sub tags_delete
{
    my ($self,$tags,$di) = @_;

    for my $tag (@$tags)
    {
	$tag = undef if defined $tag && $tag eq ''; # FIX ME
	$tag = $di->search_related('tags',{tag => $tag})->first // next;	    
	eval 
	{ 
	    ($tag->fixed || $tag->tag eq 'head' || $tag->tag eq 'default') 
		&& QVD::Admin4::Exception->throw(code => 7340);
	    $tag->delete;
	};
	
	QVD::Admin4::Exception->throw(exception => $@, 
				      query => 'tags') if $@;
    }
}

sub as_ids
{
    my ($self,$ids_or_names,$qvd_object) = @_;
    my ($as_ids_flag, $as_names_flag) = (0,0);
  
    $_ =~ /^[0-9]+$/ ? $as_ids_flag = 1 : $as_names_flag = 1 for @$ids_or_names;
    QVD::Admin4::Exception->throw(code => 6360, query => $qvd_object) 
	if $as_ids_flag && $as_names_flag;
    $as_ids_flag;
}

sub switch_ids_to_names
{
    my ($self,$table,$ids) = @_;
    [ map { $_->name }  $DB->resultset($table)->search({id => $ids})->all ]
}

sub switch_names_to_ids
{
    my ($self,$table,$names) = @_;
    [ map { $_->id }  $DB->resultset($table)->search({name => $names})->all ]
}

sub add_acls_to_role
{
    my ($self,$acls,$role) = @_;

    my $acl_names = $self->as_ids($acls,'acls') ? 
	$self->switch_ids_to_names('ACL',$acls) : $acls;

    for my $acl_name (@$acl_names)
    { 	
	$acl_name = undef if defined $acl_name && $acl_name eq '';

	next if $role->is_allowed_to($acl_name);
	$role->has_own_negative_acl($acl_name) ?
	    $self->unassign_acl_to_role($role,$acl_name) :
	    $self->assign_acl_to_role($role,$acl_name,1);
    }
}

sub del_acls_to_role
{
    my ($self,$acls,$role) = @_;

    my $acl_names = $self->as_ids($acls,'acls') ? 
	$self->switch_ids_to_names('ACL',$acls) : $acls;

    for my $acl_name (@$acl_names)
    { 	
	$acl_name = undef if defined $acl_name && $acl_name eq '';
	next unless $role->is_allowed_to($acl_name);
	
	if ($role->has_own_positive_acl($acl_name)) 
	{
	    $self->unassign_acl_to_role($role,$acl_name);
	}

	if ($role->has_inherited_acl($acl_name))
	{
	    $self->assign_acl_to_role($role,$acl_name,0);
	}
    }
}

sub add_roles_to_role
{
    my ($self,$roles_to_assign,$this_role) = @_;

    my $roles_ids = $self->as_ids($roles_to_assign,'roles') ? 
	$roles_to_assign : $self->switch_names_to_ids('Role',$roles_to_assign);

    for my $role_to_assign_id (@$roles_ids)
    {
	$role_to_assign_id = undef if defined $role_to_assign_id && $role_to_assign_id eq '';
	$self->assign_role_to_role($this_role,$role_to_assign_id);
	my $nested_role;
	
	for my $own_acl_name ($this_role->get_negative_own_acl_names,
			      $this_role->get_positive_own_acl_names)
	{
	    $nested_role //= $DB->resultset('Role')->find({id => $role_to_assign_id});
	    $self->unassign_acl_to_role($this_role,$own_acl_name) 
		if $nested_role->is_allowed_to($own_acl_name);
	}
    }
}

sub del_roles_to_role
{
    my ($self,$roles_to_unassign,$this_role) = @_;

    for my $id (@$roles_to_unassign)
    {
	$id = undef if defined $id && $id eq '';
	$self->unassign_role_to_role($this_role,$id) 
    }

    $this_role->reload_acls_info;
    for my $neg_acl_name ($this_role->get_negative_own_acl_names)
    {
	$self->unassign_acl_to_role($this_role,$neg_acl_name) 
	    unless $this_role->has_inherited_acl($neg_acl_name);

    }
}

#############

sub switch_acl_sign_in_role
{
    my ($self,$role,$acl_name) = @_;

    eval 
    {
	my $acl = $DB->resultset('ACL')->find({name => $acl_name}) 
	    // QVD::Admin4::Exception->throw(code => 6360);

	my $acl_role_rel = $DB->resultset('ACL_Role_Relation')->find(
	    {role_id => $role->id,
	     acl_id => $acl->id });

	$acl_role_rel->update({ positive => $acl_role_rel->positive ? 0 : 1 });
    };
    QVD::Admin4::Exception->throw(exception => $@, 
				  query => 'acls') if $@;
}


sub assign_acl_to_role
{
    my ($self,$role,$acl_name,$positive) = @_;

    eval
    {
	my $acl = $DB->resultset('ACL')->find({name => $acl_name})
	    // QVD::Admin4::Exception->throw(code => 6360);

	$role->create_related('acl_rels', { acl_id => $acl->id,
					    positive => $positive });
    };
    QVD::Admin4::Exception->throw(exception => $@, 
				  query => 'acls') if $@;
}

sub unassign_acl_to_role
{
    my ($self,$role,$acl_name) = @_;

    eval
    {
	my $acl = $DB->resultset('ACL')->find({name => $acl_name})
	    // QVD::Admin4::Exception->throw(code => 6360);

	$role->search_related('acl_rels', { acl_id => $acl->id })->delete_all;
    };
    QVD::Admin4::Exception->throw(exception => $@, 
				  query => 'acls') if $@;
}

sub assign_role_to_role
{
    my ($self,$inheritor_role,$inherited_role_id) = @_;

    eval
    { 
	my $inherited_role = $DB->resultset('Role')->find({id => $inherited_role_id})
	    // QVD::Admin4::Exception->throw(code => 6370);
    
	$inheritor_role->id eq $_ && QVD::Admin4::Exception->throw(code => 7350)
	    for ($inherited_role->id, $inherited_role->get_all_inherited_role_ids);

	$inheritor_role->create_related('role_rels', { inherited_id => $inherited_role_id });
    };
    QVD::Admin4::Exception->throw(exception => $@, 
				  query => 'roles') if $@;
}

sub unassign_role_to_role
{
    my ($self,$role,$role_ids) = @_;

    eval { $role->search_related('role_rels', { inherited_id => $role_ids })->delete_all };
    QVD::Admin4::Exception->throw(exception => $@, 
				  query => 'roles') if $@;
}

###########

sub del_roles_to_admin
{
    my ($self,$role_ids,$admin) = @_;

    my $ids = $self->as_ids($role_ids,'roles') ? 
	$role_ids : $self->switch_names_to_ids('Role',$role_ids);

    eval { $DB->resultset('Role_Administrator_Relation')->search(
	       {role_id => $ids,
		administrator_id => $admin->id})->delete_all };
    QVD::Admin4::Exception->throw(exception => $@, 
				  query => 'roles') if $@;
}

sub add_roles_to_admin
{
    my ($self,$role_ids,$admin) = @_;

    my $ids = $self->as_ids($role_ids,'roles') ? 
	$role_ids : $self->switch_names_to_ids('Role',$role_ids);

    for my $role_id (@$ids)
    {
	eval
	{
	    my $role = $DB->resultset('Role')->search({id => $role_id})->first
		// QVD::Admin4::Exception->throw(code => 6370);

	    $role->create_related('admin_rels', 
				  { administrator_id => $admin->id });
	};

	QVD::Admin4::Exception->throw(exception => $@, 
				      query => 'roles') if $@;
    }
}

#############################
###### AD HOC FUNCTIONS #####
#############################

sub vm_delete
{
    my ($self,$request) = @_;

    $self->delete($request,conditions => [qw(vm_is_stopped)]);
}

###############################
###############################
###############################

sub di_create_from_upload
{
    my ($self,$request) = @_;

    my $result = $self->create($request);
    my $di = @{$result->{rows}}[0];

    eval
    {
	$di->osf->delete_tag('head');
	$di->osf->delete_tag($di->version);
	$DB->resultset('DI_Tag')->create({di_id => $di->id, tag => $di->version, fixed => 1});
	$DB->resultset('DI_Tag')->create({di_id => $di->id, tag => 'head'});
	$DB->resultset('DI_Tag')->create({di_id => $di->id, tag => 'default'})
	    unless $di->osf->di_by_tag('default');
    };

    QVD::Admin4::Exception->throw(exception => $@,
				  query => 'tags') if $@;

    $di->update({path => $di->id . '-' . $di->path});
    
    $result;
}

sub di_create_from_staging
{
    my ($self,$request) = @_;

    my $images_path  = cfg('path.storage.images');
    QVD::Admin4::Exception->throw(code=>'2220')
	unless -d $images_path;

    my $staging_path = cfg('path.storage.staging');
    QVD::Admin4::Exception->throw(code=>'2230')
	unless -d $staging_path;

    my $staging_file = basename($request->arguments->{path});
    QVD::Admin4::Exception->throw(code=>'2240')
	unless -e "$staging_path/$staging_file";

    my $images_file = $request->get_parameter_value('tmp_file_name') 
	// $staging_file;

    for (1 .. 5)
    {
        eval { copy("$staging_path/$staging_file","$images_path/$images_file") };
        $@ ? print $@ : last;
    }
    if ($@) { QVD::Admin4::Exception->throw(code=>'2210');}

    my $staging_file_size = -s "$staging_path/$staging_file";
    my $images_file_size = -s "$images_path/$images_file";

    unless ($staging_file_size == $images_file_size)
    { unlink "$images_path/$images_file";
      QVD::Admin4::Exception->throw(code=>'2211');}

    my $result = eval { $self->create($request) };
    if ($@)
    { unlink "$images_path/$images_file";
      QVD::Admin4::Exception->throw(exception => $@,
				    query => 'create')};

    my $di = @{$result->{rows}}[0];

    eval
    {
	$di->osf->delete_tag('head');
	$di->osf->delete_tag($di->version);
	$DB->resultset('DI_Tag')->create({di_id => $di->id, tag => $di->version, fixed => 1});
	$DB->resultset('DI_Tag')->create({di_id => $di->id, tag => 'head'});
	$DB->resultset('DI_Tag')->create({di_id => $di->id, tag => 'default'})
	    unless $di->osf->di_by_tag('default');
    };

    if ($@)
    { unlink "$images_path/$images_file";
      QVD::Admin4::Exception->throw(exception => $@,
				    query => 'tags')};

    $di->update({path => $di->id . '-' . $staging_file});
    move("$images_path/$images_file","$images_path/".$di->id . '-' . $staging_file);
    
    $result;
}


##########################################
##########################################


sub di_delete {
    my ($self, $request) = @_;

    $self->delete($request,conditions => [qw(di_no_vm_runtimes 
                                             di_no_dependant_vms
                                             di_no_head_default_tags
                                             di_delete_disk_image)]);
}

sub vm_user_disconnect
{
    my ($self,$request) = @_;
    my $result = $self->select($request);

    my $failures;
    for my $vm (@{$result->{rows}})
    {
	eval { $vm->vm_runtime->send_user_abort  };      
	next unless $@;
	my %args = (code => 5110, object => $vm->vm_runtime->user_state);
	$failures->{$vm->id} = QVD::Admin4::Exception->new(%args)->json; 
    }
    QVD::Admin4::Exception->throw(failures => $failures) 
	if defined $failures;  

    $result->{rows} = [];
    $result;
}

sub vm_start
{
    my ($self,$request) = @_;

    my $result = $self->select($request);
    my ($failures, %host);

    for my $vm (@{$result->{rows}})
    {
	for (1 .. 5) { eval { $DB->txn_do( sub {

		  $vm->vm_runtime->can_send_vm_cmd('start')  ||
		  QVD::Admin4::Exception->throw(code => 5130, 
					      object => $vm->vm_runtime->vm_state);
		  $self->vm_assign_host($vm->vm_runtime);
		  $vm->vm_runtime->send_vm_start;
		  $host{$vm->vm_runtime->host_id}++; }

				  ) }; $@ or last; } 
	next unless $@;
	$failures->{$vm->id} = QVD::Admin4::Exception->new(exception => $@)->json; 
    }

    notify("qvd_admin4_vm_start");
    notify("qvd_cmd_for_vm_on_host$_") for keys %host;
    QVD::Admin4::Exception->throw(failures => $failures) 
	if defined $failures;  

    $result->{rows} = [];
    $result;
}

sub vm_stop
{
    my ($self,$request) = @_;

    my $result = $self->select($request);
    my ($failures, %host);

    for my $vm (@{$result->{rows}})
    {
	for (1 .. 5) { eval { $DB->txn_do( sub {

		  $vm->vm_runtime->send_vm_stop;
		  $host{$vm->vm_runtime->host_id}++; }

				  ) }; $@ or last; } 
	next unless $@;
	my %args = (code => 5120, object => $vm->vm_runtime->vm_state);
	$failures->{$vm->id} = QVD::Admin4::Exception->new(%args)->json; 

	$vm->vm_runtime->update({ vm_cmd => undef })
	    if $vm->vm_runtime->vm_state eq 'stopped' &&
	    $vm->vm_runtime->vm_cmd                   &&
	    $vm->vm_runtime->vm_cmd eq 'start'; 
    }

    notify("qvd_admin4_vm_stop");
    notify("qvd_cmd_for_vm_on_host$_") for keys %host;
    QVD::Admin4::Exception->throw(failures => $failures) 
	if defined $failures;  

    $result->{rows} = [];
    $result;
}


##########################
### AUXILIAR FUNCTIONS ###
##########################

sub dis_in_staging
{
    my $self = shift;

    my $staging_path = cfg('path.storage.staging');
    QVD::Admin4::Exception->throw(code=>'2230')
	unless -d $staging_path;
    my $dir;
    opendir $dir, $staging_path;
    my @files = grep { $_ !~ /^\.{1,2}$/ } readdir $dir; 

    { rows => [map { { name => $_ } } @files ] , total => scalar @files };
}

my $lb;
sub vm_assign_host {
    my ($self, $vmrt) = @_;
    if (!defined $vmrt->host_id) {
        $lb //= do {
            require QVD::L7R::LoadBalancer;
            QVD::L7R::LoadBalancer->new();
        };
        my $free_host = eval { $lb->get_free_host($vmrt->vm) } //
	    QVD::Admin4::Exception->throw(code => 5140);

        $vmrt->set_host_id($free_host);
    }
}

sub vm_is_stopped
{
    my ($self,$vm) = @_;
    QVD::Admin4::Exception->throw(code => 7310, query => 'delete') 
	unless $vm->vm_runtime->vm_state eq 'stopped';
}

sub di_no_vm_runtimes
{
    my ($self,$di) = @_;
    QVD::Admin4::Exception->throw(code => 7320, query => 'delete') 
	unless $di->vm_runtimes->count == 0;
}


sub di_no_dependant_vms
{
    my ($self,$di) = @_;
    my $rs = $DB->resultset('VM')->search({'di.id' => $di->id }, 
					  { join => [qw(di)] });
        QVD::Admin4::Exception->throw(code => 7120, query => 'delete') 
	    if $rs->count;
}

sub di_no_head_default_tags
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

sub di_delete_disk_image
{
    my ($self,$di) = @_;

    my $images_path  = eval { cfg('path.storage.images') } // return 1;
    my $images_file = $di->path;
    eval { unlink "$images_path/$images_file" };
}

######################################
## GENERAL FUNCTIONS; WITHOUT REQUEST
######################################

sub tenant_view_get_list
{
    my ($self,$request) = @_;

    my @rows;
    my $rs;

    eval { $rs = $DB->resultset($request->table)->search()->search(
	       $request->filters,$request->modifiers);
	   @rows = $rs->all };

    QVD::Admin4::Exception->throw(exception => $@, query => 'select') if $@;

    { total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count), 
      rows => \@rows};
}

sub acl_get_list
{
    my ($self,$request) = @_;
    my (@rows, $rs);

    my $admin = $request->get_parameter_value('administrator');
    my $aol = QVD::Admin4::AclsOverwriteList->new(admin_id => $admin->id);
    my $bind = [$aol->acls_to_close_re,$aol->acls_to_open_re,$aol->acls_to_hide_re];

    eval { $rs = $DB->resultset($request->table)->search({},{bind => $bind})->search(
	       $request->filters, $request->modifiers);
	   @rows = $rs->all };
    QVD::Admin4::Exception->throw(exception => $@, query => 'select') if $@;

    { total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count), 
      rows => \@rows};
}

sub get_acls_in_admins
{
    my ($self,$request) = @_;
    my (@rows, $rs);

    my $admin_id = $request->json_wrapper->get_filter_value('admin_id')
	// $request->get_parameter_value('administrator')->id;

    my $aol = QVD::Admin4::AclsOverwriteList->new(admin_id => $admin_id);
    my $bind = [$aol->acls_to_close_re,$aol->acls_to_open_re,$aol->acls_to_hide_re];

    eval { $rs = $DB->resultset($request->table)->search({},{bind => $bind})->search(
	       $request->filters, $request->modifiers);
	   @rows = $rs->all };
    QVD::Admin4::Exception->throw(exception => $@, query => 'select') if $@;

    { total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count), 
      rows => \@rows};
}

sub get_acls_in_roles
{
    my ($self,$request) = @_;
    my (@rows, $rs);

    my $admin = $request->get_parameter_value('administrator');
    my $aol = QVD::Admin4::AclsOverwriteList->new(admin => $admin, admin_id => $admin->id);
    my $bind = [$aol->acls_to_close_re,$aol->acls_to_hide_re];

    eval { $rs = $DB->resultset($request->table)->search({},{bind => $bind})->search(
	       $request->filters, $request->modifiers);
	   @rows = $rs->all };
    QVD::Admin4::Exception->throw(exception => $@, query => 'select') if $@;

    { total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count), 
      rows => \@rows};
}

sub current_admin_setup
{
    my ($self,$administrator,$json_wrapper) = @_;

    { multitenant => cfg('wat.multitenant'),
      admin_language => $administrator->language,
      tenant_language => $administrator->tenant_language,
      admin_block => $administrator->block,
      tenant_block => $administrator->tenant_block,
      admin_id => $administrator->id,
      tenant_id => $administrator->tenant_id,
      acls => [ $administrator->acls ],
      views => [ map { { $_->get_columns } }
		 $DB->resultset('Operative_Views_In_Administrator')->search(
		     {administrator_id => $administrator->id})->all ]};
}


sub get_number_of_acls_in_admin
{
    my ($self,$administrator,$json_wrapper) = @_;

    my $acl_patterns = $json_wrapper->get_filter_value('acl_pattern') // '%';
    $acl_patterns = ref($acl_patterns) ? $acl_patterns : [$acl_patterns];
    my $admin_id = $json_wrapper->get_filter_value('admin_id') //
        QVD::Admin4::Exception->throw(code=>'6220', object => 'admin_id');
    my $aol = QVD::Admin4::AclsOverwriteList->new(admin_id => $admin_id);
    my $bind = [$aol->acls_to_close_re,$aol->acls_to_open_re,$aol->acls_to_hide_re];

    my $output;
    for my $acl_pattern (@$acl_patterns)
    {
	my $rs = $DB->resultset('Operative_Acls_In_Administrator')->search(
	    {},{bind => $bind})->search({admin_id => $admin_id, acl_name => { ILIKE => $acl_pattern}});
	my @total = $rs->all;
	my @effective = grep { $_->operative } @total;
	$output->{$acl_pattern} = { total => scalar @total,effective => scalar @effective };
    }

    $output;
}

sub get_number_of_acls_in_role
{
    my ($self,$administrator,$json_wrapper) = @_;

    my $acl_patterns = $json_wrapper->get_filter_value('acl_pattern') // '%';
    $acl_patterns = ref($acl_patterns) ? $acl_patterns : [$acl_patterns];
    my $role_id = $json_wrapper->get_filter_value('role_id') //
        QVD::Admin4::Exception->throw(code=>'6220', object => 'role_id');
    my $aol = QVD::Admin4::AclsOverwriteList->new(admin => $administrator,admin_id => $administrator->id);
    my $bind = [$aol->acls_to_close_re,$aol->acls_to_hide_re];

    my $output;
    for my $acl_pattern (@$acl_patterns)
    {
	my $rs = $DB->resultset('Operative_Acls_In_Role')->search(
	    {},{bind => $bind})->search({role_id => $role_id, acl_name => { ILIKE => $acl_pattern }});

	my @total = $rs->all;
	my @effective = grep { $_->operative } @total;
	$output->{$acl_pattern} = { total => scalar @total,effective => scalar @effective };
    }

    $output;
}


##################################
## GENERAL STATISTICS FUNCTIONS ##
##################################

sub users_count
{
    my ($self,$admin) = @_;
    $DB->resultset('User')->search(
	{'me.tenant_id' => $admin->tenants_scoop})->count;
}

sub blocked_users_count
{
    my ($self,$admin) = @_;
    $DB->resultset('User')->search(
	{ 'me.blocked' => 'true',
	  'me.tenant_id' => $admin->tenants_scoop})->count;
}

sub vms_count
{
    my ($self,$admin) = @_;
    $DB->resultset('VM')->search(
	{'user.tenant_id' => $admin->tenants_scoop},
	{ join => [qw(user)] })->count;
}

sub blocked_vms_count
{
    my ($self,$admin) = @_;
    $DB->resultset('VM')->search(
	{ 'vm_runtime.blocked' => 'true',
	  'user.tenant_id' => $admin->tenants_scoop }, 
	{ join => [qw(vm_runtime user)] })->count;
}

sub running_vms_count
{
    my ($self,$admin) = @_;
    $DB->resultset('VM')->search(
	{ 'vm_runtime.vm_state' => 'running',
	  'user.tenant_id' => $admin->tenants_scoop }, 
	{ join => [qw(vm_runtime user)] })->count;
}

sub hosts_count
{
    my ($self,$admin) = @_;
    $DB->resultset('Host')->search()->count;
}

sub blocked_hosts_count
{
    my ($self,$admin) = @_;

    $DB->resultset('Host')->search(
	{ 'runtime.blocked' => 'true' },
	{ join => [qw(runtime)] })->count;
}

sub running_hosts_count
{
    my ($self,$admin) = @_;
    $DB->resultset('Host')->search(
	{ 'runtime.state' => 'running' },
	{ join => [qw(runtime)] })->count;
}

sub osfs_count
{
    my ($self,$admin) = @_;
    $DB->resultset('OSF')->search(
	{'me.tenant_id' => $admin->tenants_scoop})->count;
}

sub dis_count
{
    my ($self,$admin) = @_;
    $DB->resultset('DI')->search(
	{ 'osf.tenant_id' => $admin->tenants_scoop }, 
	{ join => [qw(osf)] })->count;
}

sub blocked_dis_count
{
    my ($self,$admin) = @_;
    $DB->resultset('DI')->search(
	{ 'osf.tenant_id' => $admin->tenants_scoop,
	  'me.blocked' => 'true' }, 
	{ join => [qw(osf)] })->count;
}

sub vms_with_expiration_date
{
    my ($self,$admin) = @_;

    my $is_not_null = 'IS NOT NULL';
    my $rs = $DB->resultset('VM')->search(
	{ 'osf.tenant_id' => $admin->tenants_scoop,
	  'vm_runtime.vm_expiration_hard'  => \$is_not_null },
	{ join => [qw(vm_runtime osf)],
	  prefetch => [qw(vm_runtime)]});

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

sub top_populated_hosts
{
    my ($self,$admin) = @_;

    my $rs = $DB->resultset('Host')->search({ 'vms.vm_state' => 'running'}, 
					    { distinct => 1, 
                                              join => [qw(vms)] });
    return [] unless $rs->count;

    my @hosts = sort { $b->{number_of_vms} <=> $a->{number_of_vms} }
                map {{ name          => $_->name, 
		       id            => $_->id,
		       number_of_vms => $_->vms_count }} 
                $rs->all;
    my $array_limit = $#hosts > 5 ? 5 : $#hosts;    
    return [@hosts[0 .. $array_limit]];
}

######################
####### CONFIG #######
######################

sub config_preffix_get
{
    my @keys = cfg_keys; 
    my %preffix;

    for (@keys)
    {
	next unless m/^([^.]+)\./;
	$preffix{$1} = 1;
    }
    my @preffix = sort keys %preffix; 

    { total => scalar @preffix,
      rows => \@preffix };
}

sub config_get
{
    my ($self,$admin,$json_wrapper) = @_;

    my $cp = $json_wrapper->get_filter_value('key');
    my $cp_re = $json_wrapper->get_filter_value('key_re');
    my @keys = cfg_keys;
    @keys = grep { $_ =~ /\Q$cp\E/ } @keys if $cp;
    @keys = grep { $_ =~ /$cp_re/ } @keys if $cp_re;


    my $od = $json_wrapper->order_direction // '-asc';

    my $total = scalar @keys;
    my $block = $json_wrapper->block // $total;
    my $offset = $json_wrapper->offset // 1;

    my $page = Data::Page->new($total, $block, $offset);

    @keys = sort { $a cmp $b } @keys;
    @keys = reverse @keys if $od eq '-desc'; 
    @keys = $page->splice(\@keys);

   { total => $total,
     rows => [ map {{ key => $_, 
		      operative_value => cfg($_), 
		      default_value => (defined eval{ core_cfg($_)} ? core_cfg($_) : undef) }} @keys ] };
}

sub config_set
{
    my ($self,$request) = @_;
    my $result = $self->create_or_update($request);
#    notify(qvd_config_changed);
    QVD::Config::reload();
    $result;
}

sub config_default
{
    my ($self,$request) = @_;

    my $result = $self->delete($request, conditions => [qw(is_custom_config)]);
#    notify(qvd_config_changed);
    QVD::Config::reload();
    $result;
}
 
sub config_delete
{
    my ($self,$request) = @_;

    my $result = $self->delete($request, conditions => [qw(is_not_custom_config)]);
#    notify(qvd_config_changed);
    QVD::Config::reload();
    $result;
}
 
sub is_not_custom_config
{
    my ($self,$obj) = @_;
    QVD::Admin4::Exception->throw(code=>'7372') if defined eval { core_cfg($obj->key) };
    return 1;
}

sub is_custom_config
{
    my ($self,$obj) = @_;
    QVD::Admin4::Exception->throw(code=>'7371') unless defined eval { core_cfg($obj->key) };
    return 1;
}

sub config_ssl {
    my ($self,$admin,$json_wrapper) = @_;
    my $cert = $json_wrapper->get_argument_value('cert') //
	QVD::Admin4::Exception->throw(code=>'6240', object => 'cert');

    my $key = $json_wrapper->get_argument_value('key') //
	QVD::Admin4::Exception->throw(code=>'6240', object => 'key');

    my $crl = $json_wrapper->get_argument_value('crl');

    my $ca = $json_wrapper->get_argument_value('ca');

    rs(SSL_Config)->update_or_create({ key => 'l7r.ssl.cert',
                                       value => $cert });
    rs(SSL_Config)->update_or_create({ key => 'l7r.ssl.key',
                                       value => $key });

    if (defined $crl) {
        rs(SSL_Config)->update_or_create({ key => 'l7r.ssl.crl',
                                           value => $crl })
    }
    else {
        rs(SSL_Config)->search({ key => 'l7r.ssl.crl' })->delete;
    }

    if (defined $ca) {
        rs(SSL_Config)->update_or_create({key => 'l7r.ssl.ca',
                                          value => $ca });
    }
    else {
        rs(SSL_Config)->search({ key => 'l7r.ssl.ca' })->delete;
    }

    notify(qvd_config_changed);

    { total => 1,
     rows => [ ] };
}

####################

1;
