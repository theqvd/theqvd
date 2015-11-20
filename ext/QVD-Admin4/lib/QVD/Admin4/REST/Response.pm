package QVD::Admin4::REST::Response;
use strict;
use warnings;
use Moo;

# This class is intended to build a successful response of the API.
# The object which this class implements takes the output of a method 
# in QVD::Admin4 (a list of DBIx::Class objects) and builds a corresponding JSON

# So the main processing in this class is to map from DBIx::Class objects to
# HASH structures suitable to be encoded as JSON.

# 'result' is the parameter in which the output of the QVD::Admin4 method
# is provided to the constructor
has 'result', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'HASH'; }, default => sub {{};};

# This is the model used to know what fields to retrieve are available 
# for the action executed
has 'qvd_object_model', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'QVD::Admin4::REST::Model'; };

# This is the original request that the API received
has 'json_wrapper', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'QVD::Admin4::REST::JSON'; };

sub BUILD
{
    my $self = shift;

    $self->map_result_from_dbix_objects_to_output_info
	if $self->qvd_object_model;
}

############################################
## MAIN FUNCTIONS TO MAP FROM DBIx::CLASS ##
## OBJECTS TO HASH                        ##
############################################

sub map_result_from_dbix_objects_to_output_info
{
    my $self = shift;
    return unless defined $self->result->{rows};

    $_ = $self->map_dbix_object_to_output_info($_)
	for @{$self->result->{rows}};

# ad hoc mapping for all_ids actions

    $self->map_result_to_list_of_ids
	if $self->qvd_object_model->type_of_action eq 'all_ids';
}

sub map_dbix_object_to_output_info
{
    my ($self,$dbix_object) = @_;

    my $result = {};
    my $admin = $self->qvd_object_model->current_qvd_administrator;

    for my $field_key ($self->calculate_fields) # list of fields that must be retrieved
    {                                           # for every object
	if ($self->qvd_object_model->has_property($field_key)) # checks if the field is a custom property
	{
	    $result->{$field_key} = $self->get_property_value($dbix_object,$field_key);
	}
	else
	{	    
	    my $dbix_field_key = $self->qvd_object_model->map_field_to_dbix_format($field_key);

	    # The field value would be provided from different sources
            # (i.e. the main DBIx::Class object, or a related view)  
	    my ($info_provider,$method,$argument) = $self->get_info_provider_and_method($dbix_field_key,$dbix_object);
	    if (defined $argument) 
	    {
		$result->{$field_key} = eval { $info_provider->$method($argument) } // undef;
		print $@ if $@;
	    }
	    else
	    {
		$result->{$field_key} = eval { $info_provider->$method } // undef;
		print $@ if $@;
	    }
	}
    }

    $result;
}

# AUXILIAR FUNCTIONS

# This function assumes that $dbix_field_key is a string
# that defines  where the value of a field can be found
# The syntax of that string was defined in QVD::Admin4::REST::Model
# and used in the class variable $QVD::Admin4::REST::Model::$FIELDS_TO_DBIX_FORMAT_MAPPER 

# From that string this function returns:

# a) The object from which the value must be returned (provider)
# b) The method that must be executed in that object (method)
# c) Optionally, the argument that must be passed to that method 

sub get_info_provider_and_method
{
    my ($self,$dbix_field_key,$dbix_object) = @_;

    my ($table,$column) = $dbix_field_key =~ /^(.+)\.(.+)$/;
    return ($dbix_object,$column) if $table eq 'me';

    if ($table eq 'view') # view is a special prefix that says that 
    {                     # the value of this field must be provided by a related view
                          # whose result was saved in the 'extra' key of the QVD::Admin4 result

	if (my ($method,$argument) = $column =~ /^([^#]+)#([^#]+)$/) 
		{
			return ($self->result->{extra}->{$dbix_object->id},$method,$argument)
		};
	return ($self->result->{extra}->{$dbix_object->id},$column);
    }
    return ($dbix_object->$table,$column);
}

# Custom Properties are stored in the 'extra' key of the QVD::Admin4 result

sub get_property_value
{
    my ($self,$dbix_object,$property) = @_;

    my $val = eval { $self->result->{extra}->{$dbix_object->id}->properties->{$property} }
    // undef;
}

# Calculates the fields that must be provided for every object in the API output
# It depends on the available fields for the action that was executed and the
# fields that were explicitally requested

sub calculate_fields
{
    my ($self,$dbix_obj) = @_;
    return @{$self->{available_fields}} if defined $self->{available_fields};

    my @available_fields;

    if ($self->specific_fields_asked) # The input query included explicitally 
    {                                 # a list of fields to return
	@available_fields = $self->json_wrapper->fields_list;
    }
    else
    {
	@available_fields = $self->qvd_object_model->available_fields;
	
	my $admin = $self->qvd_object_model->current_qvd_administrator;
	# This grep deletes from the output fields the admin doesn't have acls for
	@available_fields = grep  { $admin->re_is_allowed_to($self->qvd_object_model->get_acls_for_field($_)) } 
	@available_fields;
    }

    $self->{available_fields} = \@available_fields;

    @available_fields;
}

sub specific_fields_asked
{
    my $self = shift;
    $self->json_wrapper->fields_list;
}

#############################################################################

# Returns a HASH structure suitable to be encoded as JSON.

sub json
{
    my $self = shift;
    delete $self->result->{extra};
    { status => 0,message => 'Successful completion',%{$self->result}};
}

# ad hoc mapping for all_ids actions

sub map_result_to_list_of_ids
{
    my $self = shift;
    $self->result->{rows} = 
	[ map { $_->{id} } @{$self->result->{rows}} ];
}

1;
