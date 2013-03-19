package QVD::Client::SlaveClient::Unix;

use QVD::Config::Core qw(core_cfg);

use parent 'QVD::Client::SlaveClient';

my $command_sftp_server = core_cfg('command.sftp-server');

if ($^O eq 'darwin') {
    $command_sftp_server = core_cfg('command.darwin.sftp-server');
}

sub _handle_share_native {
    my ($self, $path) = @_;

    open STDIN, '<&', $self->{httpc}->{socket} or die "Unable to dup stdin: $^E";
    open STDOUT, '>&', $self->{httpc}->{socket} or die "Unable to dup stdout: $^E";
    close $self->{httpc}->{socket};

    chdir $path or die "Unable to chdir to $path: $^E";
    exec($command_sftp_server, '-e')
        or die "Unable to exec $command_sftp_server: $^E";
}

1;
