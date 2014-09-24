package QVD::Admin4::REST::JSON;

use strict;
use warnings;
use Moose;
use 5.010;
our $VERSION = '0.01';

has 'json', is => 'ro', isa => 'HashRef', required => '1';
has 'available_nested_queries', is => 'ro', isa => 'ArrayRef', default => [qw(aclChanges tagChanges propertyChanges)];

my $NESTED_QUERIES;

sub BUILD
{
	my $self = shift;
	
	$self->json->{filters}->{tenant} = $self->tenant 
		if $self->tenant;
	
	$self->json->{arguments} //= {};
	$NESTED_QUERIES = {map { $_ => (delete $self->json->{arguments}->{$_} || {}) } 
		@{$self->available_nested_queries}}; # TODO: Parse nested queries  
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

sub nested_queries
{
	my ($self,$nested_query_key) = @_;
	return $NESTED_QUERIES unless $nested_query_key;
	return $NESTED_QUERIES->{$nested_query_key} || {};
}

sub has_filter
{
    my ($self,$filter) = @_;

    $_ eq $filter && return 1
	for keys %{$self->filters};
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

1;

