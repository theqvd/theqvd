package QVD::API::REST::Request;
use strict;
use warnings;
use Moo;
use QVD::Config;
use QVD::API::Exception;
use QVD::API::REST::Filter;
use QVD::DB::Simple qw(db);

use Clone qw(clone);

# This class implements a request to the database. In fact, 
# objects of this class are used by the methods in QVD::API 
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
# are used by the methods in QVD::API in order to build the
# requests to DB

# All checks and translations in this class are operated over the 
# input query ('json_wrapper') according the model for that kind 
# of action ('qvd_object_model').

has 'json_wrapper', is => 'ro', isa => sub { die "Invalid type for attribute json_wrapper" 
						 unless ref(+shift) eq 'QVD::API::REST::JSON'; }, required => 1;
has 'qvd_object_model', is => 'ro', isa => sub { die "Invalid type for attribute qvd_object_model" 
						     unless ref(+shift) eq 'QVD::API::REST::Model'; } , required => 1;

# These are the main accessors used in QVD::API

has 'administrator', is => 'ro', isa => sub {
    die "Invalid type for attribute administrator" unless ref(+shift) eq 'QVD::DB::Result::Administrator';
};
has 'table', is => 'rw', isa => sub {
    die "Invalid type for attribute db_table" unless ref(+shift) eq 'SCALAR';
};
has 'modifiers', is => 'ro', isa => sub { die "Invalid type for attribute modifiers" 
					      unless ref(+shift) eq 'HASH'; }, 
                             default => sub { {  group_by => [], # TO DO: default dbix grouping fails for ordering in related tables. This avoids 
						                # grouping, but turns off DISTINCT...
						join => [], order_by => { }  }};
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

# Map to get the DBIx table name from QVD OBJECT
my $QVD_OBJECT_TO_DBIX_TABLE = {
    'My_Admin' => 'Administrator',
    'My_Tenant' => 'Tenant',
};

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
    my $qvd_model = $self->qvd_object_model;
    my $qvd_object = $qvd_model->qvd_object;
    my $type_of_action = $qvd_model->type_of_action;

    # Store the administrator that generates the request
    $self->{administrator} = $qvd_model->current_qvd_administrator;

    # Set the DBIx table the request will be executed against by default
    $self->{table} = $self->qvd_obj_to_table($qvd_object);

# CHECKS OR DIE

# It checks if the requested fields to retrieve 
# are available

    $self->check_fields_validity_in_json;

# It checks if the filters in the input query
# are available in the system and if the current
# admin is allowed to use them

    $self->check_filters_validity_in_json;

# It checks if the arguments in an update query
# are available in the system and if the current
# admin is allowed to use them

    $self->check_update_arguments_validity_in_json 
        if $type_of_action eq 'update';

# It checks if the arguments in a creation query
# are available in the system and if the current
# admin is allowed to use them

    $self->check_create_arguments_validity_in_json 
        if $type_of_action =~ /^create(_or_update)?$/;

# It checks if the nested queries in a creation or update query 
# (tags, custom properties, role and acls assignations...) are 
# available in the system and if the current admin is allowed to use them

    $self->check_nested_queries_validity_in_json
        if $type_of_action =~ /^(create|update)$/;

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

    # Update queries have special join needs to avoid
    # wrong affected rows in response message
    $self->set_tables_to_join_in_delete_update_request
        if $type_of_action =~ /^(delete|update)$/;

    # REQUEST CHECKS

    # Operative acls must be asked just for one role
    # Otherwise the request doesn't make sense 

    $self->check_unique_role_in_acls_search
        if $qvd_object eq 'Operative_Acls_In_Role';

    # Operative acls must be asked just for one admin
    # Otherwise the request doesn't make sense 

    if ($qvd_object eq 'Operative_Acls_In_Administrator') {
        $self->set_default_admin_id_in_acls_search;
        $self->check_unique_admin_in_acls_search;
    }

# AD HOC SETTING OF OBLIGATORY ELEMENTS 

# The recovery administrator is stored in the database
# but it cannot be neither seen, updated nor deleted.
# This method adds to the request an extra filter
# that avoids the recovery admin to be selected

    $self->hide_recovery_mode_administrator 
        if $qvd_object eq 'Administrator';

