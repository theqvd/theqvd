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
    my ($class, %opts) = @_;

    my $fh;
    my $slave_port_file = $user_dir.'/slave-port'; 
    open $fh, '<', $slave_port_file or return 0;
    my $slave_port = <$fh> // 12040;
    close $fh;

    INFO "Connecting to slave server on port $slave_port";

    my $slave_key_file = $user_dir.'/slave-key'; 
    open $fh, '<', $slave_key_file or return 0;
    my $slave_key = <$fh> // '';
    close $fh;

    chomp $slave_key;

    $opts{'slave.host'} = 'localhost';
    $opts{'slave.port'} = $slave_port;
    $opts{'slave.key'} = $slave_key;

    if ($WINDOWS) {
        return QVD::Client::SlaveClient::Windows->new(%opts);
    } else {
        return QVD::Client::SlaveClient::Unix->new(%opts);
    }
}

1;
