package QVD::Admin4::CLI::Grammar::Rule;
use strict;
use warnings;
use Moo;
use QVD::Admin4::CLI::Parser::Node;

has 'left_side', is => 'ro', isa => sub { die "Invalid type for attribute left_side" if ref(+shift); }, required => 1;
has 'right_side', is => 'ro', isa => sub { die "Invalid type for attribute right_side" unless ref(+shift) eq 'ARRAY'; }, required => 1;
has 'cb', is => 'ro', isa => sub { die "Invalid type for attribute cb" unless ref(+shift) eq 'CODE'; }, required => 1;

sub BUILD
{
    my $self = shift;

    my @rs_nodes = 
	map { QVD::Admin4::CLI::Parser::Node->new(label => $_) } 
    @{$self->right_side};
    $self->{right_side} = \@rs_nodes;
}

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
