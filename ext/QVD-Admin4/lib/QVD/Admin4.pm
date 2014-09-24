package QVD::Admin4;

use 5.010;
use strict;
use warnings;
use Moose;
use QVD::DB;
use QVD::DB::Simple;
use QVD::Config;
use File::Copy qw(copy move);
use Config::Properties;
use QVD::Admin4::Exception;
use DateTime;
use List::Util qw(sum);
use QVD::Config::Network qw(nettop_n netstart_n net_aton net_ntoa);
our $VERSION = '0.01';

has 'administrator', is => 'ro', isa => 'QVD::DB::Result::Administrator';

my $DB;

#########################
## STARTING THE OBJECT ##
#########################

sub BUILD
{
    my $self = shift;

    $DB = QVD::DB->new() // 
	QVD::Admin4::Exception->throw(code=>'2');
}

sub _db { $DB; }

sub get_credentials
{
    my ($self,%params) = @_;

    my $admin = eval { $DB->resultset('Administrator')->find(\%params) };
    return undef unless $admin;

    $admin->set_tenants_scoop(
	[ map { $_->id } 
	  $DB->resultset('Tenant')->search()->all ])
	if $admin->is_superadmin;

    $self->{administrator} = $admin;

    return { login => $admin->name,
	     tenant => $admin->tenant_id };
}


#####################
### GENERIC FUNCTIONS
#####################

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
   my ($self,$request) = @_;
   my $result = $self->select($request);
   $self->_update($request,$result);
}

sub _update
{
    my ($self,$request,$result,@conditions) = @_;

    my $failures = {};

    for my $obj (@{$result->{rows}})
    {
	eval { $self->$_($obj) for @conditions;
	       $DB->txn_do( sub { eval { $obj->update($request->arguments) };
				  QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
								message => "$@") if $@;
				  $self->update_related_objects($request,$obj);
	 if ($@) { $failures->{$obj->id} = ($@->can('code') ? $@->code : 4); }
    }

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
    $result->{rows} = [];
    $result;
}

sub update_related_objects
{
    my($self,$request,$obj)=@_;

    my %tables = %{$request->related_objects_arguments};
    for (keys %tables)
    {
	eval { $obj->$_->update($tables{$_}) }; 
	QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
	                              message => "$@") if $@;
    }
    
}


sub exec_nested_queries_in_request
{
    my ($self,$nested_queries,$result) = @_;

    my $failures = {};

    for my $obj (@{$result->{rows}})
    {
	eval { $self->$_($obj) for @conditions;
	       $DB->txn_do( sub { eval { $obj->update($request->arguments) };
				  QVD::Admin4::Exception->throw(code => ($DB->storage->_dbh->state || 4),
								message => "$@") if $@;
				  $self->update_related_objects($request,$obj);
	 if ($@) { $failures->{$obj->id} = ($@->can('code') ? $@->code : 4); }
    }

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
    $result->{rows} = [];
    $result;
}


sub exec_over_searcin_request
{
    my($self,$request,$obj)=@_;
    my %nested_queries = %{$request->nested_queries};

    my $acls_nested_query = $nested_queries{aclChanges}; 
    $self->change_acls_in_nested_request($acls_nested_query,$obj)
	if defined $acls_nested_query;

    my $tags_nested_query = $nested_queries{tagChanges}; 
    $self->change_tags_in_nested_request($tags_nested_query,$obj)
	if defined $tags_nested_query;

    my $cp_nested_query = $nested_queries{propertiesChanges}; 
    $self->change_custom_properties_in_nested_request($cp_nested_query,$obj)
	if defined $cp_nested_query;
}

sub change_acls_in_nested_request
{
    my ($self,$nested_query,$obj) = @_;

}


sub change_tags_in_nested_request
{
    my ($self,$nested_query,$obj) = @_;

}

sub change_custom_properties_in_nested_request
{
    my ($self,$nested_query,$obj) = @_;

}

    $self->custom_create($props->{set},$obj); 
    $self->custom_delete($props->{delete},$obj);    
    $self->tags_delete($tags->{delete},$di);    
    $self->tags_create($tags->{create},$di);};
$self->assign_roles($acls->{assign_roles},$role);    
$self->unassign_roles($acls->{unassign_roles},$role);
$self->assign_acls($acls->{assign_acls},$role);    
$self->unassign_acls($acls->{unassign_acls},$role); }) };	
$self->add_role_to_admin($roles->{assign_roles},$admin);
$self->del_role_to_admin($roles->{unassign_roles},$admin);

}

