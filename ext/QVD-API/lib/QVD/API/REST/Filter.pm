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

# Available logical and comparison operators in the input hash
my %LOGICAL_OPERATORS = ( -and => 1, -or => 1, -not => 1 );
my %COMPARISON_OPERATORS = (
    '>' => '>',
    '<' => '<',
    '<=' => '<=',
    '>=' => '>=',
    '=' => 'eq',
    '<>' => '!=',
    '!=' => 'ne',
    '~' => \&_include,
    'LIKE' => \&_include );

for (keys %COMPARISON_OPERATORS) {
    my $op = $COMPARISON_OPERATORS{$_};
    next if ref $op;
    $COMPARISON_OPERATORS{$_} = eval "sub { \$_[0] $op \$_[1] }";
}

# Separator for each node name in a path
my $SEPARATOR = "::";

# Default comparison operator
my $DEFAULT_COMPARISON_OP = '=';

# Root operator of the filter tree
my $ROOT_OP = '-and';

# Initial counter value
my $INITIAL_COUNTER = 1;

# Input: a hash of filters according DBIC format for filters
has 'filter', is => 'ro', isa => sub { die "Invalid filter format" unless ref(+shift) eq 'ARRAY'; }, 
    coerce => sub {
        my $filter = eval { [ $ROOT_OP, _normalize_filter($_[0]) ] };
        print $@ if $@;
        return $filter;
    }, required => 1;

# Constructor

sub BUILD
{
    my $self = shift;
}

# Private methods

sub _root_key {
    my $self = shift;
    return $self->{filter}[0];
}

sub _normalize_filter
{
    my ($filter) = @_;

    my @filter_array = ref($filter) eq 'HASH' ? %$filter : @$filter;

    for (my $index = 0; $index < @filter_array; $index += 2) {
        my $key = $filter_array[$index];
        my $value = $filter_array[$index+1];

        if (exists $LOGICAL_OPERATORS{$key}){
            $filter_array[$index+1] = _normalize_filter($value);
        } elsif(ref($key) eq '') {
            my $operator = $DEFAULT_COMPARISON_OP;
            if (ref($value) eq 'HASH'){
                $operator = (keys %$value)[0];
                $value = $value->{$operator};
                if(!exists $COMPARISON_OPERATORS{$operator}){
                    die "Hash shall contain operator and operand";
                }
            }
            $filter_array[$index+1] = { $operator => (ref($value) eq 'ARRAY') ? $value : [$value] };
        } else {
            die "Key values shall be scalar or operator";
        }
    }

    return \@filter_array;
}

sub _paths
{
    my $origin = shift;
    my $filter = shift;
    my $paths = [];

    my @filter_array = @$filter;
    my %key_counter = ();
    while (@filter_array) {
        my $key = shift @filter_array;
        my $value = shift @filter_array;
        $key_counter{$key} = exists $key_counter{$key} ? $key_counter{$key} + 1 : $INITIAL_COUNTER;
        
        my $new_origin = ($origin eq '') ? "$key" : "$origin$SEPARATOR$key";
        $new_origin .= "[$key_counter{$key}]";
        if(exists $LOGICAL_OPERATORS{$key}){
            push @$paths, @{_paths($new_origin, $value)};
        } else {
            # unshift is used to sort the elements backwards, in order to iterate without dependencies
            # Example: in {"-and": [id,100,id,101]} the counter id of -or[1]::id[2] depends on -and[1]::id[1]
            # if -and[1]::id[1] is removed, -and[1]::id[2] becomes -and[1]::id[1]
            unshift @$paths, $new_origin;
        }
    }
    
    return $paths;
}

sub _filter_node {
    my ($self,$path) = @_;
    
    my @node_names = split /$SEPARATOR/, $path;
    
    my $current_node = $self->{filter};

    while(@node_names){
        my ($node_name, $node_counter) = _name_and_counter(shift @node_names);
        my $index = 0;
        my %key_counter = ();
        while ($index < @$current_node) {
            my $key = $current_node->[$index];
            my $value = $current_node->[$index+1];
            $key_counter{$key} = exists $key_counter{$key} ? $key_counter{$key} + 1 : $INITIAL_COUNTER;

            if($key eq $node_name && $key_counter{$key} == $node_counter){
                if(@node_names == 0){
                    return [$current_node, $index];
                } else {
                    $current_node = $value;
                    last;
                }
            }
            $index += 2;
        }
    }
    
    return undef;
}

