#!/usr/bin/perl

use strict;
use warnings;
use Fcntl ':flock';

my $QVD_SESSION_STATUS_FILE = "/var/run/qvd/state";
my $APPEND = 1;
my $PASSTHROUGH = 0;
my $NXAGENT = "nxagent";
my @NXAGENT_OPTS = @ARGV;

sub openStatusFile {
    my $mode = $APPEND eq 1 ? ">>" : ">";
    open(QVD_SESSION_STATUS_FH, $mode, $QVD_SESSION_STATUS_FILE)
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

sub launchNxagent {
    open(NXAGENT_FH, $NXAGENT.' '.join(' ', @NXAGENT_OPTS).' 2>&1 |')
	or die "Can't execute nxagent: $!";
    while (<NXAGENT_FH>) {
	chomp;
	# Handle Starting, Suspending, Terminating, Aborting
	if (/Session: (\w+) session at/) {
	    handleStatus lc($1);
	}
	# Handle started, suspended, terminated, aborted
	if (/Session: Session (\w+) at/) {
	    handleStatus $1;
	}
	if ("$PASSTHROUGH" eq 1) {
	    print $_."\n";
	}
    }
    close NXAGENT_FH;
}

openStatusFile or die "Can't open status file: $!";
lockStatusFile or die "Can't lock status file: $!";
unbufferStatusFile;
launchNxagent;
unlockStatusFile;
closeStatusFile;
