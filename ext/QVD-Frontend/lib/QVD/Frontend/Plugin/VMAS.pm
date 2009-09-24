package QVD::Frontend::Plugin::VMAS;

use strict;
use warnings;

use URI::Split qw(uri_split);

use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::VMAS::Client;
use QVD::URI qw(uri_query_split);

use QVD::DB;

sub set_http_request_processors {
    my ($class, $server, $url_base) = @_;
    $server->set_http_request_processor(\&_start_vm, GET => $url_base.'start_vm');
    $server->set_http_request_processor(\&_stop_vm, GET => $url_base.'stop_vm');
}

sub _start_vm {
    my ($server, $method, $url, $headers) = @_;
    my ($path, $query) = (uri_split $url)[2, 3];
    my %params = uri_query_split $query;
    my $id = $params{id};
    unless (defined $id) {
	$server->send_http_error(HTTP_UNPROCESSABLE_ENTITY);
	return;
    }
    
    my $schema = QVD::DB->new();
    my $vm = $schema->resultset('VM')->find({id => $id});
    unless (defined $vm) {
	$server->send_http_error(HTTP_NOT_FOUND);
	return;
    }
    my $osi = $vm->osi;
    unless (defined $osi) {
	$server->send_http_error(HTTP_INTERNAL_SERVER_ERROR);
	return;
    }
    
    my $pid = fork;
    if (!$pid) {
	defined $pid or die "Couldn't fork process for vm: $!";
	{ exec "kvm -redir tcp:2222::22 -redir tcp:3030::3030 -redir tcp:5000::5000 -pidfile /var/run/qvd/vm-$id.pid -hda ".$osi->disk_image };
	die "Couldn't exec process for vm: $!";
    }
    unless (-e "/var/run/qvd/vm-$id.pid") {
	$server->send_http_error(HTTP_INTERNAL_SERVER_ERROR);
    }

    my $vma_client = QVD::VMAS::Client->new;
    until ($vma_client->is_connected) {
	$server->send_http_response(HTTP_PROCESSING,
		'X-QVD-VM-Status: starting');
	sleep 60;
	$vma_client->connect;
    }
    if ($vma_client->status) {
	$server->send_http_response(HTTP_OK,
		'X-QVD-VM-Status: started');
    } else {
	$server->send_http_error(HTTP_INTERNAL_SERVER_ERROR);
    }
}

sub _stop_vm {
    my ($server, $method, $url, $headers) = @_;
    my ($path, $query) = (uri_split $url)[2, 3];
    my %params = uri_query_split $query;
    my $id = $params{id};
    unless (defined $id) {
	$server->send_http_error(HTTP_UNPROCESSABLE_ENTITY);
	return;
    }
    
    my $schema = QVD::DB->new();
    my $vm = $schema->resultset('VM')->find({id => $id});
    unless (defined $vm) {
	$server->send_http_error(HTTP_NOT_FOUND);
	return;
    }

    my $vma_client = QVD::VMAS::Client->new;
    unless ($vma_client->is_connected) {
	$server->send_http_error(HTTP_UNPROCESSABLE_ENTITY);
	return;
    }

    unless ($vma_client->poweroff) {
	$server->send_http_ERROR(HTTP_INTERNAL_SERVER_ERROR);
	return;
    }

    my $kvm_pid = `cat /var/run/qvd/vm-$id.pid`;
    while (kill 0, $kvm_pid) {
	$server->send_http_response(HTTP_PROCESSING,
		'X-QVD-VM-Status: stopping');
	sleep 5;
    }
    $server->send_http_response(HTTP_OK,
	    'X-QVD-VM-Status: stopped');
}

1;

=head1 NAME

QVD::Frontend::Plugin::VMAS - plugin for VMAS functionality

=head1 SYNOPSIS

  use QVD::Frontend::Plugin::VMAS;
  QVD::Frontend::Plugin::VMAS->set_http_request_processors($httpd, $base_url);

=head1 DESCRIPTION

This module wraps the VMAS functionality as a plugin for L<QVD::Frontend>.

=head2 API

=over

=item QVD::Frontend::Plugin::VMAS->set_http_request_processors($httpd, $base_url)

registers the plugin into the HTTP daemon C<$httpd> at the given
C<$base_url>.

=back

=head1 AUTHOR

Salvador FandiE<ntilde>o, C<< <sfandino at yahoo.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
