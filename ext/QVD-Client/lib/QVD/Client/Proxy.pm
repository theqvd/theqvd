package QVD::Client::Proxy;

use strict;
use warnings;

use IO::Socket::Forwarder qw(forward_sockets);
use Proc::Background;

my $WINDOWS = ($^O eq 'MSWin32');

sub new {
    my $class = shift;
    my %opts = @_;
    my $self = {
	proxy_options => \%opts,
    };
    bless $self, $class;
}

sub run {
    my $self = shift;
    my $socket = shift;

    my @cmd;
    if ($WINDOWS) {
	push @cmd, "C:/WINDOWS/system32/nxproxy.exe";
    } else {
	push @cmd, "nxproxy";
    }
    push @cmd, qw(-S localhost:40);
    push @cmd, map { $_."=".$self->{proxy_options}{$_} } 
			    keys %{$self->{proxy_options}};
    warn 'Going to exec ',@cmd;
    $self->{process} = Proc::Background->new(@cmd);

    my $ll = IO::Socket::INET->new(LocalPort => 4040,
	ReuseAddr => 1,
	Listen => 1);

    my $s1 = $ll->accept()
	or die "connection from nxproxy failed";
    undef $ll; # close the listening socket
    if ($WINDOWS) {
	my $nonblocking = 1;
	ioctl ($s1, 0x8004667e, \$nonblocking);
    }

    my $s2 = $socket;
    forward_sockets($s1, $s2);
}

1;
