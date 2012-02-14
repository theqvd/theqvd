#!/usr/bin/perl

use strict;
use warnings;

print "TS, VMS, HEAVY, DELAYED\n";
my $old = '';

my $col = 0;
my %states;

while (<>) {
    my ($ts, $states) = /^([\d\.]+)>.*_debug_vm_stats> VM states: (.*)/ or next;
    my @states = split /\s*,\s*/, $states;
    my %c;
    for my $state (@states) {
        my ($n, $c) = split /\s*:\s*/, $state;
        $states{$n} = $col++ if not defined $states{$n};
        $c{$n} = $c;
    }

    my @out;
    for my $n (sort { $states{$a} <=> $states{$b} } keys %states) {
        push @out, "$n: " . ($c{$n} || 0);
    }

    my $line = join(", ", @out);
    next if $old eq $line;
    print "$ts, $line\n";
    $old = $line;
}

