package QVD::HTTPD;

use warnings;
use strict;

our $VERSION = '0.01';

use parent qw(Net::Server);

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
	if (my ($method, $url) = m|^(\w+)\s+(.*?)\s+HTTP/1\.1$|) {
	    my @headers;
	    while(<>) {
		s/\r?\n$//;
		if (/^$/) {
		    # end of headers
		    $self->process_http_request($method, \@headers);
		    last;
		}
		elsif (/^\s+(.*?)\s+$/) {
		    # header continuation
		    @headers or goto ERROR;
		    $headers[-1] .= " " . $1;
		}
		elsif (my ($name, $value) = /^\s*($token_re)\s*:\s*(.*?)\s*$/o) {
		    # new header
		    push @headers, "${name}:${value}";
		}
		else {
		    goto ERROR;
		}
	    }
	}
	else {
	    goto ERROR;
	}
    }
 OK:
    print STDERR "connection closed\n";
    return;

 ERROR:
    $self->send_http_error(500, "bad request",
			   "bad HTTP request\n\nline:\n$_\n\n");
    goto OK;
}

sub process_http_request {
    my $self = shift;
    my ($method, $headers) = @_;
    use Data::Dumper;
    my $text = Dumper \@_;
    $self->send_http_response(200, 'Ok', ['Content-Type: text/plain'], $text);
}

sub send_http_response {
    my $self = shift;
    my $code = shift;
    my $msg = shift;
    my $headers = shift;
    my $content = join('', @_);
    print join("\r\n",
	       "HTTP/1.1 $code $msg",
	       @$headers,
	       sprintf('Content-Length: %d', length $content),
	       '',
	       $content);
}

sub send_http_error {
    my ($self, $code, $msg, $text) = @_;
    $text =~ s/\r?\n/\r\n/g;
    $self->send_http_request($code, $msg, ['Content-Type: text/plain'], $text);
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


