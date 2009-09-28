#!/usr/bin/perl

use strict;
use warnings;
use QVD::VMAS::Client;
use QVD::VMA::Client;

my $vm_id = 1;
my $client = QVD::VMAS::Client->new;

print "Starting VM $vm_id...\n";
my $r = $client->start_vm('id' => $vm_id);
die "Couldn't start VM $vm_id: $r->{error}" unless $r->{vm_status} eq 'starting';

# FIXME Add vm_status method to VMAS
my $vma_client = QVD::VMA::Client->new('localhost', 3030+$vm_id);
until ($vma_client->is_connected()) {
    print "Connecting to agent...\n";
    sleep 20;
    $vma_client->connect();
}
print "Polling for VM status...\n";
$r = $vma_client->status();
if (defined($r) and $r->{status} eq 'ok') {
    print "VM started.\n";
} else {
    print "VM didn't start.\n";
}
