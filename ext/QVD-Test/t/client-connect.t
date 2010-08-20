use Test::More qw(no_plan);
use X11::GUITest qw(:ALL);
use strict;
use warnings;

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

my $client_executable = 'QVD-Test/bin/qvd-client.sh';
die("QVD Window already open") if FindWindowLike('^QVD$');		

ok(StartApp($client_executable),	"Starting client");

my ($w) = WaitWindowViewable('^QVD$');
ok($w,					"Client window appeared");

SetInputFocus($w);
SendKeys("jonix\tjoni\tlocalhost\n");

ok(!WaitWindowHidden($w, 60),		"Client window disappeared");

my ($nxw) = WaitWindowViewable('^QVD$');
ok($nxw,				"nxagent window appeared");

sleep 2;

# ctrl-alt-f1 terminates session
SendKeys("^(%(t))");

ok(WaitWindowClose($nxw, 60),		"nxagent window closed");

sleep 2;

ok(IsWindowViewable($w),		"Client window appeared");

SetInputFocus($w);
SendKeys("noexiste\tnoexiste\tlocalhost\n");
ok(WaitWindowViewable('Connection error'), "Invalid user/password");
SendKeys("\n");

kill 'TERM', GetPIDForWindow($w);
ok(WaitWindowClose($w, 60),		"Waiting for client window to close");
