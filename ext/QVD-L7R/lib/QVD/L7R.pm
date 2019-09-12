package QVD::L7R;

our $VERSION = '0.02';

use warnings;
use strict;

use Carp;
use feature 'switch';
use URI::Split qw(uri_split);
use MIME::Base64 'decode_base64';
use Socket qw(IPPROTO_TCP TCP_NODELAY);
use IO::Socket::Forwarder qw(forward_sockets);

use QVD::Config;
use QVD::Log;
use QVD::DB::Simple;
use QVD::HTTP::Headers qw(header_lookup header_eq_check header_find);
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
my $vm_stop_timeout  = cfg('internal.l7r.timeout.vm_stop');
my $x_start_retry    = cfg('internal.l7r.retry.x_start');
my $x_start_timeout  = cfg('internal.l7r.timeout.x_start');
my $vma_timeout      = cfg('internal.l7r.timeout.vma');
my $short_session    = cfg('internal.l7r.short_session');

sub new {
    my $class = shift;
    my @args = ( host => cfg('l7r.address'),
                 port => cfg('l7r.port') );

    if(cfg('l7r.use_ssl')) {
        my $path_key = cfg('path.l7r.ssl.key');
        -r $path_key or LOGDIE "SSL key file '$path_key' isn't readable";

        my $path_cert = cfg('path.l7r.ssl.cert');
        -r $path_cert or LOGDIE "SSL cert file '$path_cert' isn't readable";
        my $mode_cert = (stat $path_cert)[2] // LOGDIE "Can't stat SSL key file '$path_cert'";
        $mode_cert & 0007 and LOGDIE sprintf("SSL key file '%s' has insecure permissions '%o'",
                                             $path_cert, $mode_cert);

        push @args, ( SSL           => 1,
                      SSL_key_file  => $path_key,
                      SSL_cert_file => $path_cert,
                      SSL_version       => cfg('l7r.options.SSL_version'),
                      SSL_cipher_list   => cfg('l7r.options.SSL_cipher_list'));

        # Handle the case where we require the client to have a valid certificate:
        if (cfg('l7r.client.cert.require')) {
            my $path_ca = cfg('path.l7r.ssl.ca');
            -r $path_ca or LOGDIE "SSL ca file '$path_ca' isn't readable";
            push @args, ( SSL_verify_mode => 0x03, # 0x01 => verify peer, 0x02 => fail verification if no peer certificate exists
                          SSL_ca_file     => $path_ca );
            my $path_crl = cfg('path.l7r.ssl.crl');
            if (-f $path_crl) {
                -r $path_crl or LOGDIE "SSL crl file '$path_crl' isn't readable";
                push @args, SSL_crl_file => $path_crl;
            }
        }
    }
    $class->SUPER::new(@args);
}

