package QVD::Test::SingleServer;
use parent qw(QVD::Test);

use strict;
use warnings;

use Test::More qw(no_plan);
use QVD::Config;
use QVD::DB::Simple;

$bridge 	= cfg('vm.network.bridge');
$nodename 	= cfg('nodename');

sub check_environment : Test(startup => 3) {
    ok(-f '/etc/qvd/node.conf',		'Existence of QVD configuration, node.conf');
    ok(!system("ip addr show $bridge"), "Existence of VM network bridge $bridge");

    is(rs(Host)->find({name => $nodename})->count, 1, 
					"Presence of node $nodename in the database");

}

sub zz_start_node : Test(startup) {
    system('/etc/init.d/qvd-node start');
}

sub aa_stop_node : Test(shutdown) {
    system('/etc/init.d/qvd-node stop');
}

sub block_node : Test() {
    warn "Hello World!";
}
