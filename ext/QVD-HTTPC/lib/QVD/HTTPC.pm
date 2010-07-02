package QVD::HTTPC;

our $VERSION = '0.01';

use 5.010;

use warnings;
use strict;
use Carp;

use IO::Socket::INET;
use URI::Escape qw(uri_escape);
use Errno;
use File::Spec;
use Socket qw(IPPROTO_TCP TCP_NODELAY);
use Crypt::OpenSSL::X509;

use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTP::Headers qw(header_lookup);
use QVD::Config;

my $CRLF = "\r\n";

my $cert_pem_str = ''; sub cert_pem_str { $cert_pem_str; }
my $cert_hash    = ''; sub cert_hash    { $cert_hash; }
my $cert_data    = ''; sub cert_data    { $cert_data; }

## callback receives:
# 1) a true/false value that indicates what OpenSSL thinks of the certificate
# 2) a C-style memory address of the certificate store
# 3) a string containing the certificate's issuer attributes and owner attributes
# 4) a string containing any errors encountered (0 if no errors).
## returns:
# 1 or 0, depending on whether it thinks the certificate is valid or invalid.
sub ssl_cb {
    my ($ssl_thinks, $mem_addr, $attrs, $errs) = @_;

    $cert_pem_str = Net::SSLeay::PEM_get_string_X509 (Net::SSLeay::X509_STORE_CTX_get_current_cert ($mem_addr));
    my $x509 = Crypt::OpenSSL::X509->new_from_string ($cert_pem_str);

    $cert_hash = $x509->hash;
    $cert_data = sprintf <<'EOF', (join ':', $x509->serial=~/../g), $x509->issuer, $x509->notBefore, $x509->notAfter, $x509->subject;
Serial: %s

Issuer: %s

Validity:
    Not before: %s
    Not after:  %s

Subject: %s
EOF

    #print "cert_hash ($cert_hash)\n";
    #print "ssl_thinks ($ssl_thinks) mem_addr ($mem_addr) attrs ($attrs) errs ($errs)\n";
    #printf "cert_pem_str (%s)\n", cert_pem_str;
    #printf "cert_data (%s)\n", cert_data;

    return $ssl_thinks;
}

sub _create_socket {
    my $self = shift;
    my $target = $self->{target};
    my $SSL = $self->{SSL};

    if ($SSL) {
        require IO::Socket::SSL;
        require Net::SSLeay;
        Net::SSLeay::load_error_strings();
        my $s;

        my %ssl_args = (
            SSL_verify_mode     => 1,
            SSL_ca_path         => File::Spec->catfile (($ENV{HOME} || $ENV{APPDATA}), cfg('path.ssl.ca.personal')),
            SSL_verify_callback => \&ssl_cb,
        );
        unless ($s = IO::Socket::SSL->new(PeerAddr => $target, Blocking => 0, %ssl_args)) {
            $ssl_args{'SSL_ca_path'} = cfg('path.ssl.ca.system');
            $s = IO::Socket::SSL->new(PeerAddr => $target, Blocking => 0, %ssl_args);
        }

        $self->{socket} = $s or return 0;
    }
    else {
        $self->{socket} = IO::Socket::INET->new(PeerAddr => $target, Blocking => 0) or do {
            my $errmsg = "Unable to connect to $target";
            $SSL and $errmsg .= ': ' . $IO::Socket::SSL::SSL_ERROR;
            croak $errmsg;
        };
    }

    return 1;
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
		 bin => '',
		 bout => '' };
    bless $self, $class;
    $self->_create_socket() or return 0;
    setsockopt $self->{socket}, IPPROTO_TCP, TCP_NODELAY, 1;
    $self;
}

sub read_buffered {
    my $self = shift;
    my $data = $self->{bin};
    $self->{bin} = '';
    $data;
}

sub get_socket { shift->{socket} }

sub _print {
    my $self = shift;
    $self->_queue(@_);
    $self->_send_queued;
}

sub _queue {
    shift->{bout} .= join('', @_);
}

sub _send_queued {
    my $self = shift;
    my $socket = $self->{socket};
    my $timeout = $self->{timeout};
    my $SSL = $self->{SSL};
    my $bout = \$self->{bout};

    my $fn = fileno $socket;
    $fn >= 0 or croak "bad file handle $socket";
    while (length $$bout) {
	my $wv = '';
	vec($wv, $fn, 1) = 1;
	my $n = select(undef, $wv, undef, $timeout);
	if ($n > 0) {
	    if (vec($wv, $fn, 1)) {
		my $bytes = syswrite($socket, $$bout, 16 * 1024);
		if ($bytes) {
		    substr($$bout, 0, $bytes, '');
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
    my $bin = \$self->{bin};
    return if length($$bin) >= $length;
    my $socket = $self->{socket};
    my $SSL = $self->{SSL};
    my $fn = fileno $socket;
    $fn >= 0 or croak "bad file handle $socket";
    while (length $$bin < $length) {
	my $rv = '';
	vec($rv, $fn, 1) = 1;
	my $n = select($rv, undef, undef, $timeout);
	if ($n > 0) {
	    if (vec($rv, $fn, 1)) {
		my $bytes = sysread ($socket, $$bin, 16 * 1024, length $$bin);
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
    my $bin = \$self->{bin};
    while (1) {
	my $eol = index($$bin, "\n");
	if ($eol >= 0) {
	    my $line = substr($$bin, 0, $eol + 1, "");
	    $line =~ s/\r?\n$//;
	    return $line;
	}
	$self->_sysread(length($$bin) + 1);
    }
}

sub read_http_response {
    my $self = shift;
    my ($code, $msg, $headers) = $self->read_http_response_head();
    my $content_length = header_lookup($headers, 'Content-Length');
    my $body;
    if ($content_length) {
	$self->_sysread($content_length);
	$body = substr $self->{bin}, 0, $content_length, "";
    }
    ($code, $msg, $headers, $body);
}

sub make_http_request {
    my $self = shift;
    $self->send_http_request(@_);
    $self->read_http_response;
}

1;

__END__

=head1 NAME

QVD::HTTPC - QVD HTTP client package

=head1 SYNOPSIS

    use QVD::HTTPC;

    my $client = QVD::HTTPC->new("www.qvd.org:3333");

    my ($code, $msg, $headers, $data) =
        $client->make_http_query(GET => '/where_is_my_car');

    defined $data and print $data;

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

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
