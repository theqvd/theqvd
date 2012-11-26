#!/usr/bin/perl -T
use strict;

use Test::Expect;
use Test::More tests => 12;
use File::Temp qw(tempdir);
use Proc::Background;
use POSIX;
my ($port_proc, $test_proc, $cmd_proc, $cmd_proc2, $pppd_proc);
my ($pppd_pid);

$SIG{__DIE__} = sub {
	my $msg = shift;
	warn $msg;
	cleanup();
};

$SIG{INT} = \&cleanup;
 
undef $ENV{PATH};
my $dir = tempdir( CLEANUP => 1 );
create_temp_conf($dir);

my $random = int(rand(48000) + 16000);
my $cmdport = $random;
my $socatport = $random + 1;
my $cmdport2 = $random + 2;
my $pppdport = $random + 3;
my $pppd = '/usr/sbin/pppd';
my $localip = '172.31.31.23';
my $remoteip = '172.31.31.27';

$cmd_proc = Proc::Background->new("bin/qvdcmd", "--listen", $cmdport, "--config", "$dir/qvdcmd.conf");
sleep(0.2);
ok($cmd_proc && $cmd_proc->alive, "Start qvdcmd server on port $cmdport");




test_cmd("--interpreter localhost:$cmdport --getversion", qr/\d+/, "Test getversion");
test_cmd("--interpreter localhost:$cmdport --gethelp"   , qr/^Commands/, "Test gethelp");

$port_proc = Proc::Background->new("/usr/bin/socat", "-lf/tmp/socattest2.log", "PTY,link=$dir/testport0,raw,echo=0,wait-slave", "system:$dir/testscript.sh,nofork");
sleep(0.2);
ok($port_proc && $port_proc->alive, "Start socat for simulated port");


$test_proc = Proc::Background->new("/usr/bin/socat", "-lf/tmp/socattest_recv.log", "tcp-listen:$socatport,nonblock,reuseaddr,retry=5", "open:$dir/testoutput,create,trunc,ignoreeof");
sleep(0.2);
ok($test_proc && $test_proc->alive, "Start socat for reception port on port $socatport");

test_cmd("--daemonize --interpreter localhost:$cmdport --log-socat --serial $dir/testport0 --remote localhost:$socatport", qr/Remote socat started/, "Serial interconnect");

my $timeout = 30;
my $received_text;
while($timeout-- && !$received_text) {
	if ( -f "$dir/testoutput" ) {
		open(OUT, '<', "$dir/testoutput")  or die "Can't open $dir/testoutput:$ !";
		$received_text = <OUT>;
		chomp $received_text if ($received_text);
		close(OUT);
		last if ($received_text =~ /socat test/);
	}
	sleep 0.2;
}

ok($received_text =~ /socat test/, "Received text '$received_text' matches test pattern");

# horrible test
SKIP: {
    skip "Must run as root to test pppd", 5 unless ( geteuid() == 0 );
    skip "No pppd in $pppd", 5 unless (-x $pppd );

    use Net::Ping;

    # New command interpreter
    $cmd_proc2 = Proc::Background->new("bin/qvdcmd", "--listen", $cmdport2, "--config", "$dir/qvdcmd.conf");
    sleep(0.2);
    ok($cmd_proc2 && $cmd_proc2->alive, "Start qvdcmd server on port $cmdport2");

    test_cmd("--interpreter localhost:$cmdport2 --getversion", qr/\d+/, "Test getversion");

    # Client socat to run pppd if remote connection is alive
    $pppd_proc = Proc::Background->new("/usr/bin/socat", "-lf/tmp/socatppp_recv.log", "tcp-listen:$pppdport,nonblock,reuseaddr,retry=5", "exec:$pppd notty noauth lcp-echo-interval 0 asyncmap 0 nodefaultroute nodetach $localip\\:$remoteip");
    sleep(0.2);
    ok($pppd_proc && $pppd_proc->alive, "Start socat for reception of pppd");

    $pppd_pid = fork();
    if ($pppd_pid eq 0) {
	# child
	test_cmd("--daemonize --interpreter localhost:$cmdport2 --remote localhost:$pppdport --log-socat --pppd \"notty noauth lcp-echo-interval 0 asyncmap 0 nodefaultroute nodetach\"", qr/Remote pppd started/, "pppd interconnect");
	# should not return
	exit(0);
    } 
    sleep(2);
    my $p = Net::Ping->new();

    my $timeout = 30;
    my $ping_alive;
    while($timeout-- && !$ping_alive) {
	$ping_alive = $p->ping($remoteip);
	sleep (0.2);
    }
    ok($p->ping($remoteip), "Ping to $remoteip");
    ok($p->ping($localip), "Ping to $localip");
}



cleanup();

sub test_cmd {
	my ($args, $regex, $message) = @_;

	my $ret = `bin/qvdconnect $args 2>&1`;
	chomp $ret;
	like($ret, qr/$regex/, $message);
}


sub cleanup {
#        diag( "pppd_pid is $pppd_pid");
	kill 15, $pppd_pid if ($pppd_pid);
	sleep(0.2);
	kill 9, $pppd_pid if ($pppd_pid);	
	foreach my $proc ($port_proc, $test_proc, $cmd_proc, $cmd_proc2, $pppd_proc) {
		$proc->die if ($proc);
	}
}

sub create_temp_conf {
	my $dir = shift;

	open(CONF, ">", "$dir/qvdcmd.conf") or die "Can't create config $dir/qvdcmd.conf: $!";
	print CONF <<CONFIG;
{
	socat => '/usr/bin/socat',
	pppd  => '/usr/sbin/pppd',
	allowed_ports => [ qr#^$dir/testport\\d+# ]
};
CONFIG
	close(CONF);

	open(SCRIPT, ">", "$dir/testscript.sh") or die "Can't create script $dir/testscript.sh: $!";
	print SCRIPT <<SCRIPTDATA;
#!/bin/bash
echo socat test
/bin/sleep 1
SCRIPTDATA
	close(SCRIPT);
	chmod 0755, "$dir/testscript.sh";

	return $dir;
}

sub untaint {
	my $arg = shift;
	$arg =~ /(.*)/x;
	return $1;
}
