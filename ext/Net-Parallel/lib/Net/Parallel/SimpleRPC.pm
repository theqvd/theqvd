package Net::Parallel::SimpleRPC::Client;

use strict;
use warnings;

use URI::Escape;

use parent qw(Net::Parallel::HTTP);

my $json

sub new {
    my ($class, $url_base) = @_;
    my ($scheme, $host, $base, $query, $frag) = uri_split($url_base);
    croak "bad URL base for SimpleRPC client"
	unless ($scheme eq 'http' and !defined($query) and !defined($frag));
    $base //= '/';
    $base .= '/' unless $base =~ m|/$|;
    my $socket = IO::Socket::INET->new(PeerAddr => $host,
				       Blocking => 0,
				       Proto => 'tcp');
    my $self = $class->SUPER($socket);
    $self->{_npr_base} = $base;
    $host =~ s/:.*$//;
    $self->{_npr_host} = $host;
    return $self;
}

sub _json {
    $json //= do {
	require JSON;
	JSON->new->ascii->pretty
    };
}

sub queue_request {
    my $self = shift;
    my $method = shift;
    my $query = '';
    if (@_) {
	my @query;
	for (@_) {
	    my $key = shift;
	    my $value = shift;
	    push @query, uri_escape($key).'='.uri_escape($value);
	}
	$query .= '?'.join('&', @query);
    }
    my $base = $self->{_npr_base};
    my $host = $self->{_npr_host};
    $self->SUPER::queue_request(GET => join('', $base, $method, $query),
				headers => ["Host: $host"]);
}

sub unqueue_response {
    my $self = shift;
    my ($code, $headers, $body) = $self->SUPER::unqueue_response;
    die "HTTP request failed: $code - $msg"
	unless $code == HTTP_OK;
    my $data = $json->decode("[$body]");
    die $data->[1] if @$data >= 2;
    $data->[0];
}

1;
