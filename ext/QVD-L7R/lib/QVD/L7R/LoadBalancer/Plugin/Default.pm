package QVD::L7R::LoadBalancer::Plugin::Default;

use strict;
use warnings;

use QVD::DB::Simple;
use QVD::Log;

use parent 'QVD::L7R::LoadBalancer::Plugin';

sub get_free_host {
    my @hosts = map $_->id, rs(Host)->all;
    $hosts[rand @hosts];
}

1;
