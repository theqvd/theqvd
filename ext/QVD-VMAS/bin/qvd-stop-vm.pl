#!/usr/bin/perl

use strict;
use warnings;
use QVD::VMAS;

my $host_id = 1;
my $vmas = QVD::VMAS->new;
my $vm = $vmas->get_vms_for_host($host_id)->first;
my $vm_id = $vm->vm_id;
print "Stopping VM $vm_id...\n";
my $r = $vmas->stop_vm($vm);
die "Couldn't stop VM $vm_id: $r->{error}" unless $r->{request} eq 'success';

for (;;) {
    print "Waiting for VM $vm_id to stop...\n";
    last if not $vmas->is_vm_running($vm);
    sleep 3;
}
print "VM $vm_id stopped.\n";
