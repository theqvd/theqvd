package QVD::API;

use 5.010;
use strict;
use warnings;
use Moo;
use QVD::DB::Simple;
use File::Copy qw(copy move);
use File::Slurp qw (read_file);
use QVD::API::Exception;
use DateTime;
use List::Util qw(sum);
use File::Basename qw(basename dirname);
use QVD::API::REST::Model;
use QVD::API::REST::Request;
use DBIx::Error;
use Try::Tiny;
use Data::Page;
use Clone qw(clone);
use QVD::API::ConfigClassifier;
use QVD::API::REST::Request::Config_Field;
use QVD::DB::AclsOverwriteList;
use Mojo::JSON qw(encode_json);
use QVD::Config;
use QVD::Config::Core qw(core_cfg_unmangled);

our $VERSION = '0.01';

# This class is a store with the functions intended to properly
# execute the actions asked to the API.

my $DB;

#########################
## STARTING THE OBJECT ##
#########################

sub BUILD
{
    my $self = shift;

    $DB = eval { db() };
    QVD::API::Exception->throw(code=>'2100') if $@;

# 'exception_action' is the function that is executed when 
# the database throws an error. With this setting, DBIx::Error 
# exceptions will be thrown.

    $DB->exception_action( DBIx::Error->exception_action );
}

sub _db { $DB; }

#####################
### GENERIC FUNCTIONS
#####################

# The majority of actions in the API will be executed by means of these generic functions

# FOR REGULAR VISUALIZATION ACTIONS

sub select
{
	my ($self,$request,$modifiers) = @_;

    my @rows;
    my $rs;

    $modifiers //= {};
    my %filters = ( %{$request->get_dbi_format_filters()}, %{$modifiers->{filters} // {}} );
    my %modifiers = ( %{$request->modifiers}, %{$modifiers->{modifiers} // {}} );
    eval {
        $rs = $DB->resultset($request->table)->search(\%filters, \%modifiers);
        @rows = $rs->all
    };

    QVD::API::Exception->throw(exception => $@, query => 'select') if $@;

	{
		total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count),
      rows => \@rows,
		extra => $self->get_extra_info_from_related_views($request),
		# Extra info about objects retrieved from database
		# is stored in here. This info has been retrieved
                                                                     # by a second request to database
	};
}

# Some objects in QVD have some kind of heavy info that cannot be retrieved directly 
# in the main request to the database. For example, properties and other objects related
# to the main object in a 1 to many relation cannot be retrieved in a single step from 
# the database with the prefeatch feature. So they are retieved in an extra  

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

# Ad hoc function for tenant_view_get_list action of API 

sub tenant_view_get_list
{
    my ($self,$request) = @_;

    my @rows;
    my $rs;

# The table provided by $request is supposed to be a view
# In DBIx::Class, views don't accept filters directly. But you can 
# compose queries by adding 'search' methods in a recursive way.
# So, in this case, filters are added in a second 'search' call

    eval { $rs = $DB->resultset($request->table)->search()->search(
	       $request->filters->hash,$request->modifiers);
	   @rows = $rs->all };

    QVD::API::Exception->throw(exception => $@, query => 'select') if $@;

    { total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count), 
      rows => \@rows};
}

# Ad hoc function for acl_get_list action of API

sub acl_get_list
{
    my ($self,$request) = @_;
    my (@rows, $rs);

# The table provided by $request is supposed to be a view
# In DBIx::Class, views don't accept filters directly. But you can 
# compose queries by adding 'search' methods in a recursive way.
# So, in this case, filters are added in a second 'search' call

# This view needs to bind three placeholders. The values of the 
# placeholders must be regular expresions that define lists of 
# acls forbidden, allowed or hidden for the current administrator. 
# Those lists of acls are the acls that should be overwritten 
# over the regular assignation of acls for the administrator.

    my $admin = $request->get_parameter_value('administrator');
    my $aol = QVD::DB::AclsOverwriteList->new(admin_id => $admin->id);
    my $bind = [$aol->acls_to_close_re,$aol->acls_to_open_re,$aol->acls_to_hide_re];

    eval { $rs = $DB->resultset($request->table)->search({},{bind => $bind})->search(
        $request->get_dbi_format_filters(), $request->modifiers);
        @rows = $rs->all };
    QVD::API::Exception->throw(exception => $@, query => 'select') if $@;

    { total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count), 
      rows => \@rows};
}

# Ad hoc function for get_acls_in_admins action of API

sub get_acls_in_admins
{
    my ($self,$request) = @_;
    my (@rows, $rs);

# The table provided by $request is supposed to be a view
# In DBIx::Class, views don't accept filters directly. But you can 
# compose queries by adding 'search' methods in a recursive way.
# So, in this case, filters are added in a second 'search' call

# This view needs to bind three placeholders. The values of the 
# placeholders must be regular expresions that define lists of 
# acls forbidden, allowed or hidden for the current administrator. 
# Those lists of acls are the acls that should be overwritten 
# over the regular assignation of acls for the administrator.

    my $admin_id = $request->json_wrapper->get_filter_value('admin_id')
	// $request->get_parameter_value('administrator')->id;

    my $aol = QVD::DB::AclsOverwriteList->new(admin_id => $admin_id);
    my $bind = [$aol->acls_to_close_re,$aol->acls_to_open_re,$aol->acls_to_hide_re];

    eval { $rs = $DB->resultset($request->table)->search({},{bind => $bind})->search(
        $request->get_dbi_format_filters(), $request->modifiers);
        @rows = $rs->all };
    QVD::API::Exception->throw(exception => $@, query => 'select') if $@;

    { total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count), 
      rows => \@rows};
}

# Ad hoc function for get_acls_in_roles action of API

sub get_acls_in_roles
{
    my ($self,$request) = @_;
    my (@rows, $rs);

    my $admin = $request->get_parameter_value('administrator');
    my $aol = QVD::DB::AclsOverwriteList->new(admin => $admin, admin_id => $admin->id);
    my $bind = [$aol->acls_to_close_re,$aol->acls_to_hide_re];

# The table provided by $request is supposed to be a view
# In DBIx::Class, views don't accept filters directly. But you can 
# compose queries by adding 'search' methods in a recursive way.
# So, in this case, filters are added in a second 'search' call

# This view needs to bind two placeholders. The values of the 
# placeholders must be regular expresions that define lists of 
# acls forbidden or hidden for the current administrator. 
# Those lists of acls are the acls that should be overwritten 
# over the regular assignation of acls for the administrator.

    eval { $rs = $DB->resultset($request->table)->search({},{bind => $bind})->search(
        $request->get_dbi_format_filters(), $request->modifiers);
        @rows = $rs->all };
    QVD::API::Exception->throw(exception => $@, query => 'select') if $@;

    { total => ($rs->is_paged ? $rs->pager->total_entries : $rs->count), 
      rows => \@rows};
}

