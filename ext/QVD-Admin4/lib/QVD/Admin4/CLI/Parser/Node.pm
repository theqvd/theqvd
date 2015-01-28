package QVD::Admin4::CLI::Parser::Node;
use strict;
use warnings;
use Moo;

has 'rule',  is => 'ro', isa => sub { die "Invalid type for attribute rule" 
					  unless ref(+shift) eq 'QVD::Admin4::CLI::Grammar::Rule'; };
has 'substitution',  is => 'ro', isa => sub { die "Invalid type for attribute substitution" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Grammar::Substitution'; };
has 'label', is => 'ro', isa => sub {};
has 'meaning', is => 'ro', isa => sub {};

sub BUILD
{
    my $self = shift;

    die "Neither label nor rule" unless
	defined $self->{label} || defined $self->{rule};
    $self->{label} //= $self->rule->left_side;
}

sub percolate_meaning_from_constituents
{
    my ($self,$constituents_nodes) = @_;
    my $cb = $self->rule->meaning;
    my @constituents_meaning = map { $_->meaning } @$constituents_nodes;
    $self->{meaning} = $cb->(@constituents_meaning);
}

1;

