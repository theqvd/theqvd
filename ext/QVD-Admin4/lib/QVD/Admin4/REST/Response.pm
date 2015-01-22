package QVD::Admin4::REST::Response;
use strict;
use warnings;
use Moo;

has 'result', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'HASH'; }, default => sub {{};};
has 'qvd_object_model', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'QVD::Admin4::REST::Model'; };
has 'json_wrapper', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'QVD::Admin4::REST::JSON'; };

sub BUILD
{
    my $self = shift;

    $self->map_result_from_dbix_objects_to_output_info
	if $self->qvd_object_model;
}

sub map_result_from_dbix_objects_to_output_info
{
    my $self = shift;
    return unless defined $self->result->{rows};

    $_ = $self->map_dbix_object_to_output_info($_)
	for @{$self->result->{rows}};

    $self->map_result_to_list_of_ids
	if $self->qvd_object_model->type_of_action eq 'all_ids';
}

sub map_dbix_object_to_output_info
{
    my ($self,$dbix_object) = @_;

    my $result = {};
    my $admin = $self->qvd_object_model->current_qvd_administrator;

    for my $field_key ($self->calculate_fields)
    {
	my $dbix_field_key = $self->qvd_object_model->map_field_to_dbix_format($field_key);
	my ($info_provider,$method,$argument) = $self->get_info_provider_and_method($dbix_field_key,$dbix_object);
	if (defined $argument) 
	{
	    use Data::Dumper; print Dumper $info_provider->$method($argument);
	    $result->{$field_key} = eval { $info_provider->$method($argument) } // undef;
	    print $@ if $@;
	}
	else
	{
	    $result->{$field_key} = eval { $info_provider->$method } // undef;
	    print $@ if $@;
	}
    }

    $result;
}

sub map_result_to_list_of_ids
{
    my $self = shift;
    $self->result->{rows} = 
	[ map { $_->{id} } @{$self->result->{rows}} ];
}

sub get_info_provider_and_method
{
    my ($self,$dbix_field_key,$dbix_object) = @_;

    my ($table,$column) = $dbix_field_key =~ /^(.+)\.(.+)$/;
    return ($dbix_object,$column) if $table eq 'me';

    if ($table eq 'view')
    {
	if (my ($method,$argument) = $column =~ /^([^#]+)#([^#]+)$/) 
	{ return ($self->result->{extra}->{$dbix_object->id},$method,$argument) };
	return ($self->result->{extra}->{$dbix_object->id},$column);
    }
    return ($dbix_object->$table,$column);
}


sub json
{
    my $self = shift;
    delete $self->result->{extra};
    { status => 0,message => 'Successful completion',%{$self->result}};
}

sub is_cli
{
    my $self = shift;
    my $client = $self->json_wrapper->get_parameter_value('__client__'); 
    defined $client && $client =~ m/^cli$/i;
}

sub cli_defaults_needed
{
    my $self = shift;
    $self->is_cli && (not $self->json_wrapper->fields_list);
}

sub specific_fields_asked
{
    my $self = shift;
    $self->json_wrapper->fields_list;
}

sub calculate_fields
{
    my ($self,$dbix_obj) = @_;
    return @{$self->{available_fields}} if defined $self->{available_fields};

    my @available_fields;

    if ($self->specific_fields_asked)
    {
	@available_fields = $self->json_wrapper->fields_list;
    }
    else
    {
	@available_fields = $self->cli_defaults_needed ? 
	    $self->qvd_object_model->default_fields_for_cli :
	    $self->qvd_object_model->available_fields;
	
	my $admin = $self->qvd_object_model->current_qvd_administrator;
	@available_fields = grep  { $admin->re_is_allowed_to($self->qvd_object_model->get_acls_for_field($_)) } 
	@available_fields;
    }

    $self->{available_fields} = \@available_fields;

    @available_fields;
}



1;
