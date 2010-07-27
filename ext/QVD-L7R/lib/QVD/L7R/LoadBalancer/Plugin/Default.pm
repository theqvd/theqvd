package QVD::L7R::LoadBalancer::Plugin::Default;

use strict;
use warnings;

use QVD::DB::Simple;
use QVD::Log;

use parent 'QVD::L7R::LoadBalancer::Plugin';

sub get_free_host {
    my @hosts = map $_->host_id, rs(Host_Runtime)->search({state   => 'running',
							   blocked => 'false'});
    @hosts > 0 ? $hosts[rand @hosts] : undef;
}

1;
