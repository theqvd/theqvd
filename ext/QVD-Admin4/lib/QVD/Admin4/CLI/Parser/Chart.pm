package QVD::Admin4::CLI::Parser::Chart;
use strict;
use warnings;
use Moo;

has 'active_edges', is => 'ro', isa => sub { die "Invalid type for attribute active_edges" unless ref(+shift) eq 'ARRAY'; };
has 'inactive_edges', is => 'ro', isa => sub { die "Invalid type for attribute inactive_edges" unless ref(+shift) eq 'ARRAY'; };

sub BUILD
{
    my $self = shift;
    $self->{active_edges} = [];
    $self->{inactive_edges} = [];
}

sub add_active_edge 
{
    my ($self,$edge) = @_;

    push (@{$self->active_edges}, $edge);
} 


sub add_inactive_edge {

    my ($self,$edge) = @_;
    push (@{$self->inactive_edges}, $edge);
} 

sub add_edge 
{
    my ($self,$edge) = @_;

    if ($edge->is_active) {

	$self->add_active_edge($edge);
    } else {

	$self->add_inactive_edge($edge);
    }
}


sub get_active_edges 
{
    my $self = shift;
    return @{$self->active_edges};
}


sub get_inactive_edges 
{
    my $self = shift;
    return @{$self->inactive_edges};
}


1;
