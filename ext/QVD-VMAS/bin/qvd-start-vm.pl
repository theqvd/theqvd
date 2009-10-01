#!/usr/bin/perl

use strict;
use warnings;
use QVD::VMAS::Client;
use QVD::VMA::Client;

my $vm_id = 1;
my $client = QVD::VMAS::Client->new;

print "Starting VM $vm_id...\n";
my $r = $client->start_vm(id => $vm_id);
die "Couldn't start VM $vm_id: $r->{error}" unless $r->{vm_status} eq 'starting';

$r = $client->get_vm_status(id => $vm_id);
die "VM $vm_id wasn't started" unless $r->{vm_status} eq 'started';

for (;;) {
    print "Connecting to agent...\n";
    my $vma_status = $client->get_vm_status(id => $vm_id)->{vma_status};
    last if $vma_status eq 'ok';
    sleep 10;
}
print "VM $vm_id started, agent ready.\n";
