package QVD::Admin4::CLI::Grammar::Rule;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Parser::Node;
use Clone qw(clone);

has 'left_side', is => 'ro', isa => sub { die "Invalid type for attribute left_side" unless ref(+shift) eq 'HASH'; }, required => 1;
has 'right_side', is => 'ro', isa => sub { die "Invalid type for attribute right_side" unless ref(+shift) eq 'ARRAY'; }, required => 1;
has 'meaning', is => 'ro', isa => sub { die "Invalid type for attribute meaning" unless ref(+shift) eq 'CODE';}, required => 1;

sub mother
{
    my $self = shift;
    return $self->left_side;
}

sub daughters
{
    my $self = shift;
    return @{$self->right_side};
}

sub first_daughter
{
    my $self = shift;
    return @{$self->right_side}[0];
}

sub rest_of_daughters
{
    my $self = shift;
    my @daughters =  @{$self->right_side};
    shift @daughters;
    @daughters;
}


1;
