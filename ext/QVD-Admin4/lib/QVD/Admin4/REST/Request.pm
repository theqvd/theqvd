package QVD::Admin4::REST::Request;
use strict;
use warnings;
use Moo;
use QVD::Config;
use QVD::Admin4::Exception;
use QVD::Admin4::REST::Filter;
use QVD::Admin4::ConfigsOverwriteList;
use QVD::DB::Simple qw(db);

# This class implements a request to the database. In fact, 
# objects of this class are used by the methods in QVD::Admin4 
# in order to ask the database via DBIx::Class.

# The constructor takes two cruacial parameters: 
# a) 'json_wrapper' denotes the input query to the API
# b) 'qvd_object_model' is the model that defines
#    how the input query should be and how it should be 
#    translated into DBIx::Class format

# With these parameters, the constructor triggers several checks
# over the input query. And it throws an informative exception
# in case one check don't pass. Otherwise, the constructor
# creates a repository with the information of the input query
# translated to a certain format. When needed, some extra elements
# are added to the repository.

# The resultant object provides several accessors methods, that
# let you get the info from the repository. These accessors
# are used by the methods in QVD::Admin4 in order to build the
# requests to DB

# All checks and translations in this class are operated over the 
# input query ('json_wrapper') according the model for that kind 
# of action ('qvd_object_model').

has 'json_wrapper', is => 'ro', isa => sub { die "Invalid type for attribute json_wrapper" 
						 unless ref(+shift) eq 'QVD::Admin4::REST::JSON'; }, required => 1;
has 'qvd_object_model', is => 'ro', isa => sub { die "Invalid type for attribute qvd_object_model" 
						     unless ref(+shift) eq 'QVD::Admin4::REST::Model'; } , required => 1;

# These are the main accessors used in QVD::Admin4

has 'modifiers', is => 'ro', isa => sub { die "Invalid type for attribute modifiers" 
					      unless ref(+shift) eq 'HASH'; }, 
                             default => sub { {  group_by => [], # TO DO: default dbix grouping fails for ordering in related tables. This avoids 
						                # grouping, but turns off DISTINCT...
						join => [], order_by => { '-asc' => []}  }};
has 'filters', is => 'ro', isa => sub { die "Invalid type for attribute failures" 
					    unless ref(+shift) eq 'HASH'; }, default => sub { {}; };
has 'parameters', is => 'ro', isa => sub { die "Invalid type for attribute parameters" 
					    unless ref(+shift) eq 'HASH'; }, default => sub { {}; };
has 'arguments', is => 'ro', isa => sub { die "Invalid type for attribute arguments" 
					      unless ref(+shift) eq 'HASH'; }, default => sub { {}; };
has 'related_objects_arguments', is => 'ro', isa => sub { die "Invalid type for attribute related_objects_arguments" 
							      unless ref(+shift) eq 'HASH'; }, default => sub { {}; };
has 'nested_queries', is => 'ro', isa => sub { die "Invalid type for attribute nested_queries" 
						   unless ref(+shift) eq 'HASH'; }, default => sub { {}; };

has 'related_views', is => 'ro', isa => sub { die "Invalid type for attribute related_views" 
						   unless ref(+shift) eq 'ARRAY'; }, default => sub { []; };

my $ADMIN;

# The constructor triggers several checks
# over the input query. And it throws an informative exception
# in case one check don't pass. Otherwise, the constructor
# creates a repository with the information of the input query
# translated to a certain format. When needed, some extra elements
# are added to the repository.

# All checks and translations in this class are operated over the 
# input query ('json_wrapper') according the model for that kind 
# of action ('qvd_object_model').

