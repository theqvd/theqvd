package QVD::L7R;

our $VERSION = '0.02';

use warnings;
use strict;

use Carp;
use feature 'switch';
use URI::Split qw(uri_split);
use MIME::Base64 'decode_base64';
use IO::Socket::Forwarder qw(forward_sockets);

use QVD::Config;
use QVD::Log;
use QVD::DB::Simple;
use QVD::HTTP::Headers qw(header_lookup header_eq_check);
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::URI qw(uri_query_split);
use QVD::SimpleRPC::Client;
use QVD::L7R::Authenticator;
use QVD::L7R::LoadBalancer;

use QVD::HTTPD;
use base qw(QVD::HTTPD::INET);

my $vm_poll_time     = cfg('internal.l7r.poll_time.vm');
my $x_poll_time      = cfg('internal.l7r.poll_time.x');
my $takeover_timeout = cfg('internal.l7r.timeout.takeover');
my $vm_start_timeout = cfg('internal.l7r.timeout.vm_start');
my $x_start_retry    = cfg('internal.l7r.retry.x_start');
my $x_start_timeout  = cfg('internal.l7r.timeout.x_start');
my $vma_timeout      = cfg('internal.l7r.timeout.vma');
my $short_session    = cfg('internal.l7r.short_session');

sub new {
    my $class = shift;
    my @args = ( host => cfg('l7r.address'),
                 port => cfg('l7r.port') );
    if(cfg('l7r.use_ssl')) {
        push @args, ( SSL           => 1,
                      SSL_key_file  => cfg('path.l7r.ssl.key'),
                      SSL_cert_file => cfg('path.l7r.ssl.cert'));

        # handle the case where we require the client to have a valid certificate:
        if (cfg('l7r.client.cert.require')) {
            push @args, ( SSL_verify_mode => 0x03, # 0x01 => verify peer,
                                                   # 0x02 => fail verification if no peer certificate exists
                          SSL_ca_file     => cfg('path.l7r.ssl.ca'));

            my $crl = cfg('path.l7r.ssl.crl');
            push @args, SSL_crl_file => $crl if -f $crl;
        }
    }
    $class->SUPER::new(@args);
}

sub post_configure_hook {
    my $l7r = shift;
    $l7r->set_http_request_processor(\&connect_to_vm_processor,
                                     GET => '/qvd/connect_to_vm');
    $l7r->set_http_request_processor(\&list_of_vm_processor,
                                     GET => '/qvd/list_of_vm');
    $l7r->set_http_request_processor(\&ping_processor,
                                     GET => '/qvd/ping');
    $l7r->set_http_request_processor(\&stop_vm_processor,
                                     GET => '/qvd/stop_vm');

}

sub ping_processor {
    my ($l7r) = @_;
    my $this_host = this_host or $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, 'Host is not registered in the database');
    my $this_host_runtime = $this_host->runtime;
    my $server_state = $this_host_runtime->state;
    if ($server_state eq 'running') {
        if ($this_host_runtime->blocked) {
            INFO 'Server is blocked';
            $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, "Server is blocked");
        }
        else {
            $l7r->send_http_response_with_body(HTTP_OK, 'text/plain', [], "I am alive!\r\n");
        }
    } else {
        $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, "Server is $server_state");
    }
}

