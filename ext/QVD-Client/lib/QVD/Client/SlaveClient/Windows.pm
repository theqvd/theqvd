package QVD::Client::SlaveClient::Windows;

use strict;
use warnings;

use parent 'QVD::Client::SlaveClient::Base';

use QVD::Config::Core qw(core_cfg);
use QVD::HTTP::StatusCodes qw(:status_codes);
use Win32::API;
use Win32::Process;
use Win32API::File qw(FdGetOsFHandle WriteFile);
use File::Temp qw(tempfile);
use QVD::Log;

BEGIN {
    ## The original idea was to use named pipes for IPC. They turned out to not be as reliable as hoped,
	## so we are using temporary files instead. I'll leave the code for future reference though. -Joni
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

	# Returns the Windows "ANSI code page" (i.e. the character encoding)
    Win32::API->Import(kernel32 => 'UINT GetACP()')
        or die "Unable to import GetACP";		

		# Duplicates a windows socket for use in another process
    Win32::API->Import(ws2_32 => 'int WSADuplicateSocket(HANDLE s, DWORD dwProcessId, LPSTR lpProtocolInfo)')
            or die "Unable to import WSADuplicateSocket";
	
	# Returns the last windows socket error
    Win32::API->Import(ws2_32 => 'int WSAGetLastError()')
        or die "Unable to import WSAGetLastError";
}

my $app_dir = core_cfg('path.client.installation', 0);
if (!$app_dir) {
    my $bin_dir = File::Spec->join((File::Spec->splitpath(File::Spec->rel2abs($0)))[0, 1]);
    my @dirs = File::Spec->splitdir($bin_dir);
    $app_dir = File::Spec->catdir( @dirs[0..$#dirs-1] ); 
}

my $command_sftp_server = File::Spec->rel2abs(core_cfg('command.windows.sftp-server'), $app_dir);

sub handle_share {
    my ($self, $path) = @_;
	
	DEBUG "Making a PUT request to /shares/$path";
	
    my ($code, $msg, $headers, $data) =
    $self->{httpc}->make_http_request(PUT => '/shares/'.$path,
        headers => ['Connection: Upgrade', "Upgrade: qvd:sftp/1.0;charset=utf-8"]);
		
	DEBUG "PUT returned with code $code";
        
    if ($code != HTTP_SWITCHING_PROTOCOLS) {
        die "Server replied $code $msg $data";
    }

    #my $pipe_name = sprintf("//./PIPE/qvd:sftp-server.%04d", rand(10000));
	#		
    # Create pipe
    #INFO "** Creating named pipe $pipe_name...\n";
    #my $pipe = CreateNamedPipe($pipe_name, 0x3, 0x4, 2, 512, 512, 5000, undef);
    #if ($pipe == -1) {
    #    die "Unable to create named pipe: $^E";
    #}
	
	# Create tempfile
	my ($fh, $tempfile) = tempfile(UNLINK => 1);
	$fh->autoflush(1);
	
	my $logfile = $QVD::Client::App::user_dir . '/sftp-server.log';
	
    DEBUG "Starting $command_sftp_server to serve $path...\n";

	# To debug under GDB:
	# my $command_gdb='c:/mingw/bin/gdb.exe';
	# my $cmdline = "gdb -w --directory \"c:\\documents and settings\\administrador\\Mis documentos\\openssh-6.0p1\" --args \"$command_sftp_server\" -l DEBUG3 -F \"$tempfile\" -L \"$logfile\"";
    my $cmdline = "sftp-server.exe -l ERROR -F \"$tempfile\" -L \"$logfile\"";
	#my $cmdline = "sftp-server.exe -l ERROR -F \"$tempfile\" -P \"$pipe_name\"";
    my $child;
    Win32::Process::Create($child, 
        $command_sftp_server, 
        $cmdline,
        1,              # inherit handles
        NORMAL_PRIORITY_CLASS | CREATE_NO_WINDOW | CREATE_SUSPENDED,       # creation flags
        $path			# current working directory
	) or die "Unable to start sftp-server: $^E";
	
    # Duplicate socket
	DEBUG "Duplicating socket to send it to sftp-server";
    my $lpProtocolInfo = "\0" x 372; # Size of WSAPROTOCOL_INFO
    my $handle = FdGetOsFHandle(fileno($self->{httpc}->{socket}));
    if (WSADuplicateSocket($handle, $child->GetProcessID(), $lpProtocolInfo)) {
        die "Unable to duplicate socket: ".WSAGetLastError();
    }
	print $fh $lpProtocolInfo;
	
	$child->Resume();
	
	close $self->{httpc}->{socket};

    ## Connect to pipe
    #INFO "** Connecting to pipe $pipe_name...\n";
    #ConnectNamedPipe($pipe, undef)
    #    or die "Unable to connect to pipe: $^E";
    #
    ## Send "protocol info" to child
    #INFO "** Sending protocol info to child...\n";
    #my $written;
    #WriteFile($pipe, $lpProtocolInfo, 372, $written, [])
    #    or die "Unable to write to pipe: $^E";
    #INFO "** Wrote $written bytes to the pipe...\n";
    #
    ## Wait for child
    #INFO "** Waiting for child...\n";
    #my $status = $child->Wait(INFINITE);
    #INFO "** Finished. (exit code $status)\n";
}

1;
