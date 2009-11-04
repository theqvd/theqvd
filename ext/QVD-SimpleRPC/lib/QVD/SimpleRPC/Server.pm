package QVD::SimpleRPC::Server;

use strict;
use warnings;
use Carp;

use URI::Split qw(uri_split);
use QVD::URI qw(uri_query_split);
use QVD::HTTP::StatusCodes qw(:status_codes);

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self;
}

sub set_http_request_processors {
    my ($self, $server, $base) = @_;
    $server->set_http_request_processor(sub { $self->_process_request(@_) },
					GET => $base);
}

sub _process_request {
    my ($self, $httpd, $method, $url, $headers) = @_;
    die "bad method" unless $method eq 'GET';
    my ($scheme, $host, $path, $query, $frag) = uri_split($url);
    my ($function) = $path =~ /(\w+)$/
	or die "bad url";
    my @params = uri_query_split $query;
    $function = "SimpleRPC_$function";

    local $SIG{__DIE__};

    my $data = eval { $self->$function(@params) };
    if ($@) {
	$httpd->send_http_response_with_body(HTTP_OK,
					     'application/json-simplerpc',
					     [],
					     '"",'.$httpd->json->encode("$@")."\r\n");
    }
    else {
	$httpd->send_http_response_with_body(HTTP_OK,
					     'application/json-simplerpc',
					     [],
					     $httpd->json->encode($data)."\r\n");
    }
}


1;

__END__

=head1 NAME

QVD::SimpleRPC::Server - QVD internal RPC mechanism, server side

=head1 SYNOPSIS

  package My::Server;

  use parent 'QVD::HTTPD';

  sub post_configure_hook {
    my $self = shift;
    My::Server::Impl->new()->set_http_request_processor($self, '/base/path/*');
  }

  package My::Server::Impl;

  use parent 'QVD::SimpleRPC::Server';

  sub SimpleRPC_some_remotely_callable_method {
    my ($self, %args) = @_;
    ...
    return $data;
  }

  ...

=head1 DESCRIPTION

This module implements the SimpleRPC server side.

To use it you have to create a new class (the implementation class)
derived from it with the implementation of the methods to be accesible
via RPC.

RPC callable methods are denoted by the prefix C<SimpleRPC_>.

=head2 API

=item QVD::SimplRPC::Server->new

is a dummy constructor that just returns a blessed hash reference.

Note that calling this method on the C<QVD::SimpleRPC::Server> class
is useless. Commonly you want to call it on some derived class
implementing some RPC callable methods.

=item $rpc_server->set_http_request_processors($httpd, $base_url)

Attachs the SimpleRPC server to the given $base_url in the HTTP daemon
object C<$httpd>.

$base_url should end in C</*> in order to expose all the RPC methods
in the implementation class.

=head1 AUTHOR

Salvador FandiE<ntilde>o (sfandino@yahoo.com).

=head1 COPYRIGHT & LICENSE

Copyright C<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

