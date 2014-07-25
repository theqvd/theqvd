package QVD::Admin4::REST::Request;
use strict;
use warnings;
use Moose;

has 'json',    is => 'ro', isa => 'HashRef',  required => 1;
has 'order_by', is => 'ro', isa => 'ArratRef';
has 'order_dir', is => 'ro', isa => 'Str';
has 'fields', is => 'ro', isa => 'ArratRef';
has 'filters', is => 'ro', isa => 'HashRef';
has 'arguments', is => 'ro', isa => 'HashRef';
has 'modifiers', is => 'ro', isa => 'HashRef', default  => sub {{};};
has 'pagination', is => 'ro', isa => 'HashRef';
has 'tenant', is => 'ro', isa => 'Str';
has 'action', is => 'ro', isa => 'Str';
has 'table', is => 'ro', isa => 'Str';

sub BUILD
{
    my $self = shift;

    $self->{action} = $self->json->{'action'} // die "No parameter action";
    $self->{table} = $self->json->{'table'}  // die "No parameter table";
    $self->{tenant} = $self->json->{'tenant'} // die "No authentication tenant";
    $self->{order_dir} = $self->json->{'order_dir'} // '-desc';
    $self->{order_dir} =~ /^-(de|a)sc$/ || die "Non supported order_dir ".$self->{order_dir};

    $self->{pagination} = $self->json->{'pagination'} // { blocked => undef, offset => 1 };
    $self->{order_by} = $self->json->{'order_by'}   // [];
    $self->{fields} = $self->json->{'fields'}     // [];
    $self->{filters} = $self->json->{'filters'}    // {};
    $self->{arguments} = $self->json->{'arguments'}  // {}; 

    $self->build_modifiers();
}

sub build_modifiers
{
    my $self = shift;

    $self->build_join;
    $self->build_pagination;
    $self->build_order;
    $self->build_fields;
}

sub build_join
{
    my $self = shift;
    my %relations;

    for (keys %{$self->filters}, 
	 @{$self->fields}, 
	 @{$self->order_by})
    { 
	my ($table) = $_ =~ /^([^\.]+)\.(.+)$/;
	$relations{$table}++ if ($table && $table ne 'me');
    }

    $self->modifiers->{join} = [ keys %relations ];
}

sub build_pagination
{
    my $self = shift;

    my $rows = $self->json->{pagination}->{blocked};
    my $page = $self->json->{pagination}->{offset};

    $self->modifiers->{rows}     = $rows if $rows;
    $self->modifiers->{page}     = $page;
}

sub build_order
{
    my $self = shift;
    return unless @{$self->order_by};

    $self->modifiers->{order_by} = 
    { $self->order_dir => $self->order_by };
}

sub build_fields
{
    my $self = shift;

    for my $field (@{$self->fields})
    {
	$field =~ /^([^\.]+)\.?(.+)?$/;
	die "Bad field $field" unless $1;
	my ($table,$column) = ($1 && $2 ? ($1,$2) : (undef,$1)); 

	if ($table)
	{
	    $self->modifiers->{'+select'} //= [];
	    $self->modifiers->{'+as'}     //= [];
	    push @{$self->modifiers->{'+select'}}, $field;
	    $field =~ s/\./ /g;
	    push @{$self->modifiers->{'+as'}}, $field;
	}
	else
	{
	    $self->modifiers->{columns} //= [];
	    push @{$self->modifiers->{columns}}, $column;
	}
    }
}

sub defaults
{
    my ($self,$defaults) = @_;

    while (my ($k,$v) = each %$defaults)
    {
	$self->{arguments}->{$k} //= $v;
    }
}

1;