# FOR REGULAR UPDATE ACTIONS

sub update
{
    my ($self,$request,$modifiers) = @_;
    my $result = $self->select($request);
    QVD::API::Exception->throw(code => 1300) unless $result->{total};
    $modifiers //= {};
    my $conditions = $modifiers->{conditions} // [];
    
    my $failures;
    for my $obj (@{$result->{rows}})
    {
        eval {
            $DB->txn_do( sub {
                $self->$_($obj) for @$conditions;
                # Update the main object
                $obj->update($request->arguments);
                # Update tables related to the main object (i.e. vm_runtimes for vms)
                $self->update_related_objects($request,$obj);
                # Assign and unassign other objects to the main objects (i.e. tags for dis, acls for roles, properties for vms...)
                $self->exec_nested_queries($request,$obj);
            } )
        };
        my $status = 0;
        if($@) {
            my $exception = QVD::API::Exception->new(exception => $@, query => 'update');
            $status = $exception->code;
            $failures->{$obj->id} = $exception;
        }
        
        $self->report_in_log($request,$obj,$status);
    }
    
    QVD::API::Exception->throw(failures => $failures)
        if defined $failures;
    $result->{rows} = [];
    $result;
}

sub update_related_objects
{
    my($self,$request,$obj)=@_;

    my %tables = %{$request->related_objects_arguments};
    for (keys %tables)
    {
	$obj->$_->update($tables{$_}); 
    }    
}

# FOR REGULAR DELETE ACTIONS

sub delete
{
    my ($self,$request,$modifiers) = @_;
    my $result = $self->select($request,$modifiers);
    QVD::API::Exception->throw(code => 1300) unless $result->{total};
    
    $modifiers //= {};
    my $conditions = $modifiers->{conditions} // [];
    my $failures;
    for my $obj (@{$result->{rows}})
    {
        eval {
            $self->$_($obj) for @$conditions;
            $obj->delete;
        };
    
        my $status = 0;
        if($@) {
            my $exception = QVD::API::Exception->new(exception => $@, query => 'delete');
            $status = $exception->code;
            $failures->{$obj->id} = $exception;
        }
        
        $self->report_in_log($request,$obj,$status);
    }
    QVD::API::Exception->throw(failures => $failures)
        if defined $failures;
    
    $result->{rows} = [];
    $result;
}

# Ad hoc function to vm_delete action of API

sub vm_delete
{
    my ($self,$request) = @_;

    $self->delete($request, {conditions => [qw(vm_is_stopped)]} );
}

# Ad hoc function to di_delete action of API

sub di_delete {
    my ($self, $request) = @_;

    $self->delete($request, {conditions => [qw(di_no_vm_runtimes
                                             di_no_dependant_vms
                                             di_no_head_default_tags
                                             di_delete_disk_image)]} );
}

# Ad hoc function to host_delete action of API

sub host_delete
{
    my ($self,$request) = @_;
    $self->delete($request, {conditions => [qw(host_is_not_running)]} );
}

# Ad hoc function to admin_delete action of API

sub admin_delete {
    my ($self, $request) = @_;
    
    my $results = $self->select($request);
    
    for my $admin (@{$results->{rows}}) {
        if($request->administrator->name eq $admin->name) {
            QVD::API::Exception->throw(code => 5200, query => 'delete');
        }
    }
    
    $self->delete($request);
    
    $results->{rows} = [];
    
    return $results;
}

# It deletes config tokens in the database only when tokens
# are custom tokens (they are present neither in Defaults.pm nor in config files) 
 
sub config_delete
{
    my ($self,$request) = @_;

    # Raise an exception if admin cannot delete config
    $self->check_admin_is_allowed_to_config($request);

    my $result = $self->delete($request, { conditions => [qw(is_custom_config)] });

    QVD::Config::reload(); # To refresh config tokens in QVD::Config 
    $result;
}

sub reset_views
{
    my ($request, $tables) = @_;
    my $count = 0;
    for my $table (@$tables) {
        my @rows = $DB->resultset($table)->search()->all;
        @rows = $request->filters->cgrep(@rows);
        for my $row (@rows) {
            try {
                $row->delete;
                $count++;
            }
            catch {
                my $exception = $_;
                QVD::API::Exception->throw({exception => $exception});
            }
        }
    }

    return { rows => [], total => $count };
}

sub reset_tenant_views
{
    my ($self, $request, $modifiers) = @_;

    my $tables = [ qw(Views_Setup_Attributes_Tenant Views_Setup_Properties_Tenant) ];
    return reset_views($request, $tables);
}

sub reset_admin_views
{
    my ($self, $request, $modifiers) = @_;

    my $tables = [ qw(Views_Setup_Attributes_Administrator Views_Setup_Properties_Administrator) ];
    return reset_views($request, $tables);
}

### Manage properties ###

sub property_create {
    my ($self, $request, $modifiers) = @_;

    $self->check_property_name_is_not_registered($request->arguments->{key}, $request->arguments->{tenant_id});
    
    QVD::API::Exception->throw(code => 7215)
        if $request->arguments->{tenant_id} == -1;
        
    return $self->create($request, $modifiers);
}

sub property_update {
    my ($self, $request, $modifiers) = @_;

    $self->check_property_name_is_not_registered($request->arguments->{key}, $request->arguments->{tenant_id});

    return $self->update($request, $modifiers);
}

sub user_property_action {
	my ($self, $request) = @_;
	return $self->qvd_property_action($request, 'user');
}

sub host_property_action {
	my ($self, $request) = @_;
	return $self->qvd_property_action($request, 'host');
}

sub vm_property_action {
	my ($self, $request) = @_;
	return $self->qvd_property_action($request, 'vm');
}

sub osf_property_action {
	my ($self, $request) = @_;
	return $self->qvd_property_action($request, 'osf');
}

sub di_property_action {
	my ($self, $request) = @_;
	return $self->qvd_property_action($request, 'di');
}

sub qvd_property_action {
    my ($self, $request, $object) = @_;
    my $action = $request->get_type_of_action();
    my $outcome;
    
    if ($action eq 'list') {
        # Action to retrieve properties of a certain qvd object
        $outcome = $self->select($request, { filters => { qvd_object => $object } });
    } elsif ($action eq 'create') {
        # Action to assign a property to a qvd object
        $outcome = $self->assign_property($request->administrator, $request->arguments->{property_id}, $object);
    } elsif ($action eq 'delete') {
        # Action to unassign a property from a qvd object
        $outcome = $self->delete($request, { filters => { qvd_object => $object } });
    }
    
    return $outcome;
}

# FOR REGULAR CREATE ACTIONS

