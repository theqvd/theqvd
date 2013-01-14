package QVD::VMKiller::KVM;

use strict;
use warnings;

use Proc::ProcessTable;

sub kill_dangling_vms {
    my $t = Proc::ProcessTable->new;
    foreach my $p (@{$t->table}) {
        if ($p->ppid == 1 and $p->cmndline =~ m|^kvm.*\s-name\s+qvd/(\d+)/|) {
            my $pid = $p->pid;
            warn "killing dangling VM $1, pid: $pid\n";
            kill KILL => $pid;
        }
    }
}

1;
