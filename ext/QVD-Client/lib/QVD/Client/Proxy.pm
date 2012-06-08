package QVD::Client::Proxy;

use strict;
use warnings;
use feature qw(switch);

use Crypt::OpenSSL::X509;
use File::Path 'make_path';
use File::Spec;
use IO::Socket::INET;
use IO::Socket::Forwarder qw(forward_sockets);
use JSON;
use Proc::Background;
use QVD::Config;
use QVD::HTTP::StatusCodes qw(:status_codes);
use URI::Escape qw(uri_escape);

my $WINDOWS = ($^O eq 'MSWin32');
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

    my $cert_pem_str = Net::SSLeay::PEM_get_string_X509 (Net::SSLeay::X509_STORE_CTX_get_current_cert ($mem_addr));
    my $x509 = Crypt::OpenSSL::X509->new_from_string ($cert_pem_str);

    my $cert_hash = $x509->hash;
    my $cert_data = sprintf <<'EOF', (join ':', $x509->serial=~/../g), $x509->issuer, $x509->notBefore, $x509->notAfter, $x509->subject;
Serial: %s

Issuer: %s

Validity:
    Not before: %s
    Not after:  %s

Subject: %s
EOF

    #print "cert_hash ($cert_hash)\n";
    #print "ssl_thinks ($ssl_thinks) mem_addr ($mem_addr) attrs ($attrs) errs ($errs)\n";
    #printf "cert_pem_str (%s)\n", $cert_pem_str;
    #printf "cert_data (%s)\n", $cert_data;

    my $accept = $self->{client_delegate}->proxy_unknown_cert([$cert_pem_str, $cert_data]);

    return unless $accept;

    ## guardar certificado en archivo
    my $dir = File::Spec->catfile (($ENV{HOME} || $ENV{APPDATA}), cfg('path.ssl.ca.personal'));
    make_path $dir, { error => \my $mkpath_err };
    if ($mkpath_err and @$mkpath_err) {
        my $errs_text;
        for my $err (@$mkpath_err) {
            my ($file, $errmsg) = %$err;
            if ('' eq $file) {
                $errs_text .= "generic error: ($errmsg)\n";
            } else {
                $errs_text .= "mkpath '$file': ($errmsg)\n";
            }
        }

        die $errs_text;
    }

    my $file;
    foreach my $idx (0..9) {
        my $basename = sprintf '%s.%d', $cert_hash, $idx;
        $file = File::Spec->catfile ($dir, $basename);
        last unless -e $file;
    }
    ## TODO: -e $file and what?

    open my $fd, '>', $file or die "open: '$file': $!";
    print $fd $cert_pem_str;
    close $fd;

    return $accept;
}

