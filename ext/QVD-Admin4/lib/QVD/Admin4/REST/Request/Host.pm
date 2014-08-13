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
    $self->get_customs('Host_Property');
    $self->modifiers->{join} //= [];
    push @{$self->modifiers->{join}}, ('runtime','vms');
    $self->order_by;
}

1;


__DATA__

id = me.id
name = me.name
address = me.address
blocked =  runtime.blocked
frontend = me.frontend
backend =  me.backend
state = runtime.state
vm_id = vms.vm_id
