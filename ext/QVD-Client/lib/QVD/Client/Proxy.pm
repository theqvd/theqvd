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
	audio => delete $opts{audio},
	extra => delete $opts{extra},
	printing => delete $opts{printing},
    };
    bless $self, $class;
}

sub run {
    my $self = shift;
    my $remote_socket = shift;

    my @cmd;
    if ($WINDOWS) {
	push @cmd, "C:\\Archivos de programa\\QVD\\nxproxy.exe";
    } else {
	push @cmd, "nxproxy";
    }
    push @cmd, qw(-S localhost:40);

    my %o = ();
    $o{media} = 4713 if $self->{audio};
    if ($self->{printing}) {
	if ($WINDOWS) {
		$o{smb} = 139;
	} else {
	    $o{cups} = 631;
	}
    }
    @o{keys %{$self->{extra}}} = values %{$self->{extra}};

    push @cmd, (map "$_=$o{$_}", keys %o);

    $self->{process} = Proc::Background->new(@cmd);

    my $ll = IO::Socket::INET->new(LocalPort => 4040,
	ReuseAddr => 1,
	Listen => 1);

    my $local_socket = $ll->accept()
	or die "connection from nxproxy failed";
    undef $ll; # close the listening socket
    if ($WINDOWS) {
	my $nonblocking = 1;
	ioctl ($local_socket, 0x8004667e, \$nonblocking);
    }

    forward_sockets($local_socket, $remote_socket);
}

1;
