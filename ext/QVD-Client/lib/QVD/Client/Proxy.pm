package QVD::Client::Proxy;

use strict;
use warnings;
use 5.010;

use Crypt::OpenSSL::X509;
use File::Path 'make_path';
use File::Spec;
use Socket qw(IPPROTO_TCP TCP_NODELAY);
use IO::Socket::INET;
use IO::Socket::SSL;
use IO::Socket::Forwarder qw(forward_sockets);
use JSON;
use Proc::Background;
use QVD::Config::Core;
use QVD::HTTP::Headers qw(header_lookup);
use QVD::HTTP::StatusCodes qw(:status_codes);
use URI::Escape qw(uri_escape);
use QVD::Log;
use QVD::Client::PulseAudio;
use Time::HiRes qw(sleep);
use Carp;


my $LINUX = ($^O eq 'linux');
my $WINDOWS = ($^O eq 'MSWin32');
my $DARWIN = ($^O eq 'darwin');
my $NX_OS = "unknown";

# Start of dynamically allocated port range, as per IANA:
# https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml
my $DYNAMIC_PORT_START = 49152;
my $DYNAMIC_PORT_COUNT = 16383;

if ( $LINUX ) {
	$NX_OS = "linux";
} elsif ( $WINDOWS ) {
	$NX_OS = "windows";
} elsif ( $DARWIN ) {
	$NX_OS = "darwin";
}

sub _logdie {
    my $message = join(' ', @_);
    ERROR $message;
    die "$message\n";
}

sub new {
    my $class = shift;
    my $cli = shift;
    my %opts = @_;
    my $self = {
        client_delegate => $cli,
        audio           => delete $opts{audio},
        compress_audio  => core_cfg('client.audio.compression.enable'),
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
    } unless  $ssl_thinks ;
 
    $ci->{ssl_ok}           = $ssl_thinks;  
    $ci->{hash}             = $x509->hash;
    $ci->{subject}          = { map { lc $_->type, $_->value } @{$x509->subject_name->entries} };
    $ci->{serial}           = $x509->serial;
    $ci->{issuer}           = { map { lc $_->type, $_->value } @{$x509->issuer_name->entries} };
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

        eval {
            $self->{accepted_certs} = from_json( $data, { utf8 => 1, allow_nonref => 1 } );
        };
        if ( $@ ) {
            ERROR "Failed to load accepted certificates: $@\nData:\n$data";
        }
    } else {
        WARN "Can't open $file: $!";
    }

    if (!$self->{accepted_certs} || ref($self->{accepted_certs} ne "HASH")) {
        $self->{accepted_certs} = {};
    }

}

