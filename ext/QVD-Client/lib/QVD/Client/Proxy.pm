package QVD::Client::Proxy;

use strict;
use warnings;

use IO::Socket::Forwarder qw(forward_sockets);
use Proc::Background;
use File::Spec;

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
    my $httpc = shift;

    my @cmd;
    if ($WINDOWS) {
	push @cmd, $ENV{QVDPATH}."/nxproxy.exe";
    } else {
	push @cmd, "nxproxy";
    }

    my %o = ();

    if ($WINDOWS) {
	$o{"nx/nx,root"} = $ENV{APPDATA}.'/.qvd';
    }  
    
    $o{media} = 4713 if $self->{audio};
    if ($self->{printing}) {
	if ($WINDOWS) {
	    $o{smb} = 139;
	} else {
	    $o{cups} = 631;
	}
    }

    @o{keys %{$self->{extra}}} = values %{$self->{extra}};
    push @cmd, ("-S");
    push @cmd, (map "$_=$o{$_}", keys %o);

    push @cmd, qw(localhost:40);

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

    forward_sockets($local_socket, $httpc->get_socket,
		    buffer_2to1 => $httpc->read_buffered);
		    # debug => 1);
}

1;