sub BUILD 
{
    my $self = shift;

    $ADMIN = $self->qvd_object_model->current_qvd_administrator;

# CHECKS OR DIE

# Not all config tokens can be updated from the API
# This function checks if the requested config tokens
# are available from the API

    $self->check_config_token_availability
	if $self->qvd_object_model->qvd_object eq 
	'Config';

# Operative acls must be asked just for one role
# Otherwise the request doesn't make sense 

    $self->check_unique_role_in_acls_search
	if $self->qvd_object_model->qvd_object eq 
	'Operative_Acls_In_Role';

# Operative acls must be asked just for one admin
# Otherwise the request doesn't make sense 

    $self->check_unique_admin_in_acls_search
	if $self->qvd_object_model->qvd_object eq 
	'Operative_Acls_In_Administrator';

# It checks if the requested fields to retrieve 
# are available

    $self->check_fields_validity_in_json;

# It checks if the current admin is allowed to delete

    $self->check_acls_for_deleting if
	$self->qvd_object_model->type_of_action eq 'delete';

# It checks if the filters in the input query
# are available in the system and if the current
# admin is allowed to use them

    $self->check_filters_validity_in_json;

# It checks if the arguments in an update query
# are available in the system and if the current
# admin is allowed to use them

# The action 'myadmin_update' is used to change the 
# personal configuration of the current admin
# (password, language...). The checks are different  
# in that case: an admin can only use 'myadmin_update'
# to change its own values

    $self->check_update_arguments_validity_in_json if
	$self->qvd_object_model->type_of_action eq 'update' &&
	(not $self->json_wrapper->action eq 'myadmin_update');

# It checks if the arguments in a creation query
# are available in the system and if the current
# admin is allowed to use them

    $self->check_create_arguments_validity_in_json if
	$self->qvd_object_model->type_of_action =~ /^create(_or_update)?$/;

# It checks if the nested queries in a creation or update query 
# (tags, custom properties, role and acls assignations...) are 
# available in the system and if the current admin is allowed to use them

    $self->check_nested_queries_validity_in_json if
	$self->qvd_object_model->type_of_action =~ /^(cre|upd)ate$/;

# It checks if the order criteria in a query
# are available in the system and if the current
# admin is allowed to use them

    $self->check_order_by_validity_in_json;

# GENERAL SETTINGS ACCORDING MODEL

# Creates the info repositories that will
# be used by accessors methods in order to retrieve
# info about the Request in DBIx::Class format

    $self->set_filters_in_request;

    $self->set_parameters_in_request;
    $self->set_pagination_in_request;
    $self->set_arguments_in_request;
    $self->set_nested_queries_in_request;
    $self->set_related_views_in_request;
    $self->set_order_by_in_request;
    $self->set_tables_to_join_in_request;

# AD HOC SETTING OF OBLIGATORY ELEMENTS 

# The recovery administrator is stored in the database
# but it cannot be neither seen, updated nor deleted.
# This method adds to the request an extra filter
# that avoids the recovery admin to be selected

    $self->hide_recovery_mode_administrator
	if $self->qvd_object_model->qvd_object eq 'Administrator';

# The accion 'get_acls_in_admins' without an admin_id filter 
# is supposed to ask for the operative acls in the current admin.
# This methods adds the corresponding filter if needed 

    $self->set_default_admin_id_in_acls_search
	if $self->qvd_object_model->qvd_object eq 
	'Operative_Acls_In_Administrator';

# Requests must include a proper filter by tenant, cause
# non-superadmin admins can only operate over its own
# tenant. The corresponding filters to filtering by tenant
# are added in here

    $self->forze_filtering_by_tenant;

# The action 'myadmin_update' can be only used over the current
# admin. This method adds the corresponding filters

    $self->forze_filtering_by_own_admin
	if $self->json_wrapper->action eq 'myadmin_update';

# Actions 'admin_view_set' and 'admin_view_reset' are supposed to operate
# over the current admin. The correspondig filters are added in here

	if ($self->qvd_object_model->qvd_object eq 'Views_Setup_Attributes_Administrator' ||
		$self->qvd_object_model->qvd_object eq 'Views_Setup_Properties_Administrator') {
		$self->forze_own_admin_id_in_admin_views;
	}

# Tenants must be filtered by tenant in a different way than other objects 

    $self->forze_filtering_tenants_by_tenant
        if $self->qvd_object_model->qvd_object eq 'Tenant';

# When creating a new object it must be assigned to the right tenant

    $self->forze_tenant_assignment_in_creation
	if $self->qvd_object_model->type_of_action =~ /^create(_or_update)?$/ &&
	$self->qvd_object_model->directly_tenant_related;

# This method adds filters in order to avoid selecting
# objects the admin doesn't have acls for. These acls
# are assigned to filter values

# i.e. an admin allowed to use the 'log' table with the 
# filter 'qvd_object' may not be allowed to select
# 'log' entries with 'qvd_object' = 'vm'. In that case, 
# a filter is added to avoid retrieving log entries with 
# qvd_object=vm
 
    $self->forze_filtering_by_acls_for_filter_values;

# After check and changes, filters are retrieved as a simple hash

    $self->{filters} = $self->filters->hash;
}

