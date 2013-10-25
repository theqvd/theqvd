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

    $user_dir = File::Spec->rel2abs(File::Spec->join((getpwuid $>)[7] // $ENV{HOME}, '.qvd'));
    mkdir($user_dir);

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
    my ($class, $remove_this, %opts) = @_;

    my $slave_port_file = $user_dir.'/slave-port'; 
    open my $fh, '<', $slave_port_file or return 0;
    my $slave_port = <$fh>;
    close $fh;

    my $target = 'localhost:'.$slave_port;

    if ($WINDOWS) {
        return QVD::Client::SlaveClient::Windows->new($target, %opts);
    } else {
        return QVD::Client::SlaveClient::Unix->new($target, %opts);
    }
}

1;
