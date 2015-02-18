package QVD::Admin4::REST::Request;
use strict;
use warnings;
use Moo;
use QVD::Admin4::Exception;
use QVD::Admin4::DBConfigProvider;
use QVD::Admin4::REST::Filter;

has 'json_wrapper', is => 'ro', isa => sub { die "Invalid type for attribute json_wrapper" 
						 unless ref(+shift) eq 'QVD::Admin4::REST::JSON'; }, required => 1;
has 'qvd_object_model', is => 'ro', isa => sub { die "Invalid type for attribute qvd_object_model" 
						     unless ref(+shift) eq 'QVD::Admin4::REST::Model'; } , required => 1;
has 'modifiers', is => 'ro', isa => sub { die "Invalid type for attribute modifiers" 
					      unless ref(+shift) eq 'HASH'; }, 
                             default => sub { { group_by => [], # TO DO: default dbix grouping fails for ordering in related tables. This avoids 
						                # grouping, but turns off distinct...
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
my $DBConfigProvider;

sub BUILD 
{
    my $self = shift;

    $ADMIN = $self->qvd_object_model->current_qvd_administrator;
    $DBConfigProvider = QVD::Admin4::DBConfigProvider->new();

# CHECKS OR DIE

    $self->check_unique_role_in_acls_search
	if $self->qvd_object_model->qvd_object eq 
	'Operative_Acls_In_Role';

    $self->check_unique_admin_in_acls_search
	if $self->qvd_object_model->qvd_object eq 
	'Operative_Acls_In_Administrator';

    $self->check_fields_validity_in_json;

    $self->check_acls_for_deleting if
	$self->qvd_object_model->type_of_action eq 'delete';

    $self->check_filters_validity_in_json;

    $self->check_update_arguments_validity_in_json if
	$self->qvd_object_model->type_of_action eq 'update';

    $self->check_create_arguments_validity_in_json if
	$self->qvd_object_model->type_of_action eq 'create';

    $self->check_nested_queries_validity_in_json if
	$self->qvd_object_model->type_of_action =~ /^(cre|upd)ate$/;

    $self->check_order_by_validity_in_json;

# GENERAL SETTINGS ACCORDING MODEL

    $self->set_filters_in_request;

    $self->set_parameters_in_request;
    $self->set_pagination_in_request;
    $self->set_arguments_in_request;
    $self->set_nested_queries_in_request;
    $self->set_related_views_in_request;
    $self->set_order_by_in_request;
    $self->set_tables_to_join_in_request;

# AD HOC SETTING OF OBLIGATORY ELEMENTS 

    $self->hide_recovery_mode_administrator
	if $self->qvd_object_model->qvd_object eq 'Administrator';

    $self->set_default_admin_id_in_acls_search
	if $self->qvd_object_model->qvd_object eq 
	'Operative_Acls_In_Administrator';

    $self->forze_filtering_by_tenant;

    $self->forze_filtering_by_own_admin
	if $self->json_wrapper->action eq 'myadmin_update';

    $self->forze_filtering_tenants_by_tenant
        if $self->qvd_object_model->qvd_object eq 'Tenant';

    $self->forze_tenant_assignment_in_creation
	if $self->qvd_object_model->type_of_action eq 'create' &&
	$self->qvd_object_model->directly_tenant_related;

# After check and changes, filters are retrieved as a simple hash

    $self->{filters} = $self->filters->hash;
}

##############
## CHECKING ##
##############
## DIE UNLESS

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
	$self->qvd_object_model->has_property($_) ||
	QVD::Admin4::Exception->throw(code => 6210, object => $_)
	for $self->json_wrapper->filters_list;

    my $admin = $self->qvd_object_model->current_qvd_administrator;

    $admin->re_is_allowed_to(
	$self->qvd_object_model->get_acls_for_filter(
	    $self->qvd_object_model->has_property($_) ? 'properties' : $_)) || 
	QVD::Admin4::Exception->throw(code => 4220, object => $_)
	for $self->json_wrapper->filters_list;

    $self->json_wrapper->has_filter($_) ||
	QVD::Admin4::Exception->throw(code => 6220, object => $_)
	for $self->qvd_object_model->mandatory_filters;
}

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
	QVD::Admin4::Exception->throw(code => 6240 , object => $_)
	for $self->qvd_object_model->mandatory_arguments;
    
    $admin->re_is_allowed_to($self->qvd_object_model->get_acls_for_argument_in_creation($_)) || 
	QVD::Admin4::Exception->throw(code => 4230, object => $_)
	for $self->json_wrapper->arguments_list;
}

sub check_nested_queries_validity_in_json
{
    my $self = shift;

    my $admin = $self->qvd_object_model->current_qvd_administrator;
    my $type_of_action = $self->qvd_object_model->type_of_action;
    my ($method,$code);

    if ($type_of_action eq 'create')
    {
	$method = 'get_acls_for_nested_query_in_creation';
    }
    elsif ($type_of_action eq 'update')
    {
	my $id = $self->json_wrapper->get_filter_value('id');
	($method,$code) = ref($id) && scalar @$id > 1 ? 
	    ('get_acls_for_nested_query_in_massive_update',4240) : 
	    ('get_acls_for_nested_query_in_update',4230) ;
    }

    $self->qvd_object_model->available_nested_query($_) || 
	QVD::Admin4::Exception->throw(code => 34, object => $_)
	for $self->json_wrapper->nested_queries_list;

    $admin->re_is_allowed_to($self->qvd_object_model->$method($_)) || 
	QVD::Admin4::Exception->throw(code => $code, object => $_) 
	for $self->json_wrapper->nested_queries_list
}

