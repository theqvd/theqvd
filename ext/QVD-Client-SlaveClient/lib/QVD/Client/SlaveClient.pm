package QVD::Client::SlaveClient;

use File::Spec;
use QVD::Config::Core qw(core_cfg set_core_cfg);

our ($WINDOWS, $DARWIN, $user_dir, $app_dir, $user_config_filename, $user_certs_dir, $pixmaps_dir);

BEGIN {
    $WINDOWS = ($^O eq 'MSWin32');
    $DARWIN = ($^O eq 'darwin');



    set_core_cfg('client.log.filename', File::Spec->join($user_dir, 'qvd-client.log'))
        unless defined core_cfg('client.log.filename', 0);
    $QVD::Log::DAEMON_NAME='client';

    $app_dir = core_cfg('path.client.installation', 0);
    if (!$app_dir) {
        my $bin_dir = File::Spec->join((File::Spec->splitpath(File::Spec->rel2abs($0)))[0, 1]);
        my @dirs = File::Spec->splitdir($bin_dir);
        $app_dir = File::Spec->catdir( @dirs[0..$#dirs-1] ); 
    }
}

use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
use QVD::HTTPC;
use QVD::HTTP::StatusCodes qw(:status_codes);
use JSON qw(decode_json);
use feature 'switch';

my $command_sftp_server = core_cfg('command.sftp-server');
if ($WINDOWS) {
    $command_sftp_server = File::Spec->rel2abs(core_cfg('command.windows.sftp-server'), $app_dir);
    print core_cfg('command.windows.sftp-server'), "\n";
    print $command_sftp_server, "\n";
} elsif ($DARWIN) {
    $command_sftp_server = core_cfg('command.darwin.sftp-server');
}

sub new {
    my ($class, $target, %opts) = @_;
    my $self = { 
        httpc => QVD::HTTPC->new($target, %opts)
    };
    bless $self, $class;
    $self
}

sub dispatch {
    my ($self, $command, $help, @args) = @_;
    
    my $method = $self->can($help? "help_$command": "handle_$command");
    if (defined $method) {
        $self->$method(@args);
    } else {
        $self->handle_usage();
    }
}

sub help_share {
    print "Syntax: share /path/to/folder

    Forwards the specified folder to the virtual machine.\n"
}

sub handle_share {
    my ($self, $path) = @_;

    print "Starting $command_sftp_server...\n";

    my ($code, $msg, $headers, $data) =
    $self->{httpc}->make_http_request(PUT => '/shares/'.$path,
        headers => ['Connection: Upgrade', 'Upgrade: qvd:sftp/1.0']);
    
    if ($code != HTTP_SWITCHING_PROTOCOLS) {
        die "Server replied $code $msg $data";
    }

    open STDIN, '<&', $self->{httpc}->{socket} or die "Unable to dup stdin: $^E";
    open STDOUT, '>&', $self->{httpc}->{socket} or die "Unable to dup stdout: $^E";

    close $self->{httpc}->{socket};

    chdir $path or die "Unable to chdir to $path: $^E";
    exec($command_sftp_server, $command_sftp_server)
        or die "Unable to exec $command_sftp_server: $^E";
}

sub handle_usage {
    # FIXME
    print "Write usage doc!\n";
}

1;
