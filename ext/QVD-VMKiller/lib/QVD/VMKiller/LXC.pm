package QVD::VMKiller::LXC;

use strict;
use warnings;
use 5.010;

use Fcntl qw(LOCK_EX LOCK_NB);

use QVD::Config::Core;
use QVD::Log;

sub kill_dangling_vms {
    my $cgroup = core_cfg('path.cgroup.cpu.lxc');

    opendir my $dh, $cgroup or return;
    my @dirs = readdir $dh;
    close $dh;

    for my $dir (@dirs) {
        next unless $dir =~ /^qvd-(\d+)$/;
        my $vm_id = $1;
        INFO "Reaping VM $vm_id";
        if (open my $fh, '<', "$cgroup/$dir/cgroup.procs") {
            chomp (my @pids = <$fh>);
            if (my $pids = @pids) {
                DEBUG "Killing $pids processes from VM $vm_id";
                kill KILL => @pids;
            }
        }
        rmdir $dir;
    }
}

1;

# FIXME, reword this description

