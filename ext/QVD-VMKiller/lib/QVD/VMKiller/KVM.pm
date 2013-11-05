package QVD::VMKiller::KVM;

use strict;
use warnings;

use QVD::Config::Core;
use QVD::Log;
use Linux::Fuser;

sub kill_dangling_vms {
    my $vm_lock_fn = core_cfg('internal.hkd.vm.lock.path');
    unless (-e $vm_lock_fn) {
        INFO "VM lock '$vm_lock_fn' does not exists on disk";
        return;
    }
    my $fuser = Linux::Fuser->new;
    for my $proc ($fuser->fuser($vm_lock_fn)) {
        my $pid = $proc->pid;
        next if $pid == $$;
        # next if $proc->ppid != 1;
        DEBUG "Killing process $pid";
        kill KILL => $pid;
    }
}

1;
