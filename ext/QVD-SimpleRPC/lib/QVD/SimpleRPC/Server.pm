package QVD::SimpleRPC::Server;

use strict;
use warnings;
use Carp;

use URI::Split qw(uri_split);
use QVD::URI qw(uri_query_split);
use QVD::HTTP::StatusCodes qw(:status_codes);

sub new {
    my ($class) = @_;
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

    use Data::Dumper;
    print STDERR Dumper [$function, @params];

    local $SIG{__DIE__};

    my $data = eval { $self->$function(@params) };
    if ($@) {
	print STDERR Dumper \$@;
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
    My::Server::Impl->new()->set_htto_request_processor($self, '/base/path/*');
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

=head1 AUTHOR

Salvador FandiE<ntilde>o (sfandino@yahoo.com).

=head1 COPYRIGHT & LICENSE

Copyright C<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

