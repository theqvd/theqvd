package QVD::HTTP::Headers;

use strict;
use warnings;

use parent 'Exporter';
our @EXPORT_OK = qw(header_lookup header_eq_check header_find);

my %re;

sub header_lookup {
    my ($headers, $key) = @_;
    if ($headers) {
        my $matcher = $re{$key} ||= do {
            my $m = '^' . quotemeta($key) . '\\s*:\\s*(.*)$';
            qr/$m/;
        };
        return wantarray
            ? (map $_ =~ $matcher, @$headers)
            : (map $_ =~ $matcher, @$headers)[0];
    } else {
        return ();
    }
}

sub header_find {
    my ($headers, $regexp) = @_;
    die "Argument must be a regular expression" unless ( ref($regexp) eq "Regexp" );

    if ( $headers ) {
        my @ret;
        foreach my $hdr (@$headers) {
            my ($h) = $hdr =~ /(.*?)\s*:/;
            push @ret, $h if ( $h =~ $regexp );
        }

        return wantarray ? @ret : $ret[0];
    } else {
        return ();
    }
}

sub header_eq_check {
    my ($headers, $key, $value) = @_;
    my $found = header_lookup($headers, $key);
    defined $found and $found eq $value;
}

1;
