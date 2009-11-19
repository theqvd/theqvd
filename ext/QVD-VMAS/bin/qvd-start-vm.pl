#!/usr/bin/perl

use strict;
use warnings;
use QVD::VMAS;
use POSIX ":sys_wait_h";

my $user_id = 1;
my $vmas = QVD::VMAS->new();
my $vm = ($vmas->get_vms_for_user($user_id))[0];
$vmas->assign_host_for_vm($vm, 1);
my $vm_id = $vm->vm_id;
print "Starting VM $vm_id...\n";
my $r = $vmas->start_vm($vm);
die "VM $vm_id is already running" if $r->{vm_status} eq 'started';
die "Couldn't start VM $vm_id: $r->{error}" unless $r->{vm_status} eq 'starting';

$r = $vmas->is_vm_running($vm);
die "VM $vm_id wasn't started" unless $r;

for (;;) {
    die "VM stopped" if waitpid(-1, WNOHANG) > 0;
    print "Connecting to agent...\n";
    my $vma_status = $vmas->get_vma_status($vm);
    last if defined $vma_status and $vma_status->{status} eq 'ok';
    sleep 10;
}
print "VM $vm_id started, agent ready.\n";
