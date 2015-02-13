package QVD::Admin4::REST::Filter;
use strict;
use warnings;
use Moo;
use Clone qw(clone);
use QVD::Admin4::Exception;

has 'hash', is => 'ro', isa => sub { die "Invalid type for attribute hash" unless ref(+shift) eq 'HASH'; }, required => 1;
has 'unambiguous_filters', is => 'ro', isa => sub { my $f = shift; die "Invalid type for attribute unambiguous_filter" 
						       unless ( ref($f) && ref($f) eq 'ARRAY') ;};

my $LOGICAL_OPERATORS = { -and => 1, -or => 1, -not => 1 };

sub BUILD
{
    my $self = shift;

    my $hash = clone $self->hash;
    $self->{hash} = $hash; 

    $self->normalize_simple_filter
	unless $self->filter_with_logical_operator;

    $self->flatten_filters;
    $self->{unambiguous_filters} //= [];
    $self->check_unambiguous_filters;
}

sub check_unambiguous_filters
{
    my $self = shift;

    for my $f (@{$self->unambiguous_filters})
    {
	my $n = scalar $self->get_filter_ref_value($f) // next;

        QVD::Admin4::Exception->throw(code => 6321, object => $f)  if 
	    ( $n > 1 || (not $self->is_obligatory($f)) );
    }
}

sub is_obligatory
{
    my ($self,$f) = @_;
    my $first_level = eval { $self->hash->{-and}} // return 0;
    return $self->is_obligatory_rec($first_level,$f);
}


sub is_obligatory_rec
{
    my ($self,$list_of_key_values,$searched_key) = @_;

    my $position = 0;
    my ($key,$value);
    my $odd = sub { my $n = shift; return $n % 2; };
    my $set_value = sub { $value = shift; };
    my $set_key = sub { ($key,$value) = (shift,undef); };

    for my $item (@$list_of_key_values)
    {
	$odd->($position++) ? 
	    $set_value->($item) : $set_key->($item);

	return 1 if $key eq $searched_key;
	return 1 if defined $value && $key eq '-and' &&
	    $self->is_obligatory_rec($value,$searched_key);
    }

    return 0;
} 

sub filter_with_logical_operator
{
    my $self = shift;
    my $has_logical_operator;
    for (keys %$LOGICAL_OPERATORS)
    {
	if ($has_logical_operator = $self->hash->{$_})
	{ 
	    last; 
	} 
    }
    $has_logical_operator;
}

sub normalize_simple_filter
{
    my $self = shift;
    my $filter = $self->hash;

    my @filter;

    while (my ($k,$v) = each %$filter)
    {
	push @filter, ($k,$v);
    }
    $self->{hash} = { -and => \@filter };
}

sub flatten_filters
{
    my $self = shift;
    my $filters = $self->hash;

    $self->{flatten_filters} = {};
    while (my ($k,$v) = each %$filters)
    {
	$self->flatten_filters_rec($v);
    }
}

sub flatten_filters_rec
{
    my ($self,$filters) = @_;  

    my $position = 0;
    my ($key,$value);
    my $odd = sub { my $n = shift; return $n % 2; };
    my $set_value = sub { $value = shift; };
    my $set_key = sub { ($key,$value) = (shift,undef); };

    for my $item (@$filters)
    {
	$odd->($position++) ? 
	    $set_value->($item) : $set_key->($item);

	if (defined $value)
	{
	    if (exists $LOGICAL_OPERATORS->{$key})
	    {
		$self->flatten_filters_rec($value);
	    }
	    else
	    {
		$self->flatten_filter($filters,$position);
	    }
	}
    }
}

sub flatten_filter
{
    my ($self,$ref,$index) = @_;
    my $key_i = $index - 2;
    my $val_i = $index - 1;
    $self->{flatten_filters}->{$$ref[$key_i]} //= [];
    push @{$self->{flatten_filters}->{$$ref[$key_i]}}, 
    { ref => $ref, index => $key_i };
}

sub list_filters
{
    my $self = shift;
    keys %{$self->{flatten_filters}};
}

sub has_filter
{
    my ($self,$f) = @_;

    $self->{flatten_filters}->{$f};
}

sub get_filter_ref_value
{
    my ($self,$f) = @_;
    my $values = $self->{flatten_filters}->{$f} // 
	return ();
    @$values;    
}

sub get_filter_value
{
    my ($self,$f) = @_;

    my @vals = map {$self->get_value($_)} $self->get_filter_ref_value($f);

    scalar @vals > 1 ? return @vals : return $vals[0];
}

sub get_value
{
    my ($self,$ref_and_index) = @_;
    my $ref = $ref_and_index->{ref};

    my $key_i = $ref_and_index->{index};
    my $val_i = $key_i + 1;
    my $val = $$ref[$val_i];

    if (ref($val) && ref($val) eq 'HASH')
    {
	my @val = values %$val;
	$val = shift @val;
    }
   
    $val;
}

sub get_operator
{
    my ($self,$ref_and_index) = @_;
    my $ref = $ref_and_index->{ref};
    my $key_i = $ref_and_index->{index};
    my $val_i = $key_i + 1;
    my $val = $$ref[$val_i];
    my $op = '=';

    if (ref($val) && ref($val) eq 'HASH')
    {
	my @ops = keys %$val;
	$op = shift @ops;
    }

    $op;
}

sub set_filter
{
    my ($self,$ref_and_index,$key,$val) = @_;
    my $ref = $ref_and_index->{ref};
    my $key_i = $ref_and_index->{index};
    my $val_i = $key_i + 1;
    my $old_key = $$ref[$key_i]; 
    $$ref[$key_i] = $key;
    $$ref[$val_i] = $val;
    $self->{flatten_filters}->{$key} =
	delete $self->{flatten_filters}->{$old_key};
}


sub del_filter
{
    my ($self,$f) = @_;

    for my $ref_and_index ($self->filters->get_filter_ref_value($f))
    {
	my $ref = $ref_and_index->{ref};
	my $key_i = $ref_and_index->{index};
	splice @$ref,  $key_i, 2;
    }

    $self->flatten_filters;
}

sub add_filter
{
    my ($self,$k,$v) = @_;

    my $filter = $self->hash;
    $self->{hash} = { -and => [$k, $v, each %$filter] };
    $self->flatten_filter($self->{hash}->{-and},2);
}

1;