sub list_of_vm_processor {
    my ($l7r, $method, $url, $headers) = @_;
    my $this_host = this_host; $this_host // $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, 'Host is not registered in the database');
    $this_host->counters->incr_http_requests;
    DEBUG 'method list_of_vm requested';
    my $auth = $l7r->_authenticate_user($headers);
    if ($this_host->runtime->blocked) {
        INFO 'Server is blocked';
        $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, "Server is blocked");
    }
    my $server_state = $this_host->runtime->state;
    if ($server_state ne 'running') {
        INFO "Server is not in state 'running' but '$server_state'";
        $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, "Server is $server_state");
    }
    $auth->before_list_of_vms;
    my $user_id = $auth->user_id;

    my @vm_list = ( map { { id      => $_->vm_id,
                            state   => $_->vm_state,
                            name    => $_->vm->name,
                            blocked => $_->blocked } }
                    map $_->vm_runtime,
                    $auth->list_of_vm($url, $headers) );

    if (@vm_list) {
        DEBUG sprintf "User $user_id has %d virtual machines", scalar @vm_list;
    } else {
        INFO "User $user_id does not have virtual machines";
    }
    $l7r->send_http_response_with_body( HTTP_OK, 'application/json', [],
                                        $l7r->json->encode(\@vm_list) );
}

sub generate_slave_key {
    # generate a random 64-character string to serve as authentication key
    # between slave server and client
    my @alpha = ("A".."Z", "a".."z", "0".."9");
    join "", map @alpha[rand @alpha], 0..63;
}

sub connect_to_vm_processor {
    my ($l7r, $method, $url, $headers) = @_;
    my $this_host = this_host; $this_host // $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, 'Host is not registered in the database');
    $this_host->counters->incr_http_requests;
    DEBUG 'method connect_to_vm requested';
    my $auth = $l7r->_authenticate_user($headers);
    my $user_id = $auth->user_id;

    if ($this_host->runtime->blocked) {
        INFO 'Server is blocked';
        $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, "Server is blocked");
    }

    header_eq_check($headers, Connection => 'Upgrade') &&
    header_eq_check($headers, Upgrade => 'QVD/1.0') or do {
        INFO 'Upgrade HTTP header required';
        $l7r->throw_http_error(HTTP_UPGRADE_REQUIRED);
    };

    my $query = (uri_split $url)[3];
    my %params = uri_query_split  $query;
    my $vm_id = delete $params{id};
    my $file_name = delete $params{file_name};
    
    unless (defined $vm_id or defined $file_name)  {
        INFO 'Parameter id required';
        $l7r->throw_http_error(HTTP_UNPROCESSABLE_ENTITY, "parameter id is missing");
    }

    if (my @forbidden = grep !/^(?:qvd\.client\.|custom\.)/, keys %params) {
        INFO "Invalid parameters @forbidden";
        $l7r->throw_http_error(HTTP_FORBIDDEN,
                               "Invalid parameters @forbidden");
    }
    
    my $vm = txn_eval {
        my $vm;
        $vm = rs(VM_Runtime)->search({vm_id => $vm_id})->first // do {
            INFO 'The requested virtual machine does not exist,)'. " VM_ID: $vm_id";
            $l7r->throw_http_error(HTTP_NOT_FOUND, "The requested virtual machine does not exist");
        };
        $vm->blocked and do {
            INFO 'The requested virtual machine is offline for maintenance'. " VM_ID: $vm_id";
            $l7r->throw_http_error(HTTP_FORBIDDEN,
                                       "The requested virtual machine is offline for maintenance");
        };
        $vm->update({real_user_id => $user_id});
        return $vm,
    };

    if (!$vm) {
        $l7r->throw_http_error(HTTP_NOT_FOUND, $@);
    }

    my $slave_key = generate_slave_key();

    eval {
        if (!$auth->allow_access_to_vm($vm->vm)) {
            INFO "User $user_id has tried to access VM $vm_id but (s)he isn't allowed to";
            $l7r->throw_http_error(HTTP_FORBIDDEN,
                                   "You are not allowed to access requested virtual machine");
        }
        $l7r->_takeover_vm($vm);
        $l7r->_assign_vm($vm);
        $auth->before_connect_to_vm;
        $l7r->_start_and_wait_for_vm($vm);
        %params = (%params,
                   $vm->combined_properties,
                   $auth->params,
                   'qvd.slave.key' => $slave_key);
        $l7r->_start_x($vm, %params);
        $l7r->_wait_for_x($vm);
        $l7r->_run_forwarder($vm, %params);
    };
    my $saved_err = $@;
    DEBUG 'Releasing VM'. " VM_ID: $vm_id";
    $l7r->_release_vm($vm);
    if ($saved_err) {
        chomp $saved_err;
        INFO "The requested virtual machine is not available: '$saved_err'. Retry later". " VM_ID: $vm_id";
        $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE,
                          "The requested virtual machine is not available: ",
                          "$saved_err, retry later");
    }
    DEBUG "Session ended". " VM_ID: $vm_id";
}

