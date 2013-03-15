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
use POSIX qw(dup2);
use IPC::Open3 qw(open3);
use Win32::API;
#use Net::SFTP::Server::FS;

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
    print "** Syntax: share /path/to/folder

    Forwards the specified folder to the virtual machine.\n"
}

sub handle_share {
    my ($self, $path) = @_;

    print "** Starting $command_sftp_server...\n";

    my ($code, $msg, $headers, $data) =
    $self->{httpc}->make_http_request(PUT => '/shares/'.$path,
        headers => ['Connection: Upgrade', 'Upgrade: qvd:sftp/1.0']);
    
    if ($code != HTTP_SWITCHING_PROTOCOLS) {
        die "Server replied $code $msg $data";
    }

    #open STDIN, '<&', $self->{httpc}->{socket} or die "Unable to dup stdin: $^E";
    #open STDOUT, '>&', $self->{httpc}->{socket} or die "Unable to dup stdout: $^E";
    #dup2(fileno($self->{httpc}->{socket}), fileno(STDIN)) or die "Unable to dup stdin: $^E";
    #dup2(fileno($self->{httpc}->{socket}), fileno(STDOUT)) or die "Unable to dup stdin: $^E";

    #close $self->{httpc}->{socket};

    if ($WINDOWS) {
 	  print "** Windows OS detected\n";
	  $self->_do_windows($path);
    } else {
        chdir $path or die "Unable to chdir to $path: $^E";
        exec($command_sftp_server, '-e')
            or die "Unable to exec $command_sftp_server: $^E";
    }
}

sub handle_usage {
    # FIXME
    print "** Write usage doc!\n";
}

sub _do_windows {
my ($self, $path) = @_;
require Win32::API;
require Win32::Process;
use Win32API::File qw(FdGetOsFHandle WriteFile);

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
	  
# Create pipe
print "** Creating named pipe...\n";
my $pipe = CreateNamedPipe("//./PIPE/qvd:sftp-server", 0x3, 0x4, 2, 512, 512, 0, undef);

# Start child
print "** Creating child process...\n";
my $child;
Win32::Process::Create($child, 
	$command_sftp_server, 
	"sftp-server.exe -e -l DEBUG",
	1, # inherit handles
	CREATE_NO_WINDOW, # creation flags
	$path);

# Duplicate socket
print "** Duplicating socket...\n";
my $lpProtocolInfo = "\0"x400; # Apparently WSAPROTOCOL_INFO is 372 bytes long
print unpack('H*', $lpProtocolInfo), "\n";
my $handle = FdGetOsFHandle(fileno($self->{httpc}->{socket}));
print $handle,"\n";
if (WSADuplicateSocket($handle, $child->GetProcessID(), $lpProtocolInfo)) {
	die "Unable to duplicate socket, $ret, : ".WSAGetLastError();
}
print unpack('H*', $lpProtocolInfo), "\n";

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