sub create
{
    my ($self,$request,$modifiers) = @_;
    my $result;
    
    $modifiers //= {};
    my @conditions = @{$modifiers->{conditions} // []};
    my %arguments = (%{$request->arguments}, %{$modifiers->{'arguments'} // {}});
    
    my $obj;
    eval
    {
        $DB->txn_do(
            sub {
                $self->$_($request) for @conditions;
                $obj = $DB->resultset($request->table)->create(\%arguments);
                # Create tables related to the main object (i.e. vm_runtimes for vms)
                $self->create_related_objects($request,$obj);
                # Assign and unassign other objects to the main objects (i.e. tags for dis, acls for roles, properties for vms...)
                $self->exec_nested_queries($request,$obj);
                $result->{rows} = [ $obj ]
            }
        )
    };
    
    my $status = 0;
    my $exception;
    if($@) {
        $exception = QVD::API::Exception->new(exception => $@, query => 'create');
        $status = $exception->code;
    }
    $self->report_in_log($request, $obj, $status);
    
    $exception->throw if $exception;
    
    $result->{total} = 1;
    $result->{extra} = {};
    
    $result;
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

# Ad hoc function to di_create action of API

sub vm_create
{
    my ($self,$request) = @_;
    
    my $tenant_osf = $self->db->resultset('OSF')->find({ id => $request->arguments->{osf_id} })->tenant_id;
    my $tenant_user = $self->db->resultset('User')->find({ id => $request->arguments->{user_id} })->tenant_id;
    
    unless ($request->administrator->is_superadmin) {
        # Check provided qvd objects are included in the current administrator tenant
        my $tenant_admin = $request->administrator->tenant_id;
        
        if($tenant_admin != $tenant_osf) {
            QVD::API::Exception->throw(code => 7110, object => 'osf_id')
        }
    
        if($tenant_admin != $tenant_user) {
            QVD::API::Exception->throw(code => 7110, object => 'user_id')
        }
    } else {
        # Check provided qvd objects belongs to the same tenant
        if ($tenant_osf != $tenant_user) {
            QVD::API::Exception->throw(code => 7300)
        }
    }
    
    my $result = $self->create($request);
    
    return $result;
}

sub di_create
{
    my ($self,$request) = @_;
    
    unless ($request->administrator->is_superadmin) {
        # Check provided qvd objects are included in the current administrator tenant
        my $tenant_admin = $request->administrator->tenant_id;
        my $tenant_osf = $self->db->resultset('OSF')->find({ id => $request->arguments->{osf_id} })->tenant_id;
        
        if($tenant_admin != $tenant_osf) {
            QVD::API::Exception->throw(code => 7110, object => 'osf_id')
        }
    }
        
    my $result = $self->create($request);
    my $di = @{$result->{rows}}[0];
    
    $self->db->resultset('DI_Tag')->create({di_id => $di->id, tag => $di->version, fixed => 1});
    $self->db->resultset('DI_Tag')->create({di_id => $di->id, tag => 'head'});
    
    $result;
}

# Publication of DIs

sub di_publish {
    my ($self, $di_id) = @_;
    my $di_runtime = $self->db->resultset('DI_Runtime')->find({di_id => $di_id});
    
    QVD::API::Exception->throw(code => 1100) unless ($di_runtime->state eq 'ready');
    
    $self->tags_consolidate($di_runtime->di);
    
    $self->di_state_update($di_id, 'published');
    
    my $vms = $di_runtime->di->related_vms;
    for my $vm (@$vms) {
        if ($vm->vm_runtime->vm_state eq 'running') {
            my %update_expirations = ();
            if(defined($di_runtime->expiration_time_soft)) {
                $update_expirations{vm_expiration_soft} = DateTime->now->add( seconds => $di_runtime->expiration_time_soft );
            }
            if(defined($di_runtime->expiration_time_hard)) {
                $update_expirations{vm_expiration_hard} = DateTime->now->add( seconds => $di_runtime->expiration_time_hard );
            }
            if(%update_expirations) {
                $vm->vm_runtime->update(\%update_expirations);
            }
        }
    }
}

# Update state of creation of DIs

sub di_state_update {
    my $self = shift;
    my $di_id = shift;
    my $state = shift;
    my $message = shift;
    
    # TODO: Check transitions between states
    
    if(not defined($message)) {
        my $status_messages = {
            new            => 'New image was registered',
            generating     => 'Image is being generated',
            fail           => 'Image creation failed',
            uploading      => 'Image is being uploaded',
            upload_stalled => 'Uploading image lasted too much',
            verifying      => 'Image validity is being verified',
            ready          => 'Image is ready for publishing',
            published      => 'Image is published',
            retired        => 'Image is not available'
        };
        $message = $status_messages->{$state} // '';
    }
    
    my $di_runtime = $self->db->resultset('DI_Runtime')->find({di_id => $di_id});
    $di_runtime->update({state => $state, state_ts => time, status_message => $message });
}

# FOR SETTING OF CONFIG TOKENS AND CONFIG VIEWS
# QVD configuration tokens and WAT views are created/updated
# by means of this action 

sub create_or_update
{
	my ($self,$request,$modifiers) = @_;
    my $result;
    my $obj;

	$modifiers //= {};
	my %arguments = (%{$request->arguments}, %{$modifiers->{'arguments'} // {}});

	eval {
		$DB->txn_do( sub {
			$obj = $DB->resultset($request->table)->update_or_create(\%arguments);
			       $result->{rows} = [ $obj ] } )
	};
    
    my $e = $@ ? QVD::API::Exception->new(exception => $@, query => 'set') : undef;

    $self->report_in_log($request,$obj, $e ? $e->code : 0);
    $e->throw if $e;

    $result->{total} = 1;
    $result->{extra} = {};
    $result;
}

sub config_set
{
    my ($self,$request) = @_;

	# Raise an exception if admin cannot modify config
	$self->check_admin_is_allowed_to_config($request);

	# Modify parameter if no exception is raised
    my $result = $self->create_or_update($request);

    QVD::Config::reload(); # To refresh config tokens in QVD::Config 
	return $result;
}

# FOR EXECUTION OF VMs

sub vm_user_disconnect
{
    my ($self,$request) = @_;
    my $result = $self->select($request);
    
    my $failures;
    for my $vm (@{$result->{rows}})
    {
        eval { $vm->vm_runtime->send_user_abort  };
    
        my $status = 0;
        if($@) {
            my $exception = QVD::API::Exception->new(code => 5110, object => $vm->vm_runtime->user_state);
            $status = $exception->code;
            $failures->{$vm->id} = $exception;
        }
        
        $self->report_in_log($request,$vm,$status);
    }
    QVD::API::Exception->throw(failures => $failures)
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
        eval {
            $DB->txn_do( sub {
                $vm->vm_runtime->can_send_vm_cmd('start')  ||
                    QVD::API::Exception->throw(code => 5130,
                        object => $vm->vm_runtime->vm_state);
                $self->vm_assign_host($vm->vm_runtime);
                $vm->vm_runtime->send_vm_start;
                $host{$vm->vm_runtime->host_id}++;}
            ) };
    
        my $status = 0;
        if($@) {
            my $exception = QVD::API::Exception->new(exception => $@);
            $status = $exception->code;
            $failures->{$vm->id} = $exception;
        }
        
        $self->report_in_log($request,$vm,$status);
    }
    
    notify("qvd_admin4_vm_start");
    notify("qvd_cmd_for_vm_on_host$_") for keys %host;
    QVD::API::Exception->throw(failures => $failures)
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
        eval {
            $DB->txn_do( sub {
                $vm->vm_runtime->send_vm_stop;
                $host{$vm->vm_runtime->host_id}++; }
            ) };
    
        my $status = 0;
        if($@) {
            my $exception = QVD::API::Exception->new(code => 5120, object => $vm->vm_runtime->vm_state);
            $status = $exception->code;
            $failures->{$vm->id} = $exception;
        }
        
        $self->report_in_log($request,$vm,$status);
        
        $vm->vm_runtime->update({ vm_cmd => undef })
            if $vm->vm_runtime->vm_state eq 'stopped' &&
                $vm->vm_runtime->vm_cmd                   &&
                $vm->vm_runtime->vm_cmd eq 'start';
    }
    
    notify("qvd_admin4_vm_stop");
    notify("qvd_cmd_for_vm_on_host$_") for keys %host;
    QVD::API::Exception->throw(failures => $failures)
        if defined $failures;
    
    $result->{rows} = [];
    $result;
}

####################
# To report in log #
####################

sub report_in_log
{
   my ($self,$request,$obj,$status) = @_; 

   my $arguments = eval { $request->json_wrapper->original_request->{arguments} } // {};
   my $qvd_object = $request->qvd_object_model->qvd_object_log_style;
   my $type_of_action = $request->qvd_object_model->type_of_action_log_style;

   if ($qvd_object eq 'config' && $type_of_action eq 'delete')
   {
       @{$arguments}{qw(key value)} = ($obj->key,$obj->value);
   }

   if ($qvd_object =~ /^(tenant|admin)_view$/ && $type_of_action eq 'delete')
   {
       @{$arguments}{qw(field visible view_type device_type qvd_object)} = 
	   ($obj->field, $obj->visible, $obj->view_type, $obj->device_type, 
	    $obj->qvd_object);
   }

   my $admin = $request->get_parameter_value('administrator');

   QVD::API::LogReport->new(

       action => { action => $request->json_wrapper->action,
		   type_of_action => $type_of_action },
       qvd_object => $qvd_object,
       tenant => eval { $obj->tenant } // $admin->tenant,
       object => $obj,
       administrator => $admin,
       ip => $request->get_parameter_value('remote_address'),
       source => $request->get_parameter_value('source'),
       arguments => $arguments,
       status => $status 

       )->report;
}

#########################
##### NESTED QUERIES ####
#########################

# Creation and update functions trigger this method intended to assign
# or unassign to one QVD object other related objects:
# a) Assignation of custom properties to VMs, Users, Hosts, OSFs and DIs  
# b) Assignation of tags to DIs
# c) Assignation of roles to other roles or administrators
# d) Assignation of acls to roles

sub exec_nested_queries
{
    my($self,$request,$obj)=@_;

    my %nq = %{$request->nested_queries}; 
    for (keys %nq) #This is supposed to be a list of functions in this class
    {
		$self->$_($nq{$_},$obj,$request);
    }    
}


# ASSIGNATION OF CUSTOM PROPERTIES TO VMs, Users, etc.

sub custom_properties_set
{
    my ($self,$props,$obj,$request) = @_;

    my $class = $request->table;
    my $table = $class . "_Property";
    my $obj_id_name = lc($class) . "_id";

    while (my ($prop_name,$prop_value) = each %$props)
    {
        my @rows = ();
        eval {
            my $filter = {
                "me.qvd_object" => { '=' => lc($class) },
                "properties_list.key" => { '=' => $prop_name }
            };
            unless($request->administrator->is_superadmin()) {
                if ($class eq 'Host') {
                    QVD::API::Exception->throw(code => 7213);
                } else {
                    $filter->{'properties_list.tenant_id'} = $obj->tenant_id;
                }
            }
            @rows = $DB->resultset('QVD_Object_Property_List')->search(
                $filter,
                { join => 'properties_list' }
            )->all();
        };
        QVD::API::Exception->throw(exception => $@, query => 'properties') if $@;

        QVD::API::Exception->throw(code => 1100, query => 'properties') if @rows != 1;
        my $prop_id = $rows[0]->id;

        my $tuple = {property_id => $prop_id, value => $prop_value, $obj_id_name => $obj->id};

        eval { $DB->resultset($table)->update_or_create($tuple) };
        QVD::API::Exception->throw(exception => $@, query => 'properties') if $@;
    }
}

# ASSIGNATION OF TAGS TO DIs.

sub tags_create
{
    my ($self,$tags,$di_obj) = @_;
    
    $self->db->txn_begin;
    
    try {
        my @tags = grep { defined($_) && ($_ ne '') } @$tags;
        
        for my $tag (@tags) {
            my $is_fixed = defined (
                $self->db->resultset("DI_Tag")->find(
                    {
                        'me.tag' => $tag,
                        'di.osf_id' => $di_obj->osf_id,
                        'me.fixed' => 1
                    },
                    {
                        join => [ { di => 'di_runtime' } ]
                    })
            );
            QVD::API::Exception->throw(code => 7330)
                if $is_fixed;
            
            $self->db->resultset('DI_Tag')->create({di_id => $di_obj->id, tag => $tag});
        }
    } catch {
        my $e = shift;
        $self->db->txn_rollback;
        # TODO: QVD::API::Exception shall accept any argument to avoid this conditional
        ref($e) eq 'QVD::API::Exception' ? $e->throw : die $e;
    };
    
    $self->db->txn_commit;
    
    if ($di_obj->state eq 'published') {
        $self->tags_consolidate($di_obj);
    }
}

sub tags_delete
{
    my ($self,$tags,$di) = @_;
    
    $self->db->txn_begin;
    
    try {
        for my $tag (@$tags) {
            next unless defined $tag || $tag eq '';
            
            $tag = $di->search_related('tags',{tag => $tag})->first // next;
            eval {
                QVD::API::Exception->throw(code => 7340)
                    if ($tag->fixed || $tag->tag eq 'head' || $tag->tag eq 'default');
                $tag->delete;
            };
            
            QVD::API::Exception->throw(exception => $@,
                query => 'tags') if $@;
        }
    } catch {
        my $e = shift;
        $self->db->txn_rollback;
        # TODO: QVD::API::Exception shall accept any argument to avoid this conditional
        ref($e) eq 'QVD::API::Exception' ? $e->throw : die $e;
    };
    
    $self->db->txn_commit;
}

sub tags_consolidate
{
    my ($self, $di_obj) = @_;
    
    $self->db->txn_begin;
    
    try {
        for my $tag_obj ($di_obj->tags) {
            my $current_tag = $self->db->resultset('DI_Tag')->search(
                {
                    'me.tag' => $tag_obj->tag,
                    'di.osf_id' => $di_obj->osf_id,
                    'di_runtime.state' => 'published',
                    'di.id' => { '!=' => $di_obj->id }
                },
                {
                    join => [ { di => 'di_runtime' } ]
                })->first;
            
            if(defined($current_tag)) {
                $current_tag->delete;
            }
            
            if($tag_obj->fixed) {
                my @obsolete_tags = $self->db->resultset('DI_Tag')->search(
                    {
                        'me.tag' => $tag_obj->tag,
                        'di.osf_id' => $di_obj->osf_id,
                        'di.id' => { '!=' => $di_obj->id }
                    },
                    {
                        join => [ { di => 'di_runtime' } ]
                    })->all;
                for my $obsolete_tag (@obsolete_tags) {
                    $obsolete_tag->delete;
                }
            }
        }
    } catch {
        my $e = shift;
        $self->db->txn_rollback;
        # TODO: QVD::API::Exception shall accept any argument to avoid this conditional
        ref($e) eq 'QVD::API::Exception' ? $e->throw : die $e;
    };
    
    $self->db->txn_commit;
}

# ASSIGNATION OF ROLES AND ACLS.

sub add_acls_to_role
{
    my ($self,$acls,$role,$request) = @_;

# The API supports identification of acls both by name and by id
# But the function must operate with names. Here the switch is done if needed

    my $acl_names = $self->as_ids($acls,'acls') ? 
	$self->switch_ids_to_names('ACL',$acls) : $acls;

    for my $acl_name (@$acl_names)
    { 	
	$acl_name = undef if defined $acl_name && $acl_name eq '';

	next if $role->is_allowed_to($acl_name); # To avoid redundant assignation
	$role->has_own_negative_acl($acl_name) ?
	    $self->unassign_acl_to_role($role,$acl_name) : # Deletion of negative acl in order 
                                                           # to avoid the inhibition of the acl

	    $self->assign_acl_to_role($role,$acl_name,1);  # Direct assignation of the acl
    }
}

sub del_acls_to_role
{
    my ($self,$acls,$role,$request) = @_;

# The API supports identification of acls both by name and by id
# But the function must operate with names. Here the switch is done if needed

    my $acl_names = $self->as_ids($acls,'acls') ? 
	$self->switch_ids_to_names('ACL',$acls) : $acls;

    for my $acl_name (@$acl_names)
    { 	
	$acl_name = undef if defined $acl_name && $acl_name eq '';
	next unless $role->is_allowed_to($acl_name);
	
	# If the acl has been directly assigned, it is directly deleted

	if ($role->has_own_positive_acl($acl_name)) 
	{
	    $self->unassign_acl_to_role($role,$acl_name);
	}

	# If the acl has been inherited, it is inhibited by means of a negative acls

	if ($role->has_inherited_acl($acl_name))
	{
	    $self->assign_acl_to_role($role,$acl_name,0);
	}
    }
}

sub add_roles_to_role
{
    my ($self,$roles_to_assign,$this_role,$request) = @_;

# The API supports identification of roles both by name and by id
# But the function must operate with names. Here the switch is done if needed

    my $roles_ids = $self->as_ids($roles_to_assign,'roles') ? 
	$roles_to_assign : $self->switch_names_to_ids('Role',$roles_to_assign);

    for my $role_to_assign_id (@$roles_ids)
    {
	$role_to_assign_id = undef if defined $role_to_assign_id && $role_to_assign_id eq '';
	$self->assign_role_to_role($this_role,$role_to_assign_id);
	my $nested_role;
	
	# Deletion of redundant acls after assignation of the new role

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
    my ($self,$roles_to_unassign,$this_role,$request) = @_;

# The API supports identification of roles both by name and by id
# But the function must operate with names. Here the switch is done if needed

    my $roles_ids = $self->as_ids($roles_to_unassign,'roles') ? 
	$roles_to_unassign : $self->switch_names_to_ids('Role',$roles_to_unassign);

    for my $id (@$roles_ids)
    {
	$id = undef if defined $id && $id eq '';
	$self->unassign_role_to_role($this_role,$id) 
    }

    # This is a reload of the object needed after deletion of roles
    # in order to refresh the info in the 'has_inherited_acl' method of Role.
    # There must be a better solution... FIX ME
    # Maybe the reload could be triggered from the oibject itself
    # always has_inherited_acl and other similar methods are executed
    # That cpuld be more elegant, but it may involve performance issues

#    $this_role->discard_changes;

    # Deletion of redundant acls after assignation of the new role
    for my $neg_acl_name ($this_role->get_negative_own_acl_names)
    {
	$self->unassign_acl_to_role($this_role,$neg_acl_name) 
	    unless $this_role->has_inherited_acl($neg_acl_name);
    }
}

# Check if acls or roles have been identified by id or name

sub as_ids
{
    my ($self,$ids_or_names,$qvd_object) = @_;
    my ($as_ids_flag, $as_names_flag) = (0,0);
  
    $_ =~ /^[0-9]+$/ ? $as_ids_flag = 1 : $as_names_flag = 1 for @$ids_or_names;
    QVD::API::Exception->throw(code => 6360, query => $qvd_object) 
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


sub assign_acl_to_role
{
    my ($self,$role,$acl_name,$positive) = @_;

    eval
    {
	my $acl = $DB->resultset('ACL')->find({name => $acl_name})
	    // QVD::API::Exception->throw(code => 6360);

	$role->create_related('acl_rels', { acl_id => $acl->id,
					    positive => $positive });
    };
    QVD::API::Exception->throw(exception => $@, 
				  query => 'acls') if $@;
}

sub unassign_acl_to_role
{
    my ($self,$role,$acl_name) = @_;

    eval
    {
	my $acl = $DB->resultset('ACL')->find({name => $acl_name})
	    // QVD::API::Exception->throw(code => 6360);

	$role->search_related('acl_rels', { acl_id => $acl->id })->delete_all;
    };
    QVD::API::Exception->throw(exception => $@, 
				  query => 'acls') if $@;
}

sub assign_role_to_role
{
    my ($self,$inheritor_role,$inherited_role_id) = @_;

    eval
    { 
	my $inherited_role = $DB->resultset('Role')->find({id => $inherited_role_id})
	    // QVD::API::Exception->throw(code => 6370);

        # In order to avoid circular inheritance
    
	$inheritor_role->id eq $_ && QVD::API::Exception->throw(code => 7350)
	    for ($inherited_role->id, $inherited_role->get_all_inherited_role_ids);

	$inheritor_role->create_related('role_rels', { inherited_id => $inherited_role_id });
    };
    QVD::API::Exception->throw(exception => $@, 
				  query => 'roles') if $@;
}

sub unassign_role_to_role
{
    my ($self,$role,$role_ids) = @_;

    eval { $role->search_related('role_rels', { inherited_id => $role_ids })->delete_all };

    QVD::API::Exception->throw(exception => $@, 
				  query => 'roles') if $@;
}

sub del_roles_to_admin
{
    my ($self,$role_ids,$admin,$request) = @_;

    my $ids = $self->as_ids($role_ids,'roles') ? 
	$role_ids : $self->switch_names_to_ids('Role',$role_ids);

    eval { $DB->resultset('Role_Administrator_Relation')->search(
	       {role_id => $ids,
		administrator_id => $admin->id})->delete_all };
    QVD::API::Exception->throw(exception => $@, 
				  query => 'roles') if $@;
}

sub add_roles_to_admin
{
    my ($self,$role_ids,$admin,$request) = @_;

    my $ids = $self->as_ids($role_ids,'roles') ? 
	$role_ids : $self->switch_names_to_ids('Role',$role_ids);

    for my $role_id (@$ids)
    {
	eval
	{
	    my $role = $DB->resultset('Role')->search({id => $role_id})->first
		// QVD::API::Exception->throw(code => 6370);

	    $role->create_related('admin_rels', 
				  { administrator_id => $admin->id });
	};

	QVD::API::Exception->throw(exception => $@, 
				      query => 'roles') if $@;
    }
}

#############################################################################
### CONDITIONS TO THE EXECUTION OF GENERAL UPDATE/CREATE/DELETE FUNCTIONS ###
#############################################################################

# Same of the main functions in this class (update, create and delete) accept
# a list of conditions as argument. These conditions are checked for all objects
# that may be updated/created/deleted. For every object, the action is executed 
# only if all the conditions are true for them.

my $lb;

# It assigns a host to the vm that has been asked to start

sub vm_assign_host {
    my ($self, $vmrt) = @_;
    if (!defined $vmrt->host_id) {
        $lb //= do {
            require QVD::L7R::LoadBalancer;
            QVD::L7R::LoadBalancer->new();
        };
        my $free_host = eval { $lb->get_free_host($vmrt->vm) } //
	    QVD::API::Exception->throw(code => 5140);

        $vmrt->set_host_id($free_host);
    }
}

# It dies unless the vm is stopped

sub vm_is_stopped
{
    my ($self,$vm) = @_;
    QVD::API::Exception->throw(code => 7310, query => 'delete') 
	unless $vm->vm_runtime->vm_state eq 'stopped';
}

# It dies if the di has vm runtimes

sub di_no_vm_runtimes
{
    my ($self,$di) = @_;
    QVD::API::Exception->throw(code => 7320, query => 'delete') 
	unless $di->vm_runtimes->count == 0;
}

# It dies if the di has related vms  

sub di_no_dependant_vms
{
    my ($self,$di) = @_;
    my $rs = $DB->resultset('VM')->search({'di.id' => $di->id }, 
					  { join => [qw(di)] });
        QVD::API::Exception->throw(code => 7120, query => 'delete') 
	    if $rs->count;
}

# Check if a host is not running

sub host_is_not_running
{
    my ($self,$host) = @_;
    QVD::API::Exception->throw(code => 7321, query => 'delete')
        unless $host->runtime->state ne "running";
}

# When deleting a di with head or default tags, 
# it reassigns head and default tags to other di 

sub di_no_head_default_tags
{
    my ($self,$di) = @_;
    
    if($di->state eq 'published') {
        for my $tag (qw/default head/) {
            next unless $di->has_tag($tag);
            my @potentials = grep { $_->id ne $di->id && $_->state eq 'published' } $di->osf->dis;
            if (@potentials) {
                my $new_di = $potentials[-1];
                $self->db->resultset('DI_Tag')->create({ di_id => $new_di->id, tag => $tag });
            }
        }
    }
    return 1;
}

# When deleting a di, it deletes the related disk image 

sub di_delete_disk_image
{
    my ($self,$di) = @_;

    my $images_path  = eval { cfg('path.storage.images') } // return 1;
    my $images_file = $di->path;
    eval { unlink "$images_path/$images_file" };
}

# Checks if a config token is present in the DB. Throws an exception otherwise

sub is_custom_config
{
    my ($self,$obj) = @_;
    QVD::API::Exception->throw(code=>'7370') unless defined eval {
        QVD::API::REST::Request::Config_Field->new( {
                key => $obj->key, tenant_id => $obj->tenant_id
            } )->is_default;
    };
    return 1;
}

# Check if the current admin is allowed to change the specified configuration

sub check_admin_is_allowed_to_config
{
	my ($self,$request) = @_;

	# Get current administrator
	my $admin = $request->qvd_object_model->current_qvd_administrator;

    # Check multitenant mode
    my $is_multitenant = cfg('wat.multitenant');

    # Get the tenant_id the change will take place
    my $tenant_id = $request->get_adequate_value('tenant_id');
    $tenant_id = eval { $tenant_id->[0] };

    # Common administrators can only modify configuration in his tenant
    if ($is_multitenant & !$admin->is_superadmin && ($admin->tenant_id != $tenant_id)) {
        QVD::API::Exception->throw( code => 4230 );
    }

    # Check if configuration parameter to be changed is a global parameter
    my $keys = $request->get_adequate_value('key');
    for my $key (@$keys) {
        my $config_field = QVD::API::REST::Request::Config_Field->new( {
                key => $key, tenant_id => $tenant_id
            } );
        my $token_value = eval { $request->get_adequate_value('value')->[0] } // $config_field->default_value();
        my $is_declared = defined( $config_field->default_value );

        if ($is_multitenant) {
            # Common administrators cannot create new configuration tokens
            if (!$admin->is_superadmin && !$is_declared) {
                QVD::API::Exception->throw( code => 7382 );
            }

            # Raise exception if cannot change to monotenant
            my $false_in_postgres = '^(f(alse)?|no?|off|0)$';
            if ($key eq 'wat.multitenant' &&
                $token_value =~ /$false_in_postgres/ &&
                # There are more than 1 normal tenant 
                # (in addition to tenant 0 for
                # superadmins and invalid tenant -1)
                QVD::DB::Simple::db()->resultset('Tenant')->search()->count != 3) {
                QVD::API::Exception->throw(code => 7373)

            }
        }

    }

    return 1;
}

sub check_property_name_is_not_registered {
    my ($self,$property_name,$tenant_id) = @_;

    my $is_superadmin_property = ($tenant_id == QVD::DB::Result::Tenant::SUPERADMIN_TENANT_ID);
    my $filter = {
        key => $property_name
    };
    $filter->{tenant_id} = { '-or' => { '=' => [ $tenant_id, QVD::DB::Result::Tenant::SUPERADMIN_TENANT_ID ] } }
        if !$is_superadmin_property;

    my @rows  = ();
    eval {
        @rows = $DB->resultset('Property_List')->search($filter)->all();
    };
    QVD::API::Exception->throw(exception => $@, query => 'select') if $@;

    if(@rows > 0) {
        if($rows[0]->tenant_id == QVD::DB::Result::Tenant::SUPERADMIN_TENANT_ID) {
            QVD::API::Exception->throw(code => 7211);
        } else {
            QVD::API::Exception->throw(code => 7210);
        }
    }
}

######################################
## AD HOC FUNCTIONS WITHOUT REQUEST
######################################

# All these functions are used to process special actions of the API
# They all take a JSON as argument instead of the request of the general
# functions

# Retrieves all fields 'source' in the log table of the database

sub sources_in_wat
{
    my $self = shift;

    my @sources = 
    grep { defined $_->{name} }
    map { { name => $_->source } }  
    $DB->resultset('Log')->search(
	{},{ distinct => 1, select => [qw(source)]})->all;

    { rows => \@sources , total => scalar @sources };
}

# Retrieves all the disk images in the staging directory

sub dis_in_staging
{
    my $self = shift;

    my $staging_path = cfg('path.storage.staging');
    QVD::API::Exception->throw(code=>'2230')
	unless -d $staging_path;
    my $dir;
    opendir $dir, $staging_path;
    my @files = grep { $_ !~ /^\.{1,2}$/ } readdir $dir; 

    { rows => [map { { name => $_ } } @files ] , total => scalar @files };
}

# Retrieves to the WAT info needed to setup the enviroment
# according to the administrator that performs the query.

sub current_admin_setup
{
    my ($self,$request) = @_;

    my $administrator = $request->administrator;

    return {
        admin_language => $administrator->wat_setups->language,
        tenant_language => $administrator->tenant->wat_setups->language,
        admin_block => $administrator->wat_setups->block,
        tenant_block => $administrator->tenant->wat_setups->block,
        admin_id => $administrator->id,
        admin_name => $administrator->name,
        tenant_id => $administrator->tenant_id,
        tenant_name => $administrator->tenant->name,
        acls => [ $administrator->acls ],
        views => [ map { { $_->get_columns } }
            $DB->resultset('Operative_Views_In_Administrator')->search(
                {tenant_id => $administrator->tenant_id, administrator_id => [ undef, $administrator->id ]})->all ]
    };
}

# This function receives an administrator and a list of acl patterns. 
# And it returns the number of acls available for that administrator.

sub get_number_of_acls_in_admin
{
    my ($self,$administrator,$json_wrapper) = @_;

    my $acl_patterns = $json_wrapper->get_filter_value('acl_pattern') // '%';
    $acl_patterns = ref($acl_patterns) ? $acl_patterns : [$acl_patterns];
    my $admin_id = $json_wrapper->get_filter_value('admin_id') //
	QVD::API::Exception->throw(code=>'6220', object => 'admin_id');
    my $aol = QVD::DB::AclsOverwriteList->new(admin_id => $admin_id);
    my $bind = [$aol->acls_to_close_re,$aol->acls_to_open_re,$aol->acls_to_hide_re];

    my $rs = $DB->resultset('Operative_Acls_In_Administrator')->search(
	{},{bind => $bind})->search({admin_id => $admin_id});

    $self->get_number_of_acls($rs,$acl_patterns);
}

# This function receives a role and a list of acl patterns. 
# And it returns the number of acls available for that role.

sub get_number_of_acls_in_role
{
    my ($self,$administrator,$json_wrapper) = @_;

    my $acl_patterns = $json_wrapper->get_filter_value('acl_pattern') // '%';
    $acl_patterns = ref($acl_patterns) ? $acl_patterns : [$acl_patterns];
    my $role_id = $json_wrapper->get_filter_value('role_id') //
        QVD::API::Exception->throw(code=>'6220', object => 'role_id');

# This view needs to bind two placeholders. The values of the 
# placeholders must be regular expresions that define lists of 
# acls forbidden or hidden for the current administrator. 
# Those lists of acls are the acls that should be overwritten 
# over the regular assignation of acls for the administrator.

    my $aol = QVD::DB::AclsOverwriteList->new(admin => $administrator,admin_id => $administrator->id);
    my $bind = [$aol->acls_to_close_re,$aol->acls_to_hide_re];

    my $rs = $DB->resultset('Operative_Acls_In_Role')->search(
        {},{bind => $bind})->search({role_id => $role_id});

    $self->get_number_of_acls($rs,$acl_patterns);
}

sub get_number_of_acls
{
    my ($self,$rs,$acl_patterns) = @_;

    my @acl_patterns = @$acl_patterns;
    $_ =~ s/\./[.]/g for @acl_patterns;
    $_ =~ s/%/.*/g for @acl_patterns;
    my %acl_patterns;
    @acl_patterns{@$acl_patterns} = @acl_patterns;

    my $output;
    $output->{$_} = { total => 0, effective => 0} for @$acl_patterns;

    for my $acl ($rs->all)
    {
        for my $acl_pattern (@$acl_patterns)
        {
            my $re = $acl_patterns{$acl_pattern};
            next unless $acl->acl_name =~ /$re/;
            $output->{$acl_pattern}->{total}++;
            $output->{$acl_pattern}->{effective}++ if $acl->operative;
        }
    }

#    $output->{$_}->{total} || delete $output->{$_} 
#    for keys %$output;

    $output;
}

# Statistics functions

sub users_count
{
    my ($self,$admin) = @_;
    $DB->resultset('User')->search(
	{'me.tenant_id' => $admin->tenants_scope})->count;
}

sub blocked_users_count
{
    my ($self,$admin) = @_;
    $DB->resultset('User')->search(
	{ 'me.blocked' => 'true',
	  'me.tenant_id' => $admin->tenants_scope})->count;
}

sub connected_users_count
{
    my ($self,$admin) = @_;
    $DB->resultset('VM')->search(
	{ 'vm_runtime.user_state' => 'connected',
	  'user.tenant_id' => $admin->tenants_scope }, 
	{ columns => [ qw/user.id/ ],
	distinct => 1, 
	join => [qw(vm_runtime user)] })->count;
}

sub vms_count
{
    my ($self,$admin) = @_;
    $DB->resultset('VM')->search(
	{'user.tenant_id' => $admin->tenants_scope},
	{ join => [qw(user)] })->count;
}

sub blocked_vms_count
{
    my ($self,$admin) = @_;
    $DB->resultset('VM')->search(
	{ 'vm_runtime.blocked' => 'true',
	  'user.tenant_id' => $admin->tenants_scope }, 
	{ join => [qw(vm_runtime user)] })->count;
}

sub running_vms_count
{
    my ($self,$admin) = @_;
    $DB->resultset('VM')->search(
	{ 'vm_runtime.vm_state' => 'running',
	  'user.tenant_id' => $admin->tenants_scope }, 
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
	{'me.tenant_id' => $admin->tenants_scope})->count;
}

sub dis_count
{
    my ($self,$admin) = @_;
    $DB->resultset('DI')->search(
	{ 'osf.tenant_id' => $admin->tenants_scope }, 
	{ join => [qw(osf)] })->count;
}

sub blocked_dis_count
{
    my ($self,$admin) = @_;
    $DB->resultset('DI')->search(
	{ 'osf.tenant_id' => $admin->tenants_scope,
	  'me.blocked' => 'true' }, 
	{ join => [qw(osf)] })->count;
}

sub vms_with_expiration_date
{
    my ($self,$admin) = @_;

    my $is_not_null = 'IS NOT NULL';
    my $rs = $DB->resultset('VM')->search(
	{ 'osf.tenant_id' => $admin->tenants_scope,
	  'vm_runtime.vm_expiration_hard'  => \$is_not_null },
	{ join => [qw(vm_runtime osf)],
	  prefetch => [qw(vm_runtime)]});

    my $now = DateTime->now();

    [ sort { DateTime->compare($a->{expiration},$b->{expiration}) }
      grep { sum(values %{$_->{remaining_time}}) > 0 }
      map {{ name            => $_->name, 
	     id              => $_->id,
	     expiration      => $_->vm_runtime->vm_expiration_hard,
	     remaining_time  => $_->remaining_time_until_expiration_hard }}

      $rs->all ];
}

sub top_populated_hosts
{
    my ($self,$admin) = @_;

    #my $rs = $DB->resultset('Host')->search({ 'vms.vm_state' => 'running'}, 
    my $rs = $DB->resultset('Host')->search({}, 
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

sub config_get
{
    my ($self,$request) = @_;

    my $tenant_id = $request->filters->filter_value('tenant_id');
    my $operator = $request->filters->filter_operator('tenant_id');

    my @rows = ();
    if (defined($tenant_id) && defined($operator)){
        my $tenant_filter = QVD::API::REST::Filter->new( filter => {id => {$operator => $tenant_id} } );
        @rows = $DB->resultset('Tenant')->search($tenant_filter->hash)->all;
    } else {
        # FIXME: This is very inneficient in case the filter does not contain a tenant_id node
        @rows = $DB->resultset('Tenant')->all;
    }

    my @keys = ();
    while(@rows){
        my $row = shift @rows;

        my @all_keys = cfg_keys($tenant_id);

        push @keys, map { QVD::API::REST::Request::Config_Field->new({key => $_, tenant_id => $row->id}) } @all_keys;
    }

    $request->filters->add_filter("is_hidden", 0);

    @keys = $request->filters->cgrep(@keys);
    
    # FIXME: This filter is used to avoid duplicated tuples, current tenant and global tenant -1
    # The scope of the common tenants shall be only its own tenant except for roles, that can 
    # access to those roles that are global
    if (!$request->administrator->is_superadmin) {
        my $extra_filter = QVD::API::REST::Filter->new( filter => {tenant_id => {'!=' => '-1'} } );
        @keys = $extra_filter->cgrep(@keys);
    }

    return {
        total => scalar @keys,
        rows => \@keys
    };
}

sub config_ssl {
    my ($self,$admin,$json_wrapper) = @_;

	my %args = (
		cert => {optional => 0},
		key  => {optional => 0},
		crl  => {optional => 1},
		ca   => {optional => 1},
	);

	for my $key (keys(%args)){
		my $path = $json_wrapper->get_argument_value($key);

		if (!$args{$key}->{optional} && !defined($path)){
			QVD::API::Exception->throw(code=>'6240', object => $key);
    }

		if(defined($path)) {
			my $content = eval { read_file($path) } ||
				QVD::API::Exception->throw(code=>'2270', object => $path);
			my $config_token = "l7r.ssl.$key";

			rs("SSL_Config")->update_or_create( {
				key => $config_token,
				value => $content,
			} );
    }
    }

	QVD::Config::reload();
    
	return {
		total => 1,
		rows => [ ],
	};
}

sub config_wat_get_list
{
	my ($self,$request) = @_;

	# Get current administrator
	my $admin = $request->qvd_object_model->current_qvd_administrator;

	# Tenant is sent as an argument if superadmin
	my $tenant = $admin->tenant_id;

	my $row;
	eval {
		my $rs = $DB->resultset($request->table)->search({tenant_id => $tenant});
		$row = $rs->first;
	};

	QVD::API::Exception->throw(exception => $@, query => 'select') if $@;

	{
		total => 1,
		rows => [ $row ],
	};
}

sub config_wat_update
{
	my ($self,$request) = @_;

	# Get current administrator
	my $admin = $request->qvd_object_model->current_qvd_administrator;

	# Tenant is sent as an argument if superadmin
	my $tenant = $admin->tenant_id;

	my @rows;
	eval {
		for my $obj ($DB->resultset($request->table)->search({tenant_id => $tenant})->all){
			$DB->txn_do( sub {
				# Update the main object
				$obj->update($request->arguments);
				# Update tables related to the main object (i.e. vm_runtimes for vms)
				$self->update_related_objects($request,$obj);
			} );
		}
	};

	QVD::API::Exception->throw(exception => $@, query => 'update') if $@;

	{
		rows => [],
	};
}

sub assign_property_to_objects {
    my ($self, $obj_names, $property, $request) = @_;
    
    for my $obj_name (@$obj_names) {
        $self->assign_property($request->administrator, $property->id, $obj_name);
    }
}

sub assign_property {
    my ($self, $administrator, $property_id, $qvd_obj) = @_;
    
    eval {
        my @properties = $self->_db->resultset("Property_List")->search( { id => $property_id } )->all;
    
        QVD::API::Exception->throw(code => 1100)
            if(@properties != 1);
        my $property = $properties[0];
        
        if($qvd_obj eq 'host') {
            QVD::API::Exception->new(code => 7212)->throw
                unless $administrator->is_superadmin();
            QVD::API::Exception->throw(code => 7214)
                if $property->tenant_id != 0;
        }
        
        $self->_db->resultset("QVD_Object_Property_List")->create( {
            property_id => $property->id,
            qvd_object => $qvd_obj
        } );
    };
    QVD::API::Exception->throw(exception => $@, query => 'create') if $@;
    
    return {
        rows => [],
        total => 1,
        extra => {},
    }
}

sub myadmin_update {
    my ($self,$request,$modifiers) = @_;

    $request->filters->add_filter("id", $request->administrator->id);

    return $self->update($request,$modifiers);
}

sub mytenant_update {
    my ($self,$request,$modifiers) = @_;

    $request->filters->add_filter("id", $request->administrator->tenant_id);

    return $self->update($request,$modifiers);
}

1;