###############
## CHECKINGS ##
###############

sub check_config_token_availability
{
    my $self = shift;

	# This code gives a regex that denotes the set of acls that can be
	# accessed via API. If the config token requested doesn't match this regex
	# it is an unavailable one
	my $token = $self->get_json_adequate_value('key');

	my $tenant = $ADMIN->is_superadmin ? $self->get_json_adequate_value('tenant_id') : $ADMIN->tenant_id;

	my $col = QVD::Admin4::ConfigsOverwriteList->new(admin_id => $ADMIN->id);
	my $col_re = $col->configs_to_show_re($tenant);

    QVD::Admin4::Exception->throw(code => 6380, object => $token) 
	unless $token =~ /$col_re/;

	# This code forbids the switch to monotenant mode if
	# in the system there are multiple tenants

    my $token_value = $self->qvd_object_model->type_of_action eq 'delete' ?
	'0' : $self->json_wrapper->get_argument_value('value');

    my $false_in_postgres = '^(f(alse)?|no?|off|0)$';

	# Raise exception if cannot change to monotenant
	QVD::Admin4::Exception->throw(code => 7373)
		if $token eq 'wat.multitenant' &&
	$token_value =~ /$false_in_postgres/ &&
        # There are more than 1 normal tenant 
			# (in addition to tenant 0 for
			# superadmins and invalid tenant -1)
			QVD::DB::Simple::db()->resultset('Tenant')->search()->count != 3;
}


sub check_unique_admin_in_acls_search
{
    my $self = shift;
    my @admin_id = ($self->json_wrapper->get_filter_value('admin_id'));
    QVD::Admin4::Exception->throw(code => 6322, object => 'admin_id') 
	if scalar @admin_id > 1;     
}

sub check_unique_role_in_acls_search
{
    my $self = shift;
    my @role_id = ($self->json_wrapper->get_filter_value('role_id'));
    QVD::Admin4::Exception->throw(code => 6322, object => 'role_id') 
	if scalar @role_id > 1; 
}

sub check_filters_validity_in_json
{
    my $self = shift;

    $self->qvd_object_model->available_filter($_) || 
	$self->qvd_object_model->has_property($_) || # is a custom property
	QVD::Admin4::Exception->throw(code => 6210, object => $_)
	for $self->json_wrapper->filters_list;

    my $admin = $self->qvd_object_model->current_qvd_administrator;

    $admin->re_is_allowed_to(
	$self->qvd_object_model->get_acls_for_filter(
	    $self->qvd_object_model->has_property($_) ? 'properties' : $_)) || # There is just one acl for all custom properties 
	QVD::Admin4::Exception->throw(code => 4220, object => $_)
	for $self->json_wrapper->filters_list;

    $self->json_wrapper->has_filter($_) ||
	QVD::Admin4::Exception->throw(code => 6220, object => $_)
	for $self->qvd_object_model->mandatory_filters;
}

# When needed, it checks if the admin can perform massive
# deletions. An operation is massive if more than one
# object are involved 

