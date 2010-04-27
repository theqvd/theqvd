package QVD::SimpleRPC::Client;

use strict;
use warnings;

use Carp;
our @CARP_NOT = qw(QVD::HTTPC);

use URI::Split qw(uri_split);
use URI::Escape qw(uri_unescape uri_escape);
use QVD::HTTPC;
use QVD::HTTP::StatusCodes qw(:status_codes);
use JSON;
use Log::Log4perl qw(:easy);

Log::Log4perl::init('log4perl.conf');

my $json = JSON->new->ascii->pretty;

sub new {
    my ($class, $url_base, %opts) = @_;
    my ($scheme, $host, $base, $query, $frag) = uri_split($url_base);
    croak "bad URL base for SimpleRPC client"
	unless ($scheme eq 'http' and !defined($query) and !defined($frag));
    my $httpc = QVD::HTTPC->new($host, %opts);
    # FIXME use Log4perl
    warn $@ if $@;
    $base //= '/';
    $base .= '/' unless $base =~ m|/$|;
    my $self = { httpc => $httpc,
    		 host => $host,
		 base => $base
	       };
    bless $self, $class;
    $self
}

sub is_connected {
    my $self = shift;
    $self->{httpc}
}

sub connect {
    my $self = shift;
    my $httpc = eval { QVD::HTTPC->new($self->{host}) };
    # FIXME use Log4perl
    warn $@ if $@;
    $self->{httpc} = $httpc;
    $self->{httpc}
}

sub _make_request {
    my $self = shift;
    return undef unless $self->{httpc};
    my $method = shift;
    my @query;
    for (@_) {
	my $key = shift;
	my $value = shift;
	push @query, uri_escape($key).'='.uri_escape($value);
    }
    my $query = (@query ? '?'.join('&', @query) : '');

    my $url = "$self->{base}$method$query";
    DEBUG "SimpleRPC request: $url";
    my ($code, $msg, $headers, $body) =
	$self->{httpc}->make_http_request(GET => $url);
    die "HTTP request failed: $code - $msg"
	unless $code == HTTP_OK;

    my $data = $json->decode("[$body]");

    # FIXME: remove this:
    use Data::Dumper;
    DEBUG "remote JSON response\n" . Dumper $data;

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

=item $rpcc = QVD::SimpleRPC::Client->new($base_url, %opts)

Creates a new client object and stablishes the HTTP connection to the
remote server.

The accepted options are:

=over

=item Timeout => $timeout

=back

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