sub check_order_by_validity_in_json
{
    my $self = shift;
}

sub check_fields_validity_in_json
{
    my $self = shift;
    my $admin = $self->qvd_object_model->current_qvd_administrator;

    $self->qvd_object_model->available_field($_) || $self->qvd_object_model->has_property($_) ||
	QVD::Admin4::Exception->throw(code => 6250, object => $_)
	for $self->json_wrapper->fields_list;

    $admin->re_is_allowed_to(
	$self->qvd_object_model->get_acls_for_field(
	    $self->qvd_object_model->has_property($_) ? 'properties' : $_)) || 
	QVD::Admin4::Exception->throw(code => 4250, object => $_)
	for $self->json_wrapper->fields_list;
}

#####################
## AD HOC SETTINGS ##
####################
## ADD TO REQUEST ##
####################
## FOR FILTERS

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
    $self->filters->add_filter($id,{ '!=' => 0 });
}

sub forze_filtering_by_own_admin
{
    my $self = shift;

    my $has_id;
    my $id = $self->qvd_object_model->map_filter_to_dbix_format('id');
    for my $id ($self->json_wrapper->get_filter_value($id))
    {
	QVD::Admin4::Exception->throw(code => 6320, object => 'id')
	    unless $id  eq $ADMIN->id;
	$has_id = 1;
    } 

    $self->filters->add_filter($id,$ADMIN->id);
}

sub forze_filtering_by_tenant
{
    my $self = shift;
    return unless $self->qvd_object_model->available_filter('tenant_id');

    my $tenant_id = $self->qvd_object_model->map_filter_to_dbix_format('tenant_id');
    my $tenant_name = $self->qvd_object_model->map_filter_to_dbix_format('tenant_name');

    if ($self->json_wrapper->has_filter($tenant_id) ||
	$self->json_wrapper->has_filter($tenant_name))
    {
	QVD::Admin4::Exception->throw(code => 4220, object => 'tenant_id') 
	    unless $ADMIN->is_superadmin;
    }
    else
    {
	$self->filters->add_filter($tenant_id,$ADMIN->tenants_scoop);
    }
}

sub forze_filtering_tenants_by_tenant
{
    my $self = shift;

    my @ids = @{$ADMIN->tenants_scoop};

    @ids = grep { $_ ne 0 } @ids if 
	$self->qvd_object_model->type_of_action =~ /^delete|list$/;
    my $id = $self->qvd_object_model->map_filter_to_dbix_format('id');
    $self->filters->add_filter($id,\@ids);
}

sub forze_tenant_assignment_in_creation
{
    my $self = shift;

    if ($ADMIN->is_superadmin)
    {
	QVD::Admin4::Exception->throw(code => 6240 , object => 'tenant_id')
	    unless $self->json_wrapper->has_argument('tenant_id');
    }
    else
    {
	my $tenant_id = $self->qvd_object_model->map_argument_to_dbix_format('tenant_id');
	$self->set_argument($tenant_id,$ADMIN->tenant_id);
    }
}


############################################################
############################################################
### MAPPING OF FILTERS WITH SUPPORT TO LOGICAL OPERATORS ###
############################################################
############################################################

sub set_filters_in_request
{
    my $self = shift;
    my $filters = $self->json_wrapper->filters;

    $self->{filters} = QVD::Admin4::REST::Filter->new(
	hash => $self->json_wrapper->filters_obj->hash,
	unambiguous_filters => [$self->qvd_object_model->unambiguous_filters]);

    my $found_properties = 0;

    for my $k ($self->filters->list_filters)
    {
	my $is_property = $self->qvd_object_model->has_property($k);
	my $key_dbix_format;

	if ($is_property) 
	{ 
	    $self->add_to_join('properties');
	    $found_properties++;
	    $key_dbix_format = $found_properties > 1 ?
		"properties_$found_properties" : 'properties'; 
	}
	else
	{
	    $key_dbix_format = $self->qvd_object_model->map_filter_to_dbix_format($k); 
	}

	for my $ref_v ($self->filters->get_filter_ref_value($k))
	{
	    my $v = $self->filters->get_value($ref_v);

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
	    my $op = $self->filters->get_operator($ref_v);

	    my $value_normalized = $is_property ?  
		[$key_dbix_format.".key" => { $op => $k },
		 $key_dbix_format.".value" => { $op => $v } ] : { $op => $v };

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
	$self->qvd_object_model->type_of_action eq 'create';
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

sub instantiate_argument
{
    my ($self,$dbix_key,$value) = @_;
    $value = undef if defined $value && $value eq '';
    # WARNING: Is this the right solution to all fields??

    my ($table,$column) = $dbix_key =~ /^(.+)\.(.+)$/;

    $table eq 'me'                                            ?
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

###############
## UTILITIES ##
###############

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

sub action 
{
    my $self = shift;
    $self->json_wrapper->action;
}

sub table 
{
    my $self = shift;
    $self->qvd_object_model->qvd_object;
}

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
