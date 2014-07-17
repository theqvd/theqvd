package QVD::Admin4::Query;

use 5.010;
use strict;
use warnings;
use Moose;
use QVD::DB::Simple;
use Data::Dumper;

our $VERSION = '0.01';

has 'database',    is => 'ro', isa => 'QVD::DB',  default => 0;
has 'transaction', is => 'ro', isa => 'Bool',     default => 0;
has 'iterations',  is => 'ro', isa => 'Int',      default => 1;
has 'arguments',   is => 'rw', isa => 'HashRef',  default => sub { {}; };
has 'filters',     is => 'rw', isa => 'HashRef',  default => sub { {}; };
has 'table',       is => 'rw', isa => 'Str';
has 'get_object',  is => 'rw', isa => 'CodeRef';
has 'get_result',  is => 'rw', isa => 'CodeRef';
has 'object',      is => 'rw', isa => 'ArrayRef', default => sub { []; };
has 'result',      is => 'rw', isa => 'ArrayRef', default => sub { []; };

sub BUILD
{
    my $self = shift;
    $self->get_object(sub { [ $self->database ]; }) 
	unless $self->get_object;

    $self->get_result(sub {  shift; }) 
	unless $self->get_result;
}

sub _exec
{
    my $self = shift;
    my $table = $self->table // die "No table specified: $!";

    my $go = $self->get_object;

    $self->object([$go->($self->database,$table, $self->filters,$self->arguments)]);

    $self->transaction ? $self->_multiple : $self->_single;
}

sub _single
{ 
    my $self = shift;
    my $status;

    for my $object (@{$self->object})
    {
	for (1 .. $self->iterations)
	{
	    txn_eval { $self->_base($object) };
	    $@ or last;
	}
	$status .= "$@\n" if $@;
    }

    $status ? die $status : return $self->result;
} 

sub _multiple
{ 
    my $self = shift;

    txn_eval { 

	for my $object (@{$self->object})
	{
	    for (1 .. $self->iterations)
	    {
		eval { $self->_base($object)  };
		$@ or last;
	    }

	    die $@ if $@;
	}
    };
    $@ ? die $@ : $self->result;
} 


sub _base
{
    my ($self, $object) = @_;
    
    my $gr = $self->get_result;
    my $result = $self->result;
    push @$result, $gr->($object,$self->table,$self->filters,$self->arguments)
}

sub reset
{
    my $self = shift;
    $self->{arguments} = {};
    $self->{filters} = {};
    $self->{table} = undef;
    $self->{object} = [];
    $self->{result} = [];
}

1;
