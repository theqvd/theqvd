package QVD::Admin4::REST::Request;
use strict;
use warnings;
use Moo;
use QVD::Admin4::Exception;
use QVD::Admin4::DBConfigProvider;

has 'json_wrapper', is => 'ro', isa => sub { die "Invalid type for attribute json_wrapper" 
						 unless ref(+shift) eq 'QVD::Admin4::REST::JSON'; }, required => 1;
has 'qvd_object_model', is => 'ro', isa => sub { die "Invalid type for attribute qvd_object_model" 
						     unless ref(+shift) eq 'QVD::Admin4::REST::Model'; } , required => 1;
has 'modifiers', is => 'ro', isa => sub { die "Invalid type for attribute modifiers" 
					      unless ref(+shift) eq 'HASH'; }, 
                             default => sub { { distinct => 1, join => [], order_by => { '-asc' => []}  }};
has 'filters', is => 'ro', isa => sub { die "Invalid type for attribute failures" 
					    unless ref(+shift) eq 'HASH'; }, default => sub { {}; };
has 'arguments', is => 'ro', isa => sub { die "Invalid type for attribute arguments" 
					      unless ref(+shift) eq 'HASH'; }, default => sub { {}; };
has 'related_objects_arguments', is => 'ro', isa => sub { die "Invalid type for attribute related_objects_arguments" 
							      unless ref(+shift) eq 'HASH'; }, default => sub { {}; };
has 'nested_queries', is => 'ro', isa => sub { die "Invalid type for attribute nested_queries" 
						   unless ref(+shift) eq 'HASH'; }, default => sub { {}; };

my $ADMIN;
my $DBConfigProvider;

sub BUILD 
{
    my $self = shift;

    $ADMIN = $self->qvd_object_model->current_qvd_administrator;
    $DBConfigProvider = QVD::Admin4::DBConfigProvider->new();

    $self->forze_filtering_by_tenant;
    $self->forze_tenant_assignment_in_creation
	if $self->qvd_object_model->type_of_action eq 'create';
    $self->switch_custom_properties_json2request;

    $self->forze_default_version_in_json_for_di if
	($self->qvd_object_model->qvd_object eq 'DI' &&
	$self->qvd_object_model->type_of_action eq 'create' &&
	 not $self->json_wrapper->has_argument('version'));

    $self->switch_di_id_filter_into_osf_id_in_vm if 
	$self->json_wrapper->has_filter('di_id') &&
	$self->qvd_object_model->qvd_object eq 'VM';

    $self->check_filters_validity_in_json;
    $self->check_arguments_validity_in_json;
    $self->check_nested_queries_validity_in_json;
    $self->check_order_by_validity_in_json;

    $self->set_pagination_in_request;
    $self->set_filters_in_request;
    $self->set_arguments_in_request;
    $self->set_nested_queries_in_request;
    $self->set_order_by_in_request;
    $self->set_tables_to_join_in_request;
}

sub forze_default_version_in_json_for_di
{ 
    my $self = shift;

    my $osf_id = $self->json_wrapper->get_argument_value('osf_id') // return;

    my ($y, $m, $d) = (localtime)[5, 4, 3]; $m ++; $y += 1900;
    my $osf = $DBConfigProvider->db->resultset('OSF')->search({id => $osf_id})->first;
    my $version;

    for (0..999) 
    {
	$version = sprintf("%04d-%02d-%02d-%03d", $y, $m, $d, $_);
	last unless $osf->di_by_tag($version);
    }
    
    $self->json_wrapper->forze_argument_addition('version',$version);
}

