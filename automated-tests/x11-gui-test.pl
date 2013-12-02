#!/usr/lib/qvd/bin/perl

use strict;
use warnings;
#use lib '/usr/lib/qvd/lib/perl5/site_perl/5.14.2/x86_64-linux-thread-multi';
use lib '/usr/lib/perl5';

use Test::More qw(no_plan);
use X11::GUITest qw(:ALL);
use Getopt::Long;

my $ts = time;
my $waittime = 180;

sub WaitWindowHidden {
    my ($w, $timeout) = @_;
    $timeout ||= 5;
    sleep 1 while (IsWindowViewable($w) && $timeout-- > 0);
    IsWindowViewable($w);
}

sub GetPIDForWindow {
    my $w = shift;
    my @net_wm_pid = split / /, `xprop -id $w _NET_WM_PID`;
    $net_wm_pid[2];
}

GetOptions \my %options, 'u=s','p=s','h=s' or die 'getoptions';

my $client_executable = '/usr/lib/qvd/bin/qvd-gui-client.pl';

ok(StartApp($client_executable),"Starting client");

my ($w) = WaitWindowViewable('^QVD$');
ok($w,"Client window appeared");
system "xwd -root >/root/cap-$ts-1";

SetInputFocus($w);
sleep 1;
SendKeys("$options{u}"); SendKeys ("\t$options{p}"); SendKeys ("\t$options{h}\n");

my ($cert_w) = WaitWindowViewable('^Invalid Certificate$');
ok($cert_w,"Certificate verification");
system "xwd -root >/root/cap-$ts-2";
SendKeys("\n");

ok(!WaitWindowHidden($w, $waittime),		"Client window disappeared");

my ($nxw) = WaitWindowViewable('^QVD$');
ok($nxw && ($w != $nxw),		"nxagent window appeared");
system "xwd -root >/root/cap-$ts-3";

sleep 10;
SendKeys("^(%(t))");    # ctrl-alt-f1 terminates session
ok(WaitWindowClose($nxw, $waittime),		"nxagent window closed");

sleep 10;
ok(IsWindowViewable($w),		"Client window appeared");
system "xwd -root >/root/cap-$ts-4";

kill 'TERM', GetPIDForWindow($w);
## we're getting the following in suse:
## perl: xcb_io.c:182: process_responses: Assertion `((int) (((dpy->last_request_read)) - ((dpy->request))) <= 0)' failed.
## so I guess it's just a matter of:
system 'pkill -f qvd-gui-client';
ok(WaitWindowClose($w, $waittime),		"Waiting for client window to close");
system "xwd -root >/root/cap-$ts-5";
