package QVD::Admin4::REST::Request::OSF;
use strict;
use warnings;
use Moose;
use QVD::Config;

extends 'QVD::Admin4::REST::Request';

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;

    $self->{mapper} = $mapper;
    $self->get_customs('OSF_Property');
    $self->modifiers->{join} //= [];
    push @{$self->modifiers->{join}}, qw(vms dis tenant);
    push @{$self->modifiers->{join}}, { dis => 'tags' };
    $self->default_system;
    $self->order_by;
}


sub get_default_memory { cfg('osf.default.memory'); }
sub get_default_overlay { cfg('osf.default.overlay'); }

1;

__DATA__


id = me.id
name = me.name
overlay = me.use_overlay
user_storage = me.user_storage_size
memory = me.memory
vm_id  = vms.id
di_id  = dis.id
tenant = me.tenant_id
vms = me.vms_count
dis = me.dis_count
