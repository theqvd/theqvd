package QVD::L7R;

our $VERSION = '0.01';

use warnings;
use strict;
use Carp;

use IO::Socket::Forwarder qw(forward_sockets);
use Log::Log4perl qw(:easy);
use QVD::Config;
use QVD::DB::Simple;
use QVD::HTTP::Headers qw(header_lookup header_eq_check);
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::URI qw(uri_query_split);
use QVD::Auth;
use QVD::SimpleRPC::Client;
use URI::Split qw(uri_split);
use Sys::Hostname;

Log::Log4perl::init('log4perl.conf');
my $POLL_TIME = cfg('l7r_poll_time', 5);

use parent qw(QVD::HTTPD);

my $this_host_id = rs(Host)->search(name => hostname)->first->id;

sub post_configure_hook {
    my $l7r = shift;
    $l7r->set_http_request_processor(\&connect_to_vm_processor,
				     GET => '/qvd/connect_to_vm');
    $l7r->set_http_request_processor(\&list_of_vm_processor,
				     GET => '/qvd/list_of_vm');
}

# FIXME: replace $vm by $vmrt all over the module!

sub _authorize_user {
    my ($l7r, $method, $url, $headers) = @_;
    my $authorization = header_lookup($headers, 'Authorization');
    if ($authorization =~ /^Basic (.*)$/) {
	use MIME::Base64 'decode_base64';
	my @user_pwd = split /:/, decode_base64($1);
	my $user_login = QVD::Auth->login($user_pwd[0], $user_pwd[1]);
	
	if ($user_login == 1) {
	    my $user_rs = rs(User)->search({login => $user_pwd[0]});
	    INFO "Accepted connection from user $user_pwd[0]";
	    return $user_rs->first;
	} else {
	    INFO "Failed login attempt from user $user_pwd[0]";
	    $l7r->send_http_error(HTTP_UNAUTHORIZED,
		[ 'WWW-Authenticate: Basic realm="QVD"' ]);
	    return;
	}
    } else {
	$l7r->send_http_error(HTTP_UNAUTHORIZED,
	    [ 'WWW-Authenticate: Basic realm="QVD"' ]);
	return;
    }
}

sub list_of_vm_processor {
    my ($l7r, $method, $url, $headers) = @_;
    my $user = $l7r->_authorize_user($method, $url, $headers) or return;
    my $user_id = $user->id;

    my @vms = map $_->vm_runtime, rs(VM)->search({user_id => $user_id});

    unless (@vms) {
	INFO "User $user_id does not have any virtual machine";
	# FIXME handle this situation in a better way, for instance:
	# - allow automatic provisioning
	# - report the problem to the client
    }

    my @vm_data = map { { id => $_->vm_id,
			  state => $_->vm_state,
			  name => $_->rel_vm_id->name,
			  blocked => $_->blocked } } @vms;

    $l7r->send_http_response_with_body( HTTP_OK, 'application/json', [],
					$l7r->json->encode(\@vm_data) );
}

sub _user_vms {
    my ($l7r, $user_id) = @_;
    map {
	my $rt = $_->vm_runtime;
	ERROR "Corrupted database: virtual machine misses entry at vm_runtime"
	    unless defined $rt;
	$rt;
    } rs(VM)->search({'user_id' => $user_id});
}

sub connect_to_vm_processor {
    my ($l7r, $method, $url, $headers) = @_;
    my $user = $l7r->_authorize_user($method, $url, $headers) or return;
    # FIXME: use vm_starting_timeout cfg instead of this
    my $vm_start_timeout = cfg('vm_start_timeout');

    unless (header_eq_check($headers, Connection => 'Upgrade') and
	    header_eq_check($headers, Upgrade => 'QVD/1.0')) {
	$l7r->send_http_error(HTTP_UPGRADE_REQUIRED);
	return;
    }

    my $query = (uri_split $url)[3];
    my %params = uri_query_split  $query;
    my $vm_id = $params{id};
    unless (defined $vm_id) {
	$l7r->send_http_error(HTTP_UNPROCESSABLE_ENTITY);
	return;
    }

    my $vm = rs(VM_Runtime)->search({vm_id => $vm_id})->first;

    unless (defined $vm) {
	$l7r->send_http_error(HTTP_NOT_FOUND,
			      "The requested virtual machine does not exists");
	return;
    }
    if ($vm->rel_vm_id->user_id != $user->id) {
	$l7r->send_http_error(HTTP_FORBIDDEN,
			      "You are not allowed to access requested virtual machine");
	return;
    }
    if ($vm->blocked) {
	$l7r->send_http_error(HTTP_FORBIDDEN,
			      "The requested virtual machine is offline for maintenance");
	return;
    }

    eval {
	$l7r->_takeover_vm($vm);
	$l7r->_assign_vm($vm);
	$l7r->_start_and_wait_for_vm($vm);
	$l7r->_start_x($vm);
	$l7r->_wait_for_x($vm);
	$l7r->_run_forwarder($vm);
    };
    my $saved_err = $@;
    $l7r->_release_vm($vm);
    if ($saved_err) {
	chomp $saved_err;
	DEBUG "Session failed: $saved_err";
	$l7r->send_http_error(HTTP_SERVICE_UNAVAILABLE,
			      "The requested virtual machine is not available: ",
			      "$saved_err, retry later");
    }
    DEBUG "Session ended";
}