sub connect_to_vm {
    my $self = shift;
    my $cli = $self->{client_delegate};
    my $ci = $self->{opts};
    my %connect_info = %$ci;
    my ($host, $port, $user, $passwd) = @connect_info{qw/host port username password/};

    $cli->proxy_connection_status('CONNECTING');
    print "*** Connecting to $host:$port\n";
    # SSL library has to be initialized in the thread where it's used,
    # so we do a "require QVD::HTTPC" here instead of "use"ing it above
    require QVD::HTTPC;
    my $httpc = eval { new QVD::HTTPC(
        "$host:$port",
        SSL => $connect_info{ssl},
        SSL_verify_callback => sub { $self->_ssl_verify_callback(@_) }
    )};
    if ($@) {
        $cli->proxy_connection_error(message => $@);
        return;
    } else {
        if (!$httpc) {
            # User rejected the server SSL certificate. Return to main window.
            $cli->proxy_connection_status('CLOSED');
            return;
        }
    }

    use MIME::Base64 qw(encode_base64);
    my $auth = encode_base64("$user:$passwd", '');

    $httpc->send_http_request(
        GET => '/qvd/list_of_vm', 
        headers => [
            "Authorization: Basic $auth",
            "Accept: application/json"
        ],
    );

    my ($code, $msg, $response_headers, $body) = $httpc->read_http_response();
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
        $cli->proxy_connection_error(message => $message);
        return;
    }

    my $vm_list = JSON->new->decode($body);

    my $vm_id = $cli->proxy_list_of_vm_loaded($vm_list);

    if (!defined $vm_id) {
        $cli->proxy_connection_status('CLOSED');
        return;
    }
    $connect_info{id} = $vm_id;

    my %o = (
        id                            => $connect_info{id},
        'qvd.client.keyboard'         => $connect_info{keyboard},
        'qvd.client.os'               => $NX_OS,
        'qvd.client.link'             => $connect_info{link},
        'qvd.client.geometry'         => $connect_info{geometry},
        'qvd.client.fullscreen'       => $connect_info{fullscreen},
        'qvd.client.printing.enabled' => $self->{printing},
        'qvd.client.serial.port'      => $connect_info{remote_serial}
    );

    my $q = join '&', map { uri_escape($_) .'='. uri_escape($o{$_}) } keys %o;
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
        if ($code == HTTP_SWITCHING_PROTOCOLS) {
            $cli->proxy_connection_status('CONNECTED');
            $self->_run($httpc);
            last;
        }
        elsif ($code == HTTP_PROCESSING) {
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
            $cli->proxy_connection_error(message => $message, code => $code);
            last;
        }
    }
    $cli->proxy_connection_status('CLOSED');
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
        $self->_start_socat();
        $o{http} = cfg("client.socat.port");
    }


    if ($WINDOWS) {
        $ENV{'NX_ROOT'} = $ENV{APPDATA}.'/.qvd';
        (my $cygwin_nx_root = $ENV{NX_ROOT}) =~ tr!:\\!//!;
        $o{errors} = '/cygdrive/'.$cygwin_nx_root.'/proxy.log';
        # Call pulseaudio in Windows
        Proc::Background->new($ENV{QVDPATH}."/pulseaudio/pulseaudio.exe", "-D", "--high-priority") if $self->{audio};     
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

    if ($WINDOWS) {
        my $program = $cmd[0];
        my $cmdline = join ' ', map("\"$_\"", @cmd);
        use constant CREATE_NO_WINDOW => 0;
        use constant NORMAL_PRIORITY_CLASS => 0;
        require Win32::Process;
        Win32::Process->import;
        Win32::Process::Create({}, $program, $cmdline, 0, CREATE_NO_WINDOW|NORMAL_PRIORITY_CLASS, '.');
    } else {
        print "Starting " . join(' ' , @cmd) . "\n";
        Proc::Background->new(@cmd);
    }
    print "Listening on 4040\n";
    my $ll = IO::Socket::INET->new(
        LocalPort => 4040,
        ReuseAddr => 1,
        Listen    => 1,
    ) or die "Unable to listen on port 4040";

    my $local_socket = $ll->accept() or die "connection from nxproxy failed";
    print "Connection accepted\n";

    undef $ll; # close the listening socket
    if ($WINDOWS) {
        my $nonblocking = 1;
        use constant FIONBIO => 0x8004667e;
        ioctl($local_socket, FIONBIO, \$nonblocking);
    }

    print "Forwarding sockets\n";
    forward_sockets(
        $local_socket,
        $httpc->get_socket,
        buffer_2to1 => $httpc->read_buffered,
        # debug => 1,
    );

    print "Done.\n";

    if ( $self->{socat_proc} ) {
        print "Killing socat...";
        if ( $self->{socat_proc}->die ) {
            print " ok\n";
        } else {
            print " failed\n";
        }
    }

}

sub _start_socat {
    my ($self) = @_;

    my $socket  = $self->{local_serial};
    my $debug   = 1;
    my $port    = cfg("client.socat.port");
    my $timeout = cfg("client.socat.timeout");
    my $socat_running;

    my @args = ("PTY,link=$socket,raw,echo=0", "tcp-l:$port,reuseaddr,fork");
    
    unshift @args, "-x", "-v" if ($debug);
   
    if ($WINDOWS) {
        my $program = $ENV{QVDPATH} . "/socat/socat.exe";
        my $cmdline = join ' ', map("\"$_\"", @args);
        use constant CREATE_NO_WINDOW => 0;
        use constant NORMAL_PRIORITY_CLASS => 0;
        require Win32::Process;
        Win32::Process->import;

        print "Running socat: $program $cmdline\n";
        if ( Win32::Process::Create({}, $program, $cmdline, 0, CREATE_NO_WINDOW|NORMAL_PRIORITY_CLASS, '.') ) {
            $socat_running = 1;
        } else {
            $self->{client_delegate}->internal_error(message => "Failed to forward serial port: couldn't start socat: " .
                                                                Win32::FormatMessage( Win32::GetLastError() ));
        }
    } else {
        my $program = cfg("command.socat");
        print "Running socat: $program " . join(' ', @args) . "\n";

        $self->{socat_proc} = Proc::Background->new({'die_upon_destroy' => 1}, $program, @args);
        if ( !$self->{socat_proc} || !$self->{socat_proc}->alive ) {
            $self->{client_delegate}->internal_error(message => "Failed to forward serial port: couldn't start socat");
        } else {
            $socat_running = 1;
        }

    }
 
    if ( $socat_running ) {
        print "Waiting for socat to start listening...\n";
        my $retries = 0;
        my $sock;
        while ($retries++ < $timeout) {
                $sock = new IO::Socket::INET(PeerAddr => 'localhost', 
                                        PeerPort => $port, 
                                        Proto    => 'tcp');

                last if ($sock);

                print "Retry $retries/$timeout: $!\n";
                sleep(1);
        }

        if (!$sock) {
                print "socat not listening on port $port\n";
                $self->{client_delegate}->internal_error(message => "Failed to forward serial port: socat is not listening");
        } else {
                print "ok\n";
                close($sock);
        }
    }

}
1;
