#!/usr/bin/perl

use strict;
use warnings;

use App::Daemon qw/daemonize/;
use QVD::HKD;
use QVD::Config;

my $PID_FILE = cfg('hkd_pid_file');
my $POLL_TIME = cfg('hkd_poll_time');

$App::Daemon::pidfile = $PID_FILE;
$App::Daemon::logfile = cfg('hkd_log_file');

use Log::Log4perl qw(:levels);
Log::Log4perl::init('log4perl.conf');

$App::Daemon::loglevel = $DEBUG;
$App::Daemon::as_user = "root";

daemonize;
my $hkd = QVD::HKD->new(loop_wait_time => $POLL_TIME);
$hkd->run;