sub check_acls_for_deleting
{
    my $self = shift;
    my $id = $self->json_wrapper->get_filter_value('id');
    return unless ref($id) && scalar @$id > 1;

    my $admin = $self->qvd_object_model->current_qvd_administrator;
    $admin->re_is_allowed_to($self->qvd_object_model->get_acls_for_delete_massive) 
	|| QVD::Admin4::Exception->throw(code => 4240);
}

sub check_update_arguments_validity_in_json
{
    my $self = shift;
    my $admin = $self->qvd_object_model->current_qvd_administrator;

    $self->qvd_object_model->available_argument($_) || 
	QVD::Admin4::Exception->throw(code => 6230, object => $_)
	for $self->json_wrapper->arguments_list;

# An operation is considered massive if it is applied over more than one 
# object. For this kind of action, the 'id' is a mandatory filter
# and it is the only filter available. So it can be known the amount of objects
# will be involved by using that filter.

    my $id = $self->json_wrapper->get_filter_value('id');
    my ($method,$code) = ref($id) && scalar @$id > 1 ? 
	('get_acls_for_argument_in_massive_update',4240) : 
	('get_acls_for_argument_in_update',4230) ;

    $admin->re_is_allowed_to($self->qvd_object_model->$method($_)) || 
	QVD::Admin4::Exception->throw(code => $code, object => $_) 
	for $self->json_wrapper->arguments_list
}

sub check_create_arguments_validity_in_json
{
    my $self = shift;
    my $admin = $self->qvd_object_model->current_qvd_administrator;

    $self->json_wrapper->has_argument($_) || 
	defined $self->qvd_object_model->get_default_argument_value($_,$self->json_wrapper) ||
        ($_ eq 'tenant_id' && (not $ADMIN->is_superadmin)) || 
	QVD::Admin4::Exception->throw(code => 6240 , object => $_)
	for $self->qvd_object_model->mandatory_arguments;
    
    $self->qvd_object_model->available_argument($_) || 
	$self->qvd_object_model->mandatory_argument($_) ||
	QVD::Admin4::Exception->throw(code => 6230, object => $_)
	for $self->json_wrapper->arguments_list;

    $admin->re_is_allowed_to($self->qvd_object_model->get_acls_for_argument_in_creation($_)) || 
	QVD::Admin4::Exception->throw(code => 4230, object => $_)
	for $self->json_wrapper->arguments_list;
}

# Nested queries are queries inside either update or create
# actions. The main action ask for the creation or update of a main
# object, and these nested queries ask for assignations over that object
# (i.e. custom properties can be assigned to vms, or acls to roles, tags to dis...) 

sub check_nested_queries_validity_in_json
{
    my $self = shift;

    my $admin = $self->qvd_object_model->current_qvd_administrator;
    my $type_of_action = $self->qvd_object_model->type_of_action;
    my ($method,$code);

    if ($type_of_action =~ /^create(_or_update)?$/)
    {
	$method = 'get_acls_for_nested_query_in_creation';
    }
    elsif ($type_of_action eq 'update')
    {
# An operation is considered massive if it is applied over more than one 
# object. For this kind of action, the 'id' is a mandatory filter
# and it is the only filter available. So it can be known the amount of objects
# will be involved by using that filter.

	my $id = $self->json_wrapper->get_filter_value('id');
	($method,$code) = ref($id) && scalar @$id > 1 ? 
	    ('get_acls_for_nested_query_in_massive_update',4240) : 
	    ('get_acls_for_nested_query_in_update',4230) ;
    }

	for my $nested_query ($self->json_wrapper->nested_queries_list) {
		$self->qvd_object_model->available_nested_query($nested_query) ||
			QVD::Admin4::Exception->throw(code => 6230, object => $nested_query);

		$admin->re_is_allowed_to($self->qvd_object_model->$method($nested_query)) ||
			QVD::Admin4::Exception->throw(code => $code, object => $nested_query);
	}
}

sub check_order_by_validity_in_json
{
    my $self = shift;
}

