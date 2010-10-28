package QVD::SimpleRPC::Client::Parallel;

use strict;
use warnings;
use Carp;
use QVD::HTTP::StatusCodes qw(:status_codes);
use URI::Split qw(uri_split);
use URI::Escape;
use QVD::Log;

# FIXME: remove Time::HiRes
use Time::HiRes qw(time);

use parent qw(QVD::HTTPC::Parallel);

sub new {
    my ($class, $url_base) = @_;
    my ($scheme, $host, $base, $query, $frag) = uri_split($url_base);
    croak "bad URL base for SimpleRPC client"
	unless ($scheme eq 'http' and !defined($query) and !defined($frag));
    $base //= '/';
    $base .= '/' unless $base =~ m|/$|;
    DEBUG "connecting to VMA at $host";

    my $t0 = time;
    DEBUG "connecting to $host";
    my $socket = IO::Socket::INET->new(PeerAddr => $host,
				       Blocking => 0,
				       Proto => 'tcp');
    my $dt = time - $t0;
    DEBUG "time elapsed in socket creation: $dt";
    my $self = $class->SUPER::new($socket);
    $self->{_npr_base} = $base;
    $host =~ s/:.*$//;
    $self->{_npr_host} = $host;
    return $self;
}

my $json;
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
    my $url = join('', $base, $method, $query);
    DEBUG "SimpleRPC parallel request: $url";
    $self->SUPER::queue_request(GET => $url,
				headers => ["Host: $host"]);
}

sub unqueue_response {
    my $self = shift;
    my ($code, $headers, $body) = $self->SUPER::unqueue_response;
    DEBUG "response code: $code";
    die "HTTP request failed: $code"
	unless $code == HTTP_OK;
    # FIXME: remove this...
    # use Data::Dumper;
    # warn "body:\n" . Dumper($body);
    my $data = _json->decode("[$body]");
    # warn "data:\n" .Dumper($data);
    die $data->[1] if @$data >= 2;
    $data->[0];
}

1;
