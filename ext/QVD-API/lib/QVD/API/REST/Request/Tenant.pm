package QVD::API::REST::Request::Tenant;
use strict;
use warnings;
use Moose;

extends 'QVD::API::REST::Request';

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;

    $self->{mapper} = $mapper;

    $self->_check;
    $self->_map;
}

1;

__DATA__

id = me.id
name = me.name
description = me.description
tenant = me.id
