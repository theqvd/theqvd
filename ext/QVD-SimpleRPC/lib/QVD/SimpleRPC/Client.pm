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

__END__

=head1 NAME

QVD::SimpleRPC::Client - QVD internal RPC mechanism, client side

=head1 SYNOPSIS

  use QVD::SimpleRPC::Client;

  my $cl = QVD::SimpleRPC::Client->new('http://host:6060/some/path/');
  my $r = $cl->some_remote_method(foo => $bar, doz => $doz);

=head1 DESCRIPTION

This module implements the client side of the SimpleRPC protocol.

=head2 API

The following methods are available:

=over

=item $rpcc = QVD::SimpleRPC::Client->new($base_url)

Creates a new client object and stablishes the HTTP connection to the
remote server.

=item $rpcc->$method(@ARGS)

calls the method of the given name on the remote side and returns the
result.

=back

=head1 AUTHOR

Salvador FandiE<ntilde>o (sfandino@yahoo.com).

=head1 COPYRIGHT & LICENSE

Copyright C<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