sub _save_accepted_certs {
    my ($self) = @_;
    my $file = File::Spec->join($QVD::Client::App::user_dir, "accepted_certs.json");

    DEBUG "Saving accepted certificates";
    eval {
        open(my $fd, '>', $file) or die "Can't create $file: $!";
        print $fd to_json( $self->{accepted_certs}, { utf8 => 1, pretty => 1, allow_nonref => 1 } );
        close $fd;
    };
    if ( $@ ) {
        ERROR "Failed to save accepted certificates: $@\nData:\n$self->{accepted_certs}";
    }
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
            if ( defined $val ) {
                INFO "SSL option $opt set: $val";
                $args{$opt} = $val;
            }
        }

        DEBUG "Finding default CA paths";
        my %default_ca = IO::Socket::SSL::default_ca();
        DEBUG "System default SSL_ca_file: " . ($default_ca{SSL_ca_file} // "(none)");
        DEBUG "System default SSL_ca_path: " . ($default_ca{SSL_ca_path} // "(none)");


        my $ca_file = core_cfg('path.ssl.ca.system.file');
        DEBUG "Config value for path.ssl.ca.system.file: $ca_file";
        DEBUG "Config value for path.ssl.ca.system.path: " . core_cfg('path.ssl.ca.system.path');

        if ( $ca_file =~ /SYSTEM_DEFAULT/ ) {
            if ( exists $default_ca{SSL_ca_file} ) {
                DEBUG "SSL_ca_file set to system default";
                $args{SSL_ca_file} = $default_ca{SSL_ca_file};
            }
        } else {
            $args{SSL_ca_file} = $ca_file;
        }

        my @ca_paths_conf = split(/:/, core_cfg('path.ssl.ca.system.path'));
        my @ca_paths;
        foreach my $ca_path (@ca_paths_conf) {
            if ( $ca_path =~ /SYSTEM_DEFAULT/ ) {
                if ( exists ( $default_ca{SSL_ca_path} ) ) {
                    DEBUG "Adding system default to SSL_ca_path";
                    push @ca_paths, $default_ca{SSL_ca_path};
                }
            } else {
                DEBUG "Adding '$ca_path' to SSL_ca_path";
                push @ca_paths, $ca_path;
            }
        }

        my $user_ca_dir = $QVD::Client::App::user_certs_dir;
        $user_ca_dir    =~ s|^~(?=/)|$ENV{HOME} // $ENV{APPDATA}|e;
        DEBUG "Adding user dir '$user_ca_dir' to SSL_ca_path";
        push @ca_paths, $user_ca_dir;

        $args{SSL_ca_path} = \@ca_paths;

        DEBUG "SSL CA file: " . ($args{SSL_ca_file} // '');
        DEBUG "SSL CA path: " . join(':', @{$args{SSL_ca_path}});

        DEBUG "Parsing OCSP mode";
        $args{SSL_ocsp_mode}        = _parse_flags("IO::Socket::SSL", core_cfg('client.ssl.ocsp_mode'));

        # We handle the errors here later, rather than having HTTPC die on those errors
        $args{SSL_fail_on_ocsp}     = 0;
        $args{SSL_fail_on_hostname} = 0;

        DEBUG "SSL CA file: " . ($args{SSL_ca_file} // 'undef');
        DEBUG "SSL CA path: " . join(':', @{$args{SSL_ca_path}});

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

        my $depth=0;
        foreach my $cert ( @{ $self->{cert_info} } ) {
            my $algo = $cert->{sig_algo};
            my $bits = $cert->{bit_length};

            if ( $algo =~ /^(md2|md4|md5|sha1)/i ) {
                $self->_add_ssl_error($depth, 1002, 0, "Insecure hash algorithm: $1");
            }

            if ( $bits && $bits <= 1024 ) {
                $self->_add_ssl_error($depth, 1003, 0, "Weak key: $bits bits");
            }

            $depth++;
        }

        if ( (my $oerr = $httpc->get_ocsp_errors()) ) {
            WARN "OCSP server returned error: $oerr";

            # Error codes:
            # 20XX - OCSP worked, said the cert is not valid
            # 21XX - OCSP failed, cert status can't be determined
            # 2200 - OCSP failed, return code unrecognized

            if ( $oerr =~ /OCSP response failed: internalerror/ ) {
                # OCSP server returned an internal error. May happen when a nonce is used and unsupported
                $self->_add_ssl_error(0, 2100, 0, $oerr);
            } elsif ( $oerr =~ /request for OCSP failed/ ) {
                # OCSP server couldn't be reached, or is not listening on the socket
                $self->_add_ssl_error(0, 2101, 0, $oerr);
            } elsif ( $oerr =~ /signer certificate not found/ ) {
                $self->_add_ssl_error(0, 2102, 0, $oerr);
            } elsif ( $oerr =~ /missing ocspsigning usage/ ) {
                # Server OCSP cert without OCSP Signing extension
                $self->_add_ssl_error(0, 2103, 0, $oerr);
            } elsif ( $oerr =~ /root ca not trusted/ ) {
                # Root CA not trusted
                $self->_add_ssl_error(0, 2104, 0, $oerr);
            } elsif ( $oerr =~ /certificate verify error/ ) {
                # Error verifying certificate on OCSP answer
                $self->_add_ssl_error(0, 2105, 0, $oerr);
            } elsif ( $oerr =~ /certificate status is revoked/ ) {
                $self->_add_ssl_error(0, 2001, 0, $oerr);
            } else {
                $self->_add_ssl_error(0, 2200, 0, $oerr);
            }
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

# Parse a string containing a list of OR-ed flags by getting the values of those constants
# Example:
# $ret = _parse_flags("Example::Module", "FOO | BAR");
#
# Will set $ret to the combined values of Example::Module::FOO and Example::Module::BAR
sub _parse_flags {
    my ($module, $text) = @_;
    my $result = 0;

    DEBUG "Parsing flags for $module, value '$text'";

    my @constants = split(/\|/, $text);

    foreach my $const (@constants) {
        $const =~ s/^\s+//;
        $const =~ s/\s+$//;

        DEBUG "Checking constant $const";
        my $func_defined = eval "use ${module}; defined &${module}::${const}";
        if ( $@ ) {
            ERROR "Error when checking ${module}::${const}: $@";
        } else {
            if ( $func_defined ) {
                DEBUG "Constant found: '$const'";
                my $ret = eval "use $module; ${module}::${const}();";
                if ($@) {
                    ERROR "Error when calling ${module}::${const}: $@";
                } else {
                    $result |= $ret;
                    DEBUG "Constant's value: $ret";
                }
            } else {
                ERROR "Constant '$const' not found in module $module";
            }
        }
    }

    DEBUG "Final result: $result";
    return $result;
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

    my $auth;
    my $auth_type;

    if ( ! $opts->{token} eq '' ){
        $auth = $opts->{token};
        $auth_type = "Bearer";
    }else{
        $auth = encode_base64("$user:$passwd", '');
        $auth_type = "Basic";
    }

    my $headers = [
        "Authorization: $auth_type $auth",
        "Accept: application/json"
    ];

    for my $var ( grep(/^auth_vars\./, keys %$opts) ) {
        my $sanitized_name = $var;
        if ( !defined $opts->{$var} ) {
            DEBUG "Variable $var is undefined, not sending";
            next;
        }
        $sanitized_name =~ s/^auth_vars\.//;
        $sanitized_name = unpack("H*", $sanitized_name);
        push @$headers, "Auth-${sanitized_name}: " . encode_base64( $opts->{$var}, '' );

        DEBUG "Header to send to L7R: $var [$sanitized_name] => '" . $opts->{$var} . "'";
    }


    INFO("Sending $auth_type auth");
    $httpc->send_http_request(
        GET => '/qvd/list_of_vm?'.$q,
        headers => $headers
    );

    my ($code, $msg, $response_headers, $body) = $httpc->read_http_response();
    DEBUG("Auth reply: $code/$msg");

    if ($code != HTTP_OK) {
        my $message;

        if ( $code == HTTP_UNAUTHORIZED ) {
            $message = "The server has rejected your login. Please verify that your username and password are correct.";
        } elsif ( $code == HTTP_SERVICE_UNAVAILABLE ) {
            $message = "The server is under maintenance. Retry later.\nThe server said: $body";
        }
        $message ||= "$host replied with $msg";
        INFO("Connection error: $message");
        $cli->proxy_connection_error(message => $message);
        return;
    }
    INFO("Authentication successful");
    my $vm_list;

    eval {
        $vm_list = from_json($body, { utf8 => 1, allow_nonref => 1});
    };

    if ( $@ ) {
        ERROR "Failed to parse JSON: $@";
        ERROR "Body: $body";
        die "Failed to parse VM list";
    }

    my $vm_id;
    if ( ! $opts->{vm_id} eq '' ){
        $vm_id = $opts->{vm_id};
    }else{
        $vm_id = $cli->proxy_list_of_vm_loaded($vm_list);
    }

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
                "Authorization: $auth_type $auth",
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
        'qvd.client.audio.compression.enable' => $self->{compress_audio},
    );

    if ( $WINDOWS ) {
        DEBUG "Sending Windows version and host info";
        require Win32;
        $o{'qvd.client.os.name'}    = join('; ' , Win32::GetOSName());
        $o{'qvd.client.os.version'} = join('; ', Win32::GetOSVersion());
        $o{'qvd.client.hostname'}   = Win32::NodeName();

        DEBUG "Enabling new qvd4 printing support";
        $o{'qvd.client.printing.flavor'} = 'slave4';
    }

    $q = join '&', map { 
        warn "Undefined value for option $_" unless defined $o{$_};
        uri_escape($_) .'='. uri_escape($o{$_}) 
    } keys %o;

    DEBUG("Sending parameters: $q");
    $httpc->send_http_request(
        GET => "/qvd/connect_to_vm?$q",
        headers => [
            "Authorization: $auth_type $auth",
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
            $self->_run($httpc, %$opts);
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

sub _start_x11 {
    my ($self, %opts) = @_;

    if ( $ENV{QVD_PP_BUILD} ) {
        DEBUG "Running under a PP build, not starting X";
        return;
    }

    if ($QVD::Client::App::orig_display ) {
        DEBUG "DISPLAY set to $QVD::Client::App::orig_display";
        return;
    }

    ###
    ### Create commandline
    ###
    my @cmd;
    if ($WINDOWS) {
        DEBUG "Running on Windows, detecting X server";

        $ENV{DISPLAY} = '127.0.0.1:0';
        my $xming_bin = File::Spec->rel2abs(core_cfg('command.windows.xming'), $QVD::Client::App::app_dir);
        my $vcxsrv_bin = File::Spec->rel2abs(core_cfg('command.windows.vcxsrv'), $QVD::Client::App::app_dir);

        if ( -f $xming_bin ) {
            DEBUG "Xming found at $xming_bin";
            my @extra_args=split(/\s+/, core_cfg('client.xming.extra_args'));

            @cmd = ( $xming_bin,
                     @extra_args,
                     -logfile => File::Spec->join($QVD::Client::App::user_dir, "xserver.log") );
        }
        elsif ( -f $vcxsrv_bin ) {
            DEBUG "VcxSrv found at $vcxsrv_bin";
            my @extra_args=split(/\s+/, core_cfg('client.vcxsrv.extra_args'));
            @cmd = ( $vcxsrv_bin,
                     @extra_args,
                     -listen => 'inet',
                     -nolisten => 'inet6',
                     -logfile => File::Spec->join($QVD::Client::App::user_dir, "xserver.log") );

            if ( $opts{fullscreen} ) {
                push @cmd, "-fullscreen";
                @cmd = grep { !/rootless|mwextwm|multiwindow/ } @cmd;
            }
        }
        else {
            die "X server not found! Tried '$xming_bin' and '$vcxsrv_bin'";
        }
    }
    elsif ($DARWIN) {
        $ENV{DISPLAY} = ':0';
        my $x11_cmd = core_cfg('command.darwin.x11');
        @cmd = qq(open -a $x11_cmd --args true);
    }
    else {
        _logdie "Don't know how to start X server on $^O";
    }

    ###
    ### Execute
    ###
    DEBUG("DISPLAY set to $ENV{DISPLAY}");
    DEBUG("Starting X11 server: " . join(' ', @cmd));

    my $proc = Proc::Background->new(@cmd) or
        _logdie "X server failed to start";

    DEBUG("X server started");
    if ( $DARWIN ) {
        DEBUG("Waiting for 'open' process to exit");
        my $retries = 100;
        my $rc;
        while(--$retries > 0) {
            unless ($proc->alive) {
                $rc = $proc->wait // (255 << 8);
                last;
            }
            sleep(0.1);
        }

        if (not defined $rc) {
            WARN "X server command still seems to be running. Can't exactly determine whether the server started";
        }
        elsif ($rc) {
            _logdie "Unable to launch XQuartz, rc: " . ($rc >> 8);
        }
    }

    ###
    ### Try to wait until X11 is accepting connections
    ###

    DEBUG "Testing whether the X server is up";
    require X11::Protocol;

    # FIXME: Checks bellow kill the X server if they are run before it
    # settles down.
    sleep 3 if $WINDOWS;

    my $start = time();
    while (1) {
        my $rn = eval {
            my $x11 = X11::Protocol->new // die "no connection";
            $x11->release_number
        };
        DEBUG "X11 error: " . ($@ // 'undef');

        if (defined $rn) {
            DEBUG "release number: $rn";
            INFO "X11 server started and running";

            return $proc;
        }

        unless ($proc->alive or $DARWIN) {
            my $rc = $proc->wait // (255 << 8);
            _logdie "X server died unexpectedly, rc: " . ($rc >> 8);
        }

        _logdie "Too many retries waiting for X11 server to come up... aborting!"
            if time() - $start > core_cfg('internal.client.xserver.startup.timeout');

        sleep 0.1;
    }
}

sub _stop_proc {
    my ($self, $name, $proc) = @_;
    return unless $proc;

    if ($proc->alive) {
        DEBUG "Killing $name, PID: ".$proc->pid;
        $proc->die;
    }
    my $rc = $proc->wait // (255 << 8);
    DEBUG "$name terminated, rc: " . ($rc >> 8);
}

sub _run {
    my ($self, $httpc, %opts) = @_;

    my %o;
    my $slave_port_file = $QVD::Client::App::user_dir.'/slave-port';
    my ($nxproxy_proc, $x11_proc, $pa_proc, $qvd_pa, $syspa, $modnum);
    my $cli = $self->{client_delegate};


    eval {
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
        if ( $self->{audio} ) {
            if ( $WINDOWS || $DARWIN ) {
                # TODO: Make this variable like in the Linux branch
                $self->{audio_port} = 4713;

                my $pa_exe = File::Spec->rel2abs(core_cfg($WINDOWS
                        ? 'command.windows.pulseaudio'
                        : 'command.darwin.pulseaudio'),
                    $QVD::Client::App::app_dir);
                my $pa_cfg = File::Spec->rel2abs(core_cfg($WINDOWS
                        ? 'command.windows.pulseaudio.default.pa'
                        : 'command.darwin.pulseaudio.default.pa'),
                    $QVD::Client::App::app_dir);
                my $pa_log = File::Spec->rel2abs("pulseaudio.log", $QVD::Client::App::user_dir);
                my @pa = ($pa_exe,
                    '-n',
                    "--file=$pa_cfg",
                    '--log-level=debug',
                    '--high-priority=yes',
                    '--use-pid-file=no',
                    '--daemonize=no',
                    '--system=no',
                    '--disallow-exit=yes',
                    '--exit-idle-time=-1',
                    "--log-target=file:$pa_log");

                DEBUG("Starting pulseaudio: @pa");
                $pa_proc = Proc::Background->new(@pa) or
                WARN("Pulseaudio failed to start, ignoring error");
            } else {
                # Linux
                $self->{audio_port} = $self->_allocate_port;
                $self->{audio_secondary_port} = $self->_allocate_port;

                INFO "Sound enabled, running on Linux";
                DEBUG "Primary audio port " . $self->{audio_port};
                DEBUG "Secondary audio port " . $self->{audio_secondary_port};
    
                $syspa = QVD::Client::PulseAudio->new();
    
                DEBUG "Checking system PulseAudio";
    
                if (! $syspa->is_running ) {
                    # Since every current Linux distro uses PA, supporting systems
                    # without it seems unnecessary and would need testing.
                    #
                    # For now, we don't handle this scenario, though QVDPA could
                    # probably deal with it.

                    $cli->proxy_alert( level   => 'error',
                                       message => $self->_t("PulseAudio is not running. Sound will not work." ));
                } else {
                    # System PulseAudio is running

                    if ( $self->{compress_audio} ) {
                        DEBUG "Checking whether system PA supports Opus";

                        if ( $syspa->is_opus_supported ) {
                            INFO "System PA supports Opus, setting it up";
                            $modnum = $syspa->load_module("module-native-protocol-tcp",
                                "auth-anoymous=1", "listen=127.0.0.1", "port=" . $self->{audio_port});
                        } elsif ( $syspa->is_qvd_pulseaudio_installed() ) {
                            # Chain our own PA
                            INFO "System PA does not support Opus, chaining QVDPA";
                            DEBUG "Setting up native protocol on local PA";
                            $modnum = $syspa->load_module("module-native-protocol-tcp",
                                "auth-anonymous=1",
                                "listen=127.0.0.1",
                                "port=" . $self->{audio_secondary_port});
        
                            $qvd_pa = QVD::Client::PulseAudio->start(
                                env_func => sub { $self->{client_delegate}->proxy_set_environment(@_) }
                            );
        
                            $qvd_pa->load_module("module-native-protocol-tcp",
                                "auth-anonymous=1", "listen=127.0.0.1", "port=" . $self->{audio_port});
                            $qvd_pa->load_module("module-tunnel-sink-new",
                                "sink_name=QVD", "server=tcp:127.0.0.1:" . $self->{audio_secondary_port},
                                "sink=\@DEFAULT_SINK\@");
                        } else {
                            $cli->proxy_alert( level   => 'error',
                                               message => $self->_t("Cannot start a pulseaudio with opus compression enabled.\n" .
                                                          "The system pulseaudio does not support compression, and qvd-pulseaudio is not installed.\n\n". 
                                                          "Falling back to uncompressed audio.\n" .
                                                          "Bandwidth usage will be high. Usage of qvd-pulseaudio is highly recommended." ));

                            $modnum = $syspa->load_module("module-native-protocol-tcp",
                                        "auth-anonymous=1", "listen=127.0.0.1", "port=" . $self->{audio_port});
                        }
                    } else {
                        $cli->proxy_alert( level   => 'warning',
                                           message => $self->_t("Audio compression has been disabled by the user\n".
                                                      "Bandwidth usage will be high. Usage of qvd-pulseaudio is higly recommended."));

                        $modnum = $syspa->load_module("module-native-protocol-tcp",
                                                      "auth-anonymous=1", "listen=127.0.0.1", "port=" . $self->{audio_port});

                    }
                }
            }
        }

        $x11_proc = $self->_start_x11( fullscreen => $opts{fullscreen} );

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
            $o{media} //= $self->{audio_port};

            DEBUG "NX media port is " . $o{media};
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
            DEBUG("Slave command is '$slave_cmd'");
            if ($WINDOWS) {
                my $wrapper = File::Spec->rel2abs(core_cfg('client.slave.wrapper'), $QVD::Client::App::app_dir);
                DEBUG("NX_SLAVE_CMD=$wrapper");
                $self->{client_delegate}->proxy_set_environment(NX_SLAVE_CMD => $wrapper);
                DEBUG("QVD_SLAVE_CMD=$slave_cmd");
                $self->{client_delegate}->proxy_set_environment(QVD_SLAVE_CMD => $slave_cmd);
            }
            elsif (-x $slave_cmd ) {
                # We keep QVD_SLAVE_CMD for retrocompatibility
                $self->{client_delegate}->proxy_set_environment( QVD_SLAVE_CMD => $slave_cmd );
                $self->{client_delegate}->proxy_set_environment( NX_SLAVE_CMD => $slave_cmd );
            } else {
                WARN("Slave command '$slave_cmd' not found or not executable.");
            }
        }

        if ( $DARWIN ) {
            $self->{client_delegate}->proxy_set_environment( DYLD_LIBRARY_PATH => "$QVD::Client::App::app_dir/lib" );
            DEBUG "Running on Darwin, DYLD_LIBRARY_PATH set to $ENV{DYLD_LIBRARY_PATH}";
        }

        DEBUG("Running nxproxy: @cmd");
        $nxproxy_proc =  Proc::Background->new(@cmd) or _logdie("nxproxy failed to start");
        if ( $DARWIN ) {
            DEBUG "Unsetting DYLD_LIBRARY_PATH on Darwin";
            $self->{client_delegate}->proxy_set_environment( DYLD_LIBRARY_PATH => "" );
        }

        DEBUG("Listening on 4040");
        my $listener = IO::Socket::INET->new(LocalPort => 4040,
                                             LocalAddr => 'localhost',
                                             ReuseAddr => 1,
                                             Listen    => 1 ) or _logdie "Unable to listen on port 4040";

        my $retries = 100;
        my $fd = $listener->fileno;
        my $local_socket;
        while (--$retries > 0) {
            my $rb = '';
            vec($rb, $fd, 1) = 1;
            select($rb, undef, undef, 0.1);
            if (vec $rb, $fd, 1) {
                $local_socket = $listener->accept;
                undef $listener; # close the listener
                last;
            }
            $nxproxy_proc->alive or _logdie "nxproxy has terminated unexpectedly";
        }
        $local_socket or _logdie "connection from nxproxy failed";
        setsockopt($local_socket, IPPROTO_TCP, TCP_NODELAY, 1) or WARN "Cannot set TCP_NODELAY";

        DEBUG("Connection accepted, forwarding socket\n");
        if ($WINDOWS) {
            my $nonblocking = 1;
            use constant FIONBIO => 0x8004667e;
            ioctl($local_socket, FIONBIO, \$nonblocking);
        }
        $self->{client_delegate}->proxy_connection_status('FORWARDING');
        forward_sockets($local_socket,
                        $httpc->get_socket,
                        buffer_2to1 => $httpc->read_buffered);

        DEBUG("socket forwarding ended");
    };

    # cleanup
    do {
        local $@;
        if ($o{slave}) {
            INFO "Deleting slave port file $slave_port_file";
            unlink $slave_port_file;
        }

        $self->_stop_proc(nxproxy => $nxproxy_proc);
        $self->_stop_proc(PulseAudio => $pa_proc);
        $self->_stop_proc(X11 => $x11_proc);

        if ($syspa && $modnum) {
            # TODO: Properly unload only what we loaded, as explained here:
            # https://askubuntu.com/questions/355082/pulseaudio-loopback-unload-audio-output-devices

            DEBUG "Unloading module-native-protocol-tcp with id $modnum from Pulseaudio";
            $syspa->unload_module($modnum);
        }

        if ($qvd_pa) {
            DEBUG "Stopping qvd-pulseaudio";
            $qvd_pa->stop;
            undef $qvd_pa;
        }
    };

    die $@ if $@;

    DEBUG("Done.");

}

sub _allocate_port {
    my $self = shift;
    my $port;
    my $sock;
    my $retries;


    DEBUG "Allocating port";
    do {
        if ( $retries++ > 100 ) {
            die "Failed to allocate port!";
        }

        $port = $DYNAMIC_PORT_START + int(rand($DYNAMIC_PORT_COUNT));

        DEBUG "Trying with port $port";
        $sock = IO::Socket::SSL->new( LocalHost => '127.0.0.1',
                                      LocalPort => $port,
                                      Proto     => 'tcp',
                                      Listen    => 1,
                                      ReuseAddr => 1);
    } while(!$sock);

    $sock->shutdown(2);
    return $port;
}

# This useless function works as a marker for gettext, allowing it to find
# translatable strings. No actual translation is done in this module, and
# it's up to the caller (Frame.pm) to pass the string to the translator.

sub _t {
    return @_;
}

1;
