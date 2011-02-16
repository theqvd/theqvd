#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use Getopt::Std;
use QVD::DB::Simple qw(db);
use Time::HiRes qw(time sleep);

our ($opt_i, $opt_l);

getopt('i:l');

$opt_i //= 1;

my $dbh = db->storage->dbh;
my @states = qw(stopped starting_1 starting_2 running stopping_1 stopping_2 zombie_1 zombie_2 debug);

my $sth = $dbh->prepare("select vm_state, count(*) from vm_runtimes group by vm_state");

say join(' ', map sprintf("%10s", $_), 'time', @states);

while (1) {
    my $time = time;
    my $next = int($time/$opt_i + 1) * $opt_i;
    sleep $next - $time;

    if ($sth->execute) {
	my %state;
	while (my ($state, $count) = $sth->fetchrow_array) {
	    $state{$state} = $count;
	}

	my ($sec, $min, $hour) = localtime $next;
	my $ts = sprintf("  %02d:%02d:%02d", $hour, $min, $sec);

	

	say join(' ', $ts, map sprintf("%10d", $state{$_} // 0), @states);
    }
}
