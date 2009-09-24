package QVD::HTTPC;

our $VERSION = '0.01';

use 5.010;

use warnings;
use strict;
use Carp;

use IO::Socket::INET;
use URI::Escape qw(uri_escape);
use Errno qw(EINTR);

use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTP::Headers qw(header_lookup);

my $CRLF = "\r\n";

sub new {
    my ($class, $target) = @_;
    my $socket = IO::Socket::INET->new($target)
	or die "Unable to connect to $target";
    my $self = { target => $target,
		 socket => $socket };
    bless $self, $class;
    $self;
}

sub get_socket { shift->{socket} }

sub _print {
    my $socket = shift->{socket};
    print {$socket} @_
}

sub _print_lines {
    my $socket = shift->{socket};
    print {$socket} join $CRLF, @_, '';
}

sub send_http_request {
    my ($self, $method, $url, %opts)= @_;
    my $params = delete $opts{params};
    my @headers = @{delete $opts{headers} // []};
    my $body = delete $opts{body};

    if ($params and %$params) {
	my @kvs = map {
	    uri_escape($_) . '=' . uri_escape($params->{$_})
	} keys %$params;
	$url .= '?' . join('&', @kvs)
    }

    if (defined $body) {
	my $content_type = delete $opts{content_type} // 'text/ascii';
	push @headers, ('Content-Length: ' . length $body,
			'Content-Type: $content_type');
    }

    my $socket = $self->{socket};
    $self->_print_lines("$method $url HTTP/1.1",
			@headers,
			'');
    $self->_print($body) if defined $body;
}

# token          = 1*<any CHAR except CTLs or separators>
# separators     = "(" | ")" | "<" | ">" | "@"
#                | "," | ";" | ":" | "\" | <">
#                | "/" | "[" | "]" | "?" | "="
#                | "{" | "}" | SP | HT
my $token_re = qr/[!#\$%&'*+\-\.0-9a-zA-Z]+/;

sub read_http_response_head {
    my $self = shift;
    my $socket = $self->{socket};
    while (<$socket>) {
	s/\r?\n$//;
	next if /^\s*$/;
	if (my ($version, $code, $msg) =
	    m{^(HTTP/\S+)\s+(\d+)(?:\s+(\S.*?))?\s*$}) {
	    $version eq 'HTTP/1.1'
		or return HTTP_VERSION_NOT_SUPPORTED_BY_CLIENT;
	    my @headers;
	    while (<$socket>) {
		s/\r?\n$//; # HTTP chomp
		if (my ($name, $value) = /^($token_re)\s*:\s*(.*?)\s*$/o) {
		    # new header
		    push @headers, "${name}:${value}";
		}
		elsif (/^\s+(.*?)\s+$/) {
		    # header continuation
		    @headers or return HTTP_BAD_RESPONSE;
		    $headers[-1] .= " " . $1;
		}
		elsif (/^$/) {
		    # end of headers
		    last;
		}
		else {
		    return HTTP_BAD_RESPONSE;
		}
	    }
	    return ($code, $msg, \@headers);
	}
	last;
    }
    return HTTP_BAD_RESPONSE;
}

sub _atomic_read {
    my ($fh, $length) = @_[0,2];
    $_[1] //= '';
    while ($length) {
	my $bytes = read($fh, $_[1], $length, length $_[1]);
	if ($bytes) {
	    $length -= $bytes;
	}
	elsif ($! != EINTR) {
	    return undef;
	}
    }
    1;
}

sub read_http_response {
    my $self = shift;
    my ($code, $msg, $headers) = $self->read_http_response_head();
    my $content_length = header_lookup($headers, 'Content-Length');
    my $body;
    if ($content_length) {
	_atomic_read($self->{socket}, $body, $content_length);
    }
    ($code, $msg, $headers, $body);
}

sub make_http_request {
    my $self = shift;
    $self->send_http_request(@_);
    $self->read_http_response;
}

sub json {
    my $self = shift;
    $self->{_json} ||= do {
	require JSON;
	JSON->new->ascii->pretty;
    }
}

sub read_http_response_json {
    my $self = shift;
    my ($code, $msg, $headers, $body) = $self->read_http_response;
    my $data;
    $data = $self->json->decode($body)
	if defined $body;
    ($code, $msg, $headers, $data);
}

sub make_http_query_json {
    my $self = shift;
    $self->send_http_query_json(@_);
    $self->read_http_response_json();
}

1;

__END__

=head1 NAME

QVD::HTTPC - QVD HTTP client package

=head1 SYNOPSIS

    use QVD::HTTPC;

    my $client = QVD::HTTPC->new("www.qvd.org:3333");

    my ($code, $msg, $headers, $data) =
        $client->make_http_query_json(GET => '/where_is_my_car',
                                      maker => 'Volkswagen',
                                      color => 'red',
                                      model => 'Polo');

    if (defined $data) {
        print Dumper $data;
    }


=head1 DESCRIPTION

=head2 API

=over

=item $httpc = QVD::HTTPC->new($targe_host)

Creates a new object and connects it to the given host.

=item $httpc->get_socket

Returns the handle for the TCP connection to the remote host.

=item $httpc->send_http_request($method, $url, %opts)

Sends a new HTTP request to the remote server.

The accepted options are as follows:

=over

=item params => \%params

list of key/value pairs to be added to the given URL.

=item headers => \@headers

extra headers to include in the HTTP request

=item body => $data

data load to use as the request body

=back

=item ($code, $msg, $headers) = $httpc->read_http_response_head()

reads an HTTP response header from the socket

=item ($code, $msg, $headers, $body) = $httpc->read_http_response()

reads an HTTP response from the socket

=item ($code, $msg, $headers) = $httpc->make_http_request($method, $url, \%opts)

=back

=head1 AUTHOR

Salvador FandiE<ntilde>o (sfandino@yahoo.com).

=head1 BUGS


=head1 COPYRIGHT & LICENSE

Copyright C<copy> 2009 Qindel Formacion y Servicios S.L., all rights
reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

