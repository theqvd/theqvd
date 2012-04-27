package QVD::Test::SingleServer;
use parent qw(QVD::Test);

use lib::glob '*/lib';

use strict;
use warnings;

use Test::More;

BEGIN {
    $QVD::Config::USE_DB = 1;
}

use QVD::Config;
use QVD::DB::Simple;
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTPC;
use MIME::Base64 qw(encode_base64);

my $node;
my $hkd_executable;
my $l7r_executable;

my @required_properties = qw(
	command.brctl
	command.dhcpd
	command.ebtables
	command.ifconfig
	command.iptables
	command.kvm
	command.kvm-img
	command.lxc-create
	command.lxc-destroy
	command.lxc-start
	command.lxc-stop
	command.lxc-wait
	command.mount
	command.tar
	command.umount
	command.unionfs-fuse
	database.host
	database.name
	database.password
	database.user
	internal.hkd.agent.cluster_monitor.delay
	internal.hkd.agent.command_handler.delay
	internal.hkd.agent.rpc.retry.count
	internal.hkd.agent.rpc.retry.delay
	internal.hkd.agent.rpc.timeout
	internal.hkd.agent.ticker.delay
	internal.hkd.agent.vm_command_handler.delay
	internal.hkd.cluster.node.timeout
	internal.hkd.debugger.run
	internal.hkd.debugger.socket
	internal.hkd.dhcpdhandler.wait_on_run_error
	internal.hkd.lock.delay
	internal.hkd.lock.path
	internal.hkd.lock.retries
	internal.hkd.lxc.killer.destroy_lxc.timeout
	internal.hkd.lxc.killer.retries
	internal.hkd.lxc.killer.umount.timeout
	internal.hkd.max_heavy
	internal.hkd.vmhandler.timeout.on_state.stopping
	internal.hkd.vmhandler.vma_monitor.delay
	internal.l7r.poll_time.vm
	internal.l7r.poll_time.x
	internal.l7r.retry.x_start
	internal.l7r.short_session
	internal.l7r.timeout.takeover
	internal.l7r.timeout.vma
	internal.l7r.timeout.vm_start
	internal.l7r.timeout.x_start
	internal.nxagent.display
	internal.vm.debug.enable
	internal.vm.lxc.conf.extra
	internal.vm.monitor.redirect
	internal.vm.network.device.prefix
	internal.vm.network.dhcp-hostsfile
	internal.vm.network.firewall.enable
	internal.vm.port.ssh
	internal.vm.port.vma
	l7r.address
	l7r.auth.plugins
	l7r.port
	l7r.ssl.cert
	l7r.ssl.key
	l7r.use_ssl
	model.user.login.case-sensitive
	nodename
	path.cgroup
	path.serial.captures
	path.ssl.certs
	path.storage.basefs
	path.storage.homefs
	path.storage.homes
	path.storage.images
	path.storage.overlayfs
	path.storage.overlays
	path.storage.rootfs
	vm.hypervisor
	vm.kvm.home.drive.index
	vm.kvm.virtio
	vm.lxc.unionfs.bind.ro
	vm.lxc.unionfs.type
	vm.network.bridge
	vm.network.domain
	vm.network.gateway
	vm.network.ip.start
	vm.network.netmask
	vm.network.use_dhcp
	vm.overlay.persistent
	vm.serial.capture
	vm.serial.redirect
	vm.vnc.opts
	vm.vnc.redirect
);

sub check_environment : Test(startup => 98) {
    # FIXME better to use something derived from $0
    $hkd_executable = '/etc/init.d/qvd-hkd';
    $l7r_executable = '/etc/init.d/qvd-l7r';


    ok(-f '/etc/qvd/node.conf',		'Existence of QVD configuration, node.conf');
    ok(-x $hkd_executable,		'QVD HKD installation');
    ok(-x $l7r_executable,		'QVD L7R installation');

    my $bridge = cfg('vm.network.bridge');
    ok($bridge,				'Bridge definition in node.conf');
    ok(!system("ip addr show $bridge > /dev/null"), "Existence of VM network bridge $bridge");

    foreach my $param (@required_properties) {
        my $val;
	eval {
            $val = cfg($param);
        };
        if ( $@ ) {
            fail((split(/\n/, $@))[0]);
        } else {
            ok(1, "Required property $param exists");
        }
    }

    my $nodename = cfg('nodename');
    my $noders = rs(Host)->search({name => $nodename});
    ok($nodename,			'Node name definition in node.conf');
    is($noders->count, 1, 		"Presence of node $nodename in the database");

    $node = $noders->first;
}

sub zz_start_hkd : Test(startup) {
    my $nodert = $node->runtime;
    my $orig_ts = $nodert->ok_ts || 0;
    my $start_timeout = 10;
    system($hkd_executable, 'start');
    while (!defined $nodert->ok_ts or $nodert->ok_ts eq $orig_ts) {
    	sleep 1;
	    $nodert->discard_changes;
    	$start_timeout-- or fail("HKD didn't start"), last;
    }
}

sub aa_stop_hkd : Test(shutdown) {
    my $nodert = $node->runtime;
    system($hkd_executable, 'stop');
    my $stop_timeout = 10;

    while ($nodert->state ne 'stopped') {
	    sleep 1;
    	$nodert->discard_changes;
	    $stop_timeout-- or fail("HKD didn't stop"), last;
    }
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
    my $auth = encode_base64('qvd0:qvd', '');
    $httpc->send_http_request(GET => '/qvd/list_of_vm', headers => ["Authorization: Basic $auth",
								    "Accept: application/json"]);
    return ($httpc->read_http_response())[0];
}

1;