sub check_fields_validity_in_json # Fields to retrieve
{
    my $self = shift;
    my $admin = $self->qvd_object_model->current_qvd_administrator;

    $self->qvd_object_model->available_field($_) || $self->qvd_object_model->has_property($_) ||
	QVD::Admin4::Exception->throw(code => 6250, object => $_)
	for $self->json_wrapper->fields_list;

    $admin->re_is_allowed_to(
	$self->qvd_object_model->get_acls_for_field(
	    $self->qvd_object_model->has_property($_) ? 'properties' : $_)) || # custom properties 
	QVD::Admin4::Exception->throw(code => 4250, object => $_)
	for $self->json_wrapper->fields_list;
}

#####################
## AD HOC SETTINGS ##
####################

sub set_default_admin_id_in_acls_search
{
    my $self = shift;
    my $admin_id = $self->qvd_object_model->map_filter_to_dbix_format('admin_id');
    $self->filters->add_filter('me.admin_id',{ '=' => $ADMIN->id})
	unless $self->filters->get_filter_value($admin_id);
}

sub hide_recovery_mode_administrator
{
    my $self = shift;
    my $id = $self->qvd_object_model->map_filter_to_dbix_format('id');
    $self->filters->add_filter($id,{ '!=' => 0 }); # Recovery admin is by convention id 0
}

sub forze_filtering_by_own_admin
{
    my $self = shift;

    for my $id ($self->json_wrapper->get_filter_value('id'))
    {
	QVD::Admin4::Exception->throw(code => 6320, object => 'id')
	    unless $id  eq $ADMIN->id;
    } 

    my $id = $self->qvd_object_model->map_filter_to_dbix_format('id');
    $self->filters->add_filter($id,$ADMIN->id);
}


sub forze_own_admin_id_in_admin_views
{
    my $self = shift;

    if ($self->qvd_object_model->type_of_action eq 'create_or_update')
    {
	my $admin_id = $self->qvd_object_model->map_argument_to_dbix_format('admin_id');
	$self->instantiate_argument($admin_id,$ADMIN->id);
    }
    else # delete actions
    {
	my $admin_id = $self->qvd_object_model->map_filter_to_dbix_format('admin_id');
	$self->filters->add_filter($admin_id,$ADMIN->id);
    }
}

sub forze_filtering_by_tenant
{
    my $self = shift;

    return unless $self->qvd_object_model->available_filter('tenant_id');

    my $tenant_id = $self->qvd_object_model->map_filter_to_dbix_format('tenant_id');

    if ($self->json_wrapper->has_filter($tenant_id))
    {
	QVD::Admin4::Exception->throw(code => 4220, object => 'tenant_id') 
	    unless $ADMIN->is_superadmin; # Only superadmins can filter by tenant
    }
    elsif ($self->qvd_object_model->qvd_object eq 'Log' && $ADMIN->is_superadmin)
    {
	# In log, entries without tenant specification must be retrieved as well
	my $IS_NULL = "$tenant_id IS NULL";
	$self->filters->add_filter('-or', [$tenant_id,$ADMIN->tenants_scoop,\$IS_NULL]);
    }
    else
    {
	$self->filters->add_filter($tenant_id,$ADMIN->tenants_scoop);
    }
}

sub forze_filtering_tenants_by_tenant
{
    my $self = shift;

    my @ids = @{$ADMIN->tenants_scoop}; # All tenants available for the admin

# By convention, tenant 0 is the special tenant of superadmins 
# Tenant 0 is special. It cannot be deleted and when listing
# tenants it is not it doesn't appear

    @ids = grep { $_ ne 0 } @ids if 
	$self->qvd_object_model->type_of_action =~ /^delete|list$/;
    my $id = $self->qvd_object_model->map_filter_to_dbix_format('id');
    $self->filters->add_filter($id,\@ids);
}

# This method adds filters in order to avoid selecting
# objects the admin doesn't have acls for. These acls
# are assigned to filter values

# i.e. an admin allowed to use the 'log' table with the 
# filter 'qvd_object' may not be allowed to select
# 'log' entries with 'qvd_object' = 'vm'. In that case, 
# a filter is added to avoid retrieving log entries with 
# qvd_object=vm

