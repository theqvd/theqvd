package QVD::Frontend::Plugin::L7R;

use strict;
use warnings;

use IO::Socket::INET;

use QVD::L7R::Forwarder;


sub set_http_processors {
    my ($class, $server, $url_base') = @_;
    $server->set_http_processor( \&_connect_to_vm_processor,
				 $url_base . "connect_to_vm");
}

sub _connect_to_vm_processor {
    my ($server, $method, $url, $headers) = @_;

    my $socket = IO::Socket::INET->new(PeerAddr => "localhost",
				       PeerPort => 3030,
				       Proto => 'tcp');
    unless ($socket) {
	$server->send_http_error(502);
	return;
    }

    my $forwarder = QVD::L7R::Forwarder->new($socket);
    $forwarder->run();
}

1;
