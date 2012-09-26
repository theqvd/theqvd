package QVD::Client::Proxy;

use strict;
use warnings;
use 5.010;

use Crypt::OpenSSL::X509;
use File::Path 'make_path';
use File::Spec;
use IO::Socket::INET;
use IO::Socket::Forwarder qw(forward_sockets);
use JSON;
use Proc::Background;
use QVD::Config::Core;
use QVD::HTTP::StatusCodes qw(:status_codes);
use URI::Escape qw(uri_escape);
use QVD::Log;

my $WINDOWS = ($^O eq 'MSWin32');
my $DARWIN = ($^O eq 'darwin');
my $NX_OS = $WINDOWS ? 'windows' : 'linux';

sub new {
    my $class = shift;
    my $cli = shift;
    my %opts = @_;
    my $self = {
        client_delegate => $cli,
        audio           => delete $opts{audio},
        extra           => delete $opts{extra},
        printing        => delete $opts{printing},
        local_serial    => delete $opts{local_serial},
        opts            => \%opts,
    };
    bless $self, $class;
}

## callback receives:
# 1) a true/false value that indicates what OpenSSL thinks of the certificate
# 2) a C-style memory address of the certificate store
# 3) a string containing the certificate's issuer attributes and owner attributes
# 4) a string containing any errors encountered (0 if no errors).
## returns:
# 1 or 0, depending on whether it thinks the certificate is valid or invalid.
sub _ssl_verify_callback {
    my ($self, $ssl_thinks, $mem_addr, $attrs, $errs) = @_;
    return 1 if $ssl_thinks;

    DEBUG("_ssl_verify_callback called: " . join(' ', @_));

    my $cert_pem_str = Net::SSLeay::PEM_get_string_X509 (Net::SSLeay::X509_STORE_CTX_get_current_cert ($mem_addr));
    my $x509 = Crypt::OpenSSL::X509->new_from_string ($cert_pem_str);

    my $cert_hash = $x509->hash;
    my $cert_temp = <<'EOF';
Serial: %s

Issuer: %s

Validity:
    Not before: %s
    Not after:  %s

Subject: %s
EOF

    my $cert_data = sprintf($cert_temp,
                            (join ':', $x509->serial =~ /../g),
                            $x509->issuer,
                            $x509->notBefore,
                            $x509->notAfter,
                            $x509->subject);

    my $accept = $self->{client_delegate}->proxy_unknown_cert([$cert_pem_str, $cert_data]);
    DEBUG("Certificate " . $accept ? "accepted" : "rejected");

    return unless $accept;

    ## guardar certificado en archivo
    my $dir = core_cfg('path.ssl.ca.personal');
    $dir = File::Spec->rel2abs($dir, $QVD::Client::App::user_dir);
    make_path $dir;
    -d $dir or die "Unable to create directory $dir";

    my $file;
    foreach my $idx (0..99) {
        my $basename = sprintf '%s.%d', $cert_hash, $idx;
        $file = File::Spec->join($dir, $basename);
        last unless -e $file;
    }
    ## TODO: -e $file and what?

    open my $fd, '>', $file or die "Unable to open '$file': $!";
    print $fd $cert_pem_str;
    close $fd;

    return $accept;
}

