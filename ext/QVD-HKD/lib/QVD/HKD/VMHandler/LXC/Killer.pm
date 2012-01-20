package QVD::HKD::VMHanler::LXC::Killer;

BEGIN { *debug = \$QVD::HKD::VMHandler::debug }
our $debug;

use strict;
use warnings;
use 5.010;

use Linux::Proc::Mountinfo;

use parent qw(QVD::HKD::VMHandler);

use QVD::StateMachine::Declarative
    'new'                   => { transitions => { _on_cmd_start               => 'stopping_lxc'          } },

    'stopping_lxc'          => { enter       => '_stop_lxc',
                                 transitions => { _on_stop_lxc_done           => 'killing_lxc_processes' } },

    'killing_lxc_processes' => { enter       => '_kill_lxc_processes',
                                 transitions => { _on_kill_lxc_processes_done => 'destroying_lxc'        } },

    'destroying_lxc'        => { enter       => '_destroy_lxc',
                                 transitions => { _on_destroy_lxc_done        => 'umounting_filesystems' } },

    'umounting_filesystems' => { enter       => '_umount_filesystems',
                                 transitions => { _on_umount_filesystems_done => 'stopped'               } },

    'stopped'               => { enter       => '_on_stopped'                                              };

sub new {
    my ($class, %opts) = @_;
    my $lxc_name = delete $opts{lxc_name};
    my $rootfs = delete $opts{os_rootfs};

    my $self = $class->SUPER::new(%opts);

    $self->{lxc_name} = $lxc_name;
    $selt->{os_rootfs} = $rootfs;
    $self;
}

sub _stop_lxc {
    my $self = shift;
    $debug and $self->_debug("stopping container $self->{lxc_name}");
    system $self->_cfg('command.lxc-stop'), -n => $self->{lxc_name};
    $debug and $self->_debug("waiting for $self->{lxc_name} to reach state STOPPED");
    $self->_run_cmd([$self->_cfg('command.lxc-wait'), -n => $self->{lxc_name}, 'STOPPED'],
                    timeout => $self->_cfg('internal.hkd.vmhandler.timeout.on_state.stopping'),
                    ignore_errors => 1);
}

sub _kill_lxc_processes {
    my $self = shift;
    my $cgroup = $self->_cfg('path.cgroup');
    my $fn = "$cgroup/$self->{lxc_name}/cgroup.procs";
    open my $fh, '<', $fn or do {
        $debug and $self->_debug("unable to open $fn: $!");
        return $self->_on_kill_lxc_processes_done;
    };
    if (my @pids = <$fh>) {
        if ($self->{killing_count}++ > $self->_cfg('internal.hkd.lxc.killer.kill_process.retries'))
        chomp @pids;
        $debug and $self->_debug("killing zombie processes and then trying again, pids: @pids");
        kill KILL => @pids;
        $self->_call_after(2 => '_kill_lxc_processes');
    }
    else {
        $debug and $self->_debug("no PIDs found in $fn");
        $self->_on_kill_lxc_processes_done;
    }
}

sub _destroy_lxc {
    my $self = shift;
    my $lxc_name = $self->{lxc_name} = "qvd-$self->{vm_id}";
    $self->_run_cmd([$self->_cfg('command.lxc-destroy'), -n => $lxc_name],
                    timeout => $self->_cfg('internal.hkd.lxc.killer.destroy_lxc.timeout'),
                    ignore_errors => 1);
}


sub _umount_filesystems {
    my $self = shift;
    my $rootfs = $self->{os_rootfs};
    unless (defined $rootfs) {
        # FIXME
        $debug and $self->_debug("FIXME: rootfs path has not been calculated yet");
        return $self->_on_umount_filesystems_done;
    }
    my $mi = Linux::Proc::Mountinfo->read;
    $self->{umounted} = {};
    if (my $at = $mi->at($rootfs)) {
        my @mnts = map $_->mount_point, @{$at->flatten};
        my @remaining = grep !$self->{umounted}, @mnts;
        if (@remaining) {
            my $next = $remaining[-1];
            $self->{umounted}{$next} = 1;
            return $self->_umount_filesystem($next);
        }
        else {
            $debug and $self->_debug("Some filesystems could not be umounted: @mnts");
        }
    }
    else {
        $debug and $self->_debug("No filesystem mounted at $rootfs found");
    }
    $self->_on_umount_filesystems_done
}

sub _umount_filesystem {
    my ($self, $mnt) = @_;
    $self->_run_cmd([$self->_cfg('command.umount'), $mnt],
                    timeout => $self->_cfg('internal.hkd.lxc.killer.umount.timeout'),
                    ignore_errors => 1,
                    on_done => '_umount_filesystems');
}

1;
