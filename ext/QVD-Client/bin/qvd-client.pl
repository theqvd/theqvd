#!/usr/lib/qvd/bin/perl

eval 'exec /usr/lib/qvd/bin/perl  -S $0 ${1+"$@"}'
    if 0; # not running under some shell

BEGIN {
    package QVD::Client::App;

    use warnings;
    use strict;
    use QVD::Config::Core qw(core_cfg);
    use File::Spec;

    our $WINDOWS = ($^O eq 'MSWin32');

    our $user_dir = File::Spec->rel2abs($WINDOWS
        ? File::Spec->join($ENV{APPDATA}, 'QVD')
        : File::Spec->join((getpwuid $>)[7] // $ENV{HOME}, '.qvd'));
    mkdir $user_dir;

    our $app_dir = core_cfg('path.client.installation', 0);
    if (!$app_dir) {
        my $bin_dir = File::Spec->join((File::Spec->splitpath(File::Spec->rel2abs($0)))[0, 1]);
        my @dirs = File::Spec->splitdir($bin_dir);
        $app_dir = File::Spec->catdir( @dirs[0..$#dirs-1] ); 
    }

    our $user_certs_dir = File::Spec->rel2abs(core_cfg('path.ssl.ca.personal'), $user_dir);

    our $orig_display = $ENV{DISPLAY};
}

use strict;
use warnings;

use Proc::Background; 
use Getopt::Long;
use JSON;

our ($user_config_filename);

BEGIN {
    $user_config_filename = ($ENV{HOME} || $ENV{APPDATA}).'/.qvd/client.conf';
    if (exists($ENV{QVDCLIENTCONFIG})) {
        my $configfile = $ENV{QVDCLIENTCONFIG};
        if (-f $configfile) {
            $user_config_filename = $configfile;
        } else {
            print STDERR "Ignoring config file defined in QVDCLIENTCONFIG env variable <$configfile> defaulting to <$user_config_filename>\n";
        }
    }
    $QVD::Config::USE_DB = 0;
    $QVD::Config::USE_DB = 0;

    @QVD::Config::Core::FILES = (
        '/etc/qvd/client.conf',
        $user_config_filename
    );

    # FIXME NX_CLIENT is used for showing the user information on things
    # like broken connection, perhaps we should show them to the user
    # instead of ignoring them? 
    $ENV{NX_CLIENT} = '/bin/false';

}

use QVD::Config::Core qw(set_core_cfg core_cfg);
use File::Spec;

BEGIN {
    set_core_cfg('client.log.filename', File::Spec->join($QVD::Client::App::user_dir, 'qvd-client.log'))
        unless defined core_cfg('client.log.filename', 0);
    $QVD::Log::DAEMON_NAME = 'client';
}

use QVD::Client::Proxy;
use QVD::Log;
use MIME::Base64;
my %opts;

GetOptions \%opts,
    '--username=s',
    '--password=s',
    '--token=s',
    '--host=s',
    '--port=s',
    '--file=s',
    '--ssl!',
    '--vm-id=s',
    '--ssl-errors=s',
    '--help',
    '--list-vms',
    '--list-apps',
    '--no-header',
    '--json',
    '--create-icons',
    or die "getopt";

$opts{'username'} //= $ENV{QVDLOGIN} // core_cfg('client.user.name');
$opts{'password'} //= $ENV{QVDPASSWORD} // core_cfg('client.user.password');
$opts{'token'} //= $ENV{QVDBEARERTOKEN};
$opts{'host'} //= $ENV{QVDHOST} // core_cfg('client.host.name');
$opts{'port'} //= $ENV{QVDPORT} // core_cfg('client.host.port');
$opts{'ssl'} //= 1;
$opts{'ssl-errors'} //= $ENV{QVDSSLERRORS} // 'ask';
$opts{'usb'} //= 0;

if ( $opts{'create-icons'} ) {
    $opts{'list-apps'} = 1;
}

# Token was already used for connections from the website, and was passed already
# encoded to the client. So we only encode it here.
$opts{'origtoken'} = $opts{'token'};
$opts{'token'} = encode_base64($opts{'token'}, '');


if ( $opts{help} ) {
    print <<HELP;
$0 [options]
QVD commandline client

--username         Login username
--password         Login password
--token            Login bearer token (used instead of password)
--host             Server to connect to
--port             Port QVD is running on
--file             Open file in VM
--ssl, --no-ssl    Enable or disable the use of SSL
--ssl-errors       What to do in case of SSL errors. Valid values are:
                   'ask', 'continue' and 'abort'
--help             Shows this text
--list-vms         List VMs, and exit
--list-apps        List applications, and exit
--no-header        Don't show the header for --list-vms and --list-apps
--json             Use JSON to dump the --list-vms and --list-apps data
HELP

    exit(0);
}


my $file = delete $opts{'file'};
my $ssl_errors = delete $opts{'ssl-errors'};
my $nonblocking=1;

if ( $ssl_errors !~ /^(ask|continue|abort)$/ ) {
    print STDERR "Valid values for --ssl-errors: ask, continue or abort\n";
    exit(1);
}

my %connect_info = (
    link          => core_cfg('client.link'),
    extra_args    => core_cfg('client.nxagent.extra_args'),
    slave         => core_cfg('client.slave.enable'),
    audio         => core_cfg('client.audio.enable'),
    printing      => core_cfg('client.printing.enable'),
    geometry      => core_cfg('client.geometry'),
    fullscreen    => core_cfg('client.fullscreen'),
    keyboard      => 'pc105/es',
    kill_vm       => 0,
    %opts,
);

$connect_info{file} = $file if defined $file;
$connect_info{list_apps} = $opts{'list-apps'};

my $delegate = QVD::Client::CLI->new(file => $file, vm_id => $opts{'vm-id'});

my $proxy = QVD::Client::Proxy->new($delegate, %connect_info);
my $err_count = 0;

while ($err_count < 5) {
    $proxy->connect_to_vm();
    last unless $delegate->{error};
    $err_count++;
}
if (defined $delegate->{error}) {
    ERROR("Unable to connect to VM: ".$delegate->{error});
    exit 1;
}

package QVD::Client::CLI;

use Cwd qw(abs_path);
use QVD::Client::SlaveClient;
use QVD::Log;

sub new {
    my $class = shift;
    my %attrs = @_;
    $attrs{error} = undef;
    bless \%attrs, $class;
}

sub proxy_set_environment {
    my ($self, %args) = @_;
    @ENV{keys %args} = values %args;
}

sub proxy_unknown_cert {
    my ($self, $cert_data) = @_;

    print "Error validating certificate:\n";
    my $n=1;
    foreach my $cert ( @{ $cert_data} ) {
        print "Certificate $n:\n";
        print $self->format_cert($cert_data->[0]);
        $n++;
    }

    if ( $ssl_errors =~ /ask/i ) {
        print "\n";
        print "Do you wish to continue and connect anyway?\n";
        print "\n";

        my $answer = "";
 
        while(1) {
            print "Enter 'yes' to continue, 'accept' to permanently accept the certificate,\n";
            print "or 'quit' to quit.\n\n";

            my $answer = <STDIN>;
            chomp $answer;
            if ( $answer =~ /yes/ ) {
               return 1;
            } elsif ( $answer =~ /accept/ ) {
               return 2;
            } elsif ( $answer =~ /quit/ ) {
               return 0;
            } elsif ( $answer =~ /dump/ ) {
               require Data::Dumper;
               die Data::Dumper->Dumper([@_]);
            }
        }
    } elsif ( $ssl_errors =~ /quit|abort|exit/i ) {
        print "Aborting\n";
        return 0;
    } elsif ( $ssl_errors =~ /continue|accept|ok/i ) {
        print "Continuing\n";
        return 1;
    }

    1;
}

sub proxy_alert {
    my ($self, %args) = @_;

    if ( $args{level} =~ /warn/ ) {
        print STDERR "WARNING: ";
    } elsif ( $args{level} =~ /err/ ) {
        print STDERR "ERROR  : ";
    } elsif ( $args{level} =~ /notice|info/ ) {
        print STDERR "INFO   : ";
    } else {
        ERROR "Unknown alert level $args{level}";
        print STDERR "ERROR  : ";
    }

    print STDERR $args{message} . "\n";
}

sub format_cert {
    my ($self, $cert)  = @_;
    my $ret = "";
    $ret .= "\tCertificate for:\n" . $self->format_org($cert->{subject});
    $ret .= "\tIssued by:\n" . $self->format_org($cert->{issuer});
    $ret .= "\tFingerprint: " . $cert->{fingerprint}->{sha256} . "\n";
    $ret .= "\tNot before : " . $cert->{not_before}. "\n";
    $ret .= "\tNot after  : " . $cert->{not_after} . "\n";
    $ret .= "\tSize       : " . $cert->{bit_length} . " bits\n";

    if ( exists $cert->{extensions}->{altnames} ) {
        $ret .= "\tNames:\n";
        foreach my $alt ( @{ $cert->{extensions}->{altnames} } ) {
            foreach my $k ( keys %{$alt} ) {
                $ret .= "\t\t$k: $alt->{$k}\n"; 
            }
        }
    } 
 

    $ret .= "\tErrors:\n";

    foreach my $err ( @{$cert->{errors}} ) {
        $ret .= "\t\tError #" . $err->{err_no} . ": " . $err->{err_str} . "\n";
    }

    return $ret;
}
sub format_org {
    my ($self, $org) = @_;

    my $ret = "";
    $ret .= "\t\tCommon Name        : " . $org->{cn} . "\n";
    $ret .= "\t\tOrganizational Unit: " . $org->{ou} . "\n";
    $ret .= "\t\tOrganization       : " . $org->{o} . "\n";
    $ret .= "\t\tLocation           : " . $org->{l} . "\n";
    $ret .= "\t\tState              : " . $org->{st} . "\n";
    $ret .= "\t\tCountry            : " . $org->{c} . "\n";

    return $ret;
}

sub list_vms {
    my ($vm_data) = @_;

    unless( $opts{'no-header'} ) {
        print "You have ".@$vm_data. ($opts{'list-apps'} ? " applications" : " virtual machines"). ":\n\n";

        print sprintf("\t%-7s %-10s %-39s %-10s\n", "Id", "State", "Name", "Blocked");
        print (("=" x 74) . "\n");
    }

    foreach my $vm (sort { $a->{id} <=> $b->{id} } @$vm_data) {
        print sprintf("\t%-7s %-10s %-39s %-10s\n", $vm->{id}, $vm->{state}, $vm->{name}, $vm->{blocked});
    }
}

sub create_icons {
    my ($vm_data) = @_;

    my $desktop_dir;

    if ( open(my $fh, '-|', "xdg-user-dir", "DESKTOP") ) {
        $desktop_dir = <$fh>;
        chomp $desktop_dir;
        DEBUG "Obtained desktop dir from xdg-user-dir: '$desktop_dir'";
    } else {
        WARN "Failed to run xdg-user-dir: $!";
        $desktop_dir = "$ENV{HOME}/Desktop";
        WARN "Assuming the desktop is in '$desktop_dir'";
    }

    if ( ! -x $desktop_dir ) {
        ERROR "Desktop directory '$desktop_dir' not found. Can't create icons";
        return;
    }

    # Remove any existing QVD icon
    my $dh;
    opendir $dh, $desktop_dir;
    while(my $de = readdir($dh)) {
        next if ( $de eq "." || $de eq "..");
        next unless ( -f "$desktop_dir/$de" );
        next unless $de =~ /.desktop$/;

        my $delete;

        DEBUG "Checking if $desktop_dir/$de is a QVD icon";
        if ( open(my $fh, "<", "$desktop_dir/$de") ) {
            while(my $line = <$fh>) {
                chomp $line;
                $line =~ s/^\s+//;
                $delete = 1 if ( $line =~ /^Keywords/i && $line =~ /QVD_Session/ );
            }
            close($fh);
        } else {
            ERROR "Failed to open $desktop_dir/$de: $!";
        }

        if ( $delete ) {
            DEBUG "Deleting QVD icon $desktop_dir/$de";
            unlink("$desktop_dir/$de");
        }
    }
    closedir($dh);



    foreach my $vm (@$vm_data) {
        my $icon_name = $vm->{name} . ".desktop";
        DEBUG "Writing icon $desktop_dir/$icon_name";

        if ( open(my $fh, ">", "$desktop_dir/$icon_name") ) {
            print $fh "#!/usr/bin/env xdg-open\n";
            print $fh "[Desktop Entry]\n";
            print $fh "Version=1.0\n";
            print $fh "Encoding=UTF-8\n";
            print $fh "Hidden=false\n";
            print $fh "Type=Application\n";
            print $fh "Keywords=QVD_Session\n";
            print $fh "Terminal=false\n";
            print $fh "Name=" . $vm->{name} . "\n";
            print $fh "Path=/home/vadim/git/qvd-src\n";
            print $fh "Exec=/home/vadim/git/qvd-src/run_client.pl --cli -- --host 192.168.122.216 --token $opts{origtoken} --vm-id " . $vm->{id} . "\n";
            close $fh;
        } else {
            ERROR "Failed to create $desktop_dir/$icon_name: $!";
        }
    }
}

sub proxy_list_of_vm_loaded {
    my ($self, $vm_data) = @_;
    if (@$vm_data > 0) {
        return $self->{'vm_id'} if defined $self->{'vm_id'};

        if ( $opts{'create-icons'} ) {
            create_icons($vm_data);
            return ();
        }

        if ( $opts{'list-vms'} || $opts{'list-apps'} ) {

            if ( $opts{json} ) {
                require JSON::XS;
                print JSON::XS::encode_json($vm_data) . "\n";
            } else {
                list_vms($vm_data);
            }

            return();
        }

        my $vm;
        if ( @$vm_data > 1 ) {
            my $count=0;
            while(!$vm) {
                if ( $count++ % 10 == 0 ) {
                    list_vms($vm_data);
                    print "\n";
                }

                print "Which VM would you like to connect to? Enter a VM name or id, or an empty line to quit: ";
                my $vm_id = <STDIN>;
                chomp $vm_id;
                $vm_id =~ s/^\s+//;
                $vm_id =~ s/\s+//;

                return() if ( $vm_id eq  "");

                my @vms;
                if ( $vm_id =~ /^\d+/ ) {
                    @vms = grep { $_->{id} == $vm_id } @$vm_data;
                } else {
                    # Try full match first, then partial match only if that doesn't work
                    @vms = grep { $_->{name} =~/^$vm_id$/i }  @$vm_data;
                    @vms = grep { $_->{name} =~/^$vm_id/i } @$vm_data unless (@vms);
                }

                if ( @vms == 0 ) {
                    print "Nothing matched.\n\n";
                } elsif ( @vms > 1 ) {
                    print "Multiple matches: " . join(", ", map { $_->{name} } @vms) . "\n\n";
                } else {
                    $vm = $vms[0];
                }
            }
        } else {
            $vm = $vm_data->[0];
        }

        INFO "Connecting to VM called ".$vm->{name}."\n";
        return $vm->{id};
    } else {
        ERROR "No VM available, server returned an empty list!";
        return ();
    }
}

sub proxy_connection_status {
    my ($self, $status) = @_;
    INFO "Connection status $status\n";
    if ($status eq 'CONNECTING') {
        $self->{error} = undef;
    }
    if ($status eq 'FORWARDING') {
        $self->open_file($self->{file}) if ( $self->{file} );
    }
}

sub proxy_connection_error {
    my $self = shift;
    my %args = @_;
    ERROR 'Connection error: ',$args{message},"\n";
    print STDERR "Connection error: $args{message}\n";
    $self->{error} = $args{message};
}

sub open_file {
    my ($self, $file) = @_;
    my $pid = fork;
    if ($pid == 0) {
        my $share = '/';
        for (my $conn_attempt = 0; $conn_attempt < 10; $conn_attempt++) {
            INFO("Starting folder sharing for $share, attempt $conn_attempt");
            local $@;
            my $client = QVD::Client::SlaveClient->new();
            my $ticket = eval { $client->handle_share($share) };
            if ($@) {
                if ($@ =~ 'Connection refused') {
                    sleep 1;
                    next;
                }
                ERROR($@);
            } else {
                INFO("Folder sharing started for $share");
                INFO("Opening $file");
                $client = QVD::Client::SlaveClient->new;
                $client->handle_open(abs_path($file), $ticket);
            }
            last;
        }
        exit;
    } elsif ($pid > 0) {
        INFO("Folder sharing running with PID $pid");
    } else {
        ERROR("Unable to run folder sharing: $^E");
    }
}

__END__

=head1 NAME

qvd-client.pl

=head1 DESCRIPTION

Proof of concept command line client for QVD

=cut
