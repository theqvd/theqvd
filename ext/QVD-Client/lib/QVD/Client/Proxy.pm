package QVD::Client::Proxy;

use strict;
use warnings;

use QVD::Config;
use IO::Socket::Forwarder qw(forward_sockets);
use Proc::Background;

sub new {
    my $class = shift;
    my $socket = shift;
    my $self = {
	socket => $socket,
    };
    bless $self, $class;
}

sub run {
    my $self = shift;

    my @cmd;
    if ($^O eq 'linux') {
	@cmd= qw(nxproxy -S localhost:40 media=4713);
    } else {	
	@cmd = qw(C:/WINDOWS/system32/nxproxy.exe -S localhost:40 media=4713 kbtype=pc105/es client=windows);
    }
    my $proc1 = Proc::Background->new(@cmd);

    my $ll = IO::Socket::INET->new(LocalPort => 4040,
	ReuseAddr => 1,
	Listen => 1);

    my $s1 = $ll->accept()
	or die "connection from nxproxy failed";
    undef $ll; # close the listening socket

    my $s2 = $self->{socket};
    if ($^O eq 'MSWin32'){
	my $nonblocking = 1;
	ioctl ($s1, 0x8004667e, \$nonblocking);
    }
    forward_sockets($s1, $s2); #, debug => 1);
}

1;
