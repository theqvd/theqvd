#!/usr/bin/perl

use 5.010;
use strict;
use warnings;

use QVD::DB::Simple qw(rs txn_eval);
use QVD::L7R::LoadBalancer;

my $n = shift @ARGV || die "Usage:\n  $0 <number-of-machines-to-start>\n\n";


my $vms = rs(VM_Runtime)->search({vm_state => 'stopped'});

my $lb = QVD::L7R::LoadBalancer->new;

my $count = 0;

while (my $vm = $vms->next) {
    last if $count >= $n;

    my $host = $lb->get_free_host;
    txn_eval {
	$vm->discard_changes;
	die if (defined $vm->host_id or $vm->vm_state ne 'stopped');
	$vm->set_host_id($host);
	$vm->send_vm_start;
    };
    if ($@) {
	"Unable to start VM " . $vm->id . "\n";
    }
    else {
	$count ++;
    }
}

warn "$count VMs started\n";
