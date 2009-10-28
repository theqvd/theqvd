package QVD::Frontend::Plugin::L7R;

use strict;
use warnings;

use IO::Socket::INET;
use URI::Split qw(uri_split);

use IO::Socket::Forwarder qw(forward_sockets);
use QVD::VMAS;
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTP::Headers qw(header_eq_check);
use QVD::URI qw(uri_query_split);

sub set_http_request_processors {
    my ($class, $server, $url_base) = @_;
    $server->set_http_request_processor( \&_connect_to_vm_processor,
					 GET => $url_base . "connect_to_vm");
}

sub _connect_to_vm_processor {
    my ($server, $method, $url, $headers) = @_;
    # FIXME Move this to a configuration file
    my $vm_start_timeout = 60;

    unless (header_eq_check($headers, Connection => 'Upgrade') and
	    header_eq_check($headers, Upgrade => 'QVD/1.0')) {
	$server->send_http_error(HTTP_UPGRADE_REQUIRED);
	return;
    }

    my ($path, $query) = (uri_split $url)[2, 3];
    my %params = uri_query_split $query;
    my $user_id = $params{user_id};
    unless (defined $user_id) {
	$server->send_http_error(HTTP_UNPROCESSABLE_ENTITY);
	return;
    }

    $server->send_http_response(HTTP_PROCESSING,
				'X-QVD-VM-Status: Checking VM');

    my $db = QVD::DB->new();
    my $vmas = QVD::VMAS->new($db);
    my @vms = $vmas->get_vms_for_user($user_id);
    # FIXME this limits number of VMs per user to 1
    my $vm = $vms[0];

#: El L7R solo puede iniciar una sesion desde el estado Disconnected, en
#: cualquier otro estado tendra que usar el comando Abort para cerrar la
#: sesion actual, esperar a que el estado cambie a Disconnected y entonces
#: empezar la sesion de la manera normal. 

    warn "L7R: user_state is ".$vm->user_state;
    if (defined $vm->user_state && $vm->user_state ne 'disconnected') {
	# FIXME There is no timeout???
	$vmas->schedule_user_cmd($vm, 'Abort');
	while (defined $vm->user_state && $vm->user_state ne 'disconnected') {
	    warn "L7R: user_state is ".$vm->user_state." Waiting for 'disconnected'";
	    $vm->discard_changes;
	    sleep 5;
	}
    }

#: Connecting: el usuario ha iniciado sesión y ha pedido ser conectado a una
#: maquina virtual, pero aun no se ha podido cerrar el bucle (por ejemplo,
#: porque hay que esperar a que la VM se levante). 

    $vmas->push_user_state($vm, 'connecting');
    unless ($vmas->assign_host_for_vm($vm)) {
	# FIXME VM could not be assigned to a host, notify client?
	$server->send_http_error(HTTP_BAD_GATEWAY);
	return;
    }
    warn "L7R: Got host ".$vm->host_id;
    my $r = $vmas->schedule_start_vm($vm);
    unless ($r) {
	# The VM couldn't be scheduled for starting
	# FIXME Pass the error message to the client?
	$server->send_http_error(HTTP_BAD_GATEWAY);
	return;
    }
    warn "L7R: VM ".$vm->vm_id." started!";
    # Wait for the VMA to come online
    # FIXME use time() for checking timeout
    my $timeout_counter = $vm_start_timeout/5;
    while ($timeout_counter --> 0) {
	$server->send_http_response(HTTP_PROCESSING,
	    'X-QVD-VM-Status: Starting VM');
	warn "L7R: Waiting for VMA to start on VM ".$vm->vm_id.", $timeout_counter";
	$r = $vmas->get_vma_status($vm);
	last if exists $r->{status} && $r->{status} eq 'ok';
	sleep 5;
    }
    # Start timed out
    # FIXME Pass the error message to the client?
    if ($timeout_counter < 0) {
	$server->send_http_error(HTTP_BAD_GATEWAY);
	$vmas->push_user_state($vm, 'disconnected');
	return;
    }

    # Send 'connect' x_cmd
    $vmas->schedule_x_cmd($vm, 'connect') or
	$server->send_http_error(HTTP_BAD_GATEWAY), return;
    warn "L7R: Sent connect";
    
    # Monitor for Forward or Abort commands
    # FIXME There really is no timeout???
    for (;;) {
	warn "L7R: Waiting for user cmd, now it's ".$vm->user_cmd;
	if (defined $vm->user_cmd) {
	    if ($vm->user_cmd eq 'Forward') {
		$vmas->clear_user_cmd($vm);
		last;
	    }
	    if ($vm->user_cmd eq 'Abort') {
		$vmas->clear_user_cmd($vm);
		$vmas->push_user_state($vm, 'disconnected');
                # FIXME Pass the message to the client?
		$server->send_http_error(HTTP_BAD_GATEWAY);
		return;
	    }
	} else {
	    sleep 5;
	    $vm->discard_changes;
	}
    }
    
    warn "L7R: Got Forward";

    $server->send_http_response(HTTP_PROCESSING,
				'X-QVD-VM-Status: Connecting to VM');

    my $socket = IO::Socket::INET->new(PeerAddr => $vm->vm_address,
				       PeerPort => $vm->vm_x_port,
				       Proto => 'tcp');
    unless ($socket) {
	$server->send_http_response(HTTP_PROCESSING,
				    'X-QVD-VM-Status: Retry connection',
				    "X-QVD-VM-Info: Connection to vm failed");
	return;
    }

    $server->send_http_response(HTTP_SWITCHING_PROTOCOLS,
				    'X-QVD-VM-Status: Connected to VM');

    $vmas->push_user_state($vm, 'connected');

    # TODO Fork here in order to monitor the DB for Abort cmd while forwarding?
    forward_sockets(\*STDIN, $socket);

    for (;;) {
	warn "L7R: Waiting for user cmd Abort";
	if (defined $vm->user_cmd and $vm->user_cmd eq 'Abort') {
	    $vmas->clear_user_cmd($vm);
	    $vmas->push_user_state($vm, 'disconnected');
	    last;
	} else {
	    sleep 5;
	    $vm->discard_changes;
	}
    }
}

1;

__END__

=head1 NAME

QVD::Frontend::Plugin::L7R - plugin for L7R functionality

=head1 SYNOPSIS

  use QVD::Frontend::Plugin::L7R;
  QVD::Frontend::Plugin::L7R->set_http_request_processors($httpd, $base_url);

=head1 DESCRIPTION

This module wraps the L7R functionality as a plugin for L<QVD::Frontend>.

=head2 API

=over

=item QVD::Frontend::Plugin::L7R->set_http_request_processors($httpd, $base_url)

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

