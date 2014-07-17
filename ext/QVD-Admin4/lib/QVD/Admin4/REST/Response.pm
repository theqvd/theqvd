package QVD::Admin4::REST::Response;
use strict;
use warnings;
use Moose;

has 'rows',       is => 'ro', isa => 'ArrayRef', default => sub {[];};
has 'status',     is => 'ro', isa => 'Str', required => 1;
has 'message',    is => 'ro', isa => 'Str', default => '';


sub json
{
    my $self = shift;

   { status  => $self->status,
     message => $self->message,
     rows    => $self->rows };
}

1;
