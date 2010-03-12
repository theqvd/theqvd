#!/usr/bin/perl

use strict;
use warnings;

use App::Daemon qw/daemonize/;
use QVD::RC;
use QVD::Config;


my $PID_FILE = cfg('rc_pid_file', '/var/run/qvd/rc.pid');

$App::Daemon::pidfile = $PID_FILE;
$App::Daemon::logfile = cfg('rc_log_file');

use Log::Log4perl qw(:levels);
Log::Log4perl::init('log4perl.conf');

$App::Daemon::loglevel = $DEBUG;
$App::Daemon::as_user = "root";

daemonize;

# FIXME: make listening port configurable via DB
my $rc = QVD::RC->new(port => 8080);
$rc->run();
