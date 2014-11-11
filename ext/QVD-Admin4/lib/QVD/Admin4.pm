package QVD::Admin4;

use 5.010;
use strict;
use warnings;
use Moo;
use QVD::DB;
use QVD::DB::Simple;
use QVD::Config;
use File::Copy qw(copy move);
use Config::Properties;
use QVD::Admin4::Exception;
use DateTime;
use List::Util qw(sum);
use File::Basename qw(basename dirname);
use QVD::Admin4::REST::Model;
use QVD::Admin4::REST::Request;
use Data::Dumper;
use DBIx::Error;
use TryCatch;
use Data::Page;

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
	eval 
	{ 
	    $tag = $di->search_related('tags',{tag => $tag})->first // next;	    
	    ($tag->fixed || $tag->tag eq 'head' || $tag->tag eq 'default') 
		&& QVD::Admin4::Exception->throw(code => 7340);
	    $tag->delete;
	};
	
	QVD::Admin4::Exception->throw(exception => $@, 
				      query => 'tags') if $@;
    }
}

sub add_acls_to_role
{
    my ($self,$acl_names,$role) = @_;

    for my $acl_name (@$acl_names)
    { 	
	$acl_name = undef if defined $acl_name && $acl_name eq '';
	next if $role->is_allowed_to($acl_name);
	$role->has_own_negative_acl($acl_name) ?
	    $self->switch_acl_sign_in_role($role,$acl_name) :
	    $self->assign_acl_to_role($role,$acl_name,1);
    }
}

sub del_acls_to_role
{
    my ($self,$acl_names,$role) = @_;

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

    for my $role_to_assign_id (@$roles_to_assign)
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

    $this_role->reload_full_acls_inheritance_tree;
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
	    for $inherited_role->get_all_inherited_role_ids;

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

    eval { $DB->resultset('Role_Administrator_Relation')->search(
	       {role_id => $role_ids,
		administrator_id => $admin->id})->delete_all };
    QVD::Admin4::Exception->throw(exception => $@, 
				  query => 'roles') if $@;
}

