package QVD::Frontend::Plugin::L7R;

use strict;
use warnings;

use IO::Socket::INET;
use URI::Split qw(uri_split);

use QVD::L7R::Forwarder;
use QVD::VMAS::Client;
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::URI qw(uri_query_split);

sub set_http_request_processors {
    my ($class, $server, $url_base) = @_;
    $server->set_http_request_processor( \&_connect_to_vm_processor,
					 GET => $url_base . "connect_to_vm");
}

sub _connect_to_vm_processor {
    my ($server, $method, $url, $headers) = @_;

    my $header_connection = header_loopup('Connection', $headers);
    my $header_upgrade = header_loopup('Upgrade', $headers);

    # ensure that the client wants to upgrade the connection
    unless ($header_connection eq 'Upgrade' and
	    $header_upgrade eq 'QVD/1.0') {
	$server->send_http_error(HTTP_UPGRADE_REQUIRED);
	return;
    }

    my ($path, $query) = (uri_split $url)[2, 3];
    my %params = uri_query_split $query;
    my $id = $params{id};
    unless (defined $id) {
	$server->send_http_error(HTTP_UNPROCESSABLE_ENTITY);
	return;
    }

    $server->send_http_response(HTTP_PROCESSING,
				'X-QVD-VM-Status: Checking VM');

    my $vmas = QVD::VMAS::Client->new;
    my ($host, $port) = $vmas->start_vm_listener($id)
	or do {
	    $server->send_http_error(HTTP_BAD_GATEWAY);
	    return;
	};

    $server->send_http_response(HTTP_PROCESSING,
				'X-QVD-VM-Status: Connecting to VM',
				"X-QVD-VM-Info: host=$host, port=$port");

    my $socket = IO::Socket::INET->new(PeerAddr => $host,
				       PeerPort => $port,
				       Proto => 'tcp');
    unless ($socket) {
	$server->send_http_error(HTTP_BAD_GATEWAY);
	return;
    }

    $server->send_http_response(HTTP_SWITCHING_PROTOCOLS,
				'X-QVD-VM-Status: Connected to VM');

    my $forwarder = QVD::L7R::Forwarder->new($socket);
    $forwarder->run();
}

1;
