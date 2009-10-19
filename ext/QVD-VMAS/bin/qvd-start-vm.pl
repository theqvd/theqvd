#!/usr/bin/perl

use strict;
use warnings;
use QVD::VMAS;

my $host_id = 1;
my $vmas = QVD::VMAS->new();
my @vms = $vmas->get_vms_for_host($host_id);
my $vm = $vms[0];
my $vm_id = $vm->vm_id;

print "Starting VM $vm_id...\n";
my $r = $vmas->start_vm($vm);
die "VM $vm_id is already running" if $r->{vm_status} eq 'started';
die "Couldn't start VM $vm_id: $r->{error}" unless $r->{vm_status} eq 'starting';

$r = $vmas->get_vm_status($vm);
die "VM $vm_id wasn't started" unless $r->{vm_status} eq 'started';

for (;;) {
    print "Connecting to agent...\n";
    my $vma_status = $vmas->get_vm_status($vm)->{vma_status};
    last if $vma_status eq 'ok';
    sleep 10;
}
print "VM $vm_id started, agent ready.\n";
