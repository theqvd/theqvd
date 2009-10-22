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

# FIXME Add a non-private method to check if the vm was started!
$r = $vmas->_is_kvm_running($vm_id);
die "VM $vm_id wasn't started" unless $r;

for (;;) {
    print "Connecting to agent...\n";
    my $vma_status = $vmas->get_vma_status($vm);
    last if defined $vma_status and $vma_status->{status} eq 'ok';
    sleep 10;
}
print "VM $vm_id started, agent ready.\n";