# Requests must include a proper filter by tenant, cause
# non-superadmin admins can only operate over its own
# tenant. The corresponding filters to filtering by tenant
# are added in here

    $self->forze_filtering_by_tenant
        if $qvd_model->available_filter('tenant_id');

# Actions 'admin_view_set' and 'admin_view_reset' are supposed to operate
# over the current admin. The correspondig filters are added in here

    if ($qvd_object eq 'Views_Setup_Attributes_Administrator' ||
        $qvd_object eq 'Views_Setup_Properties_Administrator') {
        $self->forze_own_admin_id_in_admin_views;
    }

# Tenants must be filtered by tenant in a different way than other objects 

    $self->forze_filtering_tenants_by_tenant
        if $qvd_object eq 'Tenant';

# When creating a new object it must be assigned to the right tenant

    $self->forze_tenant_assignment_in_creation 
        if $type_of_action =~ /^create(_or_update)?$/ &&
            $self->qvd_object_model->directly_tenant_related;

}

###############
## CHECKINGS ##
###############

sub check_unique_admin_in_acls_search
{
    my $self = shift;
    my @admin_id = @{$self->filters->filter_value('admin_id')};
    QVD::API::Exception->throw(code => 6322, object => 'admin_id')
        if scalar @admin_id != 1;
}

sub check_unique_role_in_acls_search
{
    my $self = shift;
    my @role_id = @{$self->filters->filter_value('role_id')};
    QVD::API::Exception->throw(code => 6322, object => 'role_id')
        if scalar @role_id != 1;
}

sub check_filters_validity_in_json
{
    my $self = shift;
    
    my @filters = @{$self->json_wrapper->filter_name_list};
    
    for my $filter (@filters){
        QVD::API::Exception->throw(code => 6210, object => $filter) unless 
            ($self->qvd_object_model->available_filter($filter) ||
            $self->qvd_object_model->has_property($filter));
    }

    my $admin = $self->qvd_object_model->current_qvd_administrator;

    for my $filter (@filters) {
        QVD::API::Exception->throw(code => 4220, object => $filter) 
            unless $admin->re_is_allowed_to( 
                $self->qvd_object_model->get_acls_for_filter(
                    $self->qvd_object_model->has_property($filter) ? 'properties' : $filter));
    }
    
    for my $mandatory_filter ($self->qvd_object_model->mandatory_filters){
        QVD::API::Exception->throw(code => 6220, object => $mandatory_filter) 
            unless grep {$_ eq $mandatory_filter} @filters;
    }
}

sub check_update_arguments_validity_in_json
{
    my $self = shift;

    for my $arg ($self->json_wrapper->arguments_list)
    {
        QVD::API::Exception->throw(code => 6230, object => $arg) unless
            ($self->qvd_object_model->available_argument($arg) || $self->qvd_object_model->has_property( $arg ));
    }

}

sub check_create_arguments_validity_in_json
{
    my $self = shift;
    my $admin = $self->qvd_object_model->current_qvd_administrator;

    for ($self->qvd_object_model->mandatory_arguments) {
         unless ($self->json_wrapper->has_argument($_) ||
            defined $self->qvd_object_model->get_default_argument_value($_,$self->json_wrapper) ||
            ($_ eq 'tenant_id' && (not $self->administrator->is_superadmin))) {
             QVD::API::Exception->throw(code => 6240 , object => $_);
         }
    }
    
    $self->qvd_object_model->available_argument($_) || 
	$self->qvd_object_model->mandatory_argument($_) ||
	QVD::API::Exception->throw(code => 6230, object => $_)
	for $self->json_wrapper->arguments_list;

    $admin->re_is_allowed_to($self->qvd_object_model->get_acls_for_argument_in_creation($_)) || 
	QVD::API::Exception->throw(code => 4230, object => $_)
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

	for my $nested_query ($self->json_wrapper->nested_queries_list) {
		$self->qvd_object_model->available_nested_query($nested_query) ||
			QVD::API::Exception->throw(code => 6230, object => $nested_query);

		$admin->re_is_allowed_to($self->qvd_object_model->get_acls_for_nested_query_in_update($nested_query)) ||
			QVD::API::Exception->throw(code => 4230, object => $nested_query);
    }
}

