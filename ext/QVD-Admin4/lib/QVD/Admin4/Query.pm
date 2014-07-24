package QVD::Admin4::Query;

use 5.010;
use strict;
use warnings;
use Moose;

our $VERSION = '0.01';

has 'filter',      is => 'rw', isa => 'Str';
has 'action',      is => 'rw', isa => 'Str';
has 'tenant',      is => 'ro', isa => 'ArrayRef', required => 1;
has 'request',     is => 'rw', isa => 'QVD::Admin4::REST::Request', required => 1;


sub BUILD
{
    my $self = shift;

    die "Neither action nor filter specified" 
	unless ($self->action || $self->filter);

    my $role = $self->request->{tenant};

    for my $tenant (@{$self->tenant})
    {
	return 1 if ($tenant eq 'all' || $tenant eq $role); 
    }

    die "Forbidden action";
}


1;
