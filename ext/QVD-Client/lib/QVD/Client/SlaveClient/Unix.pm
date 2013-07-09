package QVD::Client::SlaveClient::Unix;

use parent 'QVD::Client::SlaveClient::Base';

use QVD::Config::Core qw(core_cfg);
use QVD::HTTP::StatusCodes qw(:status_codes);

my $command_sftp_server = core_cfg('command.sftp-server');

if ($^O eq 'darwin') {
    $command_sftp_server = core_cfg('command.darwin.sftp-server');
}

sub handle_share {
    my ($self, $path) = @_;

    # FIXME detect from locale, don't just assume utf-8
    my $charset = 'UTF-8';
	
    my ($code, $msg, $headers, $data) =
    $self->{httpc}->make_http_request(PUT => '/shares/'.$path,
        headers => ['Connection: Upgrade', "Upgrade: qvd:sftp/1.0;charset=$charset"]);
    
    if ($code != HTTP_SWITCHING_PROTOCOLS) {
        die "Server replied $code $msg $data";
    }

    my $pid = fork();
    if ($pid) {

    } else {
        open STDIN, '<&', $self->{httpc}->{socket} or die "Unable to dup stdin: $^E";
        open STDOUT, '>&', $self->{httpc}->{socket} or die "Unable to dup stdout: $^E";
        close $self->{httpc}->{socket};

        chdir $path or die "Unable to chdir to $path: $^E";
        exec($command_sftp_server, '-e', -l => 'INFO')
            or die "Unable to exec $command_sftp_server: $^E";
    }
}

sub handle_open {
    my ($self, $path) = @_;

    my $ticket = 'ROOT';

    # FIXME detect from locale, don't just assume utf-8
    my $charset = 'UTF-8';
	
    my ($code, $msg, $headers, $data) =
    $self->{httpc}->make_http_request(POST => '/open/'.$path,
        headers => ["X-QVD-Share-Ticket: $ticket"]);
    
    if ($code != HTTP_OK) {
        die "Server replied $code $msg $data";
    }
}

1;
