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

# Class intended to perform syntactic analysis

# An object able to decide is two feature structures unify or not needed
has 'unificator', is => 'ro', isa => sub { die "Invalid type for attribute unificator" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Grammar::Unificator'; };

# The analysis is done acording to a grammar.
has 'grammar', is => 'ro', isa => sub { die "Invalid type for attribute grammar" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Grammar'; };

# Repositories of constituents needed for the parsing
has 'agenda', is => 'ro', isa => sub { die "Invalid type for attribute agenda" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Parser::Agenda'; };

has 'chart', is => 'ro', isa => sub { die "Invalid type for attribute chart" 
						  unless ref(+shift) eq 'QVD::Admin4::CLI::Parser::Chart'; };

# This is the last position in the input tokens list 
# Needed to know if an analysis covers the whole sentence
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
	if ($self->is_root($edge) # is an axiom
	    && $edge->from eq 0 && $edge->to eq $LAST) # covers the whole sentence
	{ push @$response, 
	  $self->grammar->response(clone $edge->node->meaning) ; } # Creates an object QVD::Admin4::CLI::Grammar::Meaning
                                                                   # (a wrapper for the HASH version of the analysis)
    } 

    $response;
}

sub is_root
{
    my ($self,$edge) = @_;

    my %args = (
	target_structure => clone($self->grammar->root),
	source_structure => $edge->node->label,
	target_substitution => QVD::Admin4::CLI::Grammar::Substitution->new(), 
	source_substitution => $edge->node->substitution );

    my $bool = $self->unificator->unify(%args);
    $bool ? return 1 : return 0;
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

# This code creates the initial constituents of the parsing
# process from the input tokens 

# The grammar has info about what kind of constituent 
# (with a label and a meaning) should be created from 
# a certain string

    for my $token (@$tokens)
    {
	$LAST = $token->to if $token->to > $LAST; 
	my $meaning = $self->grammar->get_meaning_for_string($token->string);

	for my $label ($self->grammar->get_labels_for_string($token->string))
	{
	    my $node = QVD::Admin4::CLI::Parser::Node->new(
		label => $label, 
		meaning => $meaning,
		substitution => QVD::Admin4::CLI::Grammar::Substitution->new()); 
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
	my %args = (
	    target_structure => clone($rule->first_daughter),
	    source_structure => $edge->node->label,
	    target_substitution => QVD::Admin4::CLI::Grammar::Substitution->new(), 
	    source_substitution => $edge->node->substitution );

	my $substitution = $self->unificator->unify(%args) || next; 

        # Created a node that implements a new grammatical constituent. 
        # It will be the kind of constituent defined by the rule $rule
	my $node = QVD::Admin4::CLI::Parser::Node->new(rule => $rule, substitution => $substitution); 

	# Created a new edge regarding the new constituent
	my $new_edge = QVD::Admin4::CLI::Parser::Edge->new(
	    node => $node, from => $edge->from, to => $edge->to, 
	    to_find => [$rule->rest_of_daughters], found => [$edge->node] );

        # Triggers the creation of the meaning of the constituent
        # from the list of daughters
	$new_edge->node->percolate_meaning_from_constituents($new_edge->found) 
	    unless $new_edge->is_active;

	push @new_edges, $new_edge;
    }

    @new_edges;
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
	target_structure => clone($active_edge->first_to_find), 
	source_structure => $inactive_edge->node->label,
	target_substitution => $active_edge->node->substitution, 
	source_substitution => $inactive_edge->node->substitution );
    
    my $substitution = $self->unificator->unify(%args) || return;

    # Created a node that implements a new grammatical constituent. 
    # It will be the kind of constituent defined by the rule $rule
    my $node = QVD::Admin4::CLI::Parser::Node->new(rule => $active_edge->node->rule, substitution => $substitution); 

    # Created a new edge regarding the new constituent
    my $new_edge = QVD::Admin4::CLI::Parser::Edge->new(
	node => $node, from => $active_edge->from, to => $inactive_edge->to, 
	to_find => $active_edge->rest_to_find, found => [@{$active_edge->found}] );

    $new_edge->add_found($inactive_edge->node);

    # Triggers the creation of the meaning of the constituent
    # from the list of daughters
    $new_edge->node->percolate_meaning_from_constituents($new_edge->found)
	    unless $new_edge->is_active;

    $new_edge;
}

sub location_condition
{
    my ($self,$inactive_edge,$active_edge) = @_;
    $inactive_edge->from eq $active_edge->to + 1;
}

1;
