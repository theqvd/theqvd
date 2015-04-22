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
use QVD::HTTP::Headers qw(header_lookup);
use QVD::HTTP::StatusCodes qw(:status_codes);
use URI::Escape qw(uri_escape);
use QVD::Log;

my $LINUX = ($^O eq 'linux');
my $WINDOWS = ($^O eq 'MSWin32');
my $DARWIN = ($^O eq 'darwin');
my $NX_OS = "unknown";

if ( $LINUX ) {
	$NX_OS = "linux";
} elsif ( $WINDOWS ) {
	$NX_OS = "windows";
} elsif ( $DARWIN ) {
	$NX_OS = "darwin";
}

sub new {
    my $class = shift;
    my $cli = shift;
    my %opts = @_;
    my $self = {
        client_delegate => $cli,
        audio           => delete $opts{audio},
        extra           => delete $opts{extra},
        printing        => delete $opts{printing},
        usb             => delete $opts{usb},
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
    my $err_no    = Net::SSLeay::X509_STORE_CTX_get_error($mem_addr);
    my $err_depth = Net::SSLeay::X509_STORE_CTX_get_error_depth($mem_addr);
    my $err_str   = Net::SSLeay::X509_verify_cert_error_string($err_no);
    
    my $cert_hash = $x509->hash;

    DEBUG("Verification error at depth $err_depth: $err_str when checking " . $x509->subject); 

    my $cert_temp = <<'EOF';
Verification error at depth %i:
%s

Serial: %s

Issuer: %s

Validity:
    Not before: %s
    Not after:  %s

Subject: %s
EOF

    my $cert_data = sprintf($cert_temp,
                            $err_depth,
                            $err_str,
                            (join ':', $x509->serial =~ /../g),
                            $x509->issuer,
                            $x509->notBefore,
                            $x509->notAfter,
                            $x509->subject);

    my $accept = $self->{client_delegate}->proxy_unknown_cert([$cert_pem_str, $cert_data, $err_no]);
    DEBUG("Certificate " . $accept ? "accepted" : "rejected");

    return unless $accept;

    ## guardar certificado en archivo
    my $dir = $QVD::Client::App::user_certs_dir;
    DEBUG "certificates are stored in $dir";
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

sub _get_httpc {
    my ($self, $host, $port) = @_;
    my $opts = $self->{opts};
    my $cli = $self->{client_delegate};

    # SSL library has to be initialized in the thread where it's used,
    # so we do a "require QVD::HTTPC" here instead of "use"ing it above
    require QVD::HTTPC;
    my %args;
    my $ssl = $opts->{ssl};
    if ($ssl) {
        DEBUG "Using a SSL connection";
        $args{SSL}                 = 1;
        $args{SSL_ca_path}         = $DARWIN ? core_cfg('path.darwin.ssl.ca.system') : core_cfg('path.ssl.ca.system');
        $args{SSL_ca_path_alt}     = $QVD::Client::App::user_certs_dir;
        $args{SSL_ca_path_alt}     =~ s|^~(?=/)|$ENV{HOME} // $ENV{APPDATA}|e;

        DEBUG "SSL CA path: " . $args{SSL_ca_path};
        DEBUG "SSL CA alt path: " . $args{SSL_ca_path_alt};

        my $use_cert = core_cfg('client.ssl.use_cert');
        if ($use_cert) {
            $args{SSL_use_cert} = 1;
            $args{SSL_cert_file} = core_cfg('client.ssl.cert_file');
            $args{SSL_key_file} = core_cfg('client.ssl.key_file');
            
            DEBUG "SSL cert: $args{SSL_cert_file}; key: $args{SSL_key_file}";
        }
        $args{SSL_verify_callback} = sub { $self->_ssl_verify_callback(@_) };
    } else {
        DEBUG "Not using SSL";
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
    $httpc;
}

sub connect_to_vm {
    my $self = shift;
    my $cli = $self->{client_delegate};
    my $opts = $self->{opts};
    my ($host, $port, $user, $passwd) = @{$opts}{qw/host port username password/};
    my $file = $opts->{file};
    my $q = '';
    if ($file) {
        my %o = (file_name => $file);
        $q = join '&', map { uri_escape($_) .'='. uri_escape($o{$_}) } keys %o;
    }

    $cli->proxy_connection_status('CONNECTING');
    INFO("Connecting to $host:$port\n");

    my $httpc = $self->_get_httpc($host, $port) or return;

    use MIME::Base64 qw(encode_base64);
    my $auth = encode_base64("$user:$passwd", '');

    INFO("Sending auth");
    $httpc->send_http_request(
        GET => '/qvd/list_of_vm?'.$q,
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
                $message = "The server is under maintenance. Retry later.\nThe server said: $body";
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


    if ( $opts->{kill_vm} ) {        
        DEBUG("Stopping currently running VM $vm_id");
        
        my %o = ( id => $vm_id );
        $q = join '&', map { uri_escape($_) .'='. uri_escape($o{$_}) } keys %o;
        
        $httpc->send_http_request(
            GET => "/qvd/stop_vm?$q",
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
            
            
            if ( $code != HTTP_PROCESSING ) {
                if ( $code == HTTP_OK ) {
                    DEBUG "VM shut down";
                } elsif ( $code == HTTP_SERVICE_UNAVAILABLE ) {
                    # VM blocked, this should fail again when start is attempted
                    DEBUG "VM on blocked server, ignoring";
                } elsif ( $code == HTTP_NOT_FOUND ) {
                    # No VM, no problem
                    DEBUG "VM does not exist, ignoring";
                } elsif ( $code == HTTP_FORBIDDEN ) {
                    DEBUG "VM offline for maintenance";
                } else {
                    DEBUG "Unrecognized status code $code";
                }
            
                # Leave error reporting to the next step
                last;
            }
        }
        
    }
    
    
    $opts->{id} = $vm_id;

    my %o = (
        id                              => $opts->{id},
        'qvd.client.keyboard'           => $opts->{keyboard},
        'qvd.client.os'                 => $NX_OS,
        'qvd.client.link'               => $opts->{link},
        'qvd.client.nxagent.extra_args' => $opts->{extra_args},
        'qvd.client.geometry'           => $opts->{geometry},
        'qvd.client.fullscreen'         => $opts->{fullscreen},
        'qvd.client.printing.enabled'   => $self->{printing},
        'qvd.client.usb.enabled'        => $self->{usb},
    );
	
	if ( $WINDOWS ) {
		DEBUG "Sending Windows version and host info";
		require Win32;
		$o{'qvd.client.os.name'}    = join('; ' , Win32::GetOSName());
		$o{'qvd.client.os.version'} = join('; ', Win32::GetOSVersion());
		$o{'qvd.client.hostname'}   = Win32::NodeName();
	}

    $q = join '&', map { uri_escape($_) .'='. uri_escape($o{$_}) } keys %o;

    DEBUG("Sending parameters: $q");
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
            if (my ($key) = header_lookup($headers, 'X-QVD-Slave-Key')) {
                $cli->proxy_slave_key($key) if $cli->can('proxy_slave_key');
                my $slave_key_file = $QVD::Client::App::user_dir.'/slave-key'; 
                if (open(my $fh, '>', $slave_key_file)) {
                    print $fh $key;
                    close $fh;
                } else {
                    WARN "Unable to save key used for slave connections: $^E";
                }
            }
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
            $message = ($code == HTTP_NOT_FOUND        ? "Your virtual machine does not exist any more"         :
                        $code == HTTP_UPGRADE_REQUIRED ? "The server requires a more up-to-date client version" :
                        $code == HTTP_UNAUTHORIZED     ? "Login error. Please verify your user and password"    :
                        $code == HTTP_BAD_GATEWAY      ? "Server error: $body"                                  :
                        $code == HTTP_FORBIDDEN        ? "Your virtual machine is under maintenance."           :
                                                         "Unable to connect to remote VM: $code $msg\n\n$body" );
            ERROR("Fatal error: $message");
            $cli->proxy_connection_error(message => $message, code => $code);
            last;
        }
    }
    $cli->proxy_connection_status('CLOSED');
    DEBUG("Connection closed");
}

sub _run {
    my $self = shift;
    my $httpc = shift;

    my %o;

    # Erase any previously set value. This is only for nxproxy, may break other things
    $self->{client_delegate}->proxy_set_environment( DYLD_LIBRARY_PATH => "" );
    
    if ($WINDOWS) {
        my $cygwin_nx_root = "/cygdrive/$QVD::Client::App::user_dir";
        $cygwin_nx_root =~ tr|:\\|//|;
        $self->{client_delegate}->proxy_set_environment( NX_ROOT => $cygwin_nx_root );
        $o{errors} = "$cygwin_nx_root/nxproxy.log";

        DEBUG "NX_ROOT: $cygwin_nx_root";
        DEBUG "save nxproxy log at: $o{errors}";
    }

   
    # Call pulseaudio in Windows or Darwin
    my $pa_proc;
    if ( $self->{audio} && ( $WINDOWS || $DARWIN ) ) {
        my $pa_bin = $WINDOWS ? core_cfg('command.windows.pulseaudio') : core_cfg('command.darwin.pulseaudio');
        my $pa_log = File::Spec->rel2abs("pulseaudio.log", $QVD::Client::App::user_dir);
        my $pa_cfg = File::Spec->rel2abs("default.pa", $QVD::Client::App::user_dir);
        
        my @pa = (File::Spec->rel2abs($pa_bin, $QVD::Client::App::app_dir),
            "--high-priority", "-vvvv");

        # Current version of PulseAudio on Windows doesn't permit "file" target
        push @pa, "--log-target=file:/$pa_log"  if ($DARWIN);
            
        if ( -f $pa_cfg ) {
		DEBUG "Using config file $pa_cfg";
		push @pa, "-F", $pa_cfg;
	}
	
        DEBUG("Starting pulseaudio: @pa");
        if ( ( $pa_proc = Proc::Background->new(@pa)) ) {
            DEBUG("Pulseaudio started");
        } else {
            ERROR("Pulseaudio failed to start");
        }
    }

     if ( core_cfg('client.slave.enable') && core_cfg('client.usb.enable') ) {
        DEBUG "USB sharing enabled";
        my $usbsrv = core_cfg('command.usbsrv');

        if ( core_cfg('client.usb.share_all') ) {
            DEBUG "USB autoshare enabled";
            system($usbsrv, '-autoshare', 'on');
        } else {
            DEBUG "USB autoshare disabled";
            system($usbsrv, '-autoshare', 'off');

            my @usblist = `$usbsrv -list`;
            chomp @usblist;
            my (@unshare, $pid, $vid);

            DEBUG "Getting shared USB devices";
            foreach my $line ( @usblist ) {
                if ( $line =~ /^\s*\d+:/ ) {
                    undef $pid;
                    undef $vid;
                }

                if ( $line =~ /Vid: ([a-f0-9]{4})\s+Pid: ([a-f0-9]{4})/i  ) {
                    ($vid, $pid) = ($1, $2);
                }

                if ( $line =~ /^\s+Status:.*?shared/ && $pid && $vid ) {
                    push @unshare, [$vid, $pid];
                }
            }
            
            DEBUG "Unsharing devices";
            foreach my $dev (@unshare) {
                my ($vid, $pid) = @$dev;
                DEBUG "Unsharing VID $vid, PID $pid";
                system($usbsrv, "-unshare", "-vid", $vid, "-pid", $pid) == 0
                    or ERROR "Failed to unshare device with VID $vid, PID $pid";
            }

            my $tmp = core_cfg('client.usb.share_list', 0) // "";
            $tmp =~ s/\s+//g;

            DEBUG "Sharing devices: $tmp";
            foreach my $dev ( split(/,/, $tmp) ) {
                my ($vid, $pid) = split(/:/, $dev);

                DEBUG "Sharing VID $vid PID $pid";
                system($usbsrv, "-share", "-vid", $vid, "-pid", $pid) == 0 or ERROR "Failed to share device with VID $vid, PID $pid";
            }
        }
    }

    if ($self->{audio}) {
	if (defined(my $ps = $ENV{PULSE_SERVER})) {
	    # FIXME: we should read /etc/pulseaudio/client.conf and
	    # honor it and also be able to forward media to a UNIX
	    # socket!!!
	    if ($ps =~ /^(?:tcp:localhost:)?(\d+)$/) {
		$o{media} = $1;
	    }
	    else {
		WARN "Unable to detect PulseAudio configuration from \$PULSE_SERVER ($ps)";
	    }
	}
	$o{media} //= 4713;
    }

    if ($self->{printing}) {
        if ($WINDOWS) {
            $o{smb} = 445;
        } else {
            $o{cups} = 631;
        }
    }

    @o{ keys %{$self->{extra}} } = values %{$self->{extra}};
    # Use a port from the ephemeral range for slave server
    my $slave_port_file = $QVD::Client::App::user_dir.'/slave-port'; 
    if (core_cfg('client.slave.enable', 1)) {
        my $port = 62000 + int(rand(2000));
        if (open(my $fh, '>', $slave_port_file)) {
            $o{slave} = $port;
            INFO "Using slave port $port";
            print $fh $port;
            close $fh;
        } else {
            WARN "Unable to save port used for slave connections; slave client disabled: $^E";
        }
    }

    my @cmd;
    if ( $WINDOWS ) {
        @cmd = File::Spec->rel2abs(core_cfg('command.windows.nxproxy'), $QVD::Client::App::app_dir);
    } elsif ( $DARWIN ) {
        @cmd = File::Spec->rel2abs(core_cfg('command.darwin.nxproxy'), $QVD::Client::App::app_dir);
    } else {
        @cmd = core_cfg('command.nxproxy');
    }


	push @cmd, split(/\s+/, core_cfg('client.nxproxy.extra_args')) if ( core_cfg('client.nxproxy.extra_args') );
    push @cmd, '-S', map("$_=$o{$_}", keys %o), 'localhost:40';

    my $slave_cmd = core_cfg('client.slave.command', 0);
    if (defined $slave_cmd and length $slave_cmd) {
        $slave_cmd = File::Spec->rel2abs($slave_cmd, $QVD::Client::App::app_dir);
        if (-x $slave_cmd ) {
            DEBUG("Slave command is '$slave_cmd'");
            $self->{client_delegate}->proxy_set_environment( QVD_SLAVE_CMD => $slave_cmd );
        } else {
            WARN("Slave command '$slave_cmd' not found or not executable.");
        }
    }
    
    if ( $DARWIN ) {
        $self->{client_delegate}->proxy_set_environment( DYLD_LIBRARY_PATH => "$QVD::Client::App::app_dir/lib" );
        DEBUG "Running on Darwin, DYLD_LIBRARY_PATH set to $ENV{DYLD_LIBRARY_PATH}";
    }

    DEBUG("Running nxproxy: @cmd");
    my $nxproxy_proc;

    if ( ($nxproxy_proc =  Proc::Background->new(@cmd)) ) {
        DEBUG("nxproxy started, DYLD_LIBRARY_PATH=" . $ENV{DYLD_LIBRARY_PATH});
    } else {
        ERROR("nxproxy failed to start");
        die "nxproxy failed to start";
    }

    if ( $DARWIN ) {
        $self->{client_delegate}->proxy_set_environment( DYLD_LIBRARY_PATH => "" );
        DEBUG "Running on Darwin, unssetting DYLD_LIBRARY_PATH";
    }

    DEBUG("Listening on 4040\n");
    my $ll = IO::Socket::INET->new(
        LocalPort => 4040,
        LocalAddr => 'localhost',
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
    $self->{client_delegate}->proxy_connection_status('FORWARDING');
    forward_sockets(
        $local_socket,
        $httpc->get_socket,
        buffer_2to1 => $httpc->read_buffered,
        # debug => 1,
    );
    DEBUG("nxproxy exited with status " . $nxproxy_proc->wait);
    
    if ( $pa_proc ) {
        DEBUG("Stopping pulseaudio...");
        if ( $pa_proc->die ) {
	    DEBUG("Pulseaudio exited with status " . $pa_proc->wait);
        } else {
            ERROR("Failed to kill pulseaudio");
        }
    }

    if ($o{slave}) {
        INFO "Deleting slave port file $slave_port_file";
        unlink $slave_port_file ;
    }

    DEBUG("Done.");

}


1;
