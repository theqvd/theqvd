package QVD::Admin4::REST::Response;
use strict;
use warnings;
use Moose;

has 'result',     is => 'ro', isa => 'HashRef', default => sub { {}; };
has 'status',     is => 'ro', isa => 'Str', required => 1;
has 'message',    is => 'ro', isa => 'Str', default => '';

sub BUILD
{
    my $self = shift;
    $self->{result}->{total} //= undef; 
    $self->{result}->{rows} //= []; 
}

sub json
{
    my $self = shift;

   { status  => $self->status,
     message => $self->message,
     result  => $self->result };
}

sub total
{
    my $self = shift;
    $self->result->{total};
}

sub rows
{
    my $self = shift;
    $self->result->{rows};
}

1;
