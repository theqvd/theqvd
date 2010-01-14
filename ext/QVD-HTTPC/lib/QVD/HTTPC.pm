package QVD::HTTPC;

our $VERSION = '0.01';

use 5.010;

use warnings;
use strict;
use Carp;

use IO::Socket::INET;
use URI::Escape qw(uri_escape);
use Errno;

use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTP::Headers qw(header_lookup);

my $CRLF = "\r\n";

sub _create_socket {
    my $self = shift;
    my $target = $self->{target};
    my $SSL = $self->{SSL};
    my $class;
    if ($SSL) {
	require IO::Socket::SSL;
	$class = 'IO::Socket::SSL';
    }
    else {
	$class = 'IO::Socket::INET'
    }

    $self->{socket} = $class->new(PeerAddr => $target, Blocking => 0)
	or croak "Unable to connect to $target";
}

sub new {
    my ($class, $target, %opts) = @_;
    my $timeout = delete $opts{timeout};
    my $ssl = delete $opts{SSL};

    keys %opts and
	croak "unknown constructor option(s) " . join(', ', keys %opts);

    my $self = { target => $target,
		 timeout => $timeout,
		 SSL => $ssl,
		 buffer => '' };
    bless $self, $class;
    $self->_create_socket();
    $self;
}

sub get_socket { shift->{socket} }

sub _print {
    my $self = shift;
    my $socket = $self->{socket};
    my $timeout = $self->{timeout};
    my $SSL = $self->{SSL};
    my $buffer = join('', @_);
    my $fn = fileno $socket;
    $fn >= 0 or croak "bad file handle $socket";
    while (length $buffer) {
	my $wv = '';
	vec($wv, $fn, 1) = 1;
	my $n = select(undef, $wv, undef, $timeout);
	if ($n > 0) {
	    if (vec($wv, $fn, 1)) {
		my $bytes = syswrite($socket, $buffer, 16 * 1024);
		if ($bytes) {
		    substr($buffer, 0, $bytes, '');
		}
		elsif ($SSL and not defined $bytes) {
		    $IO::Socket::SSL::SSL_ERROR == IO::Socket::SSL::SSL_WANT_READ()
			or die "internal error: unexpected SSL error: " . IO::Socket::SSL::errstr();
		    my $rv = '';
		    vec($rv, $fn, 1) = 1;
		    $n = select($rv, undef, undef, $timeout);
		}
		else {
		    die "socket closed unexpectedly: $!"
		}
	    }
	}
	$n > 0 or $! == Errno::EINTR or die "connection timed out";
    }
}

sub _print_lines {
    my $self = shift;
    $self->_print(join $CRLF, @_, '');
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
    while (defined(my $line = $self->_readline)) {
	next if $line =~ /^\s*$/;
	if (my ($version, $code, $msg) =
	    $line =~ m{^(HTTP/\S+)\s+(\d+)(?:\s+(\S.*?))?\s*$}) {
	    $version eq 'HTTP/1.1'
		or return HTTP_VERSION_NOT_SUPPORTED_BY_CLIENT;
	    my @headers;
	    while (defined(my $line = $self->_readline)) {
		given($line) {
		    when (/^($token_re)\s*:\s*(.*?)\s*$/o) {
			push @headers, "${1}:${2}";
		    }
		    when (/^\s+(.*?)\s+$/) {
			@headers or return HTTP_BAD_RESPONSE;
			$headers[-1] .= " " . $1;
		    }
		    when (/^$/) {
			# end of headers
			last;
		    }
		    default {
			return HTTP_BAD_RESPONSE;
		    }
		}
	    }
	    return ($code, $msg, \@headers);
	}
	last;
    }
    return HTTP_BAD_RESPONSE;
}

sub _sysread {
    my ($self, $length, $timeout) = @_;
    $timeout //= $self->{timeout};
    my $buffer = \$self->{buffer};
    return if length($$buffer) >= $length;
    my $socket = $self->{socket};
    my $SSL = $self->{SSL};
    my $fn = fileno $socket;
    $fn >= 0 or croak "bad file handle $socket";
    while (length $$buffer < $length) {
	my $rv = '';
	vec($rv, $fn, 1) = 1;
	my $n = select($rv, undef, undef, $timeout);
	if ($n > 0) {
	    if (vec($rv, $fn, 1)) {
		my $bytes = sysread ($socket, $$buffer, 16 * 1024, length $$buffer);
		unless ($bytes) {
		    if ($SSL and defined $bytes) {
			$IO::Socket::SSL::SSL_ERROR == IO::Socket::SSL::SSL_WANT_WRITE()
			    or die "internal error: unexpected SSL error: " . IO::Socket::SSL::errstr();
			my $wv = '';
			vec($wv, $fn, 1) = 1;
			$n = select(undef, $wv, undef, $timeout);
		    }
		    else {
			die "socket closed unexpectedly";
		    }
		}
	    }
	}
	$n > 0 or $! == Errno::EINTR or die "connection timed out";
    }
}

sub _readline {
    my $self = shift;
    my $buffer = \$self->{buffer};
    while (1) {
	my $eol = index($$buffer, "\n");
	if ($eol >= 0) {
	    my $line = substr($$buffer, 0, $eol + 1, "");
	    $line =~ s/\r?\n$//;
	    return $line;
	}
	$self->_sysread(length($$buffer) + 1);
    }
}

sub read_http_response {
    my $self = shift;
    my ($code, $msg, $headers) = $self->read_http_response_head();
    my $content_length = header_lookup($headers, 'Content-Length');
    my $body;
    if ($content_length) {
	$self->_sysread($content_length);
	$body = substr $self->{buffer}, 0, $content_length, "";
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

=item $httpc = QVD::HTTPC->new($targe_host, %opts)

Creates a new object and connects it to the given host.

The accepted options are:

=over

=item timeout => $seconds

Sets default timeout for the client

=back

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
