package QVD::Test::SingleServer;
use parent qw(QVD::Test);

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    $QVD::Config::USE_DB = 0;
}

use QVD::Config;
use QVD::DB::Simple;

my $bridge 	= cfg('vm.network.bridge');
my $nodename 	= cfg('nodename');

sub check_environment : Test(startup => 6) {
    ok(-f '/etc/qvd/node.conf',		'Existence of QVD configuration, node.conf');
    ok(-f '/usr/bin/qvd-noded.pl',	'QVD node installation');

    ok($bridge,				'Bridge configuration');
    ok(!system("ip addr show $bridge"), "Existence of VM network bridge $bridge");

    ok($nodename,			'Node name configuration')
    is(rs(Host)->find({name => $nodename})->count, 1, 
					"Presence of node $nodename in the database");

}

sub zz_start_node : Test(startup) {
    system('/usr/bin/qvd-noded.pl start');
}

sub aa_stop_node : Test(shutdown) {
    system('/usr/bin/qvd-noded.pl stop');
}

sub block_node : Test() {
    warn "Hello World!";
}
