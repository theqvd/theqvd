package QVD::L7R;

our $VERSION = '0.01';

use warnings;
use strict;
use Carp;

use IO::Socket::Forwarder qw(forward_sockets);
use QVD::VMAS;
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTP::Headers qw(header_lookup header_eq_check);
use QVD::URI qw(uri_query_split);
use QVD::Config;

use Log::Log4perl qw(:easy);
Log::Log4perl::init('log4perl.conf');

use parent qw(QVD::HTTPD);

sub post_configure_hook {
    my $self = shift;
    $self->set_http_request_processor(\&_connect_to_vm_processor,
				       GET => '/qvd/connect_to_vm');
}

sub _check_abort_session {
    my ($vm, $vmas, $coderef) = @_;
    my $abort_session = $vmas->txn_do(sub {
	$vm->discard_changes;
	if (defined $vm->user_cmd and $vm->user_cmd eq 'Abort') {
	    $vmas->push_user_state($vm, 'aborting');
	    $vmas->clear_user_cmd($vm);
	    1;
	} else {
	    $coderef->() if defined $coderef;
	    0;
	}
    });
    return 0 unless $abort_session;
    _abort_session($vm, $vmas);
}

sub _abort_session {
    my ($vm, $vmas) = @_;
    
    DEBUG "Abort session: aborting";
    if ($vm->x_state ne 'disconnected') {
	DEBUG "Session abort: disconnect session";
	my $r = $vmas->disconnect_nx($vm);
	while ($vm->x_state ne 'disconnected') {
	    DEBUG "x_state is ".$vm->x_state.", waiting for disconnected";
	    sleep 5;
	    $vm->discard_changes;
	}
    }
    $vmas->push_user_state($vm, 'disconnected');
    INFO "Session abort completed";
    1
}

