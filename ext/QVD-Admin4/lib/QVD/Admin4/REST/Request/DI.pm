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
    $self->default_system;
    $self->order_by;
}

sub get_default_version
{ 
    my $self = shift;

    my ($y, $m, $d) = (localtime)[5, 4, 3];
    $m ++;
    $y += 1900;

    my $osf_id = $self->json->{arguments}->{osf_id};
    my $osf = $self->db->resultset('OSF')->search({id => $osf_id})->first;
    my $version;
    for (0..999) 
    {
	$version = sprintf("%04d-%02d-%02d-%03d", $y, $m, $d, $_);
	last unless $osf->di_by_tag($version);
    }
    $version;
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
