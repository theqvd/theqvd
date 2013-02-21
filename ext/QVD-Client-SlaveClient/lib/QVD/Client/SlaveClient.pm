package QVD::Client::SlaveClient;

use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
use QVD::HTTPC;
use QVD::Config::Core qw(core_cfg);
use QVD::HTTP::StatusCodes qw(:status_codes);
use JSON qw(decode_json);
use feature 'switch';

my $command_sftp_server = core_cfg('command.sftp-server');

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
        $self->usage();
    }
}

sub help_share {
    print "Syntax: share /path/to/folder

    Forwards the specified folder to the virtual machine.\n"
}

sub handle_share {
    my ($self, $path) = @_;

    my ($code, $msg, $headers, $data) =
    $self->{httpc}->make_http_request(PUT => '/shared/'.$path,
        headers => ['Connection: Upgrade', 'Upgrade: qvd:sftp/1.0']);
    
    if ($code != HTTP_SWITCHING_PROTOCOLS) {
        die "Server replied $code $msg $data";
    }

    open STDIN, '<&', $self->{httpc}->{socket} or die "Unable to dup stdin: $^E";
    open STDOUT, '>&', $self->{httpc}->{socket} or die "Unable to dup stdout: $^E";

    close $self->{httpc}->{socket};

    chdir $path or die "Unable to chdir to $path: $^E";
    exec $command_sftp_server 
        or die "Unable to exec $command_sftp_server: $^E";
}

sub handle_usage {
    # FIXME
    print "Write usage doc!\n";
}

1;
