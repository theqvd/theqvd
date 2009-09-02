package QVD::HTTPD;

use warnings;
use strict;

our $VERSION = '0.01';

use parent qw(Net::Server);

use QVD::HTTP::StatusCodes qw(:all);

# token          = 1*<any CHAR except CTLs or separators>
# separators     = "(" | ")" | "<" | ">" | "@"
#                | "," | ";" | ":" | "\" | <">
#                | "/" | "[" | "]" | "?" | "="
#                | "{" | "}" | SP | HT
my $token_re = qr/[!#\$%&'*+\-\.0-9a-zA-Z]+/;

sub process_request {
    my $self = shift;
    while (<>) {
	s/\r?\n$//;
	next if /^\s*$/;
	if (my ($method, $url, $version) = m|^(\w+)\s+(.*?)\s*((?:\bHTTP/\d+\.\d+)?)$|) {
	    if ($version ne 'HTTP/1.1') {
		$self->send_http_error(HTTP_VERSION_NOT_SUPPORTED);
		return;
	    }
	    my @headers;
	    while(<>) {
		s/\r?\n$//; # HTTP chomp
		if (my ($name, $value) = /^($token_re)\s*:\s*(.*?)\s*$/o) {
		    # new header
		    push @headers, "${name}:${value}";
		}
		elsif (/^\s+(.*?)\s+$/) {
		    # header continuation
		    unless (@headers) {
			$self->send_http_error(HTTP_BAD_REQUEST);
			return;
		    }
		    $headers[-1] .= " " . $1;
		}
		elsif (/^$/) {
		    # end of headers
		    $self->process_http_request($method, \@headers);
		    last;
		}
		else {
		    $self->send_http_error(HTTP_BAD_REQUEST);
		    return;
		}
	    }
	}
	else {
	    $self->send_http_error(HTTP_BAD_REQUEST);
	    return;
	}
    }
    print STDERR "connection closed\n";
}

sub process_http_request {
    my $self = shift;
    my ($method, $headers) = @_;
    use Data::Dumper;
    my $text = Dumper \@_;
    $self->send_http_response(200, 'text/plain', $text);
}

sub send_http_response {
    my $self = shift;
    my $code = int shift;
    my $content_type = shift;
    my $content = join('', @_);
    print join("\r\n",
	       "HTTP/1.1 $code ". http_status_message($code),
	       "Content-Type: $content_type",
	       "Content-Length: " . length($content),
	       '',
	       $content);
}

sub send_http_error {
    my ($self, $code) = @_;
    $code ||= HTTP_INTERNAL_SERVER_ERROR;
    my $text = http_status_description($code);
    $self->send_http_response($code, 'text/plain', $text);
}

__PACKAGE__->run(port => 8080);

1;

__END__

=head1 NAME

QVD::HTTPD - The great new QVD::HTTPD!


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::HTTPD;

    my $foo = QVD::HTTPD->new();
    ...

=head1 FUNCTIONS


=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-httpd at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-HTTPD>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=back

=head1 AUTHORS

Salvador FandiE<ntilde>o (sfandino@yahoo.com)

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Consulting S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut


