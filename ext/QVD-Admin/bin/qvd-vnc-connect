#!/usr/bin/perl

use strict;
use warnings;
use 5.010;

use App::pnc qw(netcat_socket);
use QVD::DB::Simple;
use QVD::Config;
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTPC;


my $vm_id = shift // die <<EOU;
Usage:
  $0 <vm_id>

EOU

my $vm = rs(VM)->find($vm_id);
my $ip = $vm->ip;
my $rt = $vm->vm_runtime;
given ($rt->vm_state) {
    when ('stopped') {
        die "machine $vm_id is in state stopped\n";
    }
    when ('running') {
        warn "connecting to machine $vm_id\n";
    }
    default {
        warn "machine $vm_id is in state $_, trying to stablish VNC connection anyway...\n";
    }
}

my $port = cfg('internal.vm.port.vma');

my $httpc = QVD::HTTPC->new("${ip}:$port") or die $@;

$httpc->send_http_request(GET => "/vma/vnc_connect",
                          headers => [ 'Connection: Upgrade',
                                       'Upgrade: VNC' ]);

while (1) {
    my ($code, $msg, $headers, $body) = $httpc->read_http_response;
    if ($code == HTTP_PROCESSING) {
        print STDERR "$msg\n";
    }
    elsif ($code == HTTP_SWITCHING_PROTOCOLS) {
        netcat_socket($httpc->get_socket);
        exit 0;
    }
    else {
        die "bad response: $code $msg\n";
    }
}
