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
use QVD::HTTPC;

my $node;

sub check_environment : Test(startup => 6) {
    ok(-f '/etc/qvd/node.conf',		'Existence of QVD configuration, node.conf');
    ok(-x '/usr/bin/qvd-noded.pl',	'QVD node installation');

    my $bridge = cfg('vm.network.bridge');
    ok($bridge,				'Bridge definition in node.conf');
    ok(!system("ip addr show $bridge"), "Existence of VM network bridge $bridge");

    my $nodename = cfg('nodename');
    my $noders = rs(Host)->search({name => $nodename});
    ok($nodename,			'Node name definition in node.conf');
    is($noders->count, 1, 		"Presence of node $nodename in the database");

    $node = $noders->first;
}

sub zz_start_node : Test(startup) {
    my $nodert = $node->runtime;
    my $orig_ts = $nodert->ok_ts;
    my $start_timeout = 10;
    system('/usr/bin/qvd-noded.pl start');
    while ($nodert->ok_ts == $orig_ts) {
	sleep 1;
	$nodert->discard_changes;
	$start_timeout-- or fail("Node didn't start"), last;
    }
}

sub aa_stop_node : Test(shutdown) {
    system('/usr/bin/qvd-noded.pl stop');
}

sub block_node : Test() {
    my $self = shift;
    warn $self->_check_connect;
    $node->runtime->block;
    warn $self->_check_connect;
    $node->runtime->unblock;
    warn $self->_check_connect;
}

sub _check_connect {
    my $httpc = new QVD::HTTPC('localhost:8443');
    $httpc->send_http_request('GET /qvd/list_of_vm');
    return $httpc->read_http_response();
}
