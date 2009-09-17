#!/usr/bin/perl

use strict;
use warnings;
use Fcntl ':flock';

my $QVD_SESSION_STATUS_FILE = "/var/run/qvd/state";
my $QVD_SESSION_PID_FILE = "/var/run/qvd/nxagent-pid";
my $APPEND = 0;
my $PASSTHROUGH = 0;
my $NXAGENT = "nxagent";
my @NXAGENT_OPTS = @ARGV;

sub openStatusFile {
    my $mode = $APPEND eq 1 ? ">>" : ">";
    open(QVD_SESSION_STATUS_FH, $mode, $QVD_SESSION_STATUS_FILE);
}

sub unbufferStatusFile {
    my $prev = select(QVD_SESSION_STATUS_FH);
    $| = 1;
    select($prev);
}

sub lockStatusFile {
    flock(QVD_SESSION_STATUS_FH, LOCK_EX | LOCK_NB);
}

sub unlockStatusFile {
    flock(QVD_SESSION_STATUS_FH, LOCK_UN | LOCK_NB);
}

sub closeStatusFile {
    close QVD_SESSION_STATUS_FH;
}

sub handleStatus {
    my $status = shift;
    if (! $APPEND eq 1) {
        truncate QVD_SESSION_STATUS_FH, 0;
	seek QVD_SESSION_STATUS_FH, 0, 0;
    }
    print QVD_SESSION_STATUS_FH $status."\n";
}

sub openPidFile {
    open(QVD_SESSION_PID_FH, ">", $QVD_SESSION_PID_FILE);
}

sub handlePid {
    my $pid = shift;
    print QVD_SESSION_PID_FH $pid."\n";
    close QVD_SESSION_PID_FH
    	or die "Can't write to pid file: $!";
}

sub launchNxagent {
    my $status = '';
    my $cmd = $NXAGENT.' "'.join('" "', @NXAGENT_OPTS).'"';
    open(NXAGENT_FH, $cmd.' 2>&1 |')
	or die "Can't execute nxagent: $!";
    while (<NXAGENT_FH>) {
	chomp;
	# Error message from shell
	if (/sh: (.+)$/) {
	    handleStatus "exited aborted";
	    die "Can't execute nxagent: $1";
	}
	# Save agent pid, not necessarily pid of the opened cmd
	if (/Info: Agent running with pid '(\d+)'/) {
	    handlePid $1;
	}
	# Handle Starting, Suspending, Terminating, Aborting
	if (/Session: (\w+) session at/) {
	    $status = lc($1);
	    handleStatus $status;
	}
	# Handle started, suspended, terminated, aborted
	if (/Session: Session (\w+) at/) {
	    $status = $1;
	    handleStatus $status;
	}
	if ("$PASSTHROUGH" eq 1) {
	    print $_."\n";
	}
    }
    close NXAGENT_FH;
    handleStatus "exited $status"
}

openPidFile or die "Can't open pid file: $!";
openStatusFile or die "Can't open status file: $!";
lockStatusFile or die "Can't lock status file: $!";
unbufferStatusFile;
launchNxagent;
unlockStatusFile;
closeStatusFile;