sub forze_filtering_by_acls_for_filter_values
{
    my $self = shift;

    for my $filter ($self->qvd_object_model->get_filters_with_acls_for_values) # Filters whose values may have 
    {                                                                          # acls associated
	my @forbidden_values;

	for my $value ($self->qvd_object_model->get_filter_values_with_acls($filter)) # Values of a filter that may
	{                                                                             # have acls associated
	    my @acls = $self->qvd_object_model->get_acls_for_filter_value($filter,$value);
	    push @forbidden_values, $value unless $ADMIN->re_is_allowed_to(@acls);
	}
    
	my @requested_values = ($self->json_wrapper->get_filter_value($filter)) // ();

	for my $requested_value (@requested_values)
	{
	    for my $forbidden_value (@forbidden_values)
	    {
		QVD::Admin4::Exception->throw(code => 4221, object => $requested_value) 
		    if $requested_value eq $forbidden_value;
	    }
	}

	my $filter_dbix = $self->qvd_object_model->map_filter_to_dbix_format($filter); 
	$self->filters->add_filter('-not',{ $filter_dbix => \@forbidden_values });
    }
}


sub forze_tenant_assignment_in_creation
{
    my $self = shift;

    if ($ADMIN->is_superadmin)
    { # Mandatory argument for superadmins
	QVD::Admin4::Exception->throw(code => 6240 , object => 'tenant_id')
	    unless $self->json_wrapper->has_argument('tenant_id');
    }
    else
    { # For non-superadmins a tenant_id assignation is forced according to the tenant_id of the admin
		my $tenant_id_key = $self->qvd_object_model->map_argument_to_dbix_format('tenant_id');
		my $tenant_id_value = $ADMIN->tenant_id;

		# Set tenant_id to -1 if global configuration is changed in monotenant
		my $col = QVD::Admin4::ConfigsOverwriteList->new(admin_id => $ADMIN->id);
		if( (!cfg('wat.multitenant')) and ($self->qvd_object_model->qvd_object eq 'Config') and
			($col->is_global_config($self->get_json_adequate_value('key'))) ){
			$tenant_id_value = -1;
		}

		$self->instantiate_argument($tenant_id_key,$tenant_id_value);
    }
}


############################################################
############################################################
### MAPPING OF FILTERS WITH SUPPORT TO LOGICAL OPERATORS ###
############################################################
############################################################


# This function creates an object QVD::Admin4::REST::Filter
# that implements a potentially complex set of filters.
# These are the filters of the request

