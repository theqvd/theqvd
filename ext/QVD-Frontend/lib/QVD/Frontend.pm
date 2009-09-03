package QVD::Frontend;

use warnings;
use strict;

our $VERSION = '0.01';

use parent 'QVD::HTTPD';

require QVD::Frontend::Plugin::L7R;
require QVD::Frontend::Plugin::VMAS;

sub post_configure_hook {
    my $self = shift;
    QVD::Frontend::Plugin::L7R->set_http_request_processors($self, '/qvd/');
    QVD::Frontend::Plugin::VMAS->set_http_request_processors($self, '/vmas/');
}


1;
__END__

=head1 NAME

QVD::Frontend - The great new QVD::Frontend!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::Frontend;

    my $foo = QVD::Frontend->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head1 AUTHOR

Salvador FandiE<ntilde>o, C<< <sfandino at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-frontend at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-Frontend>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

