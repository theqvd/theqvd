package QVD::Admin4::REST::Model;
use strict;
use warnings;
use Moose;

has 'current_qvd_administrator', is => 'ro', isa => 'QVD::DB::Result::Administrator', required => 1;
has 'qvd_object', is => 'ro', isa => 'Str', required => 1;
has 'type_of_action', is => 'ro', isa => 'Str', required => 1;

my $MODEL_INFO = { avaliable_filters => [],
		   available_arguments => [],
		   available_fields => [],
		   subchain_filters => [],
		   mandatory_arguments => [],
		   mandatory_filters => [],
		   default_argument_values => {},
		   default_order_criteria => [],
		   filters_to_dbix_format_mapper => {},
		   arguments_to_dbix_format_mapper => {},
		   fields_to_dbix_format_mapper => {},
		   argument_values_normalizator => {},
		   dbix_join_value => {},
		   dbix_has_one_relationships => {},
};

my $AVAILABLE_ARGUMENTS = {};
my $MANDATORY_ARGUMENTS = {};
my $DEFAULT_ARGUMENT_VALUES = {};
my $FILTERS_TO_DBIX_FORMAT_MAPPER = {};
my $FIELDS_TO_DBIX_FORMAT_MAPPER = {};
my $ARGUMENT_VALUES_NORMALIZATOR = {};
my $DBIX_JOIN_VALUE = {};
my $DBIX_HAS_ONE_RELATIONSHIPS = {};
	      
my $AVAILABLE_FILTERS = { details => [qw(id tenant_id)],
			  tiny => [qw(tenant_id)],
			  delete => [qw(id tenant_id)],
			  update => [qw(id tenant_id)],
			  state => [qw(id tenant_id)],
			  'exec' => [qw(id tenant_id)] };

my $MANDATORY_FILTERS = { list => [qw(tenant_id)],
			  details => [qw(id tenant_id)], 
			  tiny => [qw(tenant_id)],
			  delete => [qw(id tenant_id)], 
			  update=> [qw(id tenant_id)], 
			  state => [qw(id tenant_id)], 
			  all_ids => [qw(tenant_id)], 
			  'exec' => [qw(id tenant_id)]};

my $SUBCHAIN_FILTERS = { list => [qw(name)] };

my $AVAILABLE_FIELDS = { tiny => [qw(id name)],
			 all_ids_actions => [qw(id)]};

my $DEFAULT_ORDER_CRITERIA = { tiny => [qw(name)]};

sub BUILD
{
    my $self = shift;

    $self->set_avaliable_filters;
    $self->set_available_arguments;
    $self->set_available_fields;
    $self->subchain_filters;
    $self->set_mandatory_arguments;
    $self->set_mandatory_filters;
    $self->set_default_argument_values;
    $self->set_default_order_criteria;
    $self->set_filters_to_dbix_format_mapper;
    $self->set_arguments_to_dbix_format_mapper;
    $self->set_fields_to_dbix_format_mapper;
    $self->set_argument_values_normalizator;
    $self->set_dbix_join_value;
    $self->set_dbix_has_one_relationships;
};

sub set_avaliable_filters
{
    my $self = shift;

    $MODEL_INFO->{avaliable_filters} = 
	$AVAILABLE_FILTERS->{$self->qvd_object} //
	$AVAILABLE_FILTERS->{$self->type_of_action} // [];
}

sub set_subchain_filters
{
    my $self = shift;

    $MODEL_INFO->{subchain_filters} = 
	$SUBCHAIN_FILTERS->{$self->qvd_object} // 
	$SUBCHAIN_FILTERS->{$self->type_of_action} // [];
}

sub set_default_order_criteria
{
    my $self = shift;
    $MODEL_INFO->{default_order_criteria} = 
	$DEFAULT_ORDER_CRITERIA->{$self->qvd_object} //
	$DEFAULT_ORDER_CRITERIA->{$self->type_of_action} // [];
}

sub set_available_arguments
{
    my $self = shift;

    $MODEL_INFO->{avaliable_arguments} = 
	$AVAILABLE_ARGUMENTS->{$self->qvd_object} //
	$AVAILABLE_ARGUMENTS->{$self->type_of_action} // [];

}

sub set_available_fields
{
    my $self = shift;

    $MODEL_INFO->{avaliable_fields} = 
	$AVAILABLE_FIELDS->{$self->qvd_object} //
	$AVAILABLE_FIELDS->{$self->type_of_action} // [];

}

sub set_mandatory_arguments
{
    my $self = shift;
    $MODEL_INFO->{mandatory_arguments} = 
	$MANDATORY_ARGUMENTS->{$self->qvd_objects} // 
	$MANDATORY_ARGUMENTS->{$self->type_of_action} // [];
}

sub set_mandatory_filters
{
    my $self = shift;

    $MODEL_INFO->{mandatory_filters} = 
	$MANDATORY_FILTERS->{$self->qvd_objects} // 
	$MANDATORY_FILTERS->{$self->type_of_action} // [];
}

sub set_default_argument_values
{
    my $self = shift;
    $MODEL_INFO->{default_argument_values} = 
	$DEFAULT_ARGUMENT_VALUES->{$self->qvd_object} // 
	$DEFAULT_ARGUMENT_VALUES->{$self->type_of_action} // {};
}


sub set_filters_to_dbix_format_mapper
{
    my $self = shift;
    $MODEL_INFO->{filters_to_dbix_format_mapper} = 
	$FILTERS_TO_DBIX_FORMAT_MAPPER->{$self->qvd_object} // 
	$FILTERS_TO_DBIX_FORMAT_MAPPER->{$self->type_of_action} // {};

}

