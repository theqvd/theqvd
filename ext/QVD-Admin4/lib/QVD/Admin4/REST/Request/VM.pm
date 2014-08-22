package QVD::Admin4::REST::Request::VM;
use strict;
use warnings;
use Moose;
use QVD::Config::Network qw(nettop_n netstart_n net_aton net_ntoa);

extends 'QVD::Admin4::REST::Request';

my $mapper =  Config::Properties->new();
$mapper->load(*DATA);

sub BUILD
{
    my $self = shift;

    $self->{mapper} = $mapper;
    $self->{dependencies} = {vm_runtime => 1, counters => 1};
    push @{$self->modifiers->{join}}, qw(osf);
    push @{$self->modifiers->{join}}, { vm_runtime => 'host' };
    push @{$self->modifiers->{join}}, { user => 'tenant' };
    
    if (defined $self->json->{filters}->{di_id})
    {
	my $dirs = $self->db->resultset('DI'); 
	my $di_id = $self->json->{filters}->{di_id};

	$self->json->{filters}->{osf_id} = 
	{ -in => $dirs->search({ 'subquery.id' => $di_id,
                                 'tags.tag' => { -ident => 'me.di_tag' } },
			       { join => ['tags'], 
				 alias => 'subquery'})->get_column('osf_id')->as_query };
	delete $self->json->{filters}->{di_id};
    }

    $self->_check;
    $self->_map;
}


sub _get_free_ip {
    my $self = shift;
    my $nettop = nettop_n;
    my $netstart = netstart_n;

    my %ips = map { net_aton($_->ip) => 1 } 
    $self->db->resultset('VM')->all;

    while ($nettop-- > $netstart) {
        return net_ntoa($nettop) unless $ips{$nettop}
    }
    die "No free IP addresses";
}


1;

# di_version, di_name and di_id are nnot relationships: only available as output fields

__DATA__

storage         = me.storage
id              = me.id
name            = me.name
user_id         = me.user_id
user_name       = user.login
osf_id          = me.osf_id
osf_name        = osf.name
di_tag          = me.di_tag
blocked         = vm_runtime.blocked
expiration_soft = vm_runtime.vm_expiration_soft
expiration_hard = vm_runtime.vm_expiration_hard
state           = vm_runtime.vm_state
host_id         = vm_runtime.host_id
host            = host.name
host_name       = me.host_name
di_id           = vm_runtime.current_di_id
user_state      = vm_runtime.user_state
di_tag          = me.di_tag
ip              = me.ip
next_boot_ip    = vm_runtime.vm_address 
ssh_port        = vm_runtime.vm_ssh_port
vnc_port        = vm_runtime.vm_vnc_port
serial_port     = vm_runtime.vm_serial_port
tenant          = user.tenant_id
tenant_name     = tenant.name
creation_admin  = me.creation_admin
creation_date   = me.creation_date
next_boot_ip    = vm_runtime.vm_address 
ssh_port        = vm_runtime.vm_ssh_port
vnc_port        = vm_runtime.vm_vnc_port
serial_port     = vm_runtime.vm_serial_port
di_version      = me.di_version
di_name         = me.di_name
di_id           = me.di_id
