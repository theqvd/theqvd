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
use QVD::Client::USB;
use QVD::Client::USB::USBIP;
use QVD::Client::USB::IncentivesPro;
use Carp;


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
        usb_impl        => delete $opts{usb_impl},
        opts            => \%opts,
    };
    
    bless $self, $class;
}

sub _add_ssl_error {
    my ($self, $ssl_depth, $err_no, $err_depth, $err_str) = @_;

    if (!exists $self->{cert_info}->[$ssl_depth]) {
        $self->{cert_info}->[$ssl_depth] = {
            errors => [],
        }
    }

    my $ci = $self->{cert_info}->[$ssl_depth];

    push @{ $ci->{errors} }, {
        err_no    => $err_no,
        err_depth => $err_depth,
        err_str   => $err_str
    };

 
    $self->{ssl_errors}++;

    if ( $self->is_accepted( 'sha256', $ci->{fingerprint}->{sha256}, $err_no ) ) {
        DEBUG "SSL error $err_no ignored for certificate " . $ci->{fingerprint}->{sha256};
        $self->{ssl_ignored_errors}++;
    }
}

## callback receives:
# 1) a true/false value that indicates what OpenSSL thinks of the certificate
# 2) a C-style memory address of the certificate store
# 3) a string containing the certificate's issuer attributes and owner attributes
# 4) a string containing any errors encountered (0 if no errors).
## returns:
# 1 or 0, depending on whether it thinks the certificate is valid or invalid.
sub _ssl_verify_callback {
    my ($self, $ssl_thinks, $mem_addr, $attrs, $errs, $peer_cert, $ssl_depth) = @_;
    return 1 if $ssl_thinks;

    DEBUG("_ssl_verify_callback called: " . join(' ', @_));

    if (!exists $self->{cert_info}->[$ssl_depth]) {
        $self->{cert_info}->[$ssl_depth] = {
            errors => [],
        };
    }

    my $ci = $self->{cert_info}->[$ssl_depth];

    my $cert = Net::SSLeay::X509_STORE_CTX_get_current_cert ($mem_addr);
    my $cert_pem_str = Net::SSLeay::PEM_get_string_X509 ($cert);
    my $x509 = Crypt::OpenSSL::X509->new_from_string ($cert_pem_str);

    my $err_no    = Net::SSLeay::X509_STORE_CTX_get_error($mem_addr);
    my $err_depth = Net::SSLeay::X509_STORE_CTX_get_error_depth($mem_addr);
    my $err_str   = Net::SSLeay::X509_verify_cert_error_string($err_no);

    push @{ $ci->{errors} }, { 
        err_no    => $err_no,
        err_depth => $err_depth,
        err_str   => $err_str 
    };
 
    $ci->{ssl_ok}           = $ssl_thinks;  
    $ci->{hash}             = $x509->hash;
    $ci->{subject}          = _split_dn( $x509->subject );
    $ci->{serial}           = $x509->serial;
    $ci->{issuer}           = _split_dn( $x509->issuer );
    $ci->{not_before}       = $x509->notBefore;
    $ci->{not_after}        = $x509->notAfter;
    $ci->{pem}              = $cert_pem_str;
    $ci->{sig_algo}         = $x509->sig_alg_name;
    $ci->{bit_length}       = $x509->bit_length; 
    $ci->{selfsigned}       = $x509->is_selfsigned;
    $ci->{extensions}       = {};
    
    foreach my $algo ("sha1", "sha256", "ripemd160") {
        $ci->{fingerprint}->{$algo} = Net::SSLeay::X509_get_fingerprint($cert, $algo);
    }

    my $exts = $x509->extensions_by_oid();

    foreach my $oid (keys %$exts) {
        my $ext = $$exts{$oid};
        if ( $oid eq "2.5.29.15" ) { # KeyUsage
            $ci->{extensions}->{key_usage} = { $ext->hash_bit_string };
        } elsif ( $oid eq "2.16.840.1.113730.1.1" ) { # nsCertType
            $ci->{extensions}->{cert_type} = { $ext->hash_bit_string };
        }

        #print STDERR $oid, " ", $ext->object()->name(), ": ", $ext->value(), "\n";
    }


    my @altnames = Net::SSLeay::X509_get_subjectAltNames($cert);
    my @typenames = qw(Other Email DNS X400 Directory EDIPARTY URI IP RID);

    if ( @altnames ) {
        $ci->{extensions}->{altnames} = [];

        while (@altnames) {
            my $type = shift @altnames;
            my $value = shift @altnames;
            my $tname = $typenames[$type];

            $value = join('.', unpack('C4', $value)) if ( $type == 7 ); # IP Address
            push @{ $ci->{extensions}->{altnames} }, { $tname => $value };
        }
    }


    if (!$ssl_thinks) {
        DEBUG "SSL error $err_no when checking certificate " . $ci->{fingerprint}->{sha256};
        $self->{ssl_errors}++;

        if ( $self->is_accepted( 'sha256', $ci->{fingerprint}->{sha256}, $err_no ) ) {
            DEBUG "SSL error $err_no ignored for certificate " . $ci->{fingerprint}->{sha256};

            $self->{ssl_ignored_errors}++;
        }
    }



    return 1;
}