sub _normalize_comparison_operator {
    my $operator = shift;
    return (eval { $COMPARISON_OPERATORS{$operator} } // $operator);
}

sub _satisfy {
    my $self = shift;
    my $element = shift;
    my $key = shift;
    my $value = shift;
    
    if (exists $LOGICAL_OPERATORS{$key}) {
        if($key eq '-and'){
            my $index = 0;
            while($index < $#{$value}){
                my $new_key = $value->[$index];
                my $new_value = $value->[$index+1];
                $index += 2;
                return 0 unless $self->_satisfy($element, $new_key, $new_value);
            }
            return 1;
        } elsif($key eq '-or'){
            my $index = 0;
            while($index < $#{$value}){
                my $new_key = $value->[$index];
                my $new_value = $value->[$index+1];
                $index += 2;
                return 1 if $self->_satisfy($element, $new_key, $new_value);
            }
            return 0;
        } elsif($key eq '-not'){
            my $index = 0;
            while($index < $#{$value}){
                my $new_key = $value->[$index];
                my $new_value = $value->[$index+1];
                $index += 2;
                return 0 if $self->_satisfy($element, $new_key, $new_value);
            }
            return 1;
        } else {
            die "Logical operator $key not supported";
        }
    } else {
        my $elem_value = eval { $element->{$key} } // eval { $element->$key };
        return 0 unless defined($elem_value);

        my $op = (keys(%$value))[0];
        my $values = $value->{$op};
        for my $cmp_value (@{$values}){
            return 1 if _evaluate_expression($elem_value, $op, $cmp_value);
        }
        return 0;
    }
    
    return 0;
}

# Public methods

sub filter_list
{
    my $self = shift;
    return _paths('', $self->{filter}[1]);
}

sub has_filter
{
    my ($self,$path) = @_;
    
    return 0 unless defined($path);
    my $root_path = $self->_root_key() . "$SEPARATOR" . $path;
    my $node_ref = $self->_filter_node($root_path);

    if (defined($node_ref)){
        return 1;
    } else {
        return 0;
    }
}

sub filter_value
{
    my ($self,$path) = @_;
    
    return undef unless defined($path);
    my $root_path = $self->_root_key() . "$SEPARATOR" . $path;
    my $node_info = $self->_filter_node($root_path);
    
    if (defined($node_info)){
        my ($array_ref, $index) = @$node_info;
        my $value = $array_ref->[$index + 1];
        my $operand = (values %$value)[0];
        return $operand;
    }

    return undef;
}

sub filter_operator
{
    my ($self,$path) = @_;
    
    return undef unless defined($path);
    my $root_path = $self->_root_key() . "$SEPARATOR" . $path;
    my $node_info = $self->_filter_node($root_path);
    
    if (defined($node_info)){
        my ($array_ref, $index) = @$node_info;
        my $value = $array_ref->[$index + 1];
        my $operator = (keys %$value)[0];
        return $operator;
    }
    
    return undef;
}

sub add_filter
{
    my ($self,$path,$value) = @_;
    
    my @node_names = split /$SEPARATOR/, $path;
    my $new_key = pop @node_names;
    my $subpath = join( $SEPARATOR, @node_names );
    my $root_subpath = join( $SEPARATOR, ($self->_root_key(), @node_names) );
    
    eval {
        ($new_key, $value) = @{_normalize_filter([$new_key, $value])};
    };
    if($@){
        die "Invalid filter format: $@";
    }
    
    my $node_info = $self->_filter_node($root_subpath);
    if(!defined($node_info)){
        $self->add_filter($subpath, []);
        $node_info = $self->_filter_node($root_subpath);
    }
    
    my ($array_ref, $index) = @$node_info;
    $array_ref = $array_ref->[$index + 1];
    push(@$array_ref, $new_key);
    push(@$array_ref, $value);
    
    return $value;
}

sub del_filter
{
    my ($self,$path) = @_;
    
    my $root_path = $self->_root_key() . "$SEPARATOR" . $path;
    my $node_info = $self->_filter_node($root_path);

    if (defined($node_info)) {
        my ($array_ref, $index) = @$node_info;
        splice @$array_ref, $index, 1;
        return splice @$array_ref, $index, 1;
    }

    return undef;
}

sub set_filter_key
{
    my ($self,$path,$new_key) = @_;
    
    my $root_path = $self->_root_key() . "$SEPARATOR" . $path;
    my $node_info = $self->_filter_node($root_path);
    
    die "Filter key shall be a Scalar" unless ref($new_key) eq '';
    
    if (defined($node_info)) {
        my ($array_ref, $index) = @$node_info;
        $array_ref->[$index] = $new_key;
        return $new_key;
    }
    
    return undef;
}

sub set_filter_value
{
    my ($self,$path,$new_value) = @_;
    
    my $root_path = $self->_root_key() . "$SEPARATOR" . $path;
    my $name = filter_name_from_path($root_path);
    
    eval {
        ($name, $new_value) = @{_normalize_filter([$name, $new_value])};
    };
    if($@){
        die "Invalid filter format: $@";
    }
    
    my $node_info = $self->_filter_node($root_path);
    
    if (defined($node_info)) {
        my ($array_ref, $index) = @$node_info;
        $array_ref->[$index+1] = $new_value;
        return $new_value;
    }

    return undef;
}

sub cgrep
{
    my ($self, @list) = @_;
    my $root_key = $self->_root_key();
    return (grep {$self->_satisfy($_, $root_key, $self->{filter}[1])} @list);
}

sub hash {
    my $self = shift;
    return { @{$self->{filter}} };
}

# Static private methods

sub _name_and_counter {
    my $node = shift;
    
    my ($name, $counter) = ($node =~ /^(.*?)(?:\[(\d+)\])?$/);
    $counter //= $INITIAL_COUNTER;
    
    return ($name, $counter);
}

sub _evaluate_expression {
    my ($element1, $operator, $element2) = @_;
    $operator = _normalize_comparison_operator($operator);
    
    return $operator->($element1, $element2);
}

sub _include {
    my ($element, $subelement) = @_;

    my ($may_not_start_with, $matched_element, $may_not_end_with) = ($subelement =~ /^(%?)(.*?)(%?)$/);
    $matched_element = quotemeta $matched_element;

    my $regex = (($may_not_start_with) ? "" : "\^") . $matched_element . (($may_not_end_with) ? "" : "\$");
    return $element =~ $regex;
}

# Static public methods

sub filter_name_from_path {
    my $path = shift;
    my ($name, undef) = _name_and_counter((split /$SEPARATOR/, $path)[-1]);
    return $name;
}

sub filter_counter_from_path {
    my $path = shift;
    my (undef, $counter) = _name_and_counter((split /$SEPARATOR/, $path)[-1]);
    return $counter;
}

1;
