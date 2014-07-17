package QVD::Admin4::REST::Request;
use strict;
use warnings;
use Moose;

has 'json',      is => 'ro', isa => 'HashRef',  required => 1;

sub action
{
    shift->json->{'action'} // die "No parameter action: $!";
}

sub table
{
    shift->json->{'table'} // die "No parameter table: $!";
}

sub filters
{
    shift->json->{'filters'} // {};
}

sub arguments
{

    shift->json->{'arguments'} // {}; 
}

1;
