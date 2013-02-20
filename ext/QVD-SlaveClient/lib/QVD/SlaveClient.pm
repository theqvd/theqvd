package QVD::SlaveClient;

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
        exit_hooks => {},
        httpc => QVD::HTTPC->new($target, %opts)
    };
    bless $self, $class;
    $self
}

sub run {
    my ($self) = @_;
    my ($code, $msg, $headers, $data) =
    $self->{httpc}->make_http_request(PUT => '/shares/'.$ENV{HOME},
        headers => ['Accept: application/vnd.qvd-sftp',
            'Connection: Upgrade',
            'Upgrade: qvd:sftp/1.0']);
    
    if ($code != HTTP_SWITCHING_PROTOCOLS) {
        die "Server replied $code $msg";
    }

#    my $flgs = fcntl($self->{httpc}->{socket}, F_GETFL, 0);
#    fcntl($self->{httpc}->{socket}, F_SETFL, $flgs & ~O_NONBLOCK) 
#        or die "Unable set connection to blocking: $^E";
#
    open STDIN, '<&', $self->{httpc}->{socket} or die "Unable to dup stdin: $^E";
    open STDOUT, '>&', $self->{httpc}->{socket} or die "Unable to dup stdout: $^E";

    close $self->{httpc}->{socket};

    exec $command_sftp_server;
}

1;
