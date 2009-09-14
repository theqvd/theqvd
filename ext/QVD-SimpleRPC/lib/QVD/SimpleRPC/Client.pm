package QVD::SimpleRPC::Client;

use strict;
use warnings;
use Carp;

use URI::Split qw(uri_split);
use URI::Escape qw(uri_unescape uri_escape);
use QVD::HTTPC;
use QVD::HTTP::StatusCodes qw(:status_codes);

sub new {
    my ($class, $url_base) = @_;
    my ($scheme, $host, $base, $query, $frag) = uri_split($url_base);
    croak "bad URL base for SimpleRPC client"
	unless ($scheme eq 'http' and !defined($query) and !defined($frag));
    my $httpc = QVD::HTTPC->new($host);
    $base //= '/';
    $base .= '/' unless $base =~ m|/$|;
    my $self = { httpc => $httpc,
		 base => $base
	       };
    bless $self, $class;
    $self
}

sub _json {
    my $self = shift;
    $self->{_json} ||= do {
	require JSON;
	JSON->new->ascii->pretty;
    }
}

sub _make_request {
    my $self = shift;
    my $method = shift;
    my @query;
    for (@_) {
	my $key = shift;
	my $value = shift;
	push @query, uri_escape($key).'='.uri_escape($value);
    }
    my $query = (@query ? '?'.join('&', @query) : '');
    my ($code, $msg, $headers, $body) =
	$self->{httpc}->make_http_request(GET => "$self->{base}/$method$query");
    unless ($code == HTTP_OK) {
	die "HTTP request failed: $code - $msg";
    }
    my $data = $self->_json->decode("[$body]");
    use Data::Dumper;
    print STDERR Dumper [JSON_response => @$data];

    die $data->[1] if @$data >= 2;
    $data->[0];
}

sub AUTOLOAD {
    our $AUTOLOAD;
    my $method = $AUTOLOAD;
    $method =~ s/.*:://;
    my $self = shift;
    $self->_make_request($method, @_);
}

sub DESTROY {}

1;