sub stop_vm_processor {
    my ($l7r, $method, $url, $headers) = @_;
    my $this_host = this_host; $this_host // $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, 'Host is not registered in the database');
    $this_host->counters->incr_http_requests;
    DEBUG 'method stop_vm requested';
    my $auth = $l7r->_authenticate_user($headers);
    my $user_id = $auth->user_id;

    if ($this_host->runtime->blocked) {
        INFO 'Server is blocked';
        $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, "Server is blocked");
    }

    header_eq_check($headers, Connection => 'Upgrade') &&
    header_eq_check($headers, Upgrade => 'QVD/1.0') or do {
        INFO 'Upgrade HTTP header required';
        $l7r->throw_http_error(HTTP_UPGRADE_REQUIRED);
    };

    my $query = (uri_split $url)[3];
    my %params = uri_query_split  $query;
    my $vm_id = delete $params{id};
    my $file_name = delete $params{file_name};
    unless (defined $vm_id or defined $file_name)  {
        INFO 'Parameter id required';
        $l7r->throw_http_error(HTTP_UNPROCESSABLE_ENTITY, "parameter id is missing");
    }

    my $vm = txn_eval {
        my $vm;
        $vm = rs(VM_Runtime)->search({vm_id => $vm_id})->first // do {
            INFO 'The requested virtual machine does not exist,)'. " VM_ID: $vm_id";
            $l7r->throw_http_error(HTTP_NOT_FOUND, "The requested virtual machine does not exist");
        };
        $vm->blocked and do {
            INFO 'The requested virtual machine is offline for maintenance'. " VM_ID: $vm_id";
            $l7r->throw_http_error(HTTP_FORBIDDEN,
                                       "The requested virtual machine is offline for maintenance");
        };
        $vm->update({real_user_id => $user_id});
        return $vm,
    };

    if (!$vm) {
        $l7r->throw_http_error(HTTP_NOT_FOUND, $@);
    }

    eval {
        if (!$auth->allow_access_to_vm($vm->vm)) {
            INFO "User $user_id has tried to access VM $vm_id but (s)he isn't allowed to";
            $l7r->throw_http_error(HTTP_FORBIDDEN,
                die                   "You are not allowed to access requested virtual machine");
        }
    #    $l7r->_takeover_vm($vm);
    #    $l7r->_assign_vm($vm);
    #    $auth->before_connect_to_vm;
        $l7r->_stop_and_wait_for_vm($vm);
    };
    my $saved_err = $@;
    DEBUG 'Releasing VM'. " VM_ID: $vm_id";
    $l7r->_release_vm($vm);
    if ($saved_err) {
        chomp $saved_err;
        INFO "The requested virtual machine is not available: '$saved_err'. Retry later". " VM_ID: $vm_id";
        $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE,
                          "The requested virtual machine is not available: ",
                          "$saved_err, retry later");
    }
    DEBUG "VM shut down". " VM_ID: $vm_id";
    $l7r->send_http_response(HTTP_OK);

}

