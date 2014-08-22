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
    push @{$self->modifiers->{join}}, qw(tenant);
    push @{$self->modifiers->{join}}, qw(vms dis);
    push @{$self->modifiers->{join}}, { dis => 'tags' };
    $self->_check;
    $self->_map;
}


sub get_default_memory { cfg('osf.default.memory'); }
sub get_default_overlay { cfg('osf.default.overlay'); }


1;


# WARNING: 
# vm_id and di_id are has_many relationships with unambiguous filter id: only available as filter
# vms_count and dis_count are not relationships: only available as output fields

__DATA__


id = me.id
name = me.name
overlay = me.use_overlay
user_storage = me.user_storage_size
memory = me.memory
vm_id  = vms.id
di_id  = dis.id
tenant = me.tenant_id
tenant_name  = tenant.name
vms = me.vms_count
dis = me.dis_count