sub delete
{
    my ($self,$result) = @_;
    my $failures = {};

    for my $obj (@{$result->{rows}})
    {
         eval { $self->$_($obj) || 
		    QVD::Admin4::Exception->throw(code => 16)
		    for @conditions; 
		$obj->delete };
	 print $@ if $@;
	 if ($@) { $failures->{$obj->id} = ($@->can('code') ? $@->code : 4); }
    }

    QVD::Admin4::Exception->throw(code => 1, failures => $failures) if %$failures;
}

sub create
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
# Meter create related y nested
}

sub create_related
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

sub create_nested
{

}
#########################
##### NESTED QUERIES ####
#########################

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

sub assign_acls
{
    my ($self,$acl_ids,$role) = @_;

    for my $acl_id (@$acl_ids)
    { 	
	my $acl = $DB->resultset('ACL')->search(
	    { id => $acl_id })->first;
	QVD::Admin4::Exception->throw(code => 21) 
	    unless $acl; 
	next if $role->is_allowed_to($acl->name);
	$role->has_negative_acl($acl->name) ?
	    $role->unassign_acls($acl->id) :
	    $role->assign_acl($acl->id,1);
    }
}

sub unassign_acls
{
    my ($self,$acl_ids,$role) = @_;

    for my $acl_id (@$acl_ids)
    { 	
	my $acl = $DB->resultset('ACL')->search(
	    { id => $acl_id })->first;
	QVD::Admin4::Exception->throw(code => 21)
	    unless $acl; 

	next unless $role->is_allowed_to($acl->name);

	$role->has_positive_acl($acl->name) ?
	    $role->unassign_acls($acl->id) :
	    $role->assign_acl($acl->id,0);
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

	my @acl_ids = [$role_to_assign->_get_inherited_acls(return_value => 'id')];
	$this_role->unassign_acls(\@acl_ids);
	$this_role->assign_role($role_to_assign->id);
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
	$this_role->unassign_roles($role_to_unassign->id);
    }

    my %acl_ids = map { $_->id => 1 } $this_role->_get_only_inherited_acls(return_value => 'id');

    defined $acl_ids{$_} || $this_role->unassign_acls($_,0)
    for $this_role->_get_own_acls(return_value => 'id', positive => 0);
}

sub del_role_to_admin
{
    my ($self,$role_ids,$admin) = @_;
    $DB->resultset('Role_Assignment_Relation')->search(
	{role_id => $role_ids,
	 administrator_id => $admin->id})->delete_all;
}

sub add_role_to_admin
{
    my ($self,$role_ids,$admin) = @_;


    eval { $DB->resultset('Role_Assignment_Relation')->create(
	       {role_id => $_,
		administrator_id => $admin->id}) } for @$role_ids;
}

#############################
###### AD HOC FUNCTIONS #####
#############################

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

##########################
### AUXILIAR FUNCTIONS ###
##########################

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

sub _get_free_ip {
    my $self = shift;
    my $nettop = nettop_n;
    my $netstart = netstart_n;

    my %ips = map { net_aton($_->ip) => 1 } 
    $self->db->resultset('VM')->all;

    while ($nettop-- > $netstart) {
        return net_ntoa($nettop) unless $ips{$nettop}
    }
    die "No free IP addresses";
}

sub get_default_version
{ 
    my $self = shift;

    my ($y, $m, $d) = (localtime)[5, 4, 3];
    $m ++;
    $y += 1900;

    my $osf_id = $self->json->{arguments}->{straight}->{osf_id}  //
	QVD::Admin4::Exception->throw(code=>'23502'); # FIX ME: PREVIOUS REVISION OF MANDATORY ARGUMENTS
    my $osf = $self->db->resultset('OSF')->search({id => $osf_id})->first;
    my $version;

    for (0..999) 
    {
	$version = sprintf("%04d-%02d-%02d-%03d", $y, $m, $d, $_);
	last unless $osf->di_by_tag($version);
    }
    $version;
}


sub get_di_id_subquery
{    
my $self = shift; 
   if (defined $self->json->{filters}->{di_id})
    {
	my $dirs = $self->db->resultset('DI'); 
	my $di_id = $self->json->{filters}->{di_id};

	$self->json->{filters}->{osf_id} = 
	{ -in => $dirs->search({ 'subquery.id' => $di_id,
                                 'tags.tag' => { -ident => 'me.di_tag' } },
			       { join => ['tags'], 
				 alias => 'subquery'})->get_column('osf_id')->as_query };
	delete $self->json->{filters}->{di_id};
    }
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

1;

