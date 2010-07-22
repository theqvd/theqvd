package QVD::Client::Proxy;

use strict;
use warnings;
use feature qw(switch);

use File::Path 'make_path';
use File::Spec;
use IO::Socket::Forwarder qw(forward_sockets);
use JSON;
use Proc::Background;
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
	audio => delete $opts{audio},
	extra => delete $opts{extra},
	printing => delete $opts{printing},
	opts => \%opts,
    };
    bless $self, $class;
}

sub connect_to_vm {
    my $self = shift;
    my $cli = $self->{client_delegate};
    my $ci = $self->{opts};
    my %connect_info = %$ci;
    my ($host, $port, $user, $passwd) = @connect_info{qw/host port username password/};

    $cli->proxy_connection_status('CONNECTING');

    # SSL library has to be initialized in the thread where it's used,
    # so we do a "require QVD::HTTPC" here instead of "use"ing it above
    require QVD::HTTPC;
    my $httpc;
    {
        $httpc = eval { new QVD::HTTPC("$host:$port", SSL => $connect_info{ssl}) };
        if ($@) {
	    $cli->proxy_connection_error(message => $@);
            return;
        } else {
            if (!$httpc) {
		my $accept = $cli->proxy_unknown_cert([QVD::HTTPC::cert_pem_str(),
						       QVD::HTTPC::cert_data()]);

                return unless $accept;

                ## crear archivos y reintentar
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
                    my $basename = sprintf '%s.%d', QVD::HTTPC::cert_hash(), $idx;
                    $file = File::Spec->catfile ($dir, $basename);
                    last unless -e $file;
                }

                open my $fd, '>', $file or die "open: '$file': $!";
                print $fd QVD::HTTPC::cert_pem_str();
                close $fd;

                redo;
            }
        }
    }

    use MIME::Base64 qw(encode_base64);
    my $auth = encode_base64("$user:$passwd", '');

    $httpc->send_http_request(GET => '/qvd/list_of_vm', 
	headers => [
	"Authorization: Basic $auth",
	"Accept: application/json"
	]);

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

    $connect_info{id} = $vm_id;

    my %o = ( id 			    => $connect_info{id},
	      'qvd.client.keyboard'         => $connect_info{keyboard},
	      'qvd.client.os'               => $NX_OS,
	      'qvd.client.link'             => $connect_info{link},
	      'qvd.client.geometry'         => $connect_info{geometry},
	      'qvd.client.fullscreen'       => $connect_info{fullscreen},
	      'qvd.client.printing.enabled' => $self->{printing} );

    my $q = join '&', map { uri_escape($_) .'='. uri_escape($o{$_}) } keys %o;
    $httpc->send_http_request(GET => "/qvd/connect_to_vm?$q",
			      headers => [ "Authorization: Basic $auth",
					   'Connection: Upgrade',
					   'Upgrade: QVD/1.0' ]);

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
	push @cmd, $ENV{QVDPATH}."/nxproxy.bat";
    } else {
	push @cmd, "nxproxy";
    }

    my %o = ();

    if ($WINDOWS) {
	$ENV{'NX_ROOT'} = $ENV{APPDATA}.'/.qvd';
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

    @o{keys %{$self->{extra}}} = values %{$self->{extra}};
    push @cmd, ("-S");
    push @cmd, (map "$_=$o{$_}", keys %o);

    push @cmd, qw(localhost:40);

    $self->{process} = Proc::Background->new(@cmd);

    my $ll = IO::Socket::INET->new(LocalPort => 4040,
	ReuseAddr => 1,
	Listen => 1);

    my $local_socket = $ll->accept()
	or die "connection from nxproxy failed";
    undef $ll; # close the listening socket
    if ($WINDOWS) {
	my $nonblocking = 1;
	use constant FIONBIO => 0x8004667e;
	ioctl($local_socket, FIONBIO, \$nonblocking);
    }

    forward_sockets($local_socket, $httpc->get_socket,
		    buffer_2to1 => $httpc->read_buffered);
		    # debug => 1);
}

1;
