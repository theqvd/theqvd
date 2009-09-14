package QVD::URI;

use warnings;
use strict;
use Carp;

our $VERSION = '0.01';

use parent 'Exporter';
our @EXPORT_OK = qw(url_unescape uri_query_split);

sub uri_unescape_plus {
    my $url = shift;
    return undef unless defined $url;
    $url =~ tr/+/ /;
    $url =~ s/%([a-fA-F0-9]{2})/chr hex $1/eg;
    return $url;
}

sub uri_query_split {
    my $query = shift;
    ( defined $query
      ? map uri_unescape_plus($_), map /^(.*?)(?:=(.*))?$/, split /\&/, $query
      : () )
}

1;

__END__

=head1 NAME

QVD::URI - utility functions for URI manipulation

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::URI qw(uri_query_split);

    my %query_params = uri_query_split("foo=doz+mon&bar=tomate")
    ...

=head1 DESCRIPTION

This module provides some URI related functions not available from L<URI>.

=head2 FUNCTIONS

=over 4

=item %params = uri_query_split($uri_query)

splits a query string as returned by L<URI::Split::uri_split>

=item $data = uri_unescape_plus($url)

Similar to L<URI::Escape::uri_unscape> but also converts plus signs to
espaces.

=back

=head1 BUGS AND SUPPORT

Please report any bugs or feature requests to C<bug-qvd-uri at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-URI>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 AUTHORS

Salvador FandiE<ntilde>o (sfandino@yahoo.com).

=head1 COPYRIGHT & LICENSE

Copyright E<copyright> 2009 Qindel Formacion y Servicios S.L., all
rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of QVD::URI
