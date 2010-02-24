package QVD::HTTPC::Parallel;

use strict;
use warnings;
use URI::Escape qw(uri_escape);
use QVD::HTTP::StatusCodes qw(:status_codes);

use parent qw(QVD::ParallelNet::Socket);

BEGIN { *debug = \$Net::Parallel::debug }
our $debug;


my $CRLF = "\r\n";

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{_nph_state} = 'done';
    $self->{_nph_headers} = [];
    $self;
}

sub _queue_input_lines {
    my $self = shift;
    $self->queue_input(join $CRLF, @_, '');
}

sub queue_request {
    my ($self, $method, $url, %opts) = @_;
    my %params = %{delete $opts{params} // {}};
    my @headers = @{delete $opts{headers} // []};
    my $body = delete $opts{body};

    $url .= '?' . join '&', map uri_escape($_).'='.uri_escape($params{$_}), keys %params
        if %params;

    if (defined $body) {
        my $content_type = delete $opts{content_type} // 'text/ascii';
	push @headers, ('Content-Length: ' . length $body,
			'Content-Type: ' . (delete $opts{content_type} // 'text/ascii'));
    }
    $self->{_nph_state} = 'status_line';
    $self->_queue_input_lines("$method $url HTTP/1.1", @headers, '');
    $self->queue_input($body) if defined $body;
    $self->{_nph_request} = $self->{_nps_input} if $debug;
}

sub unqueue_response {
    my $self = shift;
    my $state = delete $self->{_nph_state};
    my $status_line = delete $self->{_nph_status_line};
    my $headers = delete $self->{_nph_headers};
    my $content = delete $self->{_nph_content};
    $self->{_nph_state} = 'done';
    $state eq 'done' or return HTTP_BAD_RESPONSE;
    my ($version, $code, $msg) =
	$status_line =~ m{^HTTP/(\S+)\s+(\d+)\s+(?:\s+(\S.*?))?\s*$}
	    or return HTTP_BAD_RESPONSE;
    wantarray ? ($code, $headers, $content) : $code;
}

sub _nps_done {
    my $self = shift;
    my $state = $self->{_nph_state};
    $debug and warn "state is $state";
    while (1) {
        return 1 if $state eq 'done';
        my $method = "_nph_advance_on_$state";
	$state = $self->$method or return undef;
	$debug and warn "state changed $self->{_nph_state} --> $state";
	$self->{_nph_state} = $state;
    }
}

sub _unqueue_output_line {
    my $self = shift;
    my $bout = \$self->{_nps_output};
    my $ix = index $$bout, "\r\n";
    if ($ix >= 0) {
	# $debug and warn "output line: " . substr($$bout, 0, $ix + 2). ", ix: $ix";
	return substr($$bout, 0, $ix + 2, '');
    }
    undef;
}

sub _nph_advance_on_status_line {
    my $self = shift;
    my $line = $self->_unqueue_output_line;
    if (defined $line) {
	$self->{_nph_status_line} = $line;
	return 'header';
    }
    return undef;
}

sub _nph_advance_on_header {
    my $self = shift;
    while (defined (my $line = $self->_unqueue_output_line)) {

	return ($self->{_nph_chunked} ? 'chunk_header' : 'content')
	    if $line =~ /^\r\n$/;

	$line =~ s/\r?\n$//;
	push @{$self->{_nph_headers}}, $line;
	$line =~ /^Content-Length: (\d+)$/
	    and $self->{_nph_content_length} = $1;
	$line =~ /^Transfer-Encoding:\s*chunked\b/
	    and $self->{_nph_chunked} = 1;
    }
    return undef;
}

sub _nph_advance_on_content {
    my $self = shift;
    my $len = $self->{_nph_content_length} || 0;
    return undef if $len > length $self->{_nps_output};
    $self->{_nph_content} = substr($self->{_nps_output}, 0, $len ,'');
    return 'done';
}

sub _nph_advance_on_chunk_header {
    my $self = shift;
    if (defined (my $line = $self->_unqueue_output_line)) {
	$line =~ s/\s*\r?\n$//;
	$debug and warn "chunk header line: >$line<";
	my ($len) = $line =~ /^([0-9a-f]+)$/i;
	$debug and warn "chunk len: $len";
	$len or return 'done';
	$self->{_nph_chunk_length} = hex $len;
	return 'chunk'
    }
    return undef;
}

sub _nph_advance_on_chunk {
    my $self = shift;
    my $len = $self->{_nph_chunk_length};
    return undef if $len + 2 > length $self->{_nps_output};
    $self->{_nph_content} .= substr($self->{_nps_output}, 0, $len, '');
    substr($self->{_nps_output}, 0, 2, '');
    return 'chunk_header';
}

1;