# FIXME refactor this method into smaller ones
sub _connect_to_vm_processor {
    my ($server, $method, $url, $headers) = @_;
    my $db = QVD::DB->new();
    my $user;
    my $authorization = header_lookup($headers, 'Authorization');
    if ($authorization =~ /^Basic (.*)$/) {
	use MIME::Base64 'decode_base64';
	my @user_pwd = split /:/, decode_base64($1);
	my $user_rs = $db->resultset('User')->search({login => $user_pwd[0],
						password => $user_pwd[1]});
	if ($user_rs->count == 1) {
	    INFO "Accepted connection from user $user_pwd[0]";
	    $user = $user_rs->first;
	} else {
	    INFO "Failed login attempt from user $user_pwd[0]";
	    $server->send_http_error(HTTP_FORBIDDEN);
	    return;
	}
    } else {
	$server->send_http_error(HTTP_UNAUTHORIZED);
	return;
    }
    my $vm_start_timeout = QVD::Config->get('vm_start_timeout');

    unless (header_eq_check($headers, Connection => 'Upgrade') and
	    header_eq_check($headers, Upgrade => 'QVD/1.0')) {
	$server->send_http_error(HTTP_UPGRADE_REQUIRED);
	return;
    }

    $server->send_http_response(HTTP_PROCESSING,
				'X-QVD-VM-Status: Checking VM');

    my $vmas = QVD::VMAS->new($db);
    my @vms = $vmas->get_vms_for_user($user->id);
    # FIXME this limits number of VMs per user to 1
    my $vm = $vms[0];

    unless defined ($vm) {
	INFO "User " . $user->id . " does not have any virtual machine";
	# FIXME handle this situation in a better way, for instance:
	# - allow automatic provisioning
	# - report the problem to the client
	die;
    }
    # transición disconnected -> connected
    _connect_session($vmas, $vm);

#: Connecting: el usuario ha iniciado sesión y ha pedido ser conectado a una
#: maquina virtual, pero aun no se ha podido cerrar el bucle (por ejemplo,
#: porque hay que esperar a que la VM se levante). 

    # start the vm if it's not running already
    if ($vm->vm_state ne 'running') {
	DEBUG "VM not running, trying to start it";
	unless ($vmas->assign_host_for_vm($vm)) {
	    # FIXME VM could not be assigned to a host, notify client?
	    $vmas->push_user_state($vm, 'disconnected');
	    $server->send_http_error(HTTP_BAD_GATEWAY);
	    return;
	}
	my $r = $vmas->schedule_start_vm($vm);
	unless ($r) {
	    # The VM couldn't be scheduled for starting
	    # FIXME Pass the error message to the client
	    ERROR "VM ".$vm->vm_id." couldn't be started on host ".$vm->host_id;
	    $vmas->push_user_state($vm, 'disconnected');
	    $server->send_http_error(HTTP_BAD_GATEWAY);
	    return;
	}
	INFO "Started VM ".$vm->vm_id." on host ".$vm->host_id;

	# Wait for the VMA to come online
	my $timeout_time = time + $vm_start_timeout;
	while (time < $timeout_time) {
	    $server->send_http_response(HTTP_PROCESSING,
		    'X-QVD-VM-Status: Starting VM');
	    DEBUG "Waiting for VMA to start on VM ".$vm->vm_id;
	    $r = $vmas->get_vma_status($vm);
	    last if exists $r->{status} && $r->{status} eq 'ok';
	    sleep 5;
	}
	if (time > $timeout_time) {
	    # FIXME Pass the error message to the client
	    INFO "VM ".$vm->vm_id." start timed out ";
	    $vmas->push_user_state($vm, 'disconnected');
	    $server->send_http_error(HTTP_BAD_GATEWAY);
	    return;
	}
    }

    # Send 'connect' x_cmd
    unless ($vmas->schedule_x_cmd($vm, 'connect')) {
	$vmas->push_user_state($vm, 'disconnected');
	$server->send_http_error(HTTP_BAD_GATEWAY);
	return;
    }
    DEBUG "Sent x connect";
    
# FIXME timeout?
    while (1) {
	$vm->discard_changes;
	# abort?
	if (_check_abort_session($vm, $vmas)) {
# FIXME Pass the message to the client?
	    $server->send_http_error(HTTP_BAD_GATEWAY);
	    return;
	}

	DEBUG "x_state is ".$vm->x_state." Waiting for 'listening'";
	if ($vm->x_state eq 'listening') {
	    last;
	} else {
	    $server->send_http_response(HTTP_PROCESSING,
		    'X-QVD-VM-Status: Starting VM');
	    sleep 5;
	}
    }

    
    $server->send_http_response(HTTP_PROCESSING,
				'X-QVD-VM-Status: Connecting to VM');

    my $socket = IO::Socket::INET->new(PeerAddr => $vm->vm_address,
				       PeerPort => $vm->vm_x_port,
				       Proto => 'tcp');
    unless ($socket) {
	$vmas->push_user_state($vm, 'disconnected');
	$server->send_http_response(HTTP_PROCESSING,
				    'X-QVD-VM-Status: Retry connection',
				    "X-QVD-VM-Info: Connection to vm failed");
	INFO "NX connection to VM ".$vm->vm_id." (".$vm->vm_address.":".$vm->vm_x_port.") failed";
	return;
    }

    $server->send_http_response(HTTP_SWITCHING_PROTOCOLS,
				    'X-QVD-VM-Status: Connected to VM');

    my $check_abort = _check_abort_session($vm, $vmas, sub {
	$vmas->push_user_state($vm, 'connected');
    });

    if ($check_abort) {
	DEBUG "Received Abort command";
	# FIXME Pass the message to the client
	$server->send_http_error(HTTP_BAD_GATEWAY);
	return;
    }

    DEBUG "Start socket forwarder";
    forward_sockets($server->{server}{client}, $socket);

    $vmas->push_user_state($vm, 'disconnected');
    INFO "Session terminated";
}

#: El L7R solo puede iniciar una sesion desde el estado Disconnected, en
#: cualquier otro estado tendra que usar el comando Abort para cerrar la
#: sesion actual, esperar a que el estado cambie a Disconnected y entonces
#: empezar la sesion de la manera normal. 
sub _connect_session {
    my ($vmas, $vm) = @_;

    # FIXME timeout?
    # Is there an open session?
    while (1) {
	my $session_is_open = $vmas->txn_do(sub {
	    $vm->discard_changes;
	    if ($vm->user_state eq 'disconnected') {
		DEBUG "user_state is ".$vm->user_state.", set 'connecting'";
		$vmas->push_user_state($vm, 'connecting');
		return 0;
	    }
	    if ($vm->user_state ne 'connected' and $vm->user_state ne 'aborting') {
		$vmas->schedule_user_cmd($vm, 'Abort');
	    }
	    1;
	});
	last unless $session_is_open;
	if ($vm->user_state eq 'connected') {
	    $vmas->disconnect_nx($vm);
	}
	DEBUG "user_state is ".$vm->user_state." Waiting for 'disconnected'";
	sleep 5;
    }
}

1;

__END__

=head1 NAME

QVD::L7R - The great new QVD::L7R!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use QVD::L7R;

=head1 DESCRIPTION

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 AUTHOR

Salvador Fandiño, C<< <sfandino at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-l7r at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-L7R>.  I will be
notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