sub post_configure_hook {
    my $l7r = shift;
    $l7r->set_http_request_processor(\&connect_to_vm_processor,
                                     GET => '/qvd/connect_to_vm');
    $l7r->set_http_request_processor(\&authenticate_user,
                                     GET => '/qvd/authenticate_user');
    $l7r->set_http_request_processor(\&list_of_vm_processor,
                                     GET => '/qvd/list_of_vm');
    $l7r->set_http_request_processor(\&list_of_applications_processor,
                                     GET => '/qvd/list_of_applications');
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

sub authenticate_user {
    my ($l7r, $method, $url, $headers) = @_;
    
    my $auth = $l7r->_authenticate_user($headers);
    
    my $query = (uri_split $url)[3];
    my %params = uri_query_split $query;
    
    my $response = {};
    
    $auth->before_list_of_vms;
    
    # Store auth paramaters if needed
    my $store_auth_params = $params{store_auth} // 0;
    if($store_auth_params) {
        txn_do {
            my $uas = rs('User_Auth_Parameters')->create({ parameters => $l7r->json->encode($auth->{params}) });
            $response->{auth_params_id} = $uas->id;
        };
    }
    
    $l7r->send_http_response_with_body( HTTP_OK, 'application/json', [],
        $l7r->json->encode($response) );
}



sub list_of_applications_processor {
    my ($l7r, $method, $url, $headers, ) = @_;
    DEBUG 'method list_of_applications requested';

    send_list_of_vm($l7r, $method, $url, $headers, is_application => 1);
}

sub list_of_vm_processor {
    my ($l7r, $method, $url, $headers, ) = @_;
    DEBUG 'method list_of_vm requested';

    send_list_of_vm($l7r, $method, $url, $headers, is_application => 0);
}

sub send_list_of_vm {
    my ($l7r, $method, $url, $headers, %opts) = @_;
    my $this_host = this_host; $this_host // $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, 'Host is not registered in the database');
    txn_do { $this_host->counters->incr_http_requests; };
    DEBUG 'send_list_of_vm called with is_application=' . $opts{is_application};
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
    my $user_id = $auth->{user}->id;

    my @vm_list = ( map { { id                => $_->vm_runtime->vm_id,
                            state             => $_->vm_runtime->vm_state,
                            name              => $_->vm_runtime->vm->name,
                            blocked           => $_->vm_runtime->blocked,
                            is_application    => $_->osf->is_application } }
                    grep { $_->osf->is_application == $opts{is_application} }
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
    txn_do { $this_host->counters->incr_http_requests; };
    DEBUG 'method connect_to_vm requested';
    my $auth = $l7r->_authenticate_user($headers);
    my $user_id = $auth->{user}->id;

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
    if (defined $l7r->{session}) {
        $l7r->throw_http_error(HTTP_FORBIDDEN, "vm_id does not match with provided token")
            unless $vm_id == $l7r->{session}->vm_id;
    }
    
    unless (defined $vm_id)  {
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
        # FIXME: at this point we have not checked yet if the user can
        # access this machine!!!
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
    if ($@) {
        my $err = $@;
        $err = $err->[1] if ( ref($err) eq "QVD::HTTPD::Exception" ); # Extract error message
        chomp $err;

        INFO "The requested virtual machine is not available: '$err'. Retry later". " VM_ID: $vm_id";
        $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE,
                          "The requested virtual machine is not available: ",
                          "$err, retry later.");
    }
    DEBUG "Session ended". " VM_ID: $vm_id";
}

sub stop_vm_processor {
    my ($l7r, $method, $url, $headers) = @_;
    my $this_host = this_host; $this_host // $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, 'Host is not registered in the database');
    txn_do { $this_host->counters->incr_http_requests; };
    DEBUG 'method stop_vm requested';
    my $auth = $l7r->_authenticate_user($headers);
    my $user_id = $auth->{user}->id;

    if ($this_host->runtime->blocked) {
        INFO 'Server is blocked';
        $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, "Server is blocked");
    }

    my $query = (uri_split $url)[3];
    my %params = uri_query_split  $query;
    my $vm_id = delete $params{id};
    if (defined $l7r->{session}) {
        $l7r->throw_http_error(HTTP_FORBIDDEN, "vm_id does not match with provided token") 
            unless $vm_id == $l7r->{session}->vm_id;
    }

    unless (defined $vm_id) {
        INFO 'Parameter id required';
        $l7r->throw_http_error(HTTP_UNPROCESSABLE_ENTITY, "parameter id is missing");
    }

    my $vm = rs(VM_Runtime)->search({vm_id => $vm_id})->first // do {
        INFO 'The requested virtual machine does not exist,)'. " VM_ID: $vm_id";
        $l7r->throw_http_error(HTTP_NOT_FOUND, "The requested virtual machine does not exist");
    };

    if (!$auth->allow_access_to_vm($vm->vm)) {
        INFO "User $user_id has tried to access VM $vm_id but (s)he isn't allowed to";
        $l7r->throw_http_error(HTTP_FORBIDDEN,
                               "You are not allowed to access requested virtual machine");
    }

    $l7r->_stop_and_wait_for_vm($vm);
    $l7r->send_http_response_with_body(HTTP_OK, 'text/plain', [], "Machine stopped\r\n");
}

sub _set_auth_headers {
    my ($auth, $headers) = @_;
    foreach my $hdr ( header_find($headers, qr/^Auth-/) ) {
        my ($name) = $hdr =~ /^Auth-(.*)$/;
        $name = pack("H*", $name);

        my $val  = decode_base64(header_lookup($headers, $hdr));
        $auth->set_additional_header($name, $val);
    }
}