sub check_order_by_validity_in_json
{
    my $self = shift;
    
    my $order_direction = $self->json_wrapper->order_direction;
    if(defined($order_direction)){
        unless ( grep { $_ eq $order_direction } qw(-asc -desc) ){
            QVD::API::Exception->throw(code => 6600, object => $order_direction);
        }
    }

    my $order_criteria = $self->json_wrapper->order_criteria // [];

    for (@{$order_criteria}) {
        unless ($self->qvd_object_model->available_order_criterium($_)) {
            QVD::API::Exception->throw(code => 6610, object => $_);
        }
    }

    for (@{$order_criteria}) {
        my @acls = $self->qvd_object_model->get_acls_for_order_criterium($_);
        unless ( $self->administrator->re_is_allowed_to(@acls) ) {
            QVD::API::Exception->throw(code => 4260, object => $_);
        }
    }
}

sub check_fields_validity_in_json # Fields to retrieve
{
    my $self = shift;
    my $admin = $self->qvd_object_model->current_qvd_administrator;

    for my $field ($self->json_wrapper->fields_list) {
        QVD::API::Exception->throw(code => 6250, object => $field)
            unless ($self->qvd_object_model->available_field($field) ||
                $self->qvd_object_model->has_property($field));

        QVD::API::Exception->throw(code => 4250, object => $field)
            unless $admin->re_is_allowed_to($self->qvd_object_model->get_acls_for_field($field));
    }
}

#####################
## AD HOC SETTINGS ##
####################

sub set_default_admin_id_in_acls_search
{
    my $self = shift;
    $self->filters->add_filter('admin_id', { '=' => $self->administrator->id}) 
        unless $self->filters->filter_value('admin_id');
}

sub hide_recovery_mode_administrator
{
    my $self = shift;
    $self->filters->add_filter('id', { '!=' => 0 }); # Recovery admin is by convention id 0
}

sub forze_own_admin_id_in_admin_views
{
    my $self = shift;

    if ($self->qvd_object_model->type_of_action eq 'create_or_update')
    {
	my $admin_id = $self->qvd_object_model->map_argument_to_dbix_format('admin_id');
        $self->instantiate_argument($admin_id,$self->administrator->id);
    }
    else # delete actions
    {
        $self->filters->add_filter('admin_id', $self->administrator->id);
    }
}

sub forze_filtering_by_tenant
{
    my $self = shift;

    if ($self->json_wrapper->has_filter('tenant_id'))
    {
        QVD::API::Exception->throw(code => 4220, object => 'tenant_id') 
            unless $self->administrator->is_superadmin; # Only superadmins can filter by tenant
    }
    elsif ($self->qvd_object_model->qvd_object eq 'Log' && $self->administrator->is_superadmin)
    {
        # Logs for superadmin shall not filtered by tenant
    }
    else
    {
        my $read_only = $self->qvd_object_model->type_of_action eq 'list';
        my $scope =  $self->administrator->tenants_scope($read_only ? 1 : 0);
        $self->filters->add_filter('tenant_id', $scope);
    }
}

sub forze_filtering_tenants_by_tenant
{
    my $self = shift;

    my @ids = @{$self->administrator->tenants_scope(0)}; # All tenants available for the admin

    $self->filters->add_filter('id', \@ids);
}

