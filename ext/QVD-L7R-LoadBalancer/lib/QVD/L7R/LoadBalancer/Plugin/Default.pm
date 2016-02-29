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
    my $self = shift;
    my ($best_host, $best_cap);

    my $rs = rs(Host)->search({ backend           => 'true',
                                'runtime.blocked' => 'false',
                                'runtime.state'   => 'running' },
                              { distinct => 1,
                                join => [qw(runtime vms)],
                                '+select' => [ { count => 'vms.vm_id', -as => 'amount_of_vms' } ],
                                prefetch => ['runtime'] } );

    while (my $host = $rs->next) {
        my $id = $host->id;
        my $hrt = $host->runtime;
        my $vms = $host->get_column('amount_of_vms');
        my $ram = $hrt->usable_ram;
        my $cpu = $hrt->usable_cpu;

        my $cap = ($weight_ram * $ram + $weight_cpu * $cpu) / ($vms + 1) + rand($weight_random);
        DEBUG "Host $id, RAM: $ram, CPU: $cpu, VMs: $vms, per VM cap: $cap";

        if (not defined $best_cap or $best_cap < $cap) {
            $best_host = $id;
            $best_cap = $cap;
        }
    }

    unless (defined $best_host) {
        my $msg = "Unable to assign vm to host, there is no host available";
        ERROR $msg;
        croak $msg;
    }

    INFO "Best available host is $best_host (per VM capability: $best_cap)";
    $best_host;
}

1;
