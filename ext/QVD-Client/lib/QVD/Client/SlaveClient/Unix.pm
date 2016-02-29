package QVD::Client::SlaveClient::Unix;

use parent 'QVD::Client::SlaveClient::Base';

use QVD::Config::Core qw(core_cfg);
use QVD::HTTP::Headers qw(header_lookup);
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::Log;
use strict;

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
        headers => [
            "Authorization: Basic $self->{auth_key}",
            'Connection: Upgrade', 
            "Upgrade: qvd:sftp/1.0"
        ]);
    
    if ($code != HTTP_SWITCHING_PROTOCOLS) {
        die "Server replied $code $msg $data";
    }
    
    my $ticket = header_lookup($headers, 'X-QVD-Share-Ticket');

    my $pid = fork();
    if ($pid > 0) {
        return $ticket;
    } else {
        open STDIN, '<&', $self->{httpc}->{socket} or die "Unable to dup stdin: $^E";
        open STDOUT, '>&', $self->{httpc}->{socket} or die "Unable to dup stdout: $^E";
        close $self->{httpc}->{socket};

        chdir $path or die "Unable to chdir to $path: $^E";
        exec($command_sftp_server, '-e')
            or die "Unable to exec $command_sftp_server: $^E";
    }
}

sub handle_mount {
    my ($self, $path, $mountpoint) = @_;
    my $command_sshfs = core_cfg('command.sshfs');
	my @sshfs_extra_args = split(/\s+/, core_cfg('client.sshfs.extra_args'));

    INFO "Mounting remote $path at $mountpoint";

    # FIXME detect from locale, don't just assume utf-8
    my $charset = 'UTF-8';
	
    my ($code, $msg, $headers, $data) =
    $self->{httpc}->make_http_request(GET => '/shares/'.$path,
        headers => [
            "Authorization: Basic $self->{auth_key}",
            'Connection: Upgrade', 
            "Upgrade: qvd:sftp/1.0"
        ]);
    
    if ($code != HTTP_SWITCHING_PROTOCOLS) {
        die "Server replied $code $msg $data";
    }

    DEBUG "Switched protocols";
   
    if (!-d $mountpoint) {
        mkdir($mountpoint) or die "Can't create mountpint $mountpoint: $!";
    } 

    DEBUG "Destination dir ok";

    DEBUG "Forking";
    my $pid = fork();
    if ($pid > 0) {
        return;
    } else {
        DEBUG "Redirecting";

        $self->{httpc}->{socket}->blocking(1);

        open STDIN, '<&', $self->{httpc}->{socket} or die "Unable to dup stdin: $^E";
        open STDOUT, '>&', $self->{httpc}->{socket} or die "Unable to dup stdout: $^E";
        close $self->{httpc}->{socket};

        chdir $mountpoint or die "Unable to chdir to $path: $^E";
		my @cmd;

        @cmd = ($command_sshfs => "qvd-client:", $mountpoint, -o => 'slave', @sshfs_extra_args);
        push @cmd, -o => "modules=iconv,from_code=$charset" if ($charset);

		DEBUG "sshfs extra args: " . join(' ', @sshfs_extra_args);
        DEBUG "Executing " . join(' ', @cmd);
        exec @cmd or die "Unable to exec " . join(' ', @cmd) . ": $^E";
    }

}

1;
