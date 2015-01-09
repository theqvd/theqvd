package QVD::Admin4::CLI::Parser;
use strict;
use warnings;
use Clone qw(clone);
use Moo;
use QVD::Admin4::CLI::Parser::Edge;
use QVD::Admin4::CLI::Parser::Agenda;
use QVD::Admin4::CLI::Parser::Chart;
use QVD::Admin4::CLI::Parser::Node;
use QVD::Admin4::CLI::Parser::Response;

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

    my $response = { analysis => []};
    for my $edge (@{$self->chart->inactive_edges})
    {
	if ($edge->node->label eq 'ROOT'
	    && $edge->from eq 0 && $edge->to eq $LAST)
	{ push @{$response->{analysis}}, $edge->node->api; }
    } 

    QVD::Admin4::CLI::Parser::Response->new(json => $response);
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

	my $label = $self->grammar->get_rules_by_first_right_side($token->string) ?
	    $token->string : $self->grammar->unknown_tag;
	my $node = QVD::Admin4::CLI::Parser::Node->new(label => $label, api => $token->string); 
	my $edge = QVD::Admin4::CLI::Parser::Edge->new(
	    node => $node, from => $token->from, to => $token->to);

	push @edges, $edge;
    }
    \@edges;
}

sub expand_edge
{
    my ($self,$edge) = @_;
    
    my @rules = $self->grammar->get_rules_by_first_right_side($edge->node->label);
    
    my @new_edges;

    for my $rule (@rules)
    {
	my $node = QVD::Admin4::CLI::Parser::Node->new(rule => $rule); 
	my $new_edge = QVD::Admin4::CLI::Parser::Edge->new(
	    node => $node, from => $edge->from, to => $edge->to, 
	    to_find => [$rule->rest_of_daughters], found => [$edge->node] );

	unless ($new_edge->is_active)
	{
	    my $cb = $new_edge->node->rule->cb;
	    $cb->($new_edge->node,$new_edge->found);
	}

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

    $self->unificator->unify(inactive_edge => $inactive_edge, 
			     active_edge => $active_edge) || return undef;

    my $node = QVD::Admin4::CLI::Parser::Node->new(rule => $active_edge->node->rule); 
    my $new_edge = QVD::Admin4::CLI::Parser::Edge->new(
	node => $node, from => $active_edge->from, to => $inactive_edge->to, 
	to_find => $active_edge->rest_to_find, found => [@{$active_edge->found}] );
    $new_edge->add_found($inactive_edge->node);

    unless ($new_edge->is_active)
    {
	my $cb = $new_edge->node->rule->cb;
	$cb->($new_edge->node,$new_edge->found);
    }

    $new_edge;
}

1;