sub connect_to_vm {
    my $self = shift;
    my $cli = $self->{client_delegate};
    my $opts = $self->{opts};
    my ($host, $port, $user, $passwd) = @{$opts}{qw/host port username password/};

    $cli->proxy_connection_status('CONNECTING');
    INFO("Connecting to $host:$port\n");

    # SSL library has to be initialized in the thread where it's used,
    # so we do a "require QVD::HTTPC" here instead of "use"ing it above
    require QVD::HTTPC;
    my %args;
    my $ssl = $opts->{ssl};
    if ($ssl) {
        $args{SSL}                 = 1;
        $args{SSL_ca_path}         = core_cfg('path.ssl.ca.system');
        $args{SSL_ca_path_alt}     = core_cfg('path.ssl.ca.personal');
        $args{SSL_ca_path_alt}     =~ s|^~(?=/)|$ENV{HOME} // $ENV{APPDATA}|e;
        my $use_cert = core_cfg('client.ssl.use_cert');
        if ($use_cert) {
            $args{SSL_use_cert} = 1;
            $args{SSL_cert_file} = core_cfg('client.ssl.cert_file');
            $args{SSL_key_file} = core_cfg('client.ssl.key_file');
        }
        $args{SSL_verify_callback} = sub { $self->_ssl_verify_callback(@_) };
    }
    my $httpc = eval { QVD::HTTPC->new("$host:$port", %args) };
    unless (defined $httpc) {
        if ($@) {
            ERROR("Connection error: $@");
            $cli->proxy_connection_error(message => $@);
        }
        else {
            # User rejected the server SSL certificate. Return to main window.
            INFO("User rejected certificate. Closing connection.");
            $cli->proxy_connection_status('CLOSED');
        }
        return;
    }

    use MIME::Base64 qw(encode_base64);
    my $auth = encode_base64("$user:$passwd", '');

    INFO("Sending auth");
    $httpc->send_http_request(
        GET => '/qvd/list_of_vm', 
        headers => [
            "Authorization: Basic $auth",
            "Accept: application/json"
        ],
    );

    my ($code, $msg, $response_headers, $body) = $httpc->read_http_response();
    DEBUG("Auth reply: $code/$msg");

    if ($code != HTTP_OK) {
        my $message;
        given ($code) {
            when (HTTP_UNAUTHORIZED) {
                $message = "The server has rejected your login. Please verify that your username and password are correct.";
            }
            when (HTTP_SERVICE_UNAVAILABLE) {
                $message = "The server is under maintenance. Retry later.";
            }
        }
        $message ||= "$host replied with $msg";
        INFO("Connection error: $message");
        $cli->proxy_connection_error(message => $message);
        return;
    }
    INFO("Authentication successful");

    my $vm_list = JSON->new->decode($body);

    my $vm_id = $cli->proxy_list_of_vm_loaded($vm_list);

    if (!defined $vm_id) {
        INFO("VM not selected, closing coonection");
        $cli->proxy_connection_status('CLOSED');
        return;
    }

    if ( $self->{local_serial} ) {
        if ( !$self->_start_socat() ) {
            ERROR("Socat failed to start, closing connection");
            $cli->proxy_connection_status('CLOSED');
            return;
        }
    }

    $opts->{id} = $vm_id;

    my %o = (
        id                            => $opts->{id},
        'qvd.client.keyboard'         => $opts->{keyboard},
        'qvd.client.os'               => $NX_OS,
        'qvd.client.link'             => $opts->{link},
        'qvd.client.geometry'         => $opts->{geometry},
        'qvd.client.fullscreen'       => $opts->{fullscreen},
        'qvd.client.printing.enabled' => $self->{printing},
        'qvd.client.serial.port'      => $opts->{remote_serial}
    );

    my $q = join '&', map { uri_escape($_) .'='. uri_escape($o{$_}) } keys %o;

    DEBUG("Sending parameters");
    $httpc->send_http_request(
        GET => "/qvd/connect_to_vm?$q",
        headers => [
            "Authorization: Basic $auth",
            'Connection: Upgrade',
            'Upgrade: QVD/1.0',
        ],
    );

    while (1) {
        my ($code, $msg, $headers, $body) = $httpc->read_http_response;
        DEBUG("Response: $code/$msg");
	foreach my $hdr (@$headers) {
		DEBUG("Header: $hdr");
	}
        DEBUG("Body: $body") if (defined $body);

        if ($code == HTTP_SWITCHING_PROTOCOLS) {
            DEBUG("Switching protocols. Connected.");
            
            $cli->proxy_connection_status('CONNECTED');
            $self->_run($httpc);
            last;
        }
        elsif ($code == HTTP_PROCESSING) {
            DEBUG("Starting VM...");
            # Server is starting the virtual machine and connecting to the VMA
        }
        else {
            # Fatal error
            my $message;
            if ($code == HTTP_NOT_FOUND) {
                $message = "Your virtual machine does not exist any more.";
            } elsif ($code == HTTP_UPGRADE_REQUIRED) {
                $message = "The server requires a more up-to-date client version.";
            } elsif ($code == HTTP_UNAUTHORIZED) {
                $message = "Login error. Please verify your user and password.";
            } elsif ($code == HTTP_BAD_GATEWAY) {
                $message = "Server error: ".$body;
            } elsif ($code == HTTP_FORBIDDEN) {
                $message = "Your virtual machine is under maintenance.";
            }
            $message ||= "Unable to connect to remote vm: $code $msg";
            
            ERROR("Fatal error: $message");
            $self->_stop_socat();
            $cli->proxy_connection_error(message => $message, code => $code);
            last;
        }
    }
    $cli->proxy_connection_status('CLOSED');
    $self->_stop_socat();
    DEBUG("Connection closed");
}