sub _split_dn {
    my ($dn) = @_;
    my $ret = {};
    my $buf = "";
    my ($k,$v) = ("", "");

    #print STDERR "STR: $dn\n";

    my $str = $dn;
    while($str) {
        my ($match, $rest) = ($str =~ m/^(.*?)[,=](.*)$/);

        $str = $rest;
        $buf .= $match if (defined $match);

        if ( $buf =~ /\\$/ ) {
            $buf =~ s/\\$//;
            $buf .= $k eq "" ? "=" : ",";
        } else {
            if ($k eq "") {
                $k = $buf;
                $buf = "";
            } else {
                $v = $buf;
                $buf = "";
            } 

            if ( $k ne "" && $v ne "" ) {
                for($k, $v) {
                    s/^\s+//;
                    s/\s+$//;
                }
                $k = lc($k);

                $ret->{$k} = $v;
                $buf = "";
                $k = "";
                $v = "";
            }
        }
    }

    return $ret;
}

sub accept_cert {
    my ($self, %data) = @_;

    die "algorithm required" unless ( $data{algo} );
    die "fingerprint required" unless ( $data{fingerprint} );
    die "description required" unless ( $data{description} );
    
    my $key = $data{algo} . "\$" . $data{fingerprint};
 
    $self->{accepted_certs} //= { };
    $self->{accepted_certs}->{$key} = \%data;
    
    $self->_save_accepted_certs;
}

sub is_accepted {
    my ($self, $algo, $fingerprint, $errno) = @_;
    
    my $key = "${algo}\$${fingerprint}";

    if ( exists $self->{accepted_certs}->{$key} ) {
        my $ci = $self->{accepted_certs}->{$key};

        return scalar grep { $_ == $errno } @{ $ci->{errors} };
    }
}

sub delete_exception {
    my ($self, $algo, $fingerprint) = @_;

    my $key = "${algo}\$${fingerprint}";
    delete $self->{accepted_certs}->{$key};
}


sub _load_accepted_certs {
    my ($self) = @_;
    my $file = File::Spec->join($QVD::Client::App::user_dir, "accepted_certs.json");
    $self->{accepted_certs} = {};

    DEBUG "Loading accepted certificates";

    if (open(my $fd, '<', $file)) {
        local $/;
        undef $/;
        my $data = <$fd>;
        close $fd;

        $self->{accepted_certs} = from_json( $data, { utf8 => 1 } );
    } else {
        WARN "Can't open $file: $!";
    }
}

