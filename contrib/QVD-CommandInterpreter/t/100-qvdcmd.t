#!/usr/bin/perl -wT
use strict;

use Test::Expect;
use Test::More tests => 16;
use File::Temp qw(tempdir);
use Proc::Background;

delete $ENV{PATH};

my $dir = tempdir( CLEANUP => 1 );
create_temp_conf($dir);



expect_run(
	command => "bin/qvdcmd -c $dir/qvdcmd.conf",
	prompt  => "\n> ",
	quit    => 'quit'
);

expect_send('version', "Send version");
expect_like(qr/^[0-9.]+/, "Version is a number");

expect_send('help', 'Send help');
expect_like(qr/^Commands:\n.*/m, 'Help received');

expect_send('badcmd', 'Send bad command');
expect_like(qr/ERROR: Unknown command/, 'Bad command recognized');

expect_send('', 'Send empty command');
expect_like(qr/\s*/, 'Empty output');

expect_send('socat /etc/passwd', "Test socat with non-allowed port");
expect_like(qr#ERROR: Port '/etc/passwd' is not allowed#, "Bad port is not allowed");

expect_send("socat $dir/testport99", "Test socat with inexistent port");
expect_like(qr#ERROR: Port '$dir/testport99' doesn't exist#, "Inexistent port is not allowed");


my $proc = Proc::Background->new("/usr/bin/socat", "-v", "-lf/tmp/socattest.log", "PTY,link=$dir/testport0,raw,echo=0,wait-slave", "system:$dir/testscript.sh,nofork");
sleep(1);
ok($proc && $proc->alive, "Start socat");

expect_send("socat $dir/testport0", "Test socat with simulated port");
expect_like(qr/socat test/, "Test data received");


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
echo
echo "> "
sleep 1
SCRIPTDATA
	close(SCRIPT);
	chmod 0755, "$dir/testscript.sh";

	return $dir;
}

