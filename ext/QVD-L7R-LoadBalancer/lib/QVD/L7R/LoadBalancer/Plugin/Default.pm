package QVD::L7R::LoadBalancer::Plugin::Default;

use strict;
use warnings;
use Carp;

use QVD::DB::Simple;
use QVD::Config;
use QVD::Log;

use parent 'QVD::L7R::LoadBalancer::Plugin';

my $weight_ram	  = cfg('l7r.loadbalancer.plugin.default.weight.ram',   1000);
my $weight_cpu	  = cfg('l7r.loadbalancer.plugin.default.weight.cpu',   1000);
my $weight_random = cfg('l7r.loadbalancer.plugin.default.weight.random', 100);

sub get_free_host {
    my $conditions = { backend => 'true',
		       blocked => 'false',
		       state   => 'running' };

    my %host;

    for my $hrt (rs(Host_Runtime)->search({ backend => 'true',
                                            blocked => 'false',
                                            state => 'running' })) {
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

    my $best;
    for my $id (keys %host) {
        my $host = $host{$id};
        my $vms = ++($host->{vms});
        my $cap = $weight_ram * $host->{ram} / $vms + $weight_cpu * $host->{cpu} / $vms + rand $weight_random;
        $host->{cap} = $cap;
        if (!defined $best or $host{$best}{cap} < $cap) {
            $best = $id;
        }
    }

    # TODO: allow to set limits for the number of virtual machines
    # running on any host and keep (reintroduce) realtime usage of RAM
    # and CPU

    return $best if defined $best;


    my $msg = "Unable to assign vm to host, there is no host available";
    ERROR $msg;
    croak $msg;
}

1;
