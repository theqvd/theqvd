package QVD::Client::SlaveClient;

use strict;
use warnings;
use File::Spec;
use QVD::Config::Core qw(core_cfg set_core_cfg);
use QVD::Log;

our ($WINDOWS, $DARWIN, $user_dir, $user_config_filename, $user_certs_dir, $pixmaps_dir);

BEGIN {
    $WINDOWS = ($^O eq 'MSWin32');
    $DARWIN = ($^O eq 'darwin');

    set_core_cfg('client.log.filename', File::Spec->join($user_dir, 'qvd-client.log'))
        unless defined core_cfg('client.log.filename', 0);
    $QVD::Log::DAEMON_NAME='client';

    if ($WINDOWS) {
        eval 'use QVD::Client::SlaveClient::Windows';
        ERROR $@ if ($@);
    } else {
        eval 'use QVD::Client::SlaveClient::Unix';
        ERROR $@ if ($@);
    }
}

use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
use QVD::HTTPC;
use QVD::HTTP::StatusCodes qw(:status_codes);
use JSON qw(decode_json);
use feature 'switch';

sub new {
    my ($class, $target, %opts) = @_;

    if ($WINDOWS) {
        return QVD::Client::SlaveClient::Windows->new($target, %opts);
    } else {
        return QVD::Client::SlaveClient::Unix->new($target, %opts);
    }
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
    print "Syntax: share /path/to/folder

    Forwards the specified folder to the virtual machine.\n"
}

sub handle_share {
}

sub handle_usage {
    # FIXME
    print "** Write usage doc!\n";
}

1;
