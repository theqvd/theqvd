#!/usr/bin/perl

use strict;
use warnings;

print "TS, VMS, HEAVY, DELAYED\n";
my $old = '';

while (<>) {
    my ($ts, $vms, $heavy, $delayed) = /^([\d\.]+)>.*_debug_vm_stats> VMs in this host: (\d+), heavy: (\d+), delayed: (\d+)/ or next;
    my $line = join(', ', $vms, $heavy, $delayed);
    next if $old eq $line;
    print "$ts, $line\n";
    $old = $line;
}

