#!/usr/bin/perl

use strict;
use warnings;

use QVD::HTTPC;
use QVD::HTTP::StatusCodes qw(:status_codes);
use IO::Socket::Forwarder qw(forward_sockets);

my $httpc = QVD::HTTPC->new('localhost:8080');

$httpc->send_http_request(GET => '/qvd/connect_to_vm?id=7',
			  headers => [ 'Connection: Upgrade',
				       'Upgrade: QVD/1.0' ]);
while (1) {
    my ($code, $msg, $headers, $body) = $httpc->read_http_response;
    use Data::Dumper;
    print STDERR Dumper [http_response => $code, $msg, $headers, $body];
    if ($code == HTTP_SWITCHING_PROTOCOLS) {
	my $ll = IO::Socket::INET->new(LocalPort => 4040,
				       ReuseAddr => 1,
				       Listen => 1);

	system "nxproxy -S localhost:40 &";
	my $s1 = $ll->accept();
	my $s2 = $httpc->get_socket;
	forward_sockets($s1, $s2);
	last;
    }
    elsif ($code >= 100 and $code < 200) {
	print STDERR "$code\ncontinuing...\n"
    }
    else {
	die "unable to connect to remote vm: $code";
    }
}