sub _save_accepted_certs {
    my ($self) = @_;
    my $file = File::Spec->join($QVD::Client::App::user_dir, "accepted_certs.json");

    DEBUG "Saving accepted certificates";
    open(my $fd, '>', $file) or die "Can't create $file: $!";
    print $fd to_json( $self->{accepted_certs}, { utf8 => 1, pretty => 1 } );
    close $fd;
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

        foreach my $opt ( @QVD::HTTPC::SSL_OPTIONS ) {
            DEBUG "Checking if SSL option '$opt' is set";

            my $val = core_cfg("client.ssl.options.$opt", 0);
            if ( $val ) {
                INFO "SSL option $opt set: $val";
                $args{$opt} = $val;
            }
        }

        $args{SSL_ca_path}          = $DARWIN ? core_cfg('path.darwin.ssl.ca.system') : core_cfg('path.ssl.ca.system');
        $args{SSL_ca_path_alt}      = $QVD::Client::App::user_certs_dir;
        $args{SSL_ca_path_alt}      =~ s|^~(?=/)|$ENV{HOME} // $ENV{APPDATA}|e;

        # We handle the errors here later, rather than having HTTPC die on those errors
        $args{SSL_fail_on_ocsp}     = 0;
        $args{SSL_fail_on_hostname} = 0;

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

        $self->_load_accepted_certs();
        $args{SSL_fingerprint} = [ keys %{ $self->{accepted_certs} } ];

 
        # These are used by SSL_verify_callback to store the errors encountered
        $self->{ssl_errors}         = 0;
        $self->{ssl_ignored_errors} = 0;
        $self->{cert_info}          = [];

    } else {
        DEBUG "Not using SSL";
    }
   
    my $httpc = QVD::HTTPC->new();
    my $ret; 
    eval { $ret = $httpc->connect("$host:$port", %args) };

    if ($@) {
        ERROR("Connection error: $@");
        my $msg = $@;

        if ( $@ =~ /hostname verification failed/ ) {
            if ( $httpc->is_ssl ) {
                my $sock = $httpc->get_failed_socket;
                my $certhost = $sock->peer_certificate('commonName');
 
                $msg = "Hostname verification failed.\n\n" .
                       "Connected to $host:$port, but the certificate belongs to $certhost";
            } else {
                $msg = "Hostname verification error on non-SSL connection?";
            }
        } elsif ( $@ =~ /certificate verify failed/ ) {
            # User rejected the server SSL certificate. Return to main window.
            INFO("User rejected certificate. Closing connection.");
            $cli->proxy_connection_status('CLOSED');
            return;
        }

        $cli->proxy_connection_error(message => $msg);
        return;
    }

    if ($ssl) {
        if ( (my $herr = $httpc->get_hostname_error()) ) {
            $self->_add_ssl_error(0, 1001, 0, $herr);
        }

        if ( (my $oerr = $httpc->get_ocsp_errors()) ) {
            $self->_add_ssl_error(0, 2001, 0, $oerr);
        }


        # We've successfully connected, but there may be stored up verification errors.
        # We ignore them in the verification callback so that we can store all the errors
        # and present them to the user at once here.
        
        my $errcount = $self->{ssl_errors} - $self->{ssl_ignored_errors};

        if ( $errcount > 0 ) {
            DEBUG "$errcount SSL errors ( $self->{ssl_errors} total, $self->{ssl_ignored_errors} ignored ) while logging in, asking user";

            my $accept = $self->{client_delegate}->proxy_unknown_cert($self->{cert_info});
            #print STDERR "ACCEPT: $accept\n";
            if (!$accept) {
                INFO("User rejected certificate. Closing connection.");
                $cli->proxy_connection_status('CLOSED');
                return;
            }
            if ( $accept == 2 ) {
                foreach my $cert ( @{ $self->{cert_info} } ) {
                    my @errors = map { $_->{err_no} } @{ $cert->{errors} };

                    $self->accept_cert( algo        => 'sha256', 
                                        fingerprint => $cert->{fingerprint}->{sha256},
                                        description => $cert->{subject},
                                        errors      => \@errors );
                }
            }
        }
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
                # just ignore the return status from stop_vm and let's connect_to_vm run...
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
        'qvd.client.usb.implementation' => $self->{usb_impl},
    );
	
	if ( $WINDOWS ) {
		DEBUG "Sending Windows version and host info";
		require Win32;
		$o{'qvd.client.os.name'}    = join('; ' , Win32::GetOSName());
		$o{'qvd.client.os.version'} = join('; ', Win32::GetOSVersion());
		$o{'qvd.client.hostname'}   = Win32::NodeName();
	}

    $q = join '&', map { 
        warn "Undefined value for option $_" unless defined $o{$_};
        uri_escape($_) .'='. uri_escape($o{$_}) 
    } keys %o;

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
        
        my $usb = QVD::Client::USB::instantiate( core_cfg('client.usb.implementation' ) );
        
        
        if ( core_cfg('client.usb.share_all') && $usb->can_autoshare ) {
		$usb->set_autoshare(1);
	} else {
		$usb->set_autoshare(0) if ( $usb->can_autoshare );
		
		my @devs = map { [ $_ ] } split(/,/, core_cfg('client.usb.share_list'));
		$usb->share_list_only(@devs);
		
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
