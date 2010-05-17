#!/usr/bin/perl

use strict;
use warnings;
use Fcntl ':flock';
use File::Spec::Functions qw(rel2abs);
use File::Basename;

use QVD::VMA::Config;

# FIXME: DO NOT SHOUT!!!
# use lexical file handlers and simplify

my $QVD_SESSION_DIR = cfg('path.run');
my $QVD_SESSION_STATUS_FILE = $QVD_SESSION_DIR."/state";
my $QVD_SESSION_PID_FILE = $QVD_SESSION_DIR."/nxagent.pid";
my $QVD_SESSION_LOG_FILE = $QVD_SESSION_DIR."/nxagent.log";
my $NXAGENT = cfg('command.nxagent');

my @NXAGENT_OPTS = @ARGV;

sub open_status_file {
    open(QVD_SESSION_STATUS_FH, ">", $QVD_SESSION_STATUS_FILE);
}

sub setup_environment {

    # FIXME: rename nxdiag.pl to qvd-nxdiag and let nxagent find it on the $PATH
    $ENV{NX_CLIENT} = dirname(rel2abs($0))."/nxdiag.pl";

    # Something occasionally sends a SIGTERM to the monitor and makes it die
    # FIXME Find out why we receive SIGTERM and how we should deal with it
    $SIG{TERM} = 'IGNORE';
}

sub unbuffer_fh {
    my $prev = select(shift);
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
    truncate QVD_SESSION_STATUS_FH, 0;
    seek QVD_SESSION_STATUS_FH, 0, 0;
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
    while (my $line = <NXAGENT_FH>) {
	chomp $line;
	# Error message from shell
	if ($line =~ /sh: (.+)$/) {
	    handle_status "exited aborted";
	    die "Can't execute nxagent: $1";
	}
	# Save agent pid, not necessarily pid of the opened cmd
	if ($line =~ /Info: Agent running with pid '(\d+)'/) {
	    handle_pid $1;
	}
	# Handle Starting, Suspending, Terminating, Aborting
	if ($line =~ /Session: (\w+) session at/) {
	    $status = lc($1);
	    handle_status $status;
	}
	# Handle started, suspended, terminated, aborted
	if ($line =~ /Session: Session (\w+) at/) {
	    $status = $1;
	    handle_status $status;
	}
	print QVD_SESSION_LOG_FH $line."\n";
    }
    close NXAGENT_FH;
    handle_status "exited $status"
}

mkdir $QVD_SESSION_DIR, 755;
-d $QVD_SESSION_DIR or die "Directory $QVD_SESSION_DIR does not exist";

open_pid_file or die "Can't open pid file: $!";
open_log_file or die "Can't open log file: $!";
open_status_file or die "Can't open status file: $!";
lock_status_file or die "Can't lock status file: $!";
unbuffer_fh \*QVD_SESSION_LOG_FH;
unbuffer_fh \*QVD_SESSION_STATUS_FH;
setup_environment;
launch_nxagent;
unlock_status_file;
close_status_file;
close_log_file;
