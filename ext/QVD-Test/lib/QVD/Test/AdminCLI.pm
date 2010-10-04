package QVD::Test::SingleServer;
use parent qw(QVD::Test);

use lib::glob '*/lib';

use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN {
    $QVD::Config::USE_DB = 0;
}

use QVD::Config;
use QVD::DB::Simple;
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTPC;
use QVD::Test::Mock::AdminCLI;
use MIME::Base64 qw(encode_base64);

my $node;
my $noded_executable;

sub check_environment : Test(startup => 6) {
    # FIXME better to use something derived from $0
    $noded_executable = 'QVD-Test/bin/qvd-noded.sh';

    ok(-f '/etc/qvd/node.conf',		'Existence of QVD configuration, node.conf');
    ok(-x $noded_executable,		'QVD node installation');

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
    my $orig_ts = $nodert->ok_ts || 0;
    my $start_timeout = 10;
    system($noded_executable, 'start');
    while (!defined $nodert->ok_ts or $nodert->ok_ts == $orig_ts) {
	sleep 1;
	$nodert->discard_changes;
	$start_timeout-- or fail("Node didn't start"), last;
    }
}

sub aa_stop_node : Test(shutdown) {
    my $nodert = $node->runtime;
    system($noded_executable, 'stop');
    my $stop_timeout = 10;
    while ($nodert->state ne 'stopped') {
	sleep 1;
	$nodert->discard_changes;
	$stop_timeout-- or fail("Node didn't stop"), last;
    }
}

sub user_add : Test {
    $adm = new QVD::Test::Mock::AdminCLI;
    $adm->cmd_user_add("login=qvd$i", "password=qvd") for my $i (0..9);
    $adm->cmd_user_add("login=xvd$i", "password=qvd") for my $i (0..9);
    $adm->cmd_user_list();
    $user_list = $adm->table_body;
    use Data::Dumper;
    print Dumper $user_list;
}

sub check_l7r_ping : Test(2) {
    my $httpc = new QVD::HTTPC('localhost:8443', SSL => 1, SSL_verify_callback => sub {1});
    $httpc or fail('Cannot connect to L7R');

    $httpc->send_http_request(GET => '/qvd/ping');
    my @response = $httpc->read_http_response();
    is($response[0], 200, 	'L7R should respond to ping');
}

sub block_node : Test(3) {
    my $self = shift;
    is($self->_check_connect,0+HTTP_OK,			'Connecting before block should work');
    $node->runtime->block;
    is($self->_check_connect,0+HTTP_SERVICE_UNAVAILABLE,'Connecting after block should give 503');
    $node->runtime->unblock;
    is($self->_check_connect,0+HTTP_OK,			'Connecting after unblock should work');
}

sub _check_connect {
    my $httpc = QVD::HTTPC->new('localhost:8443', SSL => 1, SSL_verify_callback => sub {1});
    die "connect" if (!$httpc);
    my $auth = encode_base64('qvd:qvd', '');
    $httpc->send_http_request(GET => '/qvd/list_of_vm', headers => ["Authorization: Basic $auth",
								    "Accept: application/json"]);
    return ($httpc->read_http_response())[0];
}

1;
