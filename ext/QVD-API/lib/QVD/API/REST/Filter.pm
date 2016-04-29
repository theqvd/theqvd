package QVD::API::REST::Filter;
use strict;
use warnings;
use Moo;
use Clone qw(clone);
use QVD::API::Exception;

# This class creates QVD::API::REST::Filter objects
# that implement  potentially complex sets of filters.

# The objects are created from a hash of filters in DBIC format. That hash may 
# have DBIC complex structures of filters with logical operators where every 
# filter key may appear many times in the structure.
# (i.e. { -or => [ -and => [ filter1 => A, 
#                            filter2 => B ], 
#                  -and => [ filter1 => B, 
#                            filter2 => A ] ] })

# This object is useful to manage this kind of complex structures
# For example, it's useful to know if a certain filter appears in
# the structure, or it's needed to normalize all occurrences of the same filter 
# key or value, and so on.

# Input: a hash of filters according DBIC format for filters
has 'hash', is => 'ro', isa => sub { die "Invalid type for attribute hash" unless ref(+shift) eq 'HASH'; }, required => 1;

# A list of filters that must be unambiguous for a kind of query
# (i.e. 'id' for delete/update queries). Some queries must select one or
# more objects in an unambiguous way. For example, in the API, the delete 
# and update queries must provide an unambiguous set of ids intended to
# identify, unambiguously, the objects that must be deleted or updated.
# That list of unambiguous filters must be provided in here
has 'unambiguous_filters', is => 'ro', isa => sub { my $f = shift; die "Invalid type for attribute unambiguous_filter" 
						       unless ( ref($f) && ref($f) eq 'ARRAY') ;};

# Available logical operator in the input hash
my $LOGICAL_OPERATORS = { -and => 1, -or => 1, -not => 1 };

sub BUILD
{
    my $self = shift;

    my $hash = clone $self->hash;
    $self->{hash} = $hash; 

# Even non-complex filters structures are normalized as complex structures with
# logical operator (i.e. { filter1 => value } is normalized as { -and => [ filter1 => value ] })

    $self->normalize_simple_filter
	if $self->filter_without_logical_operator;

# The key idea to manage complex structures of filters is 
# to create a flattened version of the complex structure
# That flattened version is a hash, where keys are the filter keys
# that appear in the original structure. And values are, for every filter key,
# the list of values that that key had in the original structure. 
# It's crucial that those values are, in fact, references to the original values. 

# Thanks to that flattened structure it's possible to list the filters in the structure,
# to check is a filter exists, to normalize filters and values in all the places of the original
# structure where they appear, and so on

# The method flatten_filters creates that flattened structure

    $self->flatten_filters;

# It checks if the filters structure fits the conditions about
# unambiguous filters. 

    $self->{unambiguous_filters} //= [];
    $self->check_unambiguous_filters;
}

####################################################################
# TO CHECK IF UNAMBIGUOUS FILTERS ARE UNAMBIGUOUS IN THE STRUCTURE #
####################################################################

# Some queries must select one or more objects in an unambiguous way. 
# For example, in the API, the delete and update queries must provide 
# an unambiguous set of ids intended to identify, unambiguously, the 
# objects that must be deleted or updated. That list of mandatory unambiguous 
# filters must be provided in the unambiguous_filters parameter of the constructor.

sub check_unambiguous_filters
{
    my $self = shift;

    for my $f (@{$self->unambiguous_filters})
    {
	my $n = scalar $self->get_filter_ref_value($f) // next;

        QVD::API::Exception->throw(code => 6321, object => $f)  if 
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

############################################################
# TO NORMALIZE FILTER STRUCTURES WITHOUT LOGICAL OPERATORS #
############################################################
# Even non-complex filters structures are normalized as complex structures with
# logical operator (i.e. { filter1 => value } is normalized as { -and => [ filter1 => value ] })

# It checks if the filters structure has logical operators

sub filter_without_logical_operator
{
    my $self = shift;
    my $has_not_logical_operator = 0;
    for (keys %{$self->hash})
    {
	next if exists $LOGICAL_OPERATORS->{$_};
	$has_not_logical_operator = 1;
    }

    $has_not_logical_operator;
}

# It takes a simple filters structure
# without logical operators and creates
# an equivalent structure with an -and logical operator
# This is usefult cause, thanks to that, all filters
# structures are supposed to be logical operators structures

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

#################################################
## TO BUILD THE FLATTENED STRUCTURE OF FILTERS ##
#################################################

# The key idea to manage complex structures of filters is 
# to create a flattened version of the complex structure.
# That flattened version is a hash, where keys are the filter keys
# that appear in the original structure. And values are, for every filter key,
# the list of values that that key had in the original structure. 
# It's crucial that those values are, in fact, references to the original values. 

# Thanks to that flattened structure it's possible to list the filters in the structure,
# to check is a filter exists, to normalize filters and values in all the places of the original
# structure where they appear, and so on

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

#############################################################
# SET/GET methods that let you manage the filters structure #
# (normalize values, check if  a filter exists...)          #
#############################################################

# The typical way to get and set (maybe normalize) the filters
# of the complex structure of filters:

# a) List the filters with 'list_filters'
# b) For every filter, get all its values in the complex structure
#    with 'get_filter_ref_value'. That function retrieves references.
#    Every reference points to a specific occurrence of a filter 
#    in the original structure. 
# c) By accessing one of those references, you can get and set the key, 
#    operator and value of the corresponding original occurrence of the
#    filter (methods 'get_value', 'get_operator', 'set_filter')

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

# It returns a list of references that give access to
# the original values of the filter in the original
# structure

sub get_filter_ref_value
{
    my ($self,$f) = @_;
    my $values = $self->{flatten_filters}->{$f} // 
	return ();
    @$values;    
}

# Returns the list of values that the filter $f
# have in the original complex structure (not references but
# actual values)

sub get_filter_value
{
    my ($self,$f) = @_;

    my @vals = map {$self->get_value($_)} $self->get_filter_ref_value($f);

    scalar @vals > 1 ? return @vals : return $vals[0];
}

# $ref_and_index is one of the references that retrieves 
# get_filter_ref_value. It let you get the actual value of the
# filter from the reference (that's to say, the value of the
# filter in a specific position of the original structure)

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


# $ref_and_index is one of the references that retrieves 
# get_filter_ref_value. It let you get the operator that relates the
# filter with its value from the reference (that's to say, the operator of the
# filter in a specific position of the original structure).

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


# $ref_and_index is one of the references that retrieves 
# get_filter_ref_value. It let you set the key and value of the
# filter the reference (that's to say, the key and value of the
# filter in a specific position of the original structure).

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

# It deletes a filter from the whole structure

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

# It adds a filter to the top of the structure

sub add_filter
{
    my ($self,$k,$v) = @_;

    my $filter = $self->hash;
    $self->{hash} = { -and => [$k, $v, each %$filter] };
    $self->flatten_filter($self->{hash}->{-and},2);
}

1;
