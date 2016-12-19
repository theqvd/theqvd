package QVD::API::VMExpiration;
use Moo;
use  5.010;
use strict;
use warnings;
use Moo;
use DateTime;
use List::Util qw(sum);

has 'vm', is => 'ro', isa => 
    sub { die "Invalid type for attribute vm" 
	      unless ref(+shift) eq 'QVD::DB::Result::VM'; }, required => 1;


my @TIME_UNITS = qw(months days hours minutes seconds);

sub now { DateTime->now();}

sub time_until_expiration_soft
{
    my $self = shift;
    $self->difference($self->now,$self->vm_expiration_soft);
}

sub time_until_expiration_hard
{
    my $self = shift;
    $self->difference($self->now,$self->vm_expiration_hard);
}

sub vm_expiration_hard
{
    my $self = shift;
    $self->vm->vm_runtime->vm_expiration_hard;
}

sub vm_expiration_soft
{
    my $self = shift;
    $self->vm->vm_runtime->vm_expiration_soft;
}


sub difference
{
    my ($self,$now,$then) = @_;

    my %time_difference;
    @time_difference{@TIME_UNITS} = $then->subtract_datetime($self->now)->in_units(@TIME_UNITS);
    $time_difference{expired} = sum(values %time_difference) > 0 ? 0 : 1;

    \%time_difference;
}

1;
