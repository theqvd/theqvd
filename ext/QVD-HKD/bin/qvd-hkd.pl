#!/usr/bin/perl

use strict;
use warnings;

use App::Daemon qw/daemonize/;
use QVD::HKD;

my $PID_FILE = '/var/run/qvd/hkd.pid';

my $hkd = QVD::HKD->new(host_id => 1, loop_wait_time => 5);

$App::Daemon::pidfile = $PID_FILE;
daemonize;
$hkd->run;
