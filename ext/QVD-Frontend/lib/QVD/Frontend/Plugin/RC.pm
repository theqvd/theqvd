package QVD::Frontend::Plugin::RC;

use strict;
use warnings;


sub set_http_request_processors {
    my ($class, $server, $url_base) = @_;
    my $impl = QVD::Frontend::Plugin::RC::Impl->new();
    $impl->set_http_request_processors($server, $url_base."*");
}

package QVD::Frontend::Plugin::RC::Impl;

use parent 'QVD::SimpleRPC::Server';

sub _get_hkd_pid {
    my $pid = undef;
    my $hkd_pid_file = '/var/run/qvd/hkd.pid';
    $pid =  `cat $hkd_pid_file` if (-f $hkd_pid_file);
    chomp $pid;
    $pid;
}

sub SimpleRPC_ping_hkd {
    my $self = shift;
    my $pid = _get_hkd_pid();
    my $result = undef;
    $result = kill('USR1', $pid) if $pid;
    if ($result) {
	return { request => 'success' };
    } else {
	my $msg = $pid ? $! : 'Not running';
	return { request => 'error', error => 'Sending signal to HKD: '.$msg };
    }
}

1;

=head1 NAME

QVD::Frontend::Plugin::RC - plugin for Remote Control

=head1 SYNOPSIS

  use QVD::Frontend::Plugin::RC;
  QVD::Frontend::Plugin::RC->set_http_request_processors($httpd, $base_url);

=head1 DESCRIPTION

This module wraps the RC functionality as a plugin for L<QVD::Frontend>.

=head2 API

=over

=item QVD::Frontend::Plugin::RC->set_http_request_processors($httpd, $base_url)

registers the plugin into the HTTP daemon C<$httpd> at the given
C<$base_url>.

=back

=head2 RPC API

The RC plugin accepts the following RPC calls.

=over

=item ping_hkd

Pings the house-keeping daemon on this host by sending it the USR1 signal.

=back

=head1 AUTHOR

Joni Salonen, C<< <jsalonen at qindel.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
