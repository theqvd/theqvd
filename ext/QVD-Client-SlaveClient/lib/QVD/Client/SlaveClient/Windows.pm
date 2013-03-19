package QVD::Client::SlaveClient::Windows;

use parent 'QVD::Client::SlaveClient';

use Win32::API;
use Win32::Process;
use Win32API::File qw(FdGetOsFHandle WriteFile);

my $app_dir = core_cfg('path.client.installation', 0);
if (!$app_dir) {
    my $bin_dir = File::Spec->join((File::Spec->splitpath(File::Spec->rel2abs($0)))[0, 1]);
    my @dirs = File::Spec->splitdir($bin_dir);
    $app_dir = File::Spec->catdir( @dirs[0..$#dirs-1] ); 
}

my $command_sftp_server = File::Spec->rel2abs(core_cfg('command.windows.sftp-server'), $app_dir);

sub _handle_share_native {
    my ($self, $path) = @_;

    Win32::API->Import(kernel32 => 'HANDLE WINAPI CreateNamedPipe(
        LPCTSTR lpName,
        DWORD dwOpenMode,
        DWORD dwPipeMode,
        DWORD nMaxInstances,
        DWORD nOutBufferSize,
        DWORD nInBufferSize,
        DWORD nDefaultTimeOut,
        LPSTR lpSecurityAttributes
        )') or die "Unable to import CreatedNamedPipe";

    Win32::API->Import(kernel32 => 'BOOL WINAPI ConnectNamedPipe(HANDLE hNamedPipe, LPSTR lpOverlapped)')
        or die "Unable to import ConnectNamedPipe";

    Win32::API->Import(ws2_32 => 'int WSAGetLastError()')
        or die "Unable to import WSAGetLastError";

    Win32::API->Import(ws2_32 => 'int WSADuplicateSocket(HANDLE s, DWORD dwProcessId, LPSTR lpProtocolInfo)')
            or die "Unable to import WSADuplicateSocket";

    my $pipe_name = "//./PIPE/qvd:sftp-server";
			
    # Create pipe
    print "** Creating named pipe...\n";
    my $pipe = CreateNamedPipe($pipe_name, 0x3, 0x4, 2, 512, 512, 0, undef);

    # Start child
    print "** Creating child process...\n";
    my $child;
    Win32::Process::Create($child, 
        $command_sftp_server, 
        "sftp-server.exe -e -l DEBUG -P $pipe_name",
        1,                      # inherit handles
        CREATE_NO_WINDOW,       # creation flags
        $path);

    # Duplicate socket
    print "** Duplicating socket...\n";
    my $lpProtocolInfo = "\0"x400; # Apparently WSAPROTOCOL_INFO is 372 bytes long
    my $handle = FdGetOsFHandle(fileno($self->{httpc}->{socket}));
    if (WSADuplicateSocket($handle, $child->GetProcessID(), $lpProtocolInfo)) {
        die "Unable to duplicate socket, $ret, : ".WSAGetLastError();
    }

    # Connect to pipe
    print "** Connecting to pipe...\n";
    ConnectNamedPipe($pipe, undef)
        or die "Unable to connect to pipe: $^E";

    # Send "protocol info" to child
    print "** Sending protocol info to child...\n";
    my $written;
    WriteFile($pipe, $lpProtocolInfo, 372, $written, [])
        or die "Unable to write to pipe: $^E";
    print "** Wrote $written bytes to the pipe...\n";

    # Wait for child
    print "** Waiting for child...\n";
    $child->Wait(INFINITE);
    print "** Finished.\n";
}

1;
