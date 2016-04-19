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

use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTP::Headers qw(header_lookup);
use QVD::Config;

my $CRLF = "\r\n";

# List of all the IO::Socket::SSL options, except the ones that only make sense on the server,
# and ones we don't wish to allow.
#
# Excluded:
#     SSL_server (this is a client)
#     SSL_startHandshake (we always want to be using SSL)
#     SSL_verify_mode (we always use SSL_VERIFY_PEER)
#
# Added:
#     SSL_ca_path_alt (not a real OpenSSL option, we handle it)
#
my @SSL_OPTIONS = qw( SSL_hostname SSL_ca SSL_ca_file SSL_ca_path SSL_client_ca SSL_client_ca_file SSL_fingerprint
                      SSL_passwd_cb SSL_use_cert SSL_version SSL_cipher_list SSL_honor_cipher_order SSL_dh_file SSL_dh SSL_ecdh_curve
                      SSL_verify_callback SSL_verifycn_scheme SSL_verifycn_publicsuffix SSL_verifycn_name 
                      SSL_check_crl SSL_crl_file SSL_ocsp_mode SSL_ocsp_staple_callback SSL_ocsp_cache SSL_reuse_ctx
                      SSL_create_ctx_callback SSL_session_cache_size SSL_session_cache SSL_session_key SSL_session_id_context
                      SSL_error_trap SSL_npn_protocols SSL_alpn_protocols SSL_ca_path_alt SSL_ocsp_no_resolve
                    );

sub _create_socket {
    my $self = shift;
    my $target = $self->{target};
    my $SSL = $self->{SSL};
    my $s;
    if ($SSL) {
        require IO::Socket::SSL;
        require Net::SSLeay;
        Net::SSLeay::load_error_strings();

        die "IO::Socket::SSL >= 2.020 required" unless ( $IO::Socket::SSL::VERSION >= 2.020 );

        IO::Socket::SSL->import('debug3');

        my %args = ( SSL_verify_mode => IO::Socket::SSL::SSL_VERIFY_PEER() );
        $args{$_} = $self->{$_} for grep { exists $self->{$_} } @SSL_OPTIONS;

        # This is not a real IO::Socket::SSL argument
        delete $args{SSL_ca_path_alt};
        delete $args{SSL_ocsp_no_resolve};

        if (defined $args{SSL_ca_path} && defined $self->{SSL_ca_path_alt}) {
            # SSL_ca_path_alt is deprecated since as of IO::Socket::SSL 2.020 the CA path is
            # an array. Support the old way of doing things here.

            if ( ref($args{SSL_ca_path}) eq "ARRAY" ) {
                push $args{SSL_ca_path}, $self->{SSL_ca_path_alt};
            } else {
                $args{SSL_ca_path} = [ $args{SSL_ca_path}, $self->{SSL_ca_path_alt} ];
            }
        }

        # Some sensible defaults
        my $sslhost = $target;
        $sslhost =~ s/:.*$//;

        $args{SSL_version}         //= "!SSLv3:!SSLv2:!TLSv1";
        $args{SSL_verifycn_scheme}   = "none";
        $args{SSL_verifycn_name}   //= $sslhost;
        $args{SSL_hostname}        //= $sslhost;
        $args{SSL_ocsp_mode}       //= IO::Socket::SSL::SSL_OCSP_FULL_CHAIN() | IO::Socket::SSL::SSL_OCSP_FAIL_HARD();

        use Data::Dumper;
        print STDERR "ssl args:\n" . Dumper( \%args );

        $s = IO::Socket::SSL->new(PeerAddr => $target, Blocking => 0, %args);

        if ( $s && ! $s->verify_hostname( $args{SSL_verifycn_name}, $self->{SSL_verifycn_scheme} // "http" ) ) {
            $self->{failed_socket} = $s;
            print STDERR "ERRSTR : ". $s->errstr() . "\n";
            print STDERR "SSL ERR: $IO::Socket::SSL::SSL_ERROR\n";
            die "hostname verification failed: " . $s->errstr();
        }

        if ( $s && !$self->{SSL_ocsp_no_resolve} ) {
            $IO::Socket::SSL::DEBUG=3;
            my $ocsp = $s->ocsp_resolver();
            my $ocsp_errors = $ocsp->resolve_blocking();
            if ( $ocsp_errors ) {
                $self->{failed_socket} = $s;
                die "OCSP validation error: $ocsp_errors";
            }
        }
    }
    else {
        $s = IO::Socket::INET->new(PeerAddr => $target, Blocking => 0);
    }
    $s or croak "Unable to connect to $target: " . ($SSL ? $IO::Socket::SSL::SSL_ERROR : $!);
    $self->{socket} = $s;
}

sub new {
    my ($class, $target, %opts) = @_;
    my $self = {
                 bin => '',
		 bout => ''
               };

    bless $self, $class;

    $self->connect($target, %opts) if ($target);
    $self;
}

sub connect {
    my ($self, $target, %opts) = @_;

    $self->{target} = $target;
    $self->{$_} = delete $opts{$_} for ("timeout", "SSL", grep { exists $opts{$_} } @SSL_OPTIONS);
    keys %opts and croak "unknown constructor option(s) " . join(', ', keys %opts);

    $self->_create_socket();
    setsockopt $self->{socket}, IPPROTO_TCP, TCP_NODELAY, 1;
 
}

sub read_buffered {
    my $self = shift;
    my $data = $self->{bin};
    $self->{bin} = '';
    $data;
}

sub get_socket { shift->{socket} }

# Used to access IO::Socket::SSL information when the connection failed to
# complete due to an error.
sub get_failed_socket { shift->{failed_socket} }

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
			my ($const) = grep { $!{$_} } keys %!;
		    die "socket closed unexpectedly: $const ($!)";
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
    push @headers, "User-Agent: QVD::HTTPC/$VERSION ($^O)";
    my $body = delete $opts{body};

    if ($params and %$params) {
	my @kvs = map {
	    uri_escape($_) . '=' . uri_escape($params->{$_})
	} keys %$params;
	$url .= '?' . join('&', @kvs)
    }

    if (defined $body) {
	my $content_type = delete $opts{content_type} // 'text/ascii';
	push @headers, ("Content-Length: " . length $body,
			"Content-Type: $content_type");
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

    my $select_mask = '';
    my $fn = fileno $socket;
    $fn >= 0 or croak "bad file handle $socket";
    vec($select_mask, $fn, 1) = 1;

    my $n = 0;
    while (1) {
        my $missing = $length - length $$bin;
        return unless $missing > 0;
        my $bytes = sysread ($socket, $$bin, $missing, length $$bin);
        next if $bytes;

        my ($wv, $rv) = ('', '');
        if ($self->{SSL} and not defined $bytes) {
            if    ($IO::Socket::SSL::SSL_ERROR == IO::Socket::SSL::SSL_WANT_READ()) {
                $rv = $select_mask;
            }
            elsif ($IO::Socket::SSL::SSL_ERROR == IO::Socket::SSL::SSL_WANT_WRITE()) {
                $wv = $select_mask;
            }
            else {
                die "internal error: unexpected SSL error: " . IO::Socket::SSL::errstr();
            }
        }
        else {
            $n > 0 and die "socket closed unexpectedly";
            $rv = $select_mask;
        }

        $n = select($rv, $wv, undef, $timeout);
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

sub is_ssl {
    my $self = shift;
    return $self->{SSL};
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
