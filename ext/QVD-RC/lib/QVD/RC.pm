package QVD::RC;

our $VERSION = '0.01';

use warnings;
use strict;

use Log::Log4perl qw(:easy);
use parent qw(QVD::HTTPD);


sub post_configure_hook {
    my $server = shift;
    my $impl = QVD::RC::Impl->new();
    $impl->set_http_request_processors($server, '/qvd/rc/*');
}

package QVD::RC::Impl;

use parent 'QVD::SimpleRPC::Server';

sub _get_hkd_pid {
    my $pid = undef;
    # FIXME: get pid from database, or at least make the filename
    # something configurable
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

__END__

=head1 NAME

QVD::RC - Remote control service

=head1 SYNOPSIS

  use QVD::RC;
  my $rc = QVD::RC->new(port => 8080);
  $rc->run();

=head1 DESCRIPTION

Webservice to signal local processes

=head2 RPC API

The RC service accepts the following RPC calls.

=over

=item ping_hkd

Pings the house-keeping daemon on this host by sending it the USR1 signal.

=back

=head1 AUTHOR

Joni Salonen, C<< <jsalonen at qindel.com> >>
Salvador Fandiño, C<< <sfandino at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-rc at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-RC>.  I will be
notified, and then you'll automatically be notified of progress on
your bug as I make changes.


=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
