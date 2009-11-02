#!/usr/bin/perl

use strict;
use warnings;

use App::Daemon qw/daemonize/;
use QVD::HKD;

my $PID_FILE = '/var/run/qvd/hkd.pid';

$App::Daemon::pidfile = $PID_FILE;
$App::Daemon::logfile = "/var/log/qvd.log";

use Log::Log4perl qw(:levels);
$App::Daemon::loglevel = $DEBUG;
$App::Daemon::as_user = "root";

daemonize;
my $hkd = QVD::HKD->new(loop_wait_time => 5);
$hkd->run;