sub switch_di_id_filter_into_osf_id_in_vm
{
    my $self = shift;
    my $di_rs = $DBConfigProvider->db->resultset('DI'); 
    my $di_id = $self->json_wrapper->get_filter_value('di_id');
    $self->json_wrapper->forze_filter_deletion('di_id');
    
    $self->set_filter($self->qvd_object_model->map_filter_to_dbix_format('osf_id'),
		      { -in => $di_rs->search({ 'subquery.id' => $di_id,
						'tags.tag' => { -ident => 'me.di_tag' } },
					      { join => ['tags'], 
						alias => 'subquery'})->get_column('osf_id')->as_query });
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

sub set_filter
{
    my ($self,$key,$val) = @_;
    $self->filters->{$key} = $val;
}

sub set_argument
{
    my ($self,$key,$val) = @_;
    $self->arguments->{$key} = $val;
}

sub set_nested_query
{
    my ($self,$key,$val) = @_;
    $self->nested_queries->{$key} = $val;
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

sub set_pagination_in_request
{
    my $self = shift;
    $self->modifiers->{page} = $self->json_wrapper->offset // 1; 
    $self->modifiers->{rows}  = $self->json_wrapper->block // 10000; 
}

sub forze_filtering_by_tenant
{
    my $self = shift;

    return unless $self->qvd_object_model->available_filter('tenant_id');
    if ($self->json_wrapper->has_filter('tenant_id'))
    {
	QVD::Admin4::Exception->throw(code => 9) 
	    unless $ADMIN->is_superadmin;
    }
    else
    {
	$self->json_wrapper->forze_filter_addition('tenant_id',$ADMIN->tenants_scoop);
    }
}

sub forze_tenant_assignment_in_creation
{
    my $self = shift;
	
    return if $ADMIN->is_superadmin; # It must be provided in the input
    return unless $self->qvd_object_model->mandatory_argument('tenant_id');
    $self->json_wrapper->forze_argument_addition('tenant_id',$ADMIN->tenant_id);
}

sub switch_custom_properties_json2request
{
    my $self = shift;
    my @custom_properties_keys = 
	$DBConfigProvider->
	get_custom_properties_keys($self->qvd_object_model->qvd_object);

    my $found_properties = 0;

    for my $property_key (@custom_properties_keys)
    {
	next unless $self->json_wrapper->has_filter($property_key);

	$found_properties++;
	my $property_value = $self->json_wrapper->get_filter_value($property_key);
	$property_value = { like => "%".$property_value."%"};
	my $property_dbix_key = $found_properties > 1 ?
	    "properties_$found_properties" : 'properties';
	$self->json_wrapper->forze_filter_deletion($property_key);
        $self->set_filter($property_dbix_key.".key",$property_key);
        $self->set_filter($property_dbix_key.".value",$property_value);
        $self->add_to_join('properties');
    }
}

sub check_filters_validity_in_json
{
    my $self = shift;

    $self->qvd_object_model->available_filter($_) || 
	QVD::Admin4::Exception->throw(code => 9)
	for $self->json_wrapper->filters_list;

    $self->json_wrapper->has_filter($_) ||
	QVD::Admin4::Exception->throw(code => 10)
	for $self->qvd_object_model->mandatory_filters;
}

sub check_arguments_validity_in_json
{
    my $self = shift;

    if ($self->qvd_object_model->type_of_action eq 'update')
    {
	$self->qvd_object_model->available_argument($_) || 
	    QVD::Admin4::Exception->throw(code => 12)
	    for $self->json_wrapper->arguments_list;
    }

    if ($self->qvd_object_model->type_of_action eq 'create')
    {
	$self->json_wrapper->has_argument($_) || 
	    defined $self->qvd_object_model->get_default_argument_value($_) ||
	    QVD::Admin4::Exception->throw(code => 23502)
	    for $self->qvd_object_model->mandatory_arguments;
    }
}

sub check_nested_queries_validity_in_json
{
    my $self = shift;
}

sub check_order_by_validity_in_json
{
    my $self = shift;
}

sub set_filters_in_request
{
    my $self = shift;
    for my $key ($self->json_wrapper->filters_list)
    {
	my $key_dbix_format = 
	    $self->qvd_object_model->map_filter_to_dbix_format($key);
	my $value = $self->json_wrapper->get_filter_value($key);
	my $value_normalized = $self->qvd_object_model->normalize_value($key,$value);

	$value_normalized = { like => "%".$value_normalized."%"} 
	if $self->qvd_object_model->subchain_filter($key);
	$self->set_filter($key_dbix_format,$value_normalized);
    }
}


sub set_arguments_in_request
{
    my $self = shift;
    for my $key ($self->json_wrapper->arguments_list)
    {
	my $key_dbix_format = 
	    $self->qvd_object_model->map_argument_to_dbix_format($key);
	my $value = $self->json_wrapper->get_argument_value($key);
	my $value_normalized = $self->qvd_object_model->normalize_value($key,$value);
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
	my $value = $self->qvd_object_model->get_default_argument_value($key);
	$self->instantiate_argument($key_dbix_format,$value);
    }
}

sub instantiate_argument
{
    my ($self,$dbix_key,$value) = @_;
    $value = undef if $value && $value eq '';
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
    $self->{nested_queries} = $self->json_wrapper->nested_queries;
}

sub set_tables_to_join_in_request
{
    my $self = shift;
    $self->add_to_join($_) 
	for @{$self->qvd_object_model->dbix_join_value};

    $self->add_to_prefetch($_) 
	for @{$self->qvd_object_model->dbix_prefetch_value};
}
1;
