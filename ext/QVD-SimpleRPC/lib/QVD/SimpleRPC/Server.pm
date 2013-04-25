package QVD::SimpleRPC::Server;

use strict;
use warnings;
use Carp;

use URI::Split qw(uri_split);
use QVD::URI qw(uri_query_split);
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::Log;

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
    # DEBUG "SimpleRPC function: url $url, $function, query: $query";
    my @params = uri_query_split $query;

    local $SIG{__DIE__};
    my $name = "SimpleRPC_$function";
    if (my $rpc_processor = $self->can($name)) {
        DEBUG "SimpleRPC serving $name(". join(', ', @params).')';
        my $data = eval { $self->$rpc_processor(@params) };
        if ($@) {
            my $saved_err = $@;
            DEBUG "SimpleRPC call $name failed: $saved_err";
            $httpd->send_http_response_with_body(HTTP_OK,
                                                 'application/json-simplerpc',
                                                 [],
                                                 '"",'.$httpd->json->encode($saved_err)."\r\n");
        }
        else {
            DEBUG "SimpleRPC call ok";
            $httpd->send_http_response_with_body(HTTP_OK,
                                                 'application/json-simplerpc',
                                                 [],
                                                 $httpd->json->encode($data)."\r\n");
        }
    }
    else {
        my $name = "HTTP_$function";
        if (my $http_processor = $self->can($name)) {
            DEBUG "Serving raw HTTP GET request $name(". join(", ", @params).')';
            $self->$http_processor($httpd, $headers, @params);
        }
        else {
            $httpd->send_http_error(HTTP_NOT_FOUND);
        }
    }
}

1;

__END__

=head1 NAME

QVD::SimpleRPC::Server - QVD internal RPC mechanism, server side

=head1 SYNOPSIS

  package My::Server;

  use QVD::HTTPD;
  use base 'QVD::HTTPD::Fork';

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

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
