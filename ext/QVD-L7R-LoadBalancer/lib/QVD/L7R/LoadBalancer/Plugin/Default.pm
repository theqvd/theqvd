package QVD::L7R::LoadBalancer::Plugin::Default;

use strict;
use warnings;

use QVD::DB::Simple;
use QVD::Config;
use QVD::Log;

use parent 'QVD::L7R::LoadBalancer::Plugin';

my $ram	   = cfg('l7r.loadbalancer.plugin.default.weight.ram');
my $cpu	   = cfg('l7r.loadbalancer.plugin.default.weight.cpu');
my $random = cfg('l7r.loadbalancer.plugin.default.weight.random');

sub get_free_host {
    my $conditions = { backend => 'true',
		       blocked => 'false',
		       state   => 'running' };

    my $attr = { columns  => 'host_id', 
		 join     => 'host',
		 order_by => \"$ram*usable_ram+$cpu*usable_cpu+$random*1000*random() DESC"};

    my $hrt = rs(Host_Runtime)->search($conditions, $attr)->first;
    return $hrt->host_id;
}

1;
