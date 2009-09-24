package QVD::Frontend::Plugin::VMAS;

use strict;
use warnings;

sub set_http_request_processors {
    my ($class, $server, $url_base) = @_;

}

1;

=head1 NAME

QVD::Frontend::Plugin::VMAS - plugin for VMAS functionality

=head1 SYNOPSIS

  use QVD::Frontend::Plugin::VMAS;
  QVD::Frontend::Plugin::VMAS->set_http_request_processors($httpd, $base_url);

=head1 DESCRIPTION

This module wraps the VMAS functionality as a plugin for L<QVD::Frontend>.

=head2 API

=over

=item QVD::Frontend::Plugin::VMAS->set_http_request_processors($httpd, $base_url)

registers the plugin into the HTTP daemon C<$httpd> at the given
C<$base_url>.

=back

=head1 AUTHOR

Salvador FandiE<ntilde>o, C<< <sfandino at yahoo.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
