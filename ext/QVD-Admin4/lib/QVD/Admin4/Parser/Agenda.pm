package QVD::Admin4::Parser::Agenda;
use strict;
use warnings;
use Moo;


my $EDGES;

sub BUILD
{
    my $self = shift;
    $EDGES = [];
}

sub get_edge
{
    my $self = shift;
    shift $EDGES;
}

sub set_edge
{
    my ($self,$edge) = @_;
    push @$EDGES, $edge;
}

1;
