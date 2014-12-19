package QVD::Admin4::CLI::Parser::Unificator;
use strict;
use warnings;
use Moo;

sub unify
{
    my ($self,%edges) = @_;

    my $inactive_edge = $edges{inactive_edge};
    my $active_edge = $edges{active_edge};

    return 0 unless $inactive_edge->from eq $active_edge->to + 1;
    return 0 unless $inactive_edge->node->label  eq $active_edge->first_to_find->label;

    return 1;
}

1;
