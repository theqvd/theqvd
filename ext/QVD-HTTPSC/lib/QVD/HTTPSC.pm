package QVD::HTTPSC;

our $VERSION = '0.01';

use warnings;
use strict;

use parent qw(QVD::HTTPC);

sub _create_socket {
    my $self = shift;
    my $target = $self->{target};
    $self->{socket} = IO::Socket::SSL->new(PeerAddr => $target, Blocking => 0)
	or croak "Unable to connect to $target";
}

sub _print {
    
}

sub _sysread {

}

=head1 NAME

QVD::HTTPSC - The great new QVD::HTTPSC!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::HTTPSC;

    my $foo = QVD::HTTPSC->new();
    ...

=head1 DESCRIPTION

=head2 API

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-httpsc at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-HTTPSC>.  I will
be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 AUTHOR

Salvador FandiE<ntilde>o (sfandino@yahoo.com)

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of QVD::HTTPSC
