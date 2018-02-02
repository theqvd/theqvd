package QVD::Client::SlaveClient::Windows;

use strict;
use warnings;

use parent 'QVD::Client::SlaveClient::Base';

use Encode qw/encode/;
use QVD::Config::Core qw(core_cfg);
use QVD::HTTP::StatusCodes qw(:status_codes);
use Win32::API;
use Win32::Process;
use Win32::LongPath;
use Win32API::File qw(FdGetOsFHandle WriteFile);
use File::Temp qw(tempfile);
use QVD::Log;
use IPC::Open3 qw(open3);

BEGIN {
    # Import the required Windows API functions.

    # Duplicates a windows socket for use in another process
    Win32::API->Import(ws2_32 => 'int WSADuplicateSocket(HANDLE s, DWORD dwProcessId, LPSTR lpProtocolInfo)')
        or die "Unable to import WSADuplicateSocket";

    # Returns the last windows socket error
    Win32::API->Import(ws2_32 => 'int WSAGetLastError()')
        or die "Unable to import WSAGetLastError";

    # The original idea was to use named pipes for IPC. They turned out to
    # not be as reliable as hoped,so we are using temporary files instead.
    # I'll leave the code for future reference though. -Joni
    #
    #Win32::API->Import(kernel32 => 'HANDLE WINAPI CreateNamedPipe(
    #    LPCTSTR lpName,
    #    DWORD dwOpenMode,
    #    DWORD dwPipeMode,
    #    DWORD nMaxInstances,
    #    DWORD nOutBufferSize,
    #    DWORD nInBufferSize,
    #    DWORD nDefaultTimeOut,
    #    LPSTR lpSecurityAttributes
    #    )') or die "Unable to import CreatedNamedPipe";
    #
    #Win32::API->Import(kernel32 => 'BOOL WINAPI ConnectNamedPipe(HANDLE hNamedPipe, LPSTR lpOverlapped)')
    #    or die "Unable to import ConnectNamedPipe";
}

my $app_dir = core_cfg('path.client.installation', 0)
    // File::Spec->join((File::Spec->splitpath(File::Spec->rel2abs($0)))[0, 1]);

sub handle_share {
    my ($self, $path) = @_;

    DEBUG "Making a PUT request to /shares/$path";

    my ($code, $msg, $headers, $data) =
    $self->httpc->make_http_request(PUT => '/shares/'.encode('utf8',$path),
        headers => [
            "Authorization: Basic $self->{auth_key}",
            'Connection: Upgrade',
            "Upgrade: qvd:sftp/1.0;charset=utf-8"
        ]);

    DEBUG "PUT returned with code $code";

    if ($code != HTTP_SWITCHING_PROTOCOLS) {
        die "Server replied $code $msg $data";
    }

    my $logfile = File::Spec->join($QVD::Client::App::user_dir, 'sftp-server.log');

    my ($cmd, @args);
    if (core_cfg('client.use.win-sftp-server')) {
        $cmd = shortpathL(File::Spec->rel2abs(core_cfg('command.windows.win-sftp-server'), $app_dir));
        @args = ('-v', '-d', shortpathL($path), '-L', shortpathL($logfile));
    }
    else { # TO BE REMOVED!!!
        $cmd = shortpathL(File::Spec->rel2abs(core_cfg('command.windows.sftp-server'), $app_dir));
        @args = ('-l', 'ERROR', '-L', shortpathL($logfile));
    }

    # Create tempfile
    my ($fh, $tempfile) = tempfile(UNLINK => 1);
    #$fh->binmode(1);
    $fh->autoflush(1);

    DEBUG "Temp file for socket info: $tempfile";
    push @args, -F => $tempfile;

    my $cmdline = _win32_cmd_quote($cmd, @args);
    DEBUG "Running SFTP server as >>$cmd<< >>$cmdline<<";

    my $child;
    Win32::Process::Create($child, $cmd, $cmdline,
                           1, # inherit handles
                           NORMAL_PRIORITY_CLASS | CREATE_NO_WINDOW | CREATE_SUSPENDED, # creation flags
                           shortpathL($path) # current working directory
                          ) or die "Unable to start sftp-server: $^E";

    # Duplicate socket
    DEBUG "Duplicating socket for SFTP server";
    my $lpProtocolInfo = "\0" x 1024; # Size of WSAPROTOCOL_INFO = 372
    my $handle = FdGetOsFHandle(fileno($self->httpc->{socket}));
    WSADuplicateSocket($handle, $child->GetProcessID(), $lpProtocolInfo) == 0
        or die "Unable to duplicate socket: ".WSAGetLastError();

    print $fh $lpProtocolInfo;
    close $fh;
    DEBUG "Socket duplicated and sent, continuing SFTP server";
    $child->Resume();

    close $self->httpc->{socket};
}

sub _w32q {
    my $arg = shift;
    for ($arg) {
        $_ eq '' and return '""';
        if (/[ \t\n\x0b"]/) {
            s{(\\+)(?="|\z)}{$1$1}g;
            s{"}{\\"}g;
            return qq("$_")
        }
        return $_
    }
}

sub _win32_cmd_quote {
    my @r = map _w32q($_), @_;
    wantarray ? @r : join(" ", @r)
}

sub handle_mount {
	die "Not implemented yet";
}
1;