sub _authenticate_user {
    my ($l7r, $headers) = @_;
    my $this_host = this_host; $this_host // $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, 'Host is not registered in the database');
    if (my ($credentials) = header_lookup($headers, 'Authorization')) {
        if (my ($basic) = $credentials =~ /^Basic (.*)$/) {
            if (my ($login, $passwd) = decode_base64($basic) =~ /^([^:]+):(.*)$/) {
		my $auth = $l7r->{_auth};
		if (defined $auth and
		    $auth->recheck_authentication_basic($login, $passwd, $l7r)) {
		    return $auth;
		}
                $auth = QVD::L7R::Authenticator->new;
		$this_host->counters->incr_auth_attempts;
                if ($auth->authenticate_basic($login, $passwd, $l7r)) {
		    INFO "Accepted connection from user $login from ip:port ".
			$l7r->{server}->{client}->peerhost().":".$l7r->{server}->{client}->peerport();
		    $l7r->{_auth} = $auth;
                    my $user = rs(User)->find($auth->user_id);
                    unless ($user->blocked) {
                        $this_host->counters->incr_auth_ok;
                        return $auth
                    }
                    ERROR "User $login is blocked";
                }
                else {
                    ERROR "Failed login attempt from user $login";
                }
            }
            else {
                ERROR "Unable to decode authentication credentials";
            }
        }
        else {
            ERROR "unimplemented authentication mechanism";
        }
    }
    $l7r->throw_http_error(HTTP_UNAUTHORIZED, ['WWW-Authenticate: Basic realm="QVD"']);
}

# Take the machine for this L7R process maybe disconnecting others
sub _takeover_vm {
    my ($l7r, $vm) = @_;
    DEBUG "Taking over session for VM " . $vm->id;

    my $timeout = time + $takeover_timeout;

    while(1) {
        txn_eval {
            DEBUG "txn_eval in _takeover_vm for VM_ID: ". $vm->id;
            $vm->discard_changes;
            if ($vm->user_state ne 'disconnected') {
                die "user is connected from another L7R instance yet";
            }
            $vm->set_user_state('connecting',
                                l7r_pid => $$,
                                l7r_host_id => this_host_id,
                                user_cmd => undef);
        };
        unless ($@) {
            DEBUG "txn_eval with no issues";
            $l7r->_tell_client("Session acquired for VM_ID: ". $vm->id);
            return;
        }

        $vm->discard_changes;
        INFO sprintf("Session acquisition failed: L7R state %s for VM %d, pid: %d, host: %d, cmd: %s, my pid: %d, \$\@: %s",
                      $vm->user_state, $vm->id, $vm->l7r_pid, $vm->l7r_host_id, $vm->user_cmd, $$, $@);

        $l7r->_tell_client("Aborting contending session for VM_ID: ". $vm->id);
        my $channel = "qvd_cmd_for_user_on_host" . $vm->l7r_host_id;
        DEBUG "notifying channel '$channel'";
        $vm->send_user_abort;
        notify($channel);

        # TODO: when contending L7R is in state "connected" this L7R
        # could send the x_suspend message to the VMA without going
        # through the HKD

        LOGDIE "Unable to acquire VM, close other clients\n" if time > $timeout;
        sleep($vm_poll_time);

        # FIXME: check the VM has not left the state running
    }
}

sub _release_vm {
    my ($l7r, $vm) = @_;
    DEBUG 'Releasing VM for VM_ID: '.$vm->id;
    txn_eval {
        $vm->discard_changes;
        my $pid = $vm->l7r_pid;
        my $host_id = $vm->l7r_host_id;
        if ($vm->is_ephemeral && $vm->vm_state eq 'running') {
            $vm->send_vm_stop; # Clean up ephemeral VMs
        }

        # FIXME: the HKD should take care of reclaiming ephemeral
        # virtual machines back into the pool:
        # It can't be done here as...
        #   $vm->update({ real_user_id => undef });

        if (defined $pid  and $pid  == $$  and
            defined $host_id and $host_id == this_host_id) {
            DEBUG 'calling clear l7r all for vm ' . $vm->id;
            $vm->clear_l7r_all;
        }
        else {
            DEBUG 'not calling clear_l7r_all for vm ' . $vm->id
                . " where pid=$pid, \$\$=$$, host=$host_id, this_host=". this_host_id;
        }
    };
    $@ and INFO "L7R release failed but don't bother, HKD will cleanup the mess: $@";
}