sub _run {
    my $self = shift;
    my $httpc = shift;

    my @cmd;
    if ($WINDOWS) {
        push @cmd, $ENV{QVDPATH}."/NX/nxproxy.exe";
    } else {
        push @cmd, "nxproxy";
    }

    my %o = ();

    if ( $self->{local_serial} ) {
        $o{http} = core_cfg("client.socat.port");
    }


    if ($WINDOWS) {
        $ENV{'NX_ROOT'} = $ENV{APPDATA}.'/.qvd';
        (my $cygwin_nx_root = $ENV{NX_ROOT}) =~ tr!:\\!//!;
        $o{errors} = '/cygdrive/'.$cygwin_nx_root.'/proxy.log';
        # Call pulseaudio in Windows

        if ( $self->{audio} ) {
            my @pa_args = ($ENV{QVDPATH}."/pulseaudio/pulseaudio.exe", "-D", "--high-priority");
            DEBUG("Starting pulseaudio: " . join(' ', @pa_args));
            if ( Proc::Background->new(@pa_args) ) {
                DEBUG("Pulseaudio started");
            } else {
                ERROR("Pulseaudio failed to start");
            }
        }
    }  
    
    $o{media} = 4713 if $self->{audio};

    if ($self->{printing}) {
        if ($WINDOWS) {
            $o{smb} = 139;
        } else {
            $o{cups} = 631;
        }
    }

    @o{ keys %{$self->{extra}} } = values %{$self->{extra}};
    push @cmd, ("-S");
    push @cmd, (map "$_=$o{$_}", keys %o);

    push @cmd, qw(localhost:40);

    # if ($WINDOWS) {
    # my $program = $cmd[0];
    # my $cmdline = join ' ', map("\"$_\"", @cmd);
    # DEBUG("Running nxproxy: $program $cmdline");
    # require Win32::Process;
    # Win32::Process->import;
    # my $ret = Win32::Process::Create({}, $program, $cmdline, 0, CREATE_NO_WINDOW|NORMAL_PRIORITY_CLASS, '.');
    # if ($ret) {
    # INFO("nxproxy started");
    # }
    # else {
    # ERROR("Failed to start nxproxy");
    # }
    # } else {

    DEBUG("Running nxproxy: @cmd");
    if ( Proc::Background->new(@cmd) ) {
        DEBUG("nxproxy started");
    } else {
        ERROR("nxproxy failed to start");
        die "nxproxy failed to start";
    }

    DEBUG("Listening on 4040\n");
    my $ll = IO::Socket::INET->new(
        LocalPort => 4040,
        ReuseAddr => 1,
        Listen    => 1,
    ) or die "Unable to listen on port 4040";

    my $local_socket = $ll->accept() or die "connection from nxproxy failed";
    DEBUG("Connection accepted\n");

    undef $ll; # close the listening socket
    if ($WINDOWS) {
        my $nonblocking = 1;
        use constant FIONBIO => 0x8004667e;
        ioctl($local_socket, FIONBIO, \$nonblocking);
    }

    DEBUG("Forwarding sockets\n");
    forward_sockets(
        $local_socket,
        $httpc->get_socket,
        buffer_2to1 => $httpc->read_buffered,
        # debug => 1,
    );

    DEBUG("Done.");

    $self->_stop_socat();
}

sub _start_socat {
    my ($self) = @_;

    my $socket  = $self->{local_serial};
    my $debug   = 1;
    my $port    = core_cfg("client.socat.port");
    my $timeout = core_cfg("client.socat.timeout");
    my $socat_running;

    my @args = ("tcp-l:$port,reuseaddr,fork", "$socket,nonblock,raw,echo=0");
    
    unshift @args, "-x", "-v" if ($debug);
   
    if ($WINDOWS) {
        ERROR "socat is not supported on Windows";
        # return undef;
    }
    else {
        if ( ! -c $socket ) {
            $self->{client_delegate}->socat_error(message => "Failed to forward serial port: port $socket doesn't exist");
        } else {
            my $program = core_cfg("command.socat");
            DEBUG("Running socat: $program " . join(' ', @args) . "\n");

            $self->{socat_proc} = Proc::Background->new({'die_upon_destroy' => 1}, $program, @args);
            if ( !$self->{socat_proc} || !$self->{socat_proc}->alive ) {
                ERROR("Failed to start socat");
                $self->{client_delegate}->socat_error(message => "Failed to forward serial port: couldn't start socat");
            } else {
                DEBUG("socat running");
                $socat_running = 1;
            }
        }
    }
    if ( $socat_running ) {
        DEBUG("Waiting for socat to start listening...");
        my $retries = 0;
        my $sock;
        while ($retries++ < $timeout) {
            $sock = IO::Socket::INET->new(PeerAddr => 'localhost',
                                          PeerPort => $port,
                                          Proto    => 'tcp');

            last if $sock;

            DEBUG("Retry $retries/$timeout: $!");
            sleep(1);
        }

        if (!$sock) {
            ERROR("socat not listening on port $port");
            $self->{client_delegate}->socat_error(message => "Failed to forward serial port: socat is not listening");
        }
        else {
            DEBUG("ok");
            close($sock);
            return 1;
        }
    }

    # Something went wrong
    return undef;
}


sub _stop_socat {
    my ($self) = @_;

    if ( $self->{socat_proc} ) {
        DEBUG("Killing socat...");
        if ( $self->{socat_proc}->die ) {
            DEBUG("ok");
        }
        else {
            DEBUG("failed\n");
        }
    }
}

1;
