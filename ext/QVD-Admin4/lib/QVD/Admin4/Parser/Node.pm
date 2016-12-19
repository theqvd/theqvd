package QVD::Admin4::Parser::Node;
use strict;
use warnings;
use Moo;
use Clone qw(clone);

# This class implements the idea of constituent of the
# syntactic analysis.
# All constituens have a label (in fact it is a set of key/value
# pairs that characterizes the morphological and syntactic nature
# of the  constituent) and a meaning (a scalar, array or hash that
# translates the constituent to a, maybe partial, request to the QVD admin API)

# The constituent can be built in different ways:

# Its label can be provided directly in the constructor,
# or it can be taken from a grammatical rule (in that case,
# the object is the constituent defined by that rule.

# Its meaning can also be provided in the constructor.
# But usually the meaning is calculated by executing
# the 'percolate_meaning_from_constituents' method

has 'rule',  is => 'ro', isa => sub { die "Invalid type for attribute rule" 
					  unless ref(+shift) eq 'QVD::Admin4::Grammar::Rule'; };
has 'substitution',  is => 'ro', isa => sub { die "Invalid type for attribute substitution" 
						  unless ref(+shift) eq 'QVD::Admin4::Grammar::Substitution'; };
has 'label', is => 'ro', isa => sub {};
has 'meaning', is => 'ro', isa => sub {};

sub BUILD
{
    my $self = shift;

    die "Neither label nor rule" unless
	defined $self->{label} || defined $self->{rule};
    $self->{label} //= $self->rule->left_side;
}

# This method instantiates the meaning attribute of the
# object. That meaning is calculated by a function provided
# by the rule. The arguments of that function must be passed
# to this method as arguments. These are supposed to be the
# meanings of the daughters of the current constituent

sub percolate_meaning_from_constituents
{
    my ($self,$constituents_nodes) = @_;
    my $cb = $self->rule->meaning;
    
    my @constituents_meaning = map { clone $_->meaning } @$constituents_nodes;
    $self->{meaning} = $cb->(@constituents_meaning);
}

1;

