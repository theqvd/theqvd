package QVD::Admin4::REST::Request::Host;
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

    $self->{dependencies} = {runtime => 1, counters => 1};
    push @{$self->modifiers->{join}}, ('runtime');
    push @{$self->modifiers->{join}}, { vms => 'host'};
    $self->_check;
    $self->_map;
}

1;

# WARNING: 
# vm_id is a has_many relationship with unambiguous filter id: only available as filter
# vms_count and vms_connected are not relationships: only available as output fields

__DATA__

id = me.id
name = me.name
description = me.description
address = me.address
blocked =  runtime.blocked
frontend = me.frontend
backend =  me.backend
state = runtime.state
vm_id = vms.vm_id
load = me.load
creation_admin = me.creation_admin
creation_date = me.creation_date
vms_connected = me.vms_connected
vms = me.vms_count