sub set_filters_in_request
{
    my $self = shift;
    my $filters = $self->json_wrapper->filters;

    $self->{filters} = QVD::Admin4::REST::Filter->new(
	# The hash of filters in the input query
	hash => $self->json_wrapper->filters_obj->hash, 
        # A list of mandatory filters that must be unambiguous for this kind 
        # of query (i.e. 'id' for delete/update queries) 
	unambiguous_filters => [$self->qvd_object_model->unambiguous_filters]); 
                                                                                
    my $found_properties = 0; # number of custom properties found

    # For every filter. This is the list of filters that appear in the
    # potentially complex filters structure of the input query. In that
    # complex structure, one filter may appear many times, in different places
    # (i.e. OR [ filter1 = A, filter1 = B ]). In this list we have every filter
    # just once

    for my $k ($self->filters->list_filters) 
    {

	my $is_property = $self->qvd_object_model->has_property($k);
	my $key_dbix_format;

	if ($is_property) 
	{ 
            # To filter by a property, the corresponding properties table must be joined.
            # This code uses the aliases system for multiple joins of the same table in DBIC
	    $self->add_to_join('properties'); 
	    $found_properties++;
	    $key_dbix_format = $found_properties > 1 ?
		"properties_$found_properties" : 'properties'; 
	}
	else
	{
	    $key_dbix_format = $self->qvd_object_model->map_filter_to_dbix_format($k); 
	}

        # For every value of the current filter in the input filters structure.
        # For example, if the input filters structure is OR [ filter1 = A, filter1 = B ]
        # and $k = filter1, this list is (A, B) 

	for my $ref_v ($self->filters->get_filter_ref_value($k))
	{
	    # $ref_v is a hash reference that points to the value of the filter $k
            # in a specific place in the complex imput structure of filters
            # We need to use a reference in order to operate over the filter value
            # no matter where that value is in the complex input structure
	    my $v = $self->filters->get_value($ref_v); # $v is the value as a string

	    unless ($is_property)
	    {
		if (ref($v) && ref($v) eq 'ARRAY')
		{
		    $_ = $self->qvd_object_model->normalize_value($k,$_) for @$v;
		}
		else
		{
		    $v = $self->qvd_object_model->normalize_value($k,$v) 		    
		}
	    }

	    my $op = $self->filters->get_operator($ref_v); # $k and $v must be related by a specific operator (=, <, >...)
	    $op = $self->qvd_object_model->normalize_operator($op);

            # This is according DBIC format
	    my $value_normalized = $is_property ?  
		[$key_dbix_format.".key" => { $op => $k },
		 $key_dbix_format.".value" => { $op => $v } ] : { $op => $v };

	    # This code sets the normalized value in the hash ref, in the original
            # place of the value in the complex filters structure
	    if ($is_property)
	    {
		$self->filters->set_filter($ref_v,'-and',$value_normalized);
	    }
	    else
	    {
		$self->filters->set_filter($ref_v,$key_dbix_format,$value_normalized);
	    }
	}
    }
    # If new filters have been added (properties), the flattened
    # list of filters must be recalculated
    $self->filters->flatten_filters if $found_properties;
}

sub set_parameters_in_request
{
    my $self = shift;
    for my $key ($self->json_wrapper->parameters_list)
    {
	my $value = $self->json_wrapper->get_parameter_value($key);
	$self->set_parameter($key,$value);
    }
    $self->set_parameter('administrator',$ADMIN);
}


sub set_arguments_in_request
{
    my $self = shift;

    for my $key ($self->json_wrapper->arguments_list)
    {
	my $key_dbix_format = 
	    $self->qvd_object_model->map_argument_to_dbix_format($key);

	my $value = $self->json_wrapper->get_argument_value($key);
	my $value_normalized =  $self->qvd_object_model->normalize_value($key,$value);

	$self->instantiate_argument($key_dbix_format,$value_normalized); 
    }

    $self->set_arguments_in_request_with_defaults if 
	$self->qvd_object_model->type_of_action =~ /^create(_or_update)?$/;
}

sub set_arguments_in_request_with_defaults
{
    my $self = shift;

    for my $key ($self->qvd_object_model->mandatory_arguments)
    {
	next if $self->json_wrapper->has_argument($key);

	my $key_dbix_format = 
	    $self->qvd_object_model->map_argument_to_dbix_format($key);

	my $value = $self->qvd_object_model->get_default_argument_value($key,$self->json_wrapper);

	$self->instantiate_argument($key_dbix_format,$value);
    }
}

# Arguments in the main table and arguments in other related
# tables are stored in different places

sub instantiate_argument
{
    my ($self,$dbix_key,$value) = @_;
    $value = undef if defined $value && $value eq '';

    my ($table,$column) = $dbix_key =~ /^(.+)\.(.+)$/;

    $table eq 'me'                                            ? # The prefix me is for the main table in the request
    $self->set_argument($column,$value)                       : 
    $self->set_related_object_argument($table,$column,$value);
}

sub set_order_by_in_request
{
    my $self = shift;

    my $order_direction = $self->json_wrapper->order_direction // '-asc';
    my $order_criteria = $self->json_wrapper->order_criteria;
    $order_criteria = [$self->qvd_object_model->default_order_criteria] 
	unless  @$order_criteria;

    $self->modifiers->{order_by}->{'-desc'} =
	delete $self->modifiers->{order_by}->{'-asc'}
    if $order_direction eq '-desc';

    for my $order_criterium (@$order_criteria)
    {
	$self->add_to_order_by(
	    $self->qvd_object_model->map_order_criteria_to_dbix_format($order_criterium));
    }
}

