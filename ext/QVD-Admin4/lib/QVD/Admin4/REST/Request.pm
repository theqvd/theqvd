package QVD::Admin4::REST::Request;
use strict;
use warnings;
use Moose;

has 'db',        is => 'ro', isa => 'QVD::DB',  required => 1;
has 'json',      is => 'ro', isa => 'HashRef',  required => 1;
has 'config',    is => 'ro', isa => 'HashRef',  required => 1;
has 'mapper',    is => 'ro', isa => 'Config::Properties';
has 'modifiers', is => 'ro', isa => 'HashRef',  default => sub { {}; };
has 'customs',   is => 'ro', isa => 'ArrayRef',  default => sub { []; };
has 'defaults',   is => 'ro', isa => 'HashRef',  default => sub { {}; };

sub BUILD
{
    my $self = shift;

    $self->json->{arguments} //= {};
    $self->json->{filters} //= {};
    $self->config->{arguments} //= {};
    $self->config->{filters} //= {};
    $self->config->{mandatory} //= {};
    $self->config->{order_by} //= [];

    $self->modifiers->{page} = $self->json->{offset} // 1; 
    $self->modifiers->{rows}  = $self->json->{blocked} // 1; 
}

sub action 
{
    my $self = shift;
    $self->json->{action};
}

sub table 
{
    my $self = shift;
    $self->config->{table};
}

sub filters 
{
    my $self = shift;
    my $filters = {};

    exists $self->config->{filters}->{$_} ||
	die "No such a filter $_ for this action" 
	for keys %{$self->json->{filters}};

    exists $self->json->{filters}->{$_} ||
	die "No mandatory filter $_ in request" 
	for keys %{$self->config->{mandatory}};

    for my $filter (keys %{$self->json->{filters}})
    {
	my $mfil = $self->mapper->getProperty($filter) // 
	    die "No map for $filter: $!"; 
	$filters->{$mfil} = $self->json->{filters}->{$filter};
    }
    $filters;
}

sub arguments 
{
    my $self = shift;
    my $arguments = {};

    exists $self->config->{arguments}->{$_} ||
	die "No such an argument $_ for this action"
	for keys %{$self->json->{arguments}};

    for my $argument (keys %{$self->json->{arguments}})
    {
	my $marg = $self->mapper->getProperty($argument) // 
	    die "No map for $argument: $!"; 
	$arguments->{$marg} = 
	    $self->json->{arguments}->{$argument} // 
	    $self->defaults->{$argument} // undef;
    }
    $arguments;
}


sub order_by
{
    my $self = shift;
    my $order_by = { '-asc' => []};

    for my $order (@{$self->config->{order_by}})
    {
	my $morder = $self->mapper->getProperty($order) // 
	    die "No map for $order: $!"; 
	push @{$order_by->{'-asc'}}, $morder;
    }

    $self->modifiers->{order_by}  = $order_by;
}

sub get_customs
{
    my ($self,$table) = @_;
    my $n = 1;
    $self->{customs} = [keys %{{map {$_->key => 1 } $self->db->resultset($table)->all}}];
    for (@{$self->customs})
    {
	if (exists $self->json->{filters}->{$_})
	{ 
	    my $pr = $n eq '1' ? "properties" : "properties_$n";
	    $self->json->{filters}->{"$pr.key"} = $_;
	    $self->json->{filters}->{"$pr.value"} = $self->json->{filters}->{$_};
	    delete $self->json->{filters}->{$_};
	    @{$self->config->{filters}}{"$pr.key","$pr.value"} = qw(1 1);
	   
	    $self->modifiers->{join} //= [];
	    push @{$self->modifiers->{join}}, 'properties';

	    $self->{mapper} //= Config::Properties->new();
	    $self->mapper->setProperty("$pr.key","$pr.key");
	    $self->mapper->setProperty("$pr.value","$pr.value");

	    $n++;
	}
    }
}

1;