# Take the machine for this L7R process disconnected others
# first if needed
sub _takeover_vm {
    my ($l7r, $vm) = @_;

    while(1) {
	txn_eval {
	    $vm->discard_changes;
	    if ($vm->user_state eq 'disconnected') {
		$vm->set_user_state('connecting',
				    l7r_pid => $$,
				    l7r_host => $this_host_id,
				    user_cmd => undef);
	    }
	};
	unless ($@) {
	    $l7r->_tell_client("Session acquired");
	    return;
	}

	$l7r->_tell_client("Aborting contending session");
	$vm->send_user_abort;
	sleep 1;
	# FIXME: check timeout
	# FIXME: check the VM has not left the state running
    }
}

sub _release_vm {
    my ($l7r, $vm) = @_;
    txn_eval {
	$vm->discard_changes;
	my $pid = $vm->l7r_pid;
	my $host = $vm->l7r_host;
	$vm->clear_l7r_all
	    if (defined $pid  and $pid  == $$  and
		defined $host and $host == $this_host_id);
    };
}

sub _assign_vm {
    my ($l7r, $vm) = @_;
    unless (defined $vm->host_id) {
	$l7r->_tell_client("Assigning VM to host");
	my $host_id = $l7r->_get_free_host($vm) //
	    die "Unable to start VM, can't assign to any host\n";

	txn_eval {
	    $vm->discard_changes;
	    die if (defined $vm->host_id or $vm->vm_state ne 'stopped');
	    $vm->set_host_id($host_id);
	};
	$@ and die "Unable to start VM, state changed unexpectedly\n";

	$l7r->_check_abort($vm);
    }
}

sub _start_and_wait_for_vm {
    my ($l7r, $vm) = @_;
    my $vm_state = $vm->vm_state;

    if ($vm_state eq 'stopped') {
	$l7r->_tell_client("Starting virtual machine");
	$vm->send_vm_start;
    }

    return if $vm_state eq 'running';

    $l7r->_tell_client("Waiting for VM to start");
    while (1) {
	DEBUG "waiting for VM to come up";
	sleep 1;
	$vm->discard_changes;
	$l7r->_check_abort($vm);
	my $vm_state = $vm->vm_state;
	return if $vm_state eq 'running';
	if (( $vm_state eq 'stopped' and
	      defined $vm->vm_cmd ) or
	    $vm_state eq 'starting') {
	    # FIXME: check timeout!
	}
	else {
	    die "Unable to start VM in state $vm_state";
	}
    }
}

sub _start_x {
    my ($l7r, $vm) = @_;
    $l7r->_tell_client("Starting X session");
    my $resp;
    for (0..3) { # FIXME: make number of retries configurable?
	my $vma = $l7r->_vma_client($vm);
	$resp = eval {
	    # FIXME: use start_x_listener method instead of
	    # obsolete...
	    $vma->start_x_listener;
	};
	last unless $@;
	sleep 2;
	$l7r->_check_abort($vm, 1);
    }
    $resp or die "Unable to start X server on VM: $@";
}

sub _wait_for_x {
    my ($l7r, $vm) = @_;
    $l7r->_tell_client("Waiting for X session to come up");
    my $x_state;
    for (0..10) { # FIXME: make number of retries configurable?
	my $vma = $l7r->_vma_client($vm);
	$x_state = eval { $vma->x_state };
	return if (defined $x_state and $x_state eq 'listening');
	sleep 1;
	$l7r->_check_abort($vm, 1);
    }
    my $reason = ( defined $x_state ? " in state $x_state" : ": $@");
    die "Unable to connect to VM X server$reason";
}

sub _run_forwarder {
    my ($l7r, $vm) = @_;
    my $vm_id = $vm->vm_id;
    my $vm_address = $vm->vm_address;
    my $vm_x_port = $vm->vm_x_port;

    $l7r->_tell_client("Connecting X session");

    my $socket = IO::Socket::INET->new(PeerAddr => $vm_address,
				       PeerPort => $vm_x_port,
				       Proto => 'tcp')
	or die "Unable to connect to X server: $!";

    DEBUG "Socket connected to X server";

    # FIXME: check abort!
    txn_do {
	$vm->discard_changes;
	$l7r->_check_abort($vm);
	$vm->set_user_state('connected');
    };
    DEBUG "Connected";

    $l7r->_tell_client("Connection established");

    $l7r->send_http_response(HTTP_SWITCHING_PROTOCOLS);

    DEBUG "Starting socket forwarder";
    forward_sockets($l7r->{server}{client}, $socket);
    DEBUG "Session terminated";
}

sub _vma_client {
    my ($l7r, $vm) = @_;
    my $host = $vm->vm_address;
    my $port = $vm->vm_vma_port;
    QVD::SimpleRPC::Client->new("http://$host:$port/vma",
				timeout => cfg(vma_response_timeout => 3));
}

sub _tell_client {
    my $l7r = shift;
    DEBUG "Telling client: @_";
    $l7r->send_http_response(HTTP_PROCESSING, "X-QVD-VM-Info: @_")
}

sub _check_abort {
    my ($l7r, $vm, $update) = @_;
    $vm->discard_changes if $update;
    my $cmd = $vm->user_cmd;
    die "Aborted by contending session"
	if (defined $cmd and $cmd eq 'abort');
}

sub _get_free_host {
    my ($self, $vm) = @_;
    # FIXME: implement some plugin-based load balancer and share it with the Admin package
    my @hosts = map $_->id, rs(Host)->all;
    $hosts[rand @hosts];
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

