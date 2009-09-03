package QVD::HTTP::Headers;

use strict;
use warnings;

use parent 'Exporter';
our @EXPORT_OK = qw(header_loopup);

my %re;

sub header_lookup {
    my ($key, $headers) = @_;
    my $matcher = $re{$key} ||= do {
	my $m = '^' . quotemeta($key) . '\\s*:\\s*(.*)$';
	qr/$m/;
    };
    wantarray
	? (map $_ =~ $matcher, @$headers)
	: (map $_ =~ $matcher, @$headers)[0];
}


1;
