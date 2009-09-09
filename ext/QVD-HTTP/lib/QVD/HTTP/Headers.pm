package QVD::HTTP::Headers;

use strict;
use warnings;

use parent 'Exporter';
our @EXPORT_OK = qw(header_lookup header_eq_check);

my %re;

sub header_lookup {
    my ($headers, $key) = @_;
    if ($headers) {
	my $matcher = $re{$key} ||= do {
	    my $m = '^' . quotemeta($key) . '\\s*:\\s*(.*)$';
	    qr/$m/;
	};
	wantarray
	    ? (map $_ =~ $matcher, @$headers)
	    : (map $_ =~ $matcher, @$headers)[0];
    }
    return ();
}

sub header_eq_check {
    my ($headers, $key, $value) = @_;
    my $found = header_lookup($headers, $key);
    defined $found and $found eq $value;
}

1;
