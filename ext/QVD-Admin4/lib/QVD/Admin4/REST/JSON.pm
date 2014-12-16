package QVD::Admin4::REST::JSON;

use strict;
use warnings;
use Moo;
use 5.010;
our $VERSION = '0.01';

has 'json', is => 'ro', isa => sub { die "Invalid type for attribute json" 
					 unless ref(+shift) eq 'HASH'; }, required => '1';

sub BUILD
{
    my $self = shift;
    $self->get_flatten_nested_queries;	
}

sub get_flatten_nested_queries
{
    my $self = shift;

    $self->json->{arguments} //= {};
    my $NQ = 
    {map { $_ => delete $self->json->{arguments}->{$_} }
     grep { $_ =~ /^__.+__$/ }
     keys %{$self->json->{arguments}}};

    for my $matrix_key (keys %$NQ)
    {
	next if $matrix_key eq '__properties__'; # FIX MEE!!!
	defined $NQ->{$matrix_key} && ref($NQ->{$matrix_key}) &&
	    ref($NQ->{$matrix_key}) eq 'HASH' || next;

	for my $nested_key (keys %{$NQ->{$matrix_key}})
	{
	    $NQ->{$matrix_key.$nested_key} = $NQ->{$matrix_key}->{$nested_key};
	}
    
	delete $NQ->{$matrix_key};
    }
    $self->{nested_queries} = $NQ;
}

sub offset
{
    my $self = shift;
    return $self->json->{offset};
}

sub block
{
    my $self = shift;
    return $self->json->{block};
}

sub action
{
	my $self = shift;
	return $self->json->{action};
}

sub filters
{
	my $self = shift;
	return $self->json->{filters} || {};
}


sub parameters
{
	my $self = shift;
	return $self->json->{parameters} || {};
}

sub arguments
{
	my $self = shift;
	return $self->json->{arguments} || {};
}

sub filters_list
{
    my $self = shift;
    keys %{$self->filters};
}

sub parameters_list
{
    my $self = shift;
    keys %{$self->parameters};
}

sub arguments_list
{
    my $self = shift;
    keys %{$self->arguments};
}

sub order_criteria
{
	my $self = shift;
	if (defined $self->json->{order_by} &&
	    defined $self->json->{order_by}->{field})
	{
		ref($self->json->{order_by}->{field}) ?
		    return $self->json->{order_by}->{field} :
		    return [$self->json->{order_by}->{field}];
	} 
	else
	{
		return [];
	}			 
}


sub fields
{
    my $self = shift;
    $self->json->{fields} || [];
}

sub fields_list
{
    my $self = shift;
    my $ref = $self->fields;
    return @$ref;
}

sub order_direction
{
	my $self = shift;
	if (defined $self->json->{order_by} &&
	    defined $self->json->{order_by}->{order})
	{
		return $self->json->{order_by}->{order};
	} 
	else
	{
		return undef;
	}
}


sub nested_queries_list
{
    my $self = shift;
    keys %{$self->nested_queries};
}

sub has_nested_query
{
    my ($self,$nq) = @_;

    $_ eq $nq && return 1
	for keys %{$self->nested_queries};
    return 0;
}

sub get_nested_query_value
{
    my ($self,$nq) = @_;
    return $self->nested_queries->{$nq};
}

sub nested_queries
{
    my $self = shift;
    return $self->{nested_queries} || {};
}

sub has_filter
{
    my ($self,$filter) = @_;

    $_ eq $filter && return 1
	for keys %{$self->filters};
    return 0;
}

sub has_parameter
{
    my ($self,$parameter) = @_;

    $_ eq $parameter && return 1
	for keys %{$self->parameters};
    return 0;
}

sub has_field
{
    my ($self,$field) = @_;

    $_ eq $field && return 1
	for $self->fields_list;
    return 0;
}

sub has_argument
{
    my ($self,$argument) = @_;

    $_ eq $argument && return 1
	for keys %{$self->arguments};
    return 0;
}

sub has_order_criterium
{
    my ($self,$order_criterium) = @_;

    $_ eq $order_criterium && return 1
	for @{$self->order_criteria};
    return 0;
}

sub get_filter_value
{
    my ($self,$filter) = @_;
    return $self->filters->{$filter};
}

sub get_parameter_value
{
    my ($self,$parameter) = @_;
    return $self->parameters->{$parameter};
}

sub get_argument_value
{
    my ($self,$argument) = @_;
    return $self->arguments->{$argument};
}

sub get_order_criterium
{
    my ($self,$order_criterium) = @_;
    $order_criterium eq $_ && return $_
	for @{$self->order_criteria};
    return undef;
}

sub forze_filter_deletion
{
    my ($self,$filter) = @_;
    delete $self->json->{filters}->{$filter};
}

sub forze_parameter_deletion
{
    my ($self,$parameter) = @_;
    delete $self->json->{parameters}->{$parameter};
}

sub forze_argument_deletion
{
    my ($self,$argument) = @_;
    delete $self->json->{arguments}->{$argument};
}

sub forze_order_criterium_deletion
{
    my ($self,$order_criterium) = @_;
    
    $self->json->{order_by}->{field} = 
	[ grep { $_ ne $order_criterium } @{$self->order_criteria} ];
}

sub forze_filter_addition
{
    my ($self,$key,$value) = @_;
    $self->json->{filters}->{$key} = $value;
}

sub forze_parameter_addition
{
    my ($self,$key,$value) = @_;
    $self->json->{parameters}->{$key} = $value;
}

sub forze_argument_addition
{
    my ($self,$key,$value) = @_;
    $self->json->{arguments}->{$key} = $value;
}

sub forze_order_criterium_addition
{
    my ($self,$order_criterium) = @_;
    
    my $order_criteria = $self->order_criteria;
    push @$order_criteria,$order_criterium;
    $self->json->{order_by}->{order} = $order_criteria;
}

1;

