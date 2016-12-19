package QVD::Admin4::Parser::Edge;
use strict;
use warnings;
use Moo;

has 'node', is => 'ro', isa => sub { die "Invalid type for attribute label" 
					  unless ref(+shift) eq 'QVD::Admin4::Parser::Node'; }, required => 1;
has 'from', is => 'ro', isa => sub { die "Invalid type for attribute from" if ref(+shift); }, required => 1;
has 'to', is => 'ro', isa => sub { die "Invalid type for attribute to" if ref(+shift); }, required => 1;
has 'found', is => 'ro', isa => sub { die "Invalid type for attribute to" unless ref(+shift) eq 'ARRAY'; };
has 'to_find', is => 'ro', isa => sub { die "Invalid type for attribute to" unless ref(+shift) eq 'ARRAY'; };

sub BUILD
{
    my $self = shift;
    $self->{found} //= [];
    $self->{to_find} //= [];
}

sub add_found 
{
    my ($self,$found) = @_;
    push @{$self->found}, $found;
} 

sub add_to_find 
{
    my ($self,$tofind) = @_;
    push @{$self->to_find}, $tofind;
}


sub get_found_as_list 
{
    my $self = shift;
    return @{$self->found};
}



sub first_to_find 
{
    my $self = shift;
    return @{$self->to_find}[0];
}

sub rest_to_find 
{
    my $self = shift;

    my @tofind = @{$self->to_find};
    shift @tofind;
    return [@tofind];
}

sub is_active
{
    my $self = shift;
    return $self->first_to_find;
}

1;
