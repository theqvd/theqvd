package Net::Parallel::HTTP;

use strict;
use warnings;
use URI::Escape qw(uri_escape);

use parent qw(Net::Parallel::Socket);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{_nph_state} = 'status_line';
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

    $self->_queue_input_lines("$method $url HTTP/1.1", @headers, '');
    $self->queue_input($body) if defined $body;
}

sub _np_done {
    my $self = shift;
    while (1) {
        my $state = $self->{_nph_state};
        return 1 if $state eq 'done';
        my $method = "_np_done_on_$state";
        $self->$method or return 0;
    }
}

sub _unqueue_output_line {

}

sub _np_done_on_status_line {
    
}

1;

