package QVD::API::REST::Response;
use strict;
use warnings;
use Moo;
use Clone qw(clone);
use Scalar::Util qw(blessed);

# This class is intended to build a successful response of the API.
# The object which this class implements takes the output of a method 
# in QVD::API (a list of DBIx::Class objects) and builds a corresponding JSON

# So the main processing in this class is to map from DBIx::Class objects to
# HASH structures suitable to be encoded as JSON.

# 'data' is the parameter in which the output of the QVD::API method
# is provided to the constructor
has 'data', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'HASH'; }, default => sub {{};};

# This is the model used to know what fields to retrieve are available 
# for the action executed
has 'qvd_object_model', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'QVD::API::REST::Model'; };

# This is the original request that the API received
has 'json_wrapper', is => 'ro', isa => sub { die "Invalid type" unless ref(+shift) eq 'QVD::API::REST::JSON'; };

sub BUILD
{
    my $self = shift;

    if (defined($self->qvd_object_model)) {
        my $rows = $self->data->{rows};
        if (defined( $rows )) {
            $self->data->{rows} = $self->_process_data_array( $rows );
        } else {
            $self->{data} = ($self->_process_data_array( [ $self->data ] ))->[0];
        }
    
        eval { delete $self->data->{extra} };
    
        $self->data->{status} = 0;
        $self->data->{message} = 'Successful completion';
    }
}

sub _process_data_array
{
    my $self = shift;
    my $elements = shift;

    my $processed_elements = [ map { $self->_process_element($_) } @{$elements} ];

    # ad hoc mapping for all_ids actions

    $processed_elements = $self->_map_result_to_list_of_ids($processed_elements)
        if $self->qvd_object_model->type_of_action eq 'all_ids';
    
    return $processed_elements;
}

sub _process_element
{
    my ($self, $element) = @_;

    my $result = {};
    
    for my $field (@{$self->_get_field_list})
    {
        if ($self->qvd_object_model->has_property($field))
        {
            $result->{$field} = $self->_get_property_value($element, $field);
        }
        else
        {
            $result->{$field} = eval { 
                blessed($element) ?
                    $self->_get_dbix_object_value($element, $field) : 
                    $element->{$field}
            };
            print $@ if $@;
        }
    }

    return $result;
}

sub _get_dbix_object_value
{
    my ($self, $dbix_object, $field) = @_;

    my $dbix_field_key = $self->qvd_object_model->map_field_to_dbix_format($field);
    my ($table,$column) = $dbix_field_key =~ /^(.+)\.(.+)$/;
    
    if($table eq 'me') {
        return $dbix_object->$column;
    } elsif ($table eq 'view') {
        # view is a special prefix that says that
        # the value of this field must be provided by a related view
        # whose result was saved in the 'extra'
        return ($self->data->{extra}->{$dbix_object->id}->$column);
    } else {
        return $dbix_object->$table->$column;
    }
    return ($dbix_object->$table,$column);
}

sub _get_property_value
{
    my ($self,$dbix_object,$property) = @_;

    return eval { $self->data->{extra}->{$dbix_object->id}->properties->{$property} };
};

sub _get_field_list
{
    my ($self) = @_;

    my @available_fields;

    if ($self->json_wrapper->fields_list)
    {
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

    return \@available_fields;
}

#############################################################################

# Returns a HASH structure suitable to be encoded as JSON.

sub json
{
    my $self = shift;
    return clone ($self->data);
}

# ad hoc mapping for all_ids actions

sub _map_result_to_list_of_ids
{
    my $self = shift;
    my $list = shift;
    
    return [ map { $_->{id} } @{$list} ];
}

1;
