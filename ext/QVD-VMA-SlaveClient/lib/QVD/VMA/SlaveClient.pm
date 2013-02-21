package QVD::VMA::SlaveClient;

use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
use QVD::HTTPC;
use QVD::HTTP::StatusCodes qw(:status_codes);
use JSON qw(decode_json);
use feature 'switch';

my $mount_root = '/tmp';

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
    $self->{httpc}->make_http_request(GET => '/qvd/resources');
    
    die "Slave server replied $code $msg" if ($code != HTTP_OK);

    my $json = decode_json($data);
    die "Slave server replied ".$json->[1] if ($#$response > 0);
    my $response = $json->[0];

    local $SIG{INT} = sub {$self->_handle_exit};
    local $SIG{TERM} = sub {$self->_handle_exit};
    local $SIG{QUIT} = sub {$self->_handle_exit};

    for my $entry (@$response) {
        $self->_handle_entry($entry);
    }

    $self->_handle_child_exit;
}

sub _handle_entry {
    my ($self, $e) = @_;
    for ($e->{uri}) {
        when (/^\/sftp/) { $self->_handle_sftp($e); }
        default { warn "Don't know how to handle ".$e->{uri} }
    }
}

sub _add_exit_hook {
    my ($self, $kid, $hook) = @_;
    my $hooks = ($self->{exit_hooks}{$kid} //= []);
    unshift @$hooks, $hook;
}

sub _handle_exit  {
    my ($self) = @_;
    warn "Sending TERM to subprocesses";
    @kids = keys $self->{exit_hooks};
    kill TERM => @kids;
}

sub _handle_child_exit {
    my ($self) = @_;
    my $kid;
    while (($kid = wait) != -1) {
        warn "Handling termination of $kid...";
        my $hooks = $self->{exit_hooks}{$kid};
        if (defined $hooks) {
            $_->() for (@$hooks);
        }
        delete $self->{exit_hooks}{$kid};
    }

    warn "No more children to wait on.";
}

sub _handle_sftp {
    my ($self, $e) = @_;

    (my $remote_path = $e->{uri}) =~ s/^\/sftp//;
    (my $mount_dir = $remote_path) =~ s/^.*\///; # pick last part of path
    $mount_dir = 'ROOT' if ($mount_dir eq '');
    my $mount_point = $mount_root.'/'.$mount_dir;


    mkdir $mount_point;

    my $kid = fork;
    if ($kid) {
        warn "Started sshfs with pid $kid";
        $self->_add_exit_hook($kid, sub {rmdir $mount_point});
    } else {
        my $httpc = QVD::HTTPC->new($self->{httpc}{target});
        my ($code, $msg, $headers, $data) = $httpc->make_http_request(
            GET => '/sftp'.$remote_path,
            headers => ['Connection: Upgrade', 'Upgrade: qvd:slave/1.0']);

        if ($code != HTTP_SWITCHING_PROTOCOLS) {
            die "Server replied $code $msg";
        }

        my $flgs = fcntl($httpc->{socket}, F_GETFL, 0);
        fcntl($httpc->{socket}, F_SETFL, $flgs & ~O_NONBLOCK) 
            or die "Unable set connection to blocking: $^E";

        open STDIN, '<&', $httpc->{socket} or die "Unable to dup stdin: $^E";
        open STDOUT, '>&', $httpc->{socket} or die "Unable to dup stdout: $^E";

        close $httpc->{socket};
        mkdir $mount_point;

        exec(sshfs => "qvd-client:$remote_path", $mount_point, -o => 'slave');
        die "Unable to exec sshfs: $^E";
    }
}

1;
