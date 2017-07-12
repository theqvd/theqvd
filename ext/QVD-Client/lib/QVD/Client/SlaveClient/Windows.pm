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

    if (core_cfg('client.use.win-sftp-server')) {
        my $cmd = File::Spec->rel2abs(core_cfg('command.windows.win-sftp-server'), $app_dir);

        my @cmd = ($cmd, '-v', '-d', shortpathL($path));
        DEBUG "Executing win-sftp-server as '@cmd'";

        DEBUG sprintf("STDIN fd: %s, STDOUT fd: %s", fileno(STDIN) // 'undef', fileno(STDOUT) // 'undef');
        open my($oldin), '<&', \*STDIN or die "Can't dup stdin: $^E";
        open my($oldout), '>&', \*STDOUT or die "Can't dup stdout: $^E";

        # local (STDIN, STDOUT);
        open STDIN, '<&', $self->httpc->{socket};
        open STDOUT, '>&', $self->httpc->{socket};

        my $pid = eval { system 1, @cmd };
        do {
            local ($@, $!, $^E, $?);
            open STDIN, '<&', $oldin;
            open STDOUT, '>&', $oldout;
        };
        unless ($pid) {
            die "Unable to launch win-sftp-server: " . ($@ || $!);
        }
    }
    else { # TO BE REMOVED!!!
        my $command_sftp_server = File::Spec->rel2abs(core_cfg('command.windows.sftp-server'), $app_dir);

        # Create tempfile
        my ($fh, $tempfile) = tempfile(UNLINK => 1);
        $fh->autoflush(1);

        DEBUG "Starting $command_sftp_server to serve $path...\n";
        DEBUG "Temp file: $tempfile, debug log: $logfile\n";

        # To debug sftp-server.exe under GDB:
        # my $command_gdb='c:/mingw/bin/gdb.exe';
        # my $cmdline = "gdb -w --directory \"c:\\documents and settings\\administrador\\Mis documentos\\openssh-6.0p1\" --args \"$command_sftp_server\" -l DEBUG3 -F \"$tempfile\" -L \"$logfile\"";
        my $cmdline = "$command_sftp_server -l ERROR -F \"$tempfile\" -L \"$logfile\"";
        my $child;
        Win32::Process::Create($child, 
                               $command_sftp_server, 
                               $cmdline,
                               1,              # inherit handles
                               NORMAL_PRIORITY_CLASS | CREATE_NO_WINDOW | CREATE_SUSPENDED,       # creation flags
                               shortpathL($path)			# current working directory
                              ) or die "Unable to start sftp-server: $^E";

        # Duplicate socket
        DEBUG "Duplicating socket to send it to sftp-server";
        my $lpProtocolInfo = "\0" x 372; # Size of WSAPROTOCOL_INFO
        my $handle = FdGetOsFHandle(fileno($self->httpc->{socket}));
        if (WSADuplicateSocket($handle, $child->GetProcessID(), $lpProtocolInfo)) {
            die "Unable to duplicate socket: ".WSAGetLastError();
        }

        print $fh $lpProtocolInfo;

        $child->Resume();

        close $self->httpc->{socket};
    }
}


sub handle_mount {
	die "Not implemented yet";
}
1;