sub _authenticate_user {
    my ($l7r, $headers) = @_;
    my $this_host = this_host; $this_host // $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE, 'Host is not registered in the database');

    my ($login, $passwd, $token);
    if (my ($credentials) = header_lookup($headers, 'Authorization')) {
        if (my ($bearer) = $credentials =~ /^Bearer (.*)$/) {
            ERROR "Unable to decode authentication credentials"
                unless ( ($token) = decode_base64($bearer) );
        } elsif (my ($basic) = $credentials =~ /^Basic (.*)$/) {
            ERROR "Unable to decode authentication credentials"
                unless ( ($login, $passwd) = decode_base64($basic) =~ /^([^:]+):(.*)$/ );
        } else {
            ERROR "unimplemented authentication mechanism";
        }
    } else {
        ERROR "No authentication credentials provided";
    }

    my $auth = $l7r->{_auth};
    if (defined $auth) {
        _set_auth_headers($auth, $headers);
        if ($auth->recheck_authentication($login, $passwd, $token)) {
            return $auth;
        }
    }

    $auth = QVD::L7R::Authenticator->new;
    _set_auth_headers($auth, $headers);
    txn_do { $this_host->counters->incr_auth_attempts; };

    my $is_authenticated = 0;
    if (defined($login) && defined($passwd)) {
        $is_authenticated = $auth->authenticate_basic( $login, $passwd, $l7r );
        ERROR "Failed login attempt from user $login" unless $is_authenticated;
    } elsif (defined($token)){
        $is_authenticated = $auth->authenticate_bearer( $token, $l7r );
        ERROR "Failed login attempt with token $token" unless $is_authenticated;
    }

    if($is_authenticated) {
        my $client = $l7r->{server}->{client};
        my $peerhost = eval { $client->peerhost() } // 'unknown';
        my $peerport = eval { $client->peerport() } // 'unknown';
        INFO "Accepted connection from user $login from ip:port ${peerhost}:$peerport";
        $l7r->{_auth} = $auth;
        my $user = $auth->{user};
        unless ($user->blocked) {
            txn_do { $this_host->counters->incr_auth_ok };
            return $auth
        }
        ERROR "User $login is blocked";
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
            DEBUG "User state set to 'connecting'";
        };
        unless ($@) {
            DEBUG "L7R takeover succeeded";
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

sub _wait_for_vm {
    my ($l7r, $vm, $target_state, $timeout) = @_;
    my $end = $timeout + time;
    my $vm_id = $vm->id;
    while (1) {
        $vm->discard_changes;
        my $current_state = $vm->vm_state;
        DEBUG "waiting for VM $vm_id to reach state $target_state from state $current_state";

        return 1 if $current_state eq $target_state;

        if ($current_state eq 'stopped' and
            not defined $vm->vm_cmd) {
            DEBUG "VM went to state 'stopped' unexpectedly";
            return;
        }

        if (time > $end) {
            DEBUG "timeout waiting for VM $vm_id to reach state '$target_state'";
            $l7r->throw_http_error(HTTP_REQUEST_TIMEOUT,
                                   "VM didn't reach state '$target_state'. Timeout");
        }
        $l7r->_tell_client("Waiting for VM to reach state '$target_state'");
        sleep($vm_poll_time);
    }
}

sub _start_and_wait_for_vm {
    my ($l7r, $vm) = @_;

    if ($vm->can_send_vm_cmd('start')) {
        $l7r->_tell_client("Starting virtual machine");
        $vm->send_vm_start;
        my $host_id = $vm->host_id;
        notify("qvd_cmd_for_vm_on_host$host_id");
    }

    if (!$l7r->_wait_for_vm($vm, 'running', $vm_start_timeout)) {
        $l7r->throw_http_error(HTTP_INTERNAL_SERVER_ERROR, "Failed to start virtual machine " . $vm->id);
        LOGDIE "Unable to start VM " . $vm->id;
    }
}

sub _stop_and_wait_for_vm {
    my ($l7r, $vm) = @_;

    # we don't use transactions in this method as it is a non-critical cmd.
    my $vm_id = $vm->id;
    my $vm_state = $vm->vm_state;
    my $host_id = $vm->host_id;

    DEBUG "stop_and_wait: VM $vm_id, timeout $vm_stop_timeout, state $vm_state, host $host_id";

    return 1 if $vm_state eq 'stopped';

    $l7r->_tell_client("Stopping virtual machine");
    if ($vm->can_send_vm_cmd('stop')) {
        $vm->send_vm_stop;
        notify("qvd_cmd_for_vm_on_host$host_id");
    }
    elsif ($vm_state ne 'stopping') {
        $l7r->throw_http_error(HTTP_SERVICE_UNAVAILABLE,
                               "The requested virtual machine is in an unstoppable state ($vm_state)");
    }

    $l7r->_wait_for_vm($vm, 'stopped', $vm_stop_timeout)
        or LOGDIE "Unable to stop VM $vm_id";
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

    txn_do { $this_host->counters->incr_nx_attempts; };
    my $socket = IO::Socket::INET->new(PeerAddr => $vm_address,
                                       PeerPort => $vm_x_port,
                                       Proto => 'tcp',
                                       KeepAlive => 1)
        or LOGDIE "Unable to connect to X server  on VM VM_ID: " . $vm->id .  ": $!";
    setsockopt($socket, IPPROTO_TCP, TCP_NODELAY, 1) or WARN "Cannot set TCP_NODELAY";

    txn_do { $this_host->counters->incr_nx_ok; };

    DEBUG "Socket connected to X server on VM VM_ID: " . $vm->id;

    txn_do {
        $vm->discard_changes;
        $l7r->_check_abort($vm);
        $vm->user_state eq 'connecting'
            or LOGDIE "User state unexpectedly went to ".$vm->user_state;
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
    txn_do { $this_host->counters->incr_short_sessions } if time - $t0 < $short_session;
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

Salvador Fandino, C<< <sfandino at yahoo.com> >>

=head1 COPYRIGHT

Copyright 2009-2012 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