sub set_nested_queries_in_request
{
    my $self = shift;

    for my $nq ($self->json_wrapper->nested_queries_list)
    {
	my $admin4method = 
	    $self->qvd_object_model->map_nested_query_to_admin4($nq);
	my $value = $self->json_wrapper->get_nested_query_value($nq);

	$self->set_nested_query($admin4method,$value);
    }
}

sub set_tables_to_join_in_request
{
    my $self = shift;
    $self->add_to_join($_) 
	for @{$self->qvd_object_model->dbix_join_value};

    $self->add_to_prefetch($_) 
	for @{$self->qvd_object_model->dbix_prefetch_value};
}

sub set_related_views_in_request
{
    my $self = shift;

    $self->add_to_related_views($_) 
	for $self->qvd_object_model->related_views_in_db;
}

sub set_pagination_in_request
{
    my $self = shift;
    $self->modifiers->{page} = $self->json_wrapper->offset // 1; 
    $self->modifiers->{rows}  = $self->json_wrapper->block // 10000; 
}

############################################
## METHODS TO SET/GET INFO IN THE REQUEST ##
############################################

sub related_view
{
    my $self = shift;
    $self->qvd_object_model->related_view;
}

sub fields
{
    my $self = shift;
    $self->json_wrapper->fields;
}

sub get_parameter_value
{
    my ($self,$p) = @_;
    $self->parameters->{$p};
}

sub set_parameter
{
    my ($self,$k,$v) = @_;
    $self->parameters->{$k} = $v;
}

# Returns the value of the key included in JSON from the filter list
# or the argument list depending of the type of the action
sub get_json_adequate_value{
	my ($self, $key) = @_;
	return $self->qvd_object_model->type_of_action eq 'delete' ?
		$self->json_wrapper->get_filter_value($key) :
		$self->json_wrapper->get_argument_value($key);
}

# Returns the value of the key passed as argument from the filter list
# or the argument list depending of the type of the action
sub get_adequate_value{
	my ($self, $key) = @_;
	return $self->qvd_object_model->type_of_action eq 'delete' ?
		$self->json_wrapper->get_filter_value($key) :
		$self->arguments->{$key} ;
}

sub action 
{
    my $self = shift;
    $self->json_wrapper->action;
}

sub get_type_of_action {
	my $self = shift;
	return $self->qvd_object_model->type_of_action;
}

sub table 
{
    my $self = shift;
    $self->qvd_object_model->qvd_object;
}

# Tables that must be created when creating an object
# (i.e. vm_runtimes for vms)

sub dependencies
{
    my $self = shift;
    $self->qvd_object_model->dbix_has_one_relationships;
}

sub set_nested_query
{
    my ($self,$nq,$val) = @_;
    $val = undef if defined $val && $val eq '';
    $nq = undef if defined $nq && $nq eq '';
    $self->nested_queries->{$nq} = $val;
}

sub add_to_related_views
{
    my ($self,$key) = @_;
    push @{$self->related_views}, $key;
}

sub set_argument
{
    my ($self,$key,$val) = @_;
    $val = undef if defined $val && $val eq '';
    $key = undef if defined $key && $key eq '';

    $self->arguments->{$key} = $val;
}

# Arguments that are stored in related tables in DB

sub set_related_object_argument
{
    my ($self,$rel_object,$key,$val) = @_;
    $self->related_objects_arguments->{$rel_object}->{$key} = $val;
}

sub add_to_join
{
    my ($self,$key) = @_;
    push @{$self->modifiers->{join}}, $key;
}

sub add_to_prefetch
{
    my ($self,$key) = @_;
    push @{$self->modifiers->{prefetch}}, $key;
}

sub add_to_order_by
{
    my ($self,$key) = @_;
    my $order_criteria = $self->modifiers->{order_by}->{'-desc'} //
	$self->modifiers->{order_by}->{'-asc'};
    push @$order_criteria, $key;
}

1;