sub forze_tenant_assignment_in_creation
{
    my $self = shift;

    if ($self->administrator->is_superadmin)
    { # Mandatory argument for superadmins
	QVD::API::Exception->throw(code => 6240 , object => 'tenant_id')
	    unless $self->json_wrapper->has_argument('tenant_id');
    }
    else
    { # For non-superadmins a tenant_id assignation is forced according to the tenant_id of the admin
		my $tenant_id_key = $self->qvd_object_model->map_argument_to_dbix_format('tenant_id');
        my $tenant_id_value = $self->administrator->tenant_id;

		# Set tenant_id to -1 if global configuration is changed in monotenant
		if( (!cfg('wat.multitenant')) and ($self->qvd_object_model->qvd_object eq 'Config') ){
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


# This function creates an object QVD::API::REST::Filter
# that implements a potentially complex set of filters.
# These are the filters of the request

sub set_filters_in_request
{
    my $self = shift;
    
    $self->{filters} = $self->json_wrapper->filters_obj;
}

sub get_dbi_format_filters {
    my $self = shift;
    
    my $filters_dbi = clone $self->filters;
    
    my $found_properties = 0; # number of custom properties found
    my $prop_suffix = "";
    for my $filter_path (@{$filters_dbi->filter_list()})
    {
        my $key = QVD::API::REST::Filter::filter_name_from_path($filter_path);
        my $value = $filters_dbi->filter_value($filter_path);

        my $is_property = $self->qvd_object_model->has_property( $key );

        my $key_dbix;
        if ($is_property)
        {
            # To filter by a property, the corresponding properties table must be joined.
            # FIXME: Adding the same join several times drives to an exponential increment of tuples,
            # this approach to filter by properties shall be changed
            # FIXME: Collateral changes to the Request object shall be removed
            my $join = {'properties' => { 'qvd_properties_list' => 'properties_list'} };
            $self->add_to_join( $join );
            # This code uses the aliases system for multiple joins of the same table in DBIC
            $found_properties++;
            $prop_suffix = $found_properties > 1 ? "_$found_properties" : "";
            $key_dbix = "properties" . "$prop_suffix";
        } else {
            $key_dbix = $self->qvd_object_model->map_filter_to_dbix_format( $key );
        }

        unless ($is_property)
        {
            if (ref($value) eq 'ARRAY')
            {
                $value = [ map { $self->qvd_object_model->normalize_value($key,$_) } @$value ];
            }
            else
            {
                $value = $self->qvd_object_model->normalize_value($key,$value)
            }
        }

        my $op = $filters_dbi->filter_operator($filter_path);
        $op = $self->qvd_object_model->normalize_operator($op);

        # This is according DBIC format
        my $value_normalized = { $op => $value };

        if ($is_property)
        {
            $filters_dbi->set_filter_value($filter_path, $value_normalized);
            $filters_dbi->set_filter_key($filter_path, $key_dbix.".value");
            my $value_path = QVD::API::REST::Filter::filter_basedir_from_path($filter_path);
            $filters_dbi->add_filter($value_path, { '=' => $key }, "properties_list$prop_suffix.key");
        }
        else
        {
            $filters_dbi->set_filter_value($filter_path, $value_normalized);
            $filters_dbi->set_filter_key($filter_path, $key_dbix);
        }
    }

    return $filters_dbi->hash;
}

sub set_parameters_in_request
{
    my $self = shift;
    for my $key ($self->json_wrapper->parameters_list)
    {
	my $value = $self->json_wrapper->get_parameter_value($key);
	$self->set_parameter($key,$value);
    }
    $self->set_parameter('administrator',$self->administrator);
}


sub set_arguments_in_request
{
    my $self = shift;

    for my $key ($self->json_wrapper->arguments_list)
    {
        my $tenant_id = $self->administrator->tenant_id;
        if($self->qvd_object_model->has_property($key)){
            my $admin4method = $self->qvd_object_model->map_nested_query_to_admin4("__properties__");
            my $value = $self->json_wrapper->get_argument_value($key, $tenant_id);
            $self->set_nested_query($admin4method, { $key => $value });
            $self->json_wrapper->forze_argument_deletion($key);
        } else {
            my $key_dbix_format =
                $self->qvd_object_model->map_argument_to_dbix_format($key);

            my $value = $self->json_wrapper->get_argument_value($key);
            my $value_normalized = $self->qvd_object_model->normalize_value($key, $value);

            $self->instantiate_argument($key_dbix_format, $value_normalized);
        }
    }

    $self->set_arguments_in_request_with_defaults if
        $self->qvd_object_model->type_of_action =~ /^create(_or_update)?$/;
}

sub set_arguments_in_request_with_defaults
{
    my $self = shift;

    for my $key (keys (%{$self->qvd_object_model->default_argument_values}) )
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
    my $order_criteria = $self->json_wrapper->order_criteria // 
        [$self->qvd_object_model->default_order_criteria];

    $self->modifiers->{order_by}->{$order_direction} = 
        [ map { $self->qvd_object_model->map_order_criteria_to_dbix_format($_) } @$order_criteria ];
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

sub set_tables_to_join_in_delete_update_request
{
    my $self = shift;

    # Joining tables might returns duplicated rows, so they shall be ommited by adding distinct
    $self->modifiers->{distinct} = 1;
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
		[ $self->arguments->{$key} ];
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

sub qvd_obj_to_table {
    my ($self,$qvd_obj) = @_;
    return $QVD_OBJECT_TO_DBIX_TABLE->{$qvd_obj} // $qvd_obj;
}

1;
