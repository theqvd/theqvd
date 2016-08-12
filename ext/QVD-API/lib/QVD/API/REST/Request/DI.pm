package QVD::API::REST::Request::DI;
use strict;
use warnings;
use Moose;
use File::Basename qw(basename);
extends 'QVD::API::REST::Request';

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;

    $self->{mapper} = $mapper;
    push @{$self->modifiers->{join}}, qw(vm_runtimes tags);
    push @{$self->modifiers->{join}}, {osf => 'tenant'};

# create function get_basename_in_disk_image

    $self->json->{arguments}->{disk_image} = 
	basename($self->json->{arguments}->{disk_image})
	if defined $self->json->{arguments}->{disk_image};

    $self->_check;
    $self->_map;
}

1;

# tags_get_columns is not a relationship: only available as output field 

__DATA__

id = me.id
disk_image = me.path
description = me.description
version = me.version
osf_id = me.osf_id
osf_name = osf.name
tenant = osf.tenant_id
blocked = me.blocked
tags = me.tags_get_columns
tenant_name     = tenant.name
