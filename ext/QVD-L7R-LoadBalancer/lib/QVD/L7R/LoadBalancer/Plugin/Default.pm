package QVD::L7R::LoadBalancer::Plugin::Default;

use strict;
use warnings;
use Carp;

use QVD::DB::Simple;
use QVD::Config;
use QVD::Log;

use parent 'QVD::L7R::LoadBalancer::Plugin';

my $weight_ram    = cfg('l7r.loadbalancer.plugin.default.weight.ram',    0) // 1000;
my $weight_cpu    = cfg('l7r.loadbalancer.plugin.default.weight.cpu',    0) // 1000;
my $weight_random = cfg('l7r.loadbalancer.plugin.default.weight.random', 0) // 100;

sub get_free_host {
    my %host;

    for my $hrt (rs(Host_Runtime)->search({ 'host.backend' => 'true',
                                            blocked => 'false',
                                            state => 'running' },
                                            { join => 'host' })) {
        my $id = $hrt->host_id;
        $host{$id} =  { ram => $hrt->usable_ram,
                        cpu => $hrt->usable_cpu };
    }

    for my $vms (rs(VM_Runtime)->search(undef,
                                        { select   => ['host_id', { count => 'vm_id'}],
                                          as       => ['host_id', 'vm_count'],
                                          group_by => ['host_id'] })) {
        my $id = $vms->host_id;
        $host{$id}{vms} = $vms->get_column('vm_count') if defined $id;
    }

    for my $id (keys %host) {
        $host{$id}{cap} =
            $weight_ram * $host->{ram} / ($host->{vms} + 1) +
            $weight_cpu * $host->{cpu} / ($host->{vms} + 1) +
            rand $weight_random;
    }

    my $best = (
        sort { $host{$a}{cap} <=> $host{$b}{cap} }
        keys %host
    )[-1];

    # TODO: allow to set limits for the number of virtual machines
    # running on any host and keep (reintroduce) realtime usage of RAM
    # and CPU

    if (defined $best) {
        $host->{$best}{vms}++;
        return $best;
    }


    my $msg = "Unable to assign vm to host, there is no host available";
    ERROR $msg;
    croak $msg;
}

1;
