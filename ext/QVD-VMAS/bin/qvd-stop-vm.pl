#!/usr/bin/perl

use strict;
use warnings;
use QVD::VMAS::Client;

my $vm_id=1;
my $client = QVD::VMAS::Client->new;
print "Stopping VM $vm_id...\n";
my $r = $client->stop_vm(id => $vm_id);
die "Couldn't stop VM $vm_id: $r->{error}" unless $r->{request} eq 'success';

$r = $client->get_vm_status(id=>$vm_id);
die "VM $vm_id wasn't stopped" unless $r->{last_vm_status} eq 'stopping';
for (;;) {
    print "Waiting for VM $vm_id to stop...\n";
    my $vm_status = $client->get_vm_status(id => $vm_id)->{vm_status};
    last if $vm_status eq 'stopped';
    sleep 10;
}
print "VM $vm_id stopped.\n";