sub add_roles_to_admin
{
    my ($self,$role_ids,$admin) = @_;

    for my $role_id (@$role_ids)
    {
	eval
	{
	    my $role = $DB->resultset('Role')->find({id => $role_id})
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


sub di_create
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

    my $images_file  = $di->id . '-' . $staging_file;
    $di->update({path => $images_file});

    for (1 .. 5)
    {
	eval { copy("$staging_path/$staging_file","$images_path/$images_file") };
	$@ ? print $@ : last;
    }
    if ($@) { $di->delete; QVD::Admin4::Exception->throw(code=>'2210');}

    $result;
}

sub di_delete {
    my ($self, $request) = @_;

    $self->delete($request,conditions => [qw(di_no_vm_runtimes 
                                             di_no_dependant_vms
                                             di_no_head_default_tags)]);
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

    my $f = sub { my $vm = shift; 
		  $vm->vm_runtime->can_send_vm_cmd('start')  ||
		  QVD::Admin4::Exception->new(code => 5130, 
					      object => $vm->vm_runtime->vm_state);
		  $self->vm_assign_host($vm->vm_runtime);
		  $vm->vm_runtime->send_vm_start;
		  $host{$vm->vm_runtime->host_id}++;};

    for my $vm (@{$result->{rows}})
    {
	for (1 .. 5) { eval { $DB->txn_do($f->($vm)) }; $@ or last; } 
	next unless $@;
	$failures->{$vm->id} = QVD::Admin4::Exception->new(exception => $@)->json; 
    }

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

    my $f = sub { my $vm = shift; 
		  $vm->vm_runtime->send_vm_stop;
		  $host{$vm->vm_runtime->host_id}++;};

    for my $vm (@{$result->{rows}})
    {
	for (1 .. 5) { eval { $DB->txn_do($f->($vm)) }; $@ or last; } 
	next unless $@;
	my %args = (code => 5120, object => $vm->vm_runtime->vm_state);
	$failures->{$vm->id} = QVD::Admin4::Exception->new(%args)->json; 

	$vm->vm_runtime->update({ vm_cmd => undef })
	    if $vm->vm_runtime->vm_state eq 'stopped' &&
	    $vm->vm_runtime->vm_cmd                   &&
	    $vm->vm_runtime->vm_cmd eq 'start'; 
    }

    notify("qvd_cmd_for_vm_on_host$_") for keys %host;
    QVD::Admin4::Exception->throw(failures => $failures) 
	if defined $failures;  

    $result->{rows} = [];
    $result;
}


##########################
### AUXILIAR FUNCTIONS ###
##########################

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



######################################
## GENERAL FUNCTIONS; WITHOUT REQUEST
######################################

sub get_properties_by_qvd_object
{
    my ($self,$admin,$json) = @_;
    my $qvd_object = lc $json->forze_filter_deletion('qvd_object') //
        QVD::Admin4::Exception->throw(code=>'6220', object => 'qvd_object');
   $qvd_object =~ /^user|vm|host|osf|di$/ ||
       QVD::Admin4::Exception->throw(code=>'6320');

    my $tenant_id =  $json->forze_filter_deletion('tenant_id');

    my %tables = (user=>'User',vm =>'VM',host=>'Host',osf=>'OSF',di =>'DI');

    my $tenants_scoop = defined $tenant_id && $admin->is_superadmin ?
        $tenant_id : $admin->tenants_scoop;

    $tenants_scoop = [$tenants_scoop] unless ref($tenants_scoop);

    my $filters = $qvd_object eq 'host' ? {} :
    {tenant_id => { IN =>  $tenants_scoop }};

    my $rs = $DB->resultset($tables{$qvd_object}.'_Properties_List_View')->
        search($filters);

    my %props;
    for my $props_in_tenant (map { $_->properties } $rs->all)
    {
        $props{$_} = 1 for @$props_in_tenant;
    }

    { total => scalar keys %props,
      rows => [sort keys %props ] };
}


sub current_admin_setup
{
    my ($self,$administrator,$json_wrapper) = @_;

    my $f =
        sub { my $obj = shift;
              my @methods = qw(field qvd_object view_type                                                                                                                                     
                               device_type property);
              my $out; $out .= $obj->$_ for @methods; $out; };

    my @tenant_views = $DB->resultset('Tenant_Views_Setup')->search(
        {tenant_id => $administrator->tenant_id})->all;
    my @admin_views = $DB->resultset('Administrator_Views_Setup')->search(
        {administrator_id => $administrator->id})->all;
    my %views = map { $f->($_) => $_ } @tenant_views;
    $views{$f->($_)} = $_ for  @admin_views;

   { admin_id => $administrator->id,
     tenant_id => $administrator->tenant_id,
     acls => [ $administrator->acls ],
     views => [ map { { $_->get_columns } } values %views ]};
}

sub get_acls_in_admins
{
    my ($self,$admin,$json_wrapper) = @_;
    my $admin_id = $json_wrapper->get_filter_value('admin_id') //
	QVD::Admin4::Exception->throw(code=>'6220', object => 'admin_id');
    $admin_id = [$admin_id] unless ref($admin_id);
    
    my $acls_info;

    for my $role (map { $_->role } $DB->resultset('Role_Administrator_Relation')->search(
		      {administrator_id => $admin_id})->all)
    {
	my $inherited_acls_tree = $role->get_full_acls_inheritance_tree;

	for my $acl_id (keys %{$inherited_acls_tree->{$role->id}->{iacls}})
	{
	    $acls_info->{$acl_id}->{name} = $inherited_acls_tree->{$role->id}->{iacls}->{$acl_id}->{name};
	    $acls_info->{$acl_id}->{id} = $acl_id;
            $acls_info->{$acl_id}->{roles}->{$role->id} =
                $inherited_acls_tree->{$role->id}->{name};
	}
    }

    my $acls_name = $json_wrapper->get_filter_value('acl_name') // '%';
    my $acls_rs = $DB->resultset('ACL')->search({id => [keys %$acls_info], 
						 name => { like => $acls_name }},
	{ order_by => { ($json_wrapper->order_direction || '-asc') => 
			($json_wrapper->order_criteria || []) },
	  page => ($json_wrapper->offset || 1),
	  rows => ($json_wrapper->block || 10000) });

   { total => ($acls_rs->is_paged ? $acls_rs->pager->total_entries : $acls_rs->count), 
     rows => [map { $acls_info->{$_->id} } $acls_rs->all] };
}

sub get_acls_in_roles
{
    my ($self,$admin,$json_wrapper) = @_;
    my $role_id = $json_wrapper->get_filter_value('role_id') //
	QVD::Admin4::Exception->throw(code=>'6220', object => 'role_id');
    $role_id = [$role_id] unless ref($role_id);
    
    my $acls_info;

    for my $role ($DB->resultset('Role')->search({id => $role_id})->all)
    {
	my $inherited_acls_tree = $role->get_full_acls_inheritance_tree;
	for my $acl_id (keys %{$inherited_acls_tree->{$role->id}->{iacls}})
	{
	    $acls_info->{$acl_id} = $inherited_acls_tree->{$role->id}->{iacls}->{$acl_id};
	    $acls_info->{$acl_id}->{roles}->{$role->id} = $role->name if
                defined $inherited_acls_tree->{$role->id}->{acls}->{1}->{$acl_id};

            $acls_info->{$acl_id}->{roles}->{$_->{id}} = $_->{name}
                for grep { defined $_->{iacls}->{$acl_id} }
                    values %{$inherited_acls_tree->{$role->id}->{roles}};
	}
    }

    my $acls_name = $json_wrapper->get_filter_value('acl_name') // '%';
    my $acls_rs = $DB->resultset('ACL')->search({id => [keys %$acls_info], 
						 name => { like => $acls_name }},
	{ order_by => { ($json_wrapper->order_direction || '-asc') => 
			($json_wrapper->order_criteria || []) },
	  page => ($json_wrapper->offset || 1),
	  rows => ($json_wrapper->block || 10000) });

   { total => ($acls_rs->is_paged ? $acls_rs->pager->total_entries : $acls_rs->count), 
     rows => [map { $acls_info->{$_->id} } $acls_rs->all] };
}

sub get_number_of_acls_in_role
{
    my ($self,$admin,$json_wrapper) = @_;
    $self->get_number_of_acls_in_role_or_admin('Role',$json_wrapper);
}

sub get_number_of_acls_in_admin
{
    my ($self,$admin,$json_wrapper) = @_;
    $self->get_number_of_acls_in_role_or_admin('Administrator',$json_wrapper);
}

sub get_number_of_acls_in_role_or_admin
{
    my ($self,$table,$json_wrapper) = @_;

    my $acl_patterns = $json_wrapper->get_filter_value('acl_pattern') //
	QVD::Admin4::Exception->throw(code=>'6220', object => 'acl_pattern');
    $acl_patterns = ref($acl_patterns) ? $acl_patterns : [$acl_patterns];
    my $id = $json_wrapper->get_filter_value($table eq 'Role' ? 'role_id' : 'admin_id') // 
	QVD::Admin4::Exception->throw(code=>'6220', object => $table eq 'Role' ? 'role_id' : 'admin_id'); 

    my $object = $DB->resultset($table)->find({ id => $id }) //
	QVD::Admin4::Exception->throw(code=>  $table eq 'Role' ? 6370 : 6360);

    my $output;
    for my $acl_pattern (@$acl_patterns)
    {
	my $rs = $DB->resultset('ACL')->search({ name => { ilike => $acl_pattern }});
	my $total_number_of_acls = $rs->count;
	my @available_acls_in_role = grep { $object->is_allowed_to($_->name) } $rs->all;
	my $available_acls_in_role = @available_acls_in_role;
 
	$output->{$acl_pattern} = 
	{ total => $total_number_of_acls,
	  effective => $available_acls_in_role };
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
	{ 'vm_runtime.vm_expiration_hard'  => \$is_not_null },
	{ join => [qw(vm_runtime)],
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
		       number_of_vms => $_->vms_connected }} 
                $rs->all;
    my $array_limit = $#hosts > 5 ? 5 : $#hosts;    
    return [@hosts[0 .. $array_limit]];
}

######################
####### CONFIG #######
######################

sub config_get
{
    my ($self,$table,$json_wrapper) = @_;

    my $cp = $json_wrapper->get_filter_value('key');
    my @keys = $cp ? grep { $_ =~ /\Q$cp\E/ } cfg_keys : cfg_keys ;

    use Data::Dumper; print Dumper \@keys;

    my $od = $json_wrapper->order_direction // '-asc';

    my $total = scalar @keys;
    my $block = $json_wrapper->block // $total - 1;
    my $offset = $json_wrapper->offset // 1;

    my $page = Data::Page->new($total, $block, $offset);

    @keys = sort { $a cmp $b } @keys;
    @keys = reverse @keys if $od eq '-desc'; 
    @keys = $page->splice(\@keys);

   { total => $total,
     rows => [ map {{ $_ => cfg($_) }} @keys ] };

}

sub config_set
{
    my ($self,$request) = @_;

    $self->create_or_update($request);
    notify(qvd_config_changed);
}

sub config_default
{
    my ($self,$request) = @_;

    $self->delete($request);
    notify(qvd_config_changed);
}
 


sub config_ssl {
    my ($self,$admin,$json_wrapper) = @_;
    my $cert = $json_wrapper->get_filter_value('cert') //
	QVD::Admin4::Exception->throw(code=>'6220', object => 'cert');

    my $key = $json_wrapper->get_filter_value('key') //
	QVD::Admin4::Exception->throw(code=>'6220', object => 'key');

    my $crl = $json_wrapper->get_filter_value('crl');

    my $ca = $json_wrapper->get_filter_value('ca');

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

    1
}



1;
