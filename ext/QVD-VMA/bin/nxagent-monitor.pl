#!/usr/bin/perl

use strict;
use warnings;
use Fcntl ':flock';

my $QVD_SESSION_DIR = "/var/run/qvd";
my $QVD_SESSION_STATUS_FILE = $QVD_SESSION_DIR."/state";
my $QVD_SESSION_PID_FILE = $QVD_SESSION_DIR."/nxagent.pid";
my $QVD_SESSION_LOG_FILE = $QVD_SESSION_DIR."/nxagent.log";
my $APPEND = 0;
my $NXAGENT = "nxagent";
my @NXAGENT_OPTS = @ARGV;

sub open_status_file {
    my $mode = $APPEND eq 1 ? ">>" : ">";
    open(QVD_SESSION_STATUS_FH, $mode, $QVD_SESSION_STATUS_FILE);
}

sub setup_environment {
    $ENV{NX_CLIENT} = '/usr/lib/nx/nxdialog';
}

sub unbuffer_status_file {
    my $prev = select(QVD_SESSION_STATUS_FH);
    $| = 1;
    select($prev);
}

sub lock_status_file {
    flock(QVD_SESSION_STATUS_FH, LOCK_EX | LOCK_NB);
}

sub unlock_status_file {
    flock(QVD_SESSION_STATUS_FH, LOCK_UN | LOCK_NB);
}

sub close_status_file {
    close QVD_SESSION_STATUS_FH;
}

sub close_log_file {
    close QVD_SESSION_LOG_FH;
}

sub handle_status {
    my $status = shift;
    if (! $APPEND eq 1) {
        truncate QVD_SESSION_STATUS_FH, 0;
	seek QVD_SESSION_STATUS_FH, 0, 0;
    }
    print QVD_SESSION_STATUS_FH $status."\n";
}

sub open_pid_file {
    open(QVD_SESSION_PID_FH, ">", $QVD_SESSION_PID_FILE);
}

sub open_log_file {
    open(QVD_SESSION_LOG_FH, ">", $QVD_SESSION_LOG_FILE);
}

sub handle_pid {
    my $pid = shift;
    print QVD_SESSION_PID_FH $pid."\n";
    close QVD_SESSION_PID_FH
    	or die "Can't write to pid file: $!";
}

sub launch_nxagent {
    my $status = '';
    my $cmd = $NXAGENT.' "'.join('" "', @NXAGENT_OPTS).'"';
    open(NXAGENT_FH, $cmd.' 2>&1 |')
	or handle_status "exited aborted", die "Can't execute nxagent: $!";
    handle_status "initiated";
    while (<NXAGENT_FH>) {
	chomp;
	# Error message from shell
	if (/sh: (.+)$/) {
	    handle_status "exited aborted";
	    die "Can't execute nxagent: $1";
	}
	# Save agent pid, not necessarily pid of the opened cmd
	if (/Info: Agent running with pid '(\d+)'/) {
	    handle_pid $1;
	}
	# Handle Starting, Suspending, Terminating, Aborting
	if (/Session: (\w+) session at/) {
	    $status = lc($1);
	    handle_status $status;
	}
	# Handle started, suspended, terminated, aborted
	if (/Session: Session (\w+) at/) {
	    $status = $1;
	    handle_status $status;
	}
	print QVD_SESSION_LOG_FH $_."\n";
    }
    close NXAGENT_FH;
    handle_status "exited $status"
}

open_pid_file or die "Can't open pid file: $!";
open_log_file or die "Can't open log file: $!";
open_status_file or die "Can't open status file: $!";
lock_status_file or die "Can't lock status file: $!";
unbuffer_status_file;
setup_environment;
launch_nxagent;
unlock_status_file;
close_status_file;
close_log_file;
