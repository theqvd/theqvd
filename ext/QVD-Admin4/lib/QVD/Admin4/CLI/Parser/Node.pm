package QVD::Admin4::CLI::Parser::Node;
use strict;
use warnings;
use Moo;
use Clone qw(clone);

has 'rule',  is => 'ro', isa => sub { die "Invalid type for attribute rule" unless ref(+shift) eq 'QVD::Admin4::CLI::Grammar::Rule'; };
has 'label', is => 'ro', isa => sub { die "Invalid type for attribute label" if ref(+shift); };
has 'api', is => 'ro', isa => sub {  };

sub BUILD
{
    my $self = shift;

    $self->{label} //= $self->rule->left_side;
    $self->{api} //= {};
}

sub get_api
{
    my $self = shift;
    return clone $self->api;
}

sub set_api
{
    my $self = shift;
    $self->{api} = shift;
}

1;

