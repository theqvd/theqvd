#!/usr/bin/perl

use strict;
use warnings;
use QVD::VMAS::Client;

my $vm_id=1;
my $client = QVD::VMAS::Client->new;
print "Stopping VM $vm_id...\n";
my $r = $client->stop_vm(id => $vm_id);
die "Couldn't stop VM $vm_id: $r->{error}" unless $r->{request} eq 'success';

# FIXME Add vm_status method to VMAS
my $kvm_pid = `cat /var/run/qvd/vm-$vm_id.pid`;
while (kill 0, $kvm_pid) {
    sleep 5;
    print "Waiting for VM $vm_id to stop...\n";
}
print "VM stopped.\n";
