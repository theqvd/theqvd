#!/usr/bin/perl

use strict;
use warnings;

use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTPC;

my $ip = shift;

$^F=3;

my $httpc = QVD::HTTPC->new("$ip:3030") or die $@;

$httpc->send_http_request(GET => "/vma/vnc_connect",
                          headers => [ 'Connection: Upgrade',
                                       'Upgrade: VNC' ]);

while (1) {
    my ($code, $msg, $headers, $body) = $httpc->read_http_response;
    if ($code == HTTP_PROCESSING) {
        print STDERR "$msg\n";
    }
    elsif ($code == HTTP_SWITCHING_PROTOCOLS) {
        warn "running ssvncviewer\n";
        my $socket = $httpc->get_socket;
        my $fn = fileno($socket);
        


        eval { exec strace => -o => '/tmp/out', ssvncviewer => "fd=$fn" };
        exit 0;
    }
    else {
        die "bad response: $code $msg\n";
    }
}