sub _assign_vm {
    my ($l7r, $vm) = @_;
    my $vm_id = $vm->id;
    unless (defined $vm->host_id) {
        $l7r->_tell_client("Assigning VM $vm_id to host");
        my $lb = QVD::L7R::LoadBalancer->new;
        my $host_id = $lb->get_free_host($vm->vm) //
            LOGDIE "Unable to start VM $vm_id, can't assign to any host\n";

        # FIXME: assigning the host and pushing the start command
        # should go in the same transaction!

        txn_eval {
            $vm->discard_changes;
            LOGDIE if (defined $vm->host_id or $vm->vm_state ne 'stopped');
            $vm->set_host_id($host_id);
        };
        $@ and LOGDIE "Unable to start VM $vm_id, state changed unexpectedly\n";

        $l7r->_check_abort($vm);
    }
}

sub _start_and_wait_for_vm {
    my ($l7r, $vm) = @_;

    my $vm_id = $vm->id;
    my $timeout = time + $vm_start_timeout;
    my $vm_state = $vm->vm_state;

    if ($vm_state eq 'stopped') {
        $l7r->_tell_client("Starting virtual machine");
        $vm->send_vm_start;
        my $host_id = $vm->host_id;
        notify("qvd_cmd_for_vm_on_host$host_id");
    }

    return if $vm_state eq 'running';

    $l7r->_tell_client("Waiting for VM $vm_id to start");
    while (1) {
        DEBUG "waiting for VM $vm_id to come up";
        sleep($vm_poll_time);
        $vm->discard_changes;
        $l7r->_check_abort($vm);
        my $vm_state = $vm->vm_state;
        if ($vm_state eq 'running') {
            DEBUG 'VM is running VM_ID: '. $vm->id;
            return;
        }
        # FIXME: timeout in state starting_1 should be relaxed a bit
        if (( $vm_state eq 'stopped' and
              defined $vm->vm_cmd ) or
            $vm_state =~ /^starting/) {
            LOGDIE "Unable to start VM $vm_id, operation timed out!\n"
                if time > $timeout;
        }
        else {
            LOGDIE "Unable to start VM $vm_id in state $vm_state";
        }
    }
}

sub _stop_and_wait_for_vm {
    my ($l7r, $vm) = @_;

    my $vm_id = $vm->id;
    my $timeout = time + $vm_start_timeout;
    my $vm_state = $vm->vm_state;

    DEBUG "stop_and_wait: VM $vm_id, timeout $timeout, state $vm_state";

    if ($vm_state eq 'running') {
        $l7r->_tell_client("Stopping virtual machine");
        DEBUG "VM $vm_id running, stopping";
        $vm->send_vm_stop;
        my $host_id = $vm->host_id;
        notify("qvd_cmd_for_vm_on_host$host_id");
    }

    return if $vm_state eq 'stopped';

    $l7r->_tell_client("Waiting for VM $vm_id to stop");
    while (1) {
        DEBUG "waiting for VM $vm_id to shut down";
        sleep($vm_poll_time);
        $vm->discard_changes;
        $l7r->_check_abort($vm);
        my $vm_state = $vm->vm_state;
        if ($vm_state eq 'stopped') {
            DEBUG 'VM is running VM_ID: '. $vm->id;
            return;
        }
        # FIXME: timeout in state starting_1 should be relaxed a bit
        if (( $vm_state eq 'running' and
              defined $vm->vm_cmd ) or
            $vm_state =~ /^stopping/) {
            LOGDIE "Unable to stop VM $vm_id, operation timed out!\n"
                if time > $timeout;
        }
        else {
            LOGDIE "Unable to stop VM $vm_id in state $vm_state";
        }
    }
}




