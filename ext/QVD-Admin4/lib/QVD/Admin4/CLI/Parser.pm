package QVD::Admin4::CLI::Parser;
use strict;
use warnings;
use Clone qw(clone);
use Moo;
use QVD::Admin4::CLI::Parser::Edge;
use QVD::Admin4::CLI::Parser::Agenda;
use QVD::Admin4::CLI::Parser::Chart;
use QVD::Admin4::CLI::Parser::Node;
use QVD::Admin4::CLI::Grammar::Substitution;

has 'unificator', is => 'ro', isa => sub { die "Invalid type for attribute unificator" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Parser::Unificator'; };
has 'grammar', is => 'ro', isa => sub { die "Invalid type for attribute grammar" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Grammar'; };

has 'agenda', is => 'ro', isa => sub { die "Invalid type for attribute agenda" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Parser::Agenda'; };

has 'chart', is => 'ro', isa => sub { die "Invalid type for attribute chart" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Parser::Chart'; };
my $LAST;

sub BUILD
{
    my $self = shift;
}


sub parse
{
    my ($self,$tokens_list) = @_;

    $LAST = 0;
    $self->{agenda} = QVD::Admin4::CLI::Parser::Agenda->new();
    $self->{chart} = QVD::Admin4::CLI::Parser::Chart->new();

    my $edges = $self->get_edges_from_initial_tokens($tokens_list);

    $self->parse_recursive($edges);

    my $response = [];
    for my $edge (@{$self->chart->inactive_edges})
    {
	if ($edge->node->label eq 'ROOT'
	    && $edge->from eq 0 && $edge->to eq $LAST)
	{ push @$response, $edge->node->meaning; }
    } 

    $response;
}


sub parse_recursive
{
    my ($self,$old_edges) = @_;
    $self->agenda->set_edge($_) for @$old_edges;
    my $new_edges = [];

    while (my $old_edge = $self->agenda->get_edge) 
    {
	push @$new_edges, $self->expand_edge($old_edge)
	    unless $old_edge->is_active;
	push @$new_edges, $self->combine_edge($old_edge);
	$self->chart->add_edge($old_edge);
    }

    $self->parse_recursive($new_edges)
	if @$new_edges;
}

sub get_edges_from_initial_tokens
{
    my ($self,$tokens) = @_;
    my @edges;
    for my $token (@$tokens)
    {
	$LAST = $token->to if $token->to > $LAST; 

	for my $label ($self->grammar->get_labels_for_string($token->string))
	{
	    my $node = QVD::Admin4::CLI::Parser::Node->new(label => $label); 
	    my $edge = QVD::Admin4::CLI::Parser::Edge->new(
		node => $node, from => $token->from, to => $token->to);

	    push @edges, $edge;
	}
    }
    \@edges;
}

sub expand_edge
{
    my ($self,$edge) = @_;
    
    my @new_edges;

    for my $rule ($self->grammar->get_rules)
    {
	my $new_edge = $self->expand_edge_aux($edge,$rule);
	push @new_edges, $new_edge;
    }

    @new_edges;
}

sub expand_edge_aux
{
    my ($self,$edge,$rule) = @_;

    my %args = (
	target_structure => $rule->first_daughter,
	source_structure => $edge->node->first_to_find->label,
	target_substitution => QVD::Admin4::CLI::Grammar::Substitution->new(), 
	source_substitution => $edge->node->first_to_find->substitution );
    
    my $substitution = $self->unificator->unify(%args) // next;

    my $node = QVD::Admin4::CLI::Parser::Node->new(rule => $rule, substitution => $substitution); 
    my $new_edge = QVD::Admin4::CLI::Parser::Edge->new(
	node => $node, from => $edge->from, to => $edge->to, 
	to_find => [$rule->rest_of_daughters], found => [$edge->node] );
    $new_edge->node->percolate_meaning_from_constituents($new_edge->found);
    return $new_edge;
}

sub combine_edge
{
    my ($self,$edge) = @_;
    my @new_edges = $edge->is_active ?
	$self->combine_active_edge($edge) :
	$self->combine_inactive_edge($edge);
}

sub combine_inactive_edge
{
    my ($self,$inactive_edge) = @_;
    my @new_edges;
    for my $active_edge ($self->chart->get_active_edges) 
    {
	my $new_edge = $self->combine_edge_aux($active_edge,$inactive_edge)
	    // next;
	push @new_edges, $new_edge;
    }
    @new_edges;
}


sub combine_active_edge 
{
    my ($self, $active_edge) = @_;
    my @new_edges;
    for my $inactive_edge ($self->chart->get_inactive_edges) 
    {
	my $new_edge = $self->combine_edge_aux($active_edge,$inactive_edge)
	    // next;
	push @new_edges, $new_edge;
    }
    @new_edges;
}


sub combine_edge_aux 
{
    my ($self, $active_edge, $inactive_edge) = @_;

    return undef unless $self->location_condition($inactive_edge,$active_edge);

    my %args = (
	target_structure => $active_edge->node->first_to_find->label, 
	source_structure => $inactive_edge->node->label,
	target_substitution => $active_edge->node->first_to_find->substitution, 
	source_substitution => $inactive_edge->node->substitution );
    
    my $substitution = $self->unificator->unify(%args) // return;

    my $node = QVD::Admin4::CLI::Parser::Node->new(rule => $active_edge->node->rule, substitution => $substitution); 
    my $new_edge = QVD::Admin4::CLI::Parser::Edge->new(
	node => $node, from => $active_edge->from, to => $inactive_edge->to, 
	to_find => $active_edge->rest_to_find, found => [@{$active_edge->found}] );
    $new_edge->add_found($inactive_edge->node);
    $new_edge->node->percolate_meaning_from_constituents($new_edge->found);

    $new_edge;
}

sub location_condition
{
    my ($self,$inactive_edge,$active_edge) = @_;
    $inactive_edge->from eq $active_edge->to + 1;
}

1;
