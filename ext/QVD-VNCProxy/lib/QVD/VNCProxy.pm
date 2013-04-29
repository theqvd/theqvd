package QVD::VNCProxy;

our $VERSION = '0.01';

use strict;
use warnings;
use 5.010;

use QVD::DB::Simple;
use QVD::Config;
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTPC;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(vnc_connect);


sub vnc_connect {
    my ($vm_id, $err_cb);
    $err_cb //= sub {};

    my $vm = rs(VM)->find($vm_id);
    my $ip = $vm->ip;
    my $rt = $vm->vm_runtime;
    given ($rt->vm_state) {
        when ('stopped') {
            $err_cb->(1, "machine $vm_id is in state stopped");
            return;
        }
        when ('running') {
            $err_cb->(0, "connecting to machine $vm_id");
        }
        default {
            $err_cb->(0, "machine $vm_id is in state $_, trying to stablish VNC connection anyway");
        }
    }

    my $port = cfg('internal.vm.port.vma');
    my $httpc = QVD::HTTPC->new("${ip}:$port") or do {
        $err_cb->(1, "unable to connect to VMA at ${ip}:$port");
        return;
    }

    $httpc->send_http_request(GET => "/vma/vnc_connect",
                              headers => [ 'Connection: Upgrade',
                                           'Upgrade: VNC' ]);

    while (1) {
        my ($code, $msg, $headers, $body) = $httpc->read_http_response;
        if ($code == HTTP_PROCESSING) {
            $err_cb->(0, $msg);
        }
        elsif ($code == HTTP_SWITCHING_PROTOCOLS) {
            $err_cb->(0, "connected!");
            return $httpc->get_socket;
        }
        else {
            $err_cb->(1, "bad response: $code $msg");
            return;
        }
    }
}

1;
__END__

=head1 NAME

QVD::VNCProxy - Forwards a VNC connection through QVD VMA

=head1 SYNOPSIS

  use QVD::VNCProxy;
  my $socket = vnc_connect($ip, $port);

=head1 AUTHOR

Salvador FandiE<ntilde>o, E<lt>sfandino@yahoo.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut
