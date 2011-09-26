use Test::More qw(no_plan);
use X11::GUITest qw(:ALL);
use Getopt::Long;
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

my %options = (); 
$options{u}='nicolas.arenas'.'@'.'qindel.com';
$options{p}="B6nDrrmt";
$options{h}="qvddemo";
GetOptions (\%options, 'u=s','p=s','h=s');


my $client_executable = 'QVD-Test/bin/qvd-client.sh';
	#die("QVD Window already open") if FindWindowLike('^QVD$');		

ok(StartApp($client_executable),"Starting client");

my ($w) = WaitWindowViewable('^QVD$');
ok($w,"Client window appeared");

SetInputFocus($w);
SendKeys("$options{u}\t$options{p}\t$options{h}\n");

my ($cert_w) = WaitWindowViewable('^Invalid Certificate$');
ok($cert_w,"Certificate verification");
SendKeys("\n");

ok(!WaitWindowHidden($w, 60),		"Client window disappeared");

my ($nxw) = WaitWindowViewable('^QVD$');
ok($nxw && ($w != $nxw),		"nxagent window appeared");

sleep 10;

# ctrl-alt-f1 terminates session
SendKeys("^(%(t))");

ok(WaitWindowClose($nxw, 60),		"nxagent window closed");

sleep 10;

ok(IsWindowViewable($w),		"Client window appeared");

SetInputFocus($w);
SendKeys("$options{u}\t$options{p}\tnoexiste\n");
ok(WaitWindowViewable('Connection error'), "Connection to server fails");
SendKeys("\n");

SetInputFocus($w);
SendKeys("$options{u}\tnoexiste\t$options{h}\n");
ok(WaitWindowViewable('Connection error'), "Invalid password");
SendKeys("\n");

SetInputFocus($w);
SendKeys("noexiste\t$options{p}\t$options{h}\n");
ok(WaitWindowViewable('Connection error'), "Invalid username");
SendKeys("\n");

kill 'TERM', GetPIDForWindow($w);
ok(WaitWindowClose($w, 60),		"Waiting for client window to close");