sub set_arguments_to_dbix_format_mapper
{
    my $self = shift;
    $MODEL_INFO->{arguments_to_dbix_format_mapper} = 
	$ARGUMENTS_TO_DBIX_FORMAT_MAPPER->{$self->qvd_object} //
	$ARGUMENTS_TO_DBIX_FORMAT_MAPPER->{$self->type_of_action} // {};

}

sub set_fields_to_dbix_format_mapper
{
    my $self = shift;
    $MODEL_INFO->{fields_to_dbix_format_mapper} = 
	$FIELDS_TO_DBIX_FORMAT_MAPPER->{$self->qvd_object} // 
	$FIELDS_TO_DBIX_FORMAT_MAPPER->{$self->type_of_action} // {};

}

sub set_argument_values_normalizator
{
    my $self = shift;
    $MODEL_INFO->{argument_values_normalizator} = 
	$ARGUMENT_VALUES_NORMALIZATOR->{$self->qvd_object} // 
	$ARGUMENT_VALUES_NORMALIZATOR->{$self->type_of_action} // {};

}

sub set_dbix_join_value
{
    my $self = shift;
    $MODEL_INFO->{dbix_join_value} = 
	$DBIX_JOIN_VALUE->{$self->qvd_object} // 
	$DBIX_JOIN_VALUE->{$self->type_of_action} // [];
}

sub set_dbix_has_one_relationships
{
    my $self = shift;
    $MODEL_INFO->{dbix_has_one_relationships} = 
	$DBIX_HAS_ONE_RELATIONSHIPS->{$self->qvd_object} // 
	$DBIX_HAS_ONE_RELATIONSHIPS->{$self->type_of_action} // [];

}

############
###########
##########

sub get_avaliable_filters
{
    my $self = shift;

   my $filters =  $MODEL_INFO->{avaliable_filters} // [];
    @$filters;
}

sub get_subchain_filters
{
    my $self = shift;

    my $filters = $MODEL_INFO->{subchain_filters} // [];
    @$filters;
}

sub get_default_order_criteria
{
    my $self = shift;
    my $order_criteria =  $MODEL_INFO->{default_order_criteria} // [];
    @$order_criteria;
}

sub get_available_arguments
{
    my $self = shift;
    my $args = $MODEL_INFO->{avaliable_arguments} // [];
    @$args;
}

sub get_available_fields
{
    my $self = shift;
    my $fields =  $MODEL_INFO->{avaliable_fields} // [];
    @$fields;
}

sub get_mandatory_arguments
{
    my $self = shift;
    my $args =  $MODEL_INFO->{mandatory_arguments} // [];
    @$args;
}

sub get_mandatory_filters
{
    my $self = shift;

    my $filters = $MODEL_INFO->{mandatory_filters} // [];
    @$filters;
}

sub get_default_argument_values
{
    my $self = shift;
    return $MODEL_INFO->{default_argument_values} || {};
}


sub get_filters_to_dbix_format_mapper
{
    my $self = shift;
    return $MODEL_INFO->{filters_to_dbix_format_mapper} || {};
}

sub get_arguments_to_dbix_format_mapper
{
    my $self = shift;
    return $MODEL_INFO->{arguments_to_dbix_format_mapper} || {};
}

sub get_fields_to_dbix_format_mapper
{
    my $self = shift;
    return $MODEL_INFO->{fields_to_dbix_format_mapper} || {};
}

sub get_argument_values_normalizator
{
    my $self = shift;
    return $MODEL_INFO->{argument_values_normalizator} || {};
}

sub get_dbix_join_value
{
    my $self = shift;
    return $MODEL_INFO->{dbix_join_value} || [];
}

sub get_dbix_has_one_relationships
{
    my $self = shift;
    my $rels = $MODEL_INFO->{dbix_has_one_relationships} // [];
    @$rels;
}

#################
################
#################


sub is_avaliable_filter
{
    my $self = shift;
    my $filter = shift;
    $_ eq $filter && return 1
	for $self->get_avaliable_filters;

    return 0;
}

sub is_subchain_filter
{
    my $self = shift;
    my $filter = shift;

    $_ eq $filter && return 1
	for $self->get_subchain_filters;
    return 0;
}

sub is_default_order_criterium
{
    my $self = shift;
    my $order_criterium = shift;
    $_ eq $order_criterium && return 1
	for $self->get_default_order_criteria;
    return 1;
}

sub is_available_argument
{
    my $self = shift;
    my $argument = shift;

    $_ eq $argument && return 1
	for $self->get_available_arguments;

    return 0;
}

sub is_available_field
{
    my $self = shift;
    my $field = shift;
    $_ eq $field && return 1
	for $self->get_available_fields;

    return 0;
}

sub is_mandatory_argument
{
    my $self = shift;
    my $argument = shift;

    $_ eq $argument && return 1
	for $self->get_mandatory_arguments;
    return 0;
}

sub is_mandatory_filter
{
    my $self = shift;
    my $filter = shift;
    $_ eq $filter && return 1
	for $self->get_mandatory_filters;
    return 0;
}

sub get_default_argument_value
{
    my $self = shift;
    my $arg = shift;

    return $self->get_default_argument_values->{$arg};
}


sub map_filter_to_dbix_format
{
    my $self = shift;
    my $filter = shift;

    return $self->get_filters_to_dbix_format_mapper->{$filter};
}

sub map_argument_to_dbix_format
{
    my $self = shift;
    my $argument = shift;

    return $self->get_arguments_to_dbix_format_mapper->{$argument};
}

sub map_field_to_dbix_format
{
    my $self = shift;
    my $field = shift;

    return $self->get_fields_to_dbix_format_mapper->{$field};
}

sub map_argument_value_normalized
{
    my $self = shift;
    my $argument = shift;

    return $self->get_argument_values_normalizator->{$argument};
}

    
1;
