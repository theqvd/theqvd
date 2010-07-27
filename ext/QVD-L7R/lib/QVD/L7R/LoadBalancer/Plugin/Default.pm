package QVD::L7R::LoadBalancer::Plugin::Default;

use strict;
use warnings;

use QVD::DB::Simple;
use QVD::Log;

use parent 'QVD::L7R::LoadBalancer::Plugin';

sub get_free_host {
    my @hosts = map $_->id, rs(Host)->search_related('runtime', { backend 	  => 'true',
								'runtime.blocked' => 'false',
								'runtime.state'   => 'running' });
    @hosts > 0 ? $hosts[rand @hosts] : undef;
}

1;
