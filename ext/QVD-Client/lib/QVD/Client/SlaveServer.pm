package QVD::Client::SlaveServer;

use strict;
use warnings;

BEGIN {
    @QVD::Config::Core::FILES = ( ($ENV{HOME} || $ENV{APPDATA}).'/.qvd/qvd-client-slaveserver.conf' );
}

use QVD::Config::Core qw(core_cfg set_core_cfg);
use File::Spec;
use IO::Select;

our $WINDOWS;

BEGIN {
    $WINDOWS = ($^O eq 'MSWin32');

    my $user_dir = File::Spec->rel2abs($WINDOWS
        ? File::Spec->join($ENV{APPDATA}, 'QVD')
        : File::Spec->join((getpwuid $>)[7] // $ENV{HOME}, '.qvd'));
    mkdir $user_dir;

    set_core_cfg('client-slaveserver.log.filename', File::Spec->join($user_dir, 'qvd-client-slaveserver.log'))
        unless defined core_cfg('client-slaveserver.log.filename', 0);
    $QVD::Log::DAEMON_NAME = 'client-slaveserver';

	$SIG{PIPE} = sub { die "SIGPIPE"; };

}

our $VERSION = '3.5';

use QVD::Log;
use QVD::HTTP::Headers qw(header_eq_check header_lookup);
use QVD::HTTP::StatusCodes qw(:all);
use QVD::HTTPD;
use File::Spec;
use URI::Split qw(uri_split);
use URI;
use QVD::Client::SlaveServer::Nsplugin;
use base 'QVD::HTTPD::INET';
use QVD::Client::USB::USBIP;


my $socat = "/usr/bin/socat";

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new();
    $self->set_http_request_processor(\&handle_ping          , GET  => '/ping');
    $self->set_http_request_processor(\&handle_version       , GET  => '/version');
    $self->set_http_request_processor(\&handle_connect       , POST => '/tcp/connect/*');
    $self->set_http_request_processor(\&handle_port_check    , GET  => '/tcp/portcheck/*');
    $self->set_http_request_processor(\&handle_get_nsplugin  , GET  => '/nsplugin');
    $self->set_http_request_processor(\&handle_usbip         , POST => '/usbip/connect');
    $self->set_http_request_processor(\&handle_usbip_devices , GET  => '/usbip/shared_devices');
    $self->set_http_request_processor(\&handle_usbip_check   , GET  => '/usbip/portcheck');    
    
    if ( core_cfg('client.slave.debug_commands' ) ) {
        $self->set_http_request_processor(\&handle_echo   , POST => '/echo');
        $self->set_http_request_processor(\&handle_discard, POST => '/discard');
        $self->set_http_request_processor(\&handle_chargen, GET  => '/chargen');
        $self->set_http_request_processor(\&handle_randgen, GET  => '/randgen');
        $self->set_http_request_processor(\&handle_fastgen, GET  => '/fastgen/*');
    }

    bless $self, $class;
}

sub _url_to_port {
    my ($self, $url) = @_;
    chop $url if $url =~ /[\/\\]$/;  # remove dir separator if last character

    (my $port = $url) =~ s/.*[\/\\]//; # pick last part of path

    if ( $port =~ /^\d+$/ && $port >=0 && $port <= 65535 ) {
        return $port;
    } else {
        return undef;
    }

}

sub handle_ping {
    my ($self, $method, $url, $headers) = @_;

    $self->send_http_response_with_body(HTTP_OK, 'text/plain', [], "Pong!\n");
}

sub handle_version {
	my ($self, $method, $url, $headers) = @_;
	
	$self->send_http_response_with_body(HTTP_OK, 'text/plain', [], "$VERSION\n");
}

sub handle_echo {
	my ($self, $method, $url, $headers) = @_;
	
	$self->send_http_response(HTTP_SWITCHING_PROTOCOLS);
	
	my $sel = IO::Select->new();
	$sel->add(\*STDIN);
	
	while($sel->can_read()) {
		my $buf;
		sysread(STDIN, $buf, 1024) or return;
		syswrite(STDOUT, $buf) or return;
	}

}

sub handle_discard {
	my ($self, $method, $url, $headers) = @_;
	
	$self->send_http_response(HTTP_SWITCHING_PROTOCOLS);
	
	my $buf;
	while( sysread(STDIN, $buf, 1024) != 0 ) {
		# nothing
	}
}

sub handle_chargen {
	my ($self, $method, $url, $headers) = @_;
	
	$self->send_http_response(HTTP_SWITCHING_PROTOCOLS);
	my $text = "";
	
	for(my $i=33;$i<33+95;$i++) { 
		$text .= chr($i);
	}
	
	
	my $pos = 0;
	my $strlen = 72;
	while( 1 ) {
		my $out = substr($text, $pos, $strlen);
		
		if ( $pos + $strlen > length($text) ) {
			$out .= substr($text, 0, $pos + $strlen - length($text) + 1);
		}
		
		$out .= "\n";
		
		syswrite(STDOUT, $out) or return;
		
		if ( ++$pos >= length($text) ) {
			$pos=0;
		}
	}
}

sub handle_randgen {
	my ($self, $method, $url, $headers) = @_;
	  
	if ( $WINDOWS ) {
		# Needs a decently fast replacement for /dev/urandom
		$self->send_http_response(HTTP_NOT_IMPLEMENTED, "Not implemented yet on Windows");
		return;
	} 
	
	$self->send_http_response(HTTP_SWITCHING_PROTOCOLS);
	
	open(my $rand, '<', '/dev/urandom') or die "Failed to open /dev/urandom: $!";
	my $buf;
	while(1) {
		read($rand, $buf, 1024);
		syswrite(STDOUT, $buf) or return;
	}
	close $rand;
}

sub handle_fastgen {
	my ($self, $method, $url, $headers) = @_;
	
	my $char = $self->_url_to_port($url);
	if (!$char && $char < 0 || $char > 255 ) {
		$self->send_http_error(HTTP_BAD_REQUEST, "Character number must be between 0 and 255");
		return;
	}
	
	$self->send_http_response(HTTP_SWITCHING_PROTOCOLS);
	
	my $buf = chr($char) x 1024;
	while( syswrite(STDOUT, $buf) ) {
		# nothing
	}

}


sub handle_connect {
    my ($self, $method, $url, $headers) = @_;

    my $port = $self->_url_to_port($url);

    unless ($port) {
        $self->send_http_error(HTTP_BAD_REQUEST, "Bad port number");
        return;
    }

    my $pid = fork();
    if ($pid) {
        $self->send_http_response(HTTP_SWITCHING_PROTOCOLS);
        wait;
    } else {
        INFO "Connecting to tcp:localhost:$port,nonblock,reuseaddr,nodelay,retry=5";
        my @cmd = ($socat, "-", "tcp:localhost:$port,nonblock,reuseaddr,nodelay,retry=5");
        exec @cmd;
        die "Unable to exec: $^E";
    }
}

sub handle_port_check {
    my ($self, $method, $url, $headers) = @_;

    my $port = $self->_url_to_port($url);

    unless ($port) {
        $self->send_http_error(HTTP_BAD_REQUEST, "Bad port number");
        return;
    }

    my $sock = new IO::Socket::INET( PeerAddr => 'localhost',
                                     PeerPort => $port,
                                     Proto    => 'tcp' );

    if ( $sock ) {
        $self->send_http_response(HTTP_OK);
    } else {
        $self->send_http_error(HTTP_FORBIDDEN, $!);
    }
}

sub handle_get_nsplugin {
    my ($httpd, $method, $url, $headers) = @_;

    $httpd->send_http_error(HTTP_BAD_REQUEST)
        unless header_eq_check($headers, Connection => 'Upgrade')
           and header_eq_check($headers, Upgrade => 'qvd:slave/1.0');

    my $uri = URI->new($url);
    my %query = $uri->query_form();
    my $plugin = QVD::Client::SlaveServer::Nsplugin->new(%query);

    $httpd->send_http_response(HTTP_SWITCHING_PROTOCOLS);

    $plugin->execute();
}

sub handle_usbip_check {
	my ($httpd, $method, $url, $headers) = @_;

	my $port = core_cfg('client.usb.usbip.port');
	handle_port_check($httpd, $method, "/tcp/portcheck/$port", $headers);
}

sub handle_usbip {
	my ($httpd, $method, $url, $headers) = @_;
	
	# Connecting to usbipd is just port redirection.
	# We use a dedicated command here so that VMA doesn't need to know
	# the port.
	my $port = core_cfg('client.usb.usbip.port');
	handle_connect($httpd, $method, "/tcp/connect/$port", $headers);
}


sub handle_usbip_devices {
	my ($self, $method, $url, $headers) = @_;
	
	my $usb = QVD::Client::USB::USBIP->new();
	my @ids;
	
	foreach my $dev ( @{$usb->list_shared_devices} ) {
		push @ids, $dev->{busid};
	}
	
	$self->send_http_response_with_body(HTTP_OK, 'text/plain', [], join("\n", @ids));
}


'QVD-Client'

__END__

=head1 NAME

QVD::Client::SlaveServer - QVD slave server for the client side.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::VMA::SlaveServer

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-SlaveServer>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/QVD-SlaveServer>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/QVD-SlaveServer>

=item * Search CPAN

L<http://search.cpan.org/dist/QVD-SlaveServer/>

=back

=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 QVD Team.

This program is released under the GNU Public License, version 3.
