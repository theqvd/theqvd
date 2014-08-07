package QVD::Admin4::REST::Request::DI;
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
    $self->get_customs('DI_Property');
    $self->modifiers->{join} //= [];
    push @{$self->modifiers->{join}}, qw(osf vm_runtimes tags);
    $self->order_by;
}

1;

__DATA__

id = me.id
disk_image = me.path
version = me.version
osf_id = osf.id
osf_name = osf.name
tenant = osf.tenant_id
blocked = me.blocked
