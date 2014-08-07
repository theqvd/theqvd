package QVD::Admin4::REST::Request::VM;
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
    $self->get_customs('VM_Property');
    $self->modifiers->{join} //= [];
    push @{$self->modifiers->{join}}, qw(vm_runtime user osf);
    $self->order_by;
}

1;

__DATA__

id              = me.id
name            = me.name
user_id         = me.user_id
osf_id          = me.osf_id
osf_name        = osf.name
di_tag          = me.di_tag
blocked         = vm_runtime.blocked
expiration_soft = vm_runtime.vm_expiration_soft
expiration_hard = vm_runtime.vm_expiration_hard
state           = vm_runtime.vm_state
host_id         = vm_runtime.host_id
di_id           = vm_runtime.current_di_id
user_state      = vm_runtime.user_state
di_tag          = me.di_tag
ip              = me.ip
next_boot_ip    = vm_runtime.vm_address 
ssh_port        = vm_runtime.vm_ssh_port
vnc_port        = vm_runtime.vm_vnc_port
serial_port     = vm_runtime.vm_serial_port
tenant          = user.tenant_id
