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
use QVD::Config;

sub set_http_request_processors {
    my ($class, $server, $url_base) = @_;
    $server->set_http_request_processor( \&_connect_to_vm_processor,
					 GET => $url_base . "connect_to_vm");
}

sub _abort_session {
    my ($vm, $vmas) = @_;
    $vmas->push_user_state($vm, 'aborting');
    $vmas->disconnect_nx($vm);
    while (defined $vm->x_state and $vm->x_state ne 'disconnected') {
	sleep 5;
	$vm->discard_changes;
    }
    $vmas->push_user_state($vm, 'disconnected');
    warn "L7R: aborting session";
}

sub _connect_to_vm_processor {
    my ($server, $method, $url, $headers) = @_;
    my $vm_start_timeout = QVD::Config->get('vm_start_timeout');

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

    # FIXME timeout?
    # Is there an open session?
    while (1) {
	$vm->discard_changes;
	if (! defined $vm->user_state || $vm->user_state eq 'disconnected') {
	    $vmas->push_user_state($vm, 'connecting');
	    $vmas->txn_commit;
	    last;
	} else {
	    if ($vm->user_state eq 'connected') {
		$vmas->disconnect_nx($vm);
	    } else {
		$vmas->schedule_user_cmd($vm, 'Abort');
		$vmas->txn_commit;
	    }
	    sleep 5;
	    warn "L7R: user_state is ".$vm->user_state." Waiting for 'disconnected'";
	    $db->txn_rollback;
	}
    }

#: Connecting: el usuario ha iniciado sesión y ha pedido ser conectado a una
#: maquina virtual, pero aun no se ha podido cerrar el bucle (por ejemplo,
#: porque hay que esperar a que la VM se levante). 

    # start the vm if it's not running already
    if ($vm->vm_state ne 'running') {

	unless ($vmas->assign_host_for_vm($vm)) {
# FIXME VM could not be assigned to a host, notify client?
	    $server->send_http_error(HTTP_BAD_GATEWAY);
	    return;
	}
	$vmas->txn_commit;
	warn "L7R: starting vm ".$vm->vm_id." on host ".$vm->host_id;
	my $r = $vmas->schedule_start_vm($vm);
	$vmas->txn_commit;
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
    }

    # Send 'connect' x_cmd
    $vmas->schedule_x_cmd($vm, 'connect') or
	$server->send_http_error(HTTP_BAD_GATEWAY), return;
    warn "L7R: Sent x connect";
    $vmas->txn_commit;
    
# FIXME timeout?
    while (1) {
	$vm->discard_changes;
	# abort?
	if (defined $vm->user_cmd && $vm->user_cmd eq 'Abort') {
	    _abort_session($vm, $vmas);
	    $vmas->clear_user_cmd($vm);
	    $vmas->push_user_state($vm, 'disconnected');
	    $vmas->txn_commit;
# FIXME Pass the message to the client?
	    $server->send_http_error(HTTP_BAD_GATEWAY);
	    return;
	}

	warn "L7R: x_state is ".$vm->x_state." Waiting for 'listening'";
	if ($vm->x_state eq 'listening') {
	    last;
	} else {
	    $server->send_http_response(HTTP_PROCESSING,
		    'X-QVD-VM-Status: Starting VM');
	    $db->txn_rollback;
	    sleep 5;
	}
    }

    # abort?
    if (defined $vm->user_cmd && $vm->user_cmd eq 'Abort') {
	_abort_session($vm, $vmas);
	$vmas->clear_user_cmd($vm);
	$vmas->push_user_state($vm, 'disconnected');
	$vmas->txn_commit;
# FIXME Pass the message to the client?
	$server->send_http_error(HTTP_BAD_GATEWAY);
	return;
    }
    
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
    $vmas->txn_commit;

    forward_sockets(\*STDIN, $socket);

    $vmas->push_user_state($vm, 'disconnected');
    $vmas->txn_commit;
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

