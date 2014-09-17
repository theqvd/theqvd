package QVD::Admin4::REST::Request::Tenant;
use strict;
use warnings;
use Moose;

extends 'QVD::Admin4::REST::Request';

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
tenant = me.id
