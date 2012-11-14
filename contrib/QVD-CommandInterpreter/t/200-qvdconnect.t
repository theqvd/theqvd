#!/usr/bin/perl -wT
use strict;

use Test::Expect;
use Test::More tests => 7;
use File::Temp qw(tempdir);
use Proc::Background;
my ($port_proc, $test_proc, $cmd_proc);

$SIG{__DIE__} = sub {
	my $msg = shift;
	warn $msg;
	cleanup();
};

$SIG{INT} = \&cleanup;
 
undef $ENV{PATH};
my $dir = tempdir( CLEANUP => 1 );
create_temp_conf($dir);


my $cmdport = int(rand(48000) + 16000);
my $socatport = int(rand(48000) + 16000);


$cmd_proc = Proc::Background->new("bin/qvdcmd", "--listen", $cmdport, "--config", "$dir/qvdcmd.conf");
sleep(1);
ok($cmd_proc && $cmd_proc->alive, "Start qvdcmd server on port $cmdport");




test_cmd("--interpreter localhost:$cmdport --getversion", qr/\d+/, "Test getversion");
test_cmd("--interpreter localhost:$cmdport --gethelp"   , qr/^Commands/, "Test gethelp");

$port_proc = Proc::Background->new("/usr/bin/socat", "-lf/tmp/socattest2.log", "PTY,link=$dir/testport0,raw,echo=0,wait-slave", "system:$dir/testscript.sh,nofork");
sleep(1);
ok($port_proc && $port_proc->alive, "Start socat for simulated port");


$test_proc = Proc::Background->new("/usr/bin/socat", "-lf/tmp/socattest_recv.log", "tcp-listen:$socatport,nonblock,reuseaddr,retry=5", "open:$dir/testoutput,create,trunc,ignoreeof");
sleep(1);
ok($test_proc && $test_proc->alive, "Start socat for reception port on port $socatport");




test_cmd("--daemonize --interpreter localhost:$cmdport --log-socat --serial $dir/testport0 --remote localhost:$socatport", qr/Remote socat started/, "Serial interconnect");

my $timeout = 10;
my $received_text;
while($timeout-- && !$received_text) {
	if ( -f "$dir/testoutput" ) {
		open(OUT, '<', "$dir/testoutput")  or die "Can't open $dir/testoutput:$ !";
		$received_text = <OUT>;
		chomp $received_text if ($received_text);
		close(OUT);
	}
	sleep 1;
}

ok($received_text =~ /socat test/, "Received text '$received_text' matches test pattern");






cleanup();

sub test_cmd {
	my ($args, $regex, $message) = @_;

	my $ret = `bin/qvdconnect $args 2>&1`;
	chomp $ret;
	ok($ret =~ /$regex/, $message);
}


sub cleanup {
	foreach my $proc ($port_proc, $test_proc, $cmd_proc) {
		$proc->die if ($proc);
	}
}

sub create_temp_conf {
	my $dir = shift;

	open(CONF, ">", "$dir/qvdcmd.conf") or die "Can't create config $dir/qvdcmd.conf: $!";
	print CONF <<CONFIG;
{
	socat => '/usr/bin/socat',
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