sub _start_x {
    my ($l7r, $vm, @params) = @_;
    my $vm_id = $vm->id;
    $l7r->_tell_client("Starting X session at VM $vm_id");
    my $resp;
    for (0..$x_start_retry) {
        my $vma = $l7r->_vma_client($vm);
        $resp = eval { $vma->x_start(@params) };
        last unless $@;
        sleep($x_poll_time);
        $l7r->_check_abort($vm, 1);
    }
    $resp or LOGDIE "Unable to start X session on VM $vm_id: $@";
}

sub _wait_for_x {
    my ($l7r, $vm) = @_;
    my $vm_id = $vm->id;
    my $timeout = time + $x_start_timeout;
    $l7r->_tell_client("Waiting for X session to come up on VM $vm_id");
    my $x_state;
    while (1) {
        my $vma = $l7r->_vma_client($vm);
        $x_state = eval { $vma->x_state };
        DEBUG "X session state on VM $vm_id is $x_state";
        given ($x_state) {
            when ('listening') {
                DEBUG "X session is ready on VM $vm_id";
                return
            }
            when ([undef, 'starting']) {
                LOGDIE "Unable to start X session on VM $vm_id, operation timed out!\n"
                    if time > $timeout;
            }
            when ('provisioning') {
                # do not timeout while provisioning as it can be a
                # long process
            }
            default {
                LOGDIE "Unable to start X session on VM $vm_id, state went to $_\n"
            }
        }
        sleep($x_poll_time);
        # $l7r->_check_abort($vm, 1);
    }
}

sub _run_forwarder {
    my ($l7r, $vm, %params) = @_;
    my $vm_id = $vm->vm_id;
    my $vm_address = $vm->vm_address;
    my $vm_x_port = $vm->vm_x_port;
    my $this_host = this_host;
    $this_host // $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, 'Host is not registered in the database');

    $l7r->_tell_client("Connecting X session for VM_ID: " . $vm->id);

    $this_host->counters->incr_nx_attempts;
    my $socket = IO::Socket::INET->new(PeerAddr => $vm_address,
                                       PeerPort => $vm_x_port,
                                       Proto => 'tcp',
                                       KeepAlive => 1)
        or LOGDIE "Unable to connect to X server  on VM VM_ID: " . $vm->id .  ": $!";
    $this_host->counters->incr_nx_ok;

    DEBUG "Socket connected to X server on VM VM_ID: " . $vm->id;

    txn_do {
        $vm->discard_changes;
        $l7r->_check_abort($vm);
        $vm->set_user_state('connected');
    };
    DEBUG "Connected on VM VM_ID: " . $vm->id ;

    $l7r->_tell_client("Connection established");

    $l7r->send_http_response(HTTP_SWITCHING_PROTOCOLS,
        "X-QVD-Slave-Key: $params{'qvd.slave.key'}");

    DEBUG "Starting socket forwarder for VM " . $vm->id;
    db->storage->disconnect; # don't keep the DB connection open while
                             # the session is running.
    DEBUG "L7R disconnected from the database for VM " . $vm->id . " while user session runs";
    my $t0 = time;
    forward_sockets($l7r->{server}{client}, $socket);
    DEBUG "Session terminated on VM VM_ID: " . $vm->id ;
    $this_host->counters->incr_short_sessions if time - $t0 < $short_session;
}

sub _vma_client {
    my ($l7r, $vm) = @_;
    my $host = $vm->vm_address;
    my $port = $vm->vm_vma_port;
    QVD::SimpleRPC::Client->new("http://$host:$port/vma", timeout => $vma_timeout);
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
    LOGDIE "Aborted by contending session VM VM_ID: ". $vm->id
        if (defined $cmd and $cmd eq 'abort');
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

=head1 COPYRIGHT

Copyright 2009-2012 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
