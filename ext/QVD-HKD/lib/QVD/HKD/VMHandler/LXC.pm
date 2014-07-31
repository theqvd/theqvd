package QVD::HKD::VMHandler::LXC;

BEGIN { *debug = \$QVD::HKD::VMHandler::debug }
our $debug;

use strict;
use warnings;
use 5.010;

use POSIX;
use AnyEvent;
use AnyEvent::Util;
use QVD::Log;
use File::Temp qw(tempfile);
use Linux::Proc::Mountinfo;
use File::Spec;
use Fcntl ();
use Fcntl::Packer ();
use Method::WeakCallback qw(weak_method_callback);
use QVD::HKD::Helpers qw(mkpath);
use QVD::HKD::VMHandler::LXC::FS;

use parent qw(QVD::HKD::VMHandler);

use Class::StateMachine::Declarative
    __any__   => { ignore => [qw(_on_cmd_start on_expired _on_lxc_done)],
                   delay => [qw(on_hkd_kill
                                _on_cmd_stop)],
                   on => { on_hkd_stop => 'on_hkd_kill' },
                   transitions => { _on_dirty => 'dirty' } },

    new       => { transitions => { _on_cmd_start        => 'starting',
                                    _on_cmd_stop         => 'stopping/db',
                                    _on_cmd_catch_zombie => 'zombie' } },

    starting  => { advance => '_on_done',
                   on => { on_hkd_kill => '_on_error' },
                   substates => [ db              => { transitions => { _on_error   => 'stopping/db' },
                                                       substates => [ loading_row        => { enter => '_load_row' },
                                                                      searching_di       => { enter => '_search_di' },
                                                                      calculating_attrs  => { enter => '_calculate_attrs' },
                                                                      saving_runtime_row => { enter => '_save_runtime_row' },
                                                                      updating_stats     => { enter => '_incr_run_attempts' } ] },

                                  clean_old       => { transitions => { _on_error => 'zombie/reap',
                                                                        on_hkd_kill => 'stopping/db' },
                                                       substates => [ killing_lxc            => { enter => '_kill_lxc' },
                                                                      unlinking_iface        => { enter => '_unlink_iface' },
                                                                      removing_fw_rules      => { enter => '_remove_fw_rules' },
                                                                      unmounting_filesystems => { enter => '_unmount_filesystems' } ] },

                                  os_fs           => { enter => '_start_os_fs',
                                                       transitions => { _on_error   => 'stopping/os_fs' } },

                                  heavy           => { enter => '_heavy_down',
                                                       transitions => { _on_error    => 'stopping/os_fs',
                                                                        _on_cmd_stop => 'stopping/os_fs' } },

                                  setup           => { transitions => { _on_error   => 'stopping/cleanup' },
                                                       substates => [ allocating_home_fs      => { enter => '_allocate_home_fs' },
                                                                      configuring_dhcpd       => { enter => '_add_to_dhcpd' },
                                                                      creating_lxc            => { enter => '_create_lxc' },
                                                                      running_prestart_hook   => { enter => '_run_prestart_hook' },
                                                                      setting_fw_rules        => { enter => '_set_fw_rules' },
                                                                      launching               => { enter => '_start_lxc' } ] },

                                  waiting_for_vma => { enter => '_start_vma_monitor',
                                                       transitions => { _on_alive      => 'running',
                                                                        _on_dead       => 'stopping/stop',
                                                                        _on_cmd_stop   => 'stopping/stop',
                                                                        _on_lxc_done   => 'stopping/cleanup',
                                                                        on_hkd_kill    => 'stopping/stop',
                                                                        _on_goto_debug => 'debugging' } } ] },

    running   => { advance => '_on_done',
                   delay => [qw(_on_lxc_done)],
                   transitions => { _on_error => 'stopping/stop' },
                   substates => [ saving_state           => { enter => '_save_state' },
                                  updating_stats         => { enter => '_incr_run_ok' },
                                  running_poststart_hook => { enter => '_run_poststart_hook' },
                                  unheavy                => { enter => '_heavy_up' },
                                  monitoring             => { enter => '_start_vma_monitor',
                                                              ignore => [qw(_on_alive)],
                                                              transitions => { _on_dead       => 'stopping/stop',
                                                                               _on_cmd_stop   => 'stopping/shutdown',
                                                                               _on_lxc_done   => 'stopping/cleanup',
                                                                               on_hkd_kill    => 'stopping/stop',
                                                                               _on_goto_debug => 'debugging',
                                                                               on_expired     => 'expiring' } },
                                  '(expiring)'           => { enter => '_expire',
                                                              transitions => { _on_done => 'monitoring' } } ] },

    debugging => { advance => '_on_done',
                   delay => [qw(_on_lxc_done)],
                   transitions => { _on_error => 'stopping/stop' },
                   substates => [ saving_state => { enter => '_save_state' },
                                  unheavy      => { enter => '_heavy_up' },
                                  monitoring   => { enter => '_start_vma_monitor',
                                                    ignore => [qw(_on_dead
                                                                  _on_goto_debug)],
                                                    transitions => { _on_alive    => 'running',
                                                                     _on_cmd_stop => 'stopping/stop',
                                                                     _on_lxc_done => 'stopping/cleanup',
                                                                     on_hkd_kill  => 'stopping/stop' } } ] },

    stopping  => { advance => '_on_done',
                   transitions => { _on_error => 'zombie/reap' },
                   delay => [qw(_on_lxc_done)],
                   substates => [ shutdown => { transitions => { on_hkd_kill => 'stop' },
                                                substates => [ saving_state    => { enter => '_save_state' },
                                                               heavy           => { enter => '_heavy_down' },
                                                               shuttingdown    => { enter => '_shutdown',
                                                                                    transitions => { _on_error    => 'stop',
                                                                                                     _on_lxc_done => 'cleanup' } },
                                                               waiting_for_lxc => { enter => '_set_state_timer',
                                                                                    transitions => { _on_lxc_done      => 'cleanup',
                                                                                                     _on_state_timeout => 'stop' } } ] },
                                  stop     => { substates => [ saving_state    => { enter => '_save_state' },
                                                               heavy           => { enter => '_heavy_down' },
                                                               running_stop    => { enter => '_stop_lxc' },
                                                               waiting_for_lxc => { enter => '_set_state_timer',
                                                                                    transitions => { _on_lxc_done      => 'cleanup',
                                                                                                     _on_state_timeout => 'cleanup' } } ] },
                                  cleanup  => { ignore => [qw(_on_lxc_done)], # FIXME: is there really a reason for that?
                                                substates => [ saving_state           => { enter => '_save_state' },
                                                               checking_dirty         => { enter => '_check_dirty_flag' },
                                                               heavy                  => { enter => '_heavy_down' },
                                                               killing_lxc            => { enter => '_kill_lxc' },
                                                               unlinking_iface        => { enter => '_unlink_iface' },
                                                               removing_fw_rules      => { enter => '_remove_fw_rules' },
                                                               running_poststop_hook  => { enter => '_run_poststop_hook',
                                                                                           transitions => { _on_error => 'destroying_lxc' } },
                                                               destroying_lxc         => { enter => '_destroy_lxc' },
                                                               configuring_dhcpd      => { enter => '_rm_from_dhcpd' } ] },

                                  os_fs    => { enter => '_unmount_filesystems' },

                                  db       => { enter => '_clear_runtime_row',
                                                transitions => { _on_error => 'zombie/db',
                                                                 _on_done  => 'stopped' } } ] },

    stopped => { enter => '_on_stopped' },

    zombie  => { advance => '_on_done',
                 delay => [qw(_on_lxc_done)],
                 ignore => [qw(on_hkd_stop)],
                 transitions => { on_hkd_kill => 'stopped' },
                 substates => [ config => { transitions => { _on_error => 'delaying' },
                                            substates => [ saving_state      => { enter => '_save_state',
                                                                                  on => { _on_error => '_on_done' } },
                                                           calculating_attrs => { enter => '_calculate_attrs',
                                                                                  transitions => { _on_error => 'delaying' } },
                                                           '(delaying)'      => { enter => '_set_state_timer',
                                                                                  transitions => { _on_timeout => 'config' } } ] },

                                reap   => { transitions => { _on_error => 'delaying' },
                                            substates => [ saving_state           => { enter => '_save_state',
                                                                                       on => { _on_error => '_on_done' } },
                                                           dirty                  => { enter => '_check_dirty_flag',
                                                                                       transitions => { _on_error => 'dirty' } },
                                                           heavy                  => { enter => '_heavy_down' },
                                                           checking_lxc           => { enter => '_check_lxc',
                                                                                      transitions => { _on_error => 'killing_lxc' } },
                                                           stopping_lxc           => { enter => '_stop_lxc' },
                                                           waiting_for_lxc        => { enter => '_set_state_timer',
                                                                                       transitions => { _on_lxc_done      => 'killing_lxc',
                                                                                                        _on_state_timeout => 'killing_lxc'} },
                                                           killing_lxc            => { enter => '_kill_lxc' },
                                                           unlinking_iface        => { enter => '_unlink_iface' },
                                                           removing_fw_rules      => { enter => '_remove_fw_rules' },
                                                           destroying_lxc         => { enter => '_destroy_lxc',
                                                                                       transitions => { _on_error => 'unmounting_filesystems'  } },
                                                           unmounting_filesystems => { enter => '_unmount_filesystems' },
                                                           unheavy                => { enter => '_heavy_up' },
                                                           configuring_dhcpd      => { enter => '_rm_from_dhcpd' },
                                                           '(delaying)'           => { enter => '_set_state_timer',
                                                                                       transitions => { _on_state_timeout => 'reap'} } ] },

                                db     => { transitions => { _on_error => 'delaying' },
                                            substates => [ clearing_runtime_row => { enter => '_clear_runtime_row',
                                                                                     transitions => { _on_done => 'stopped' } },
                                                           '(delaying)'         => { enter => '_set_state_timer',
                                                                                     transitions => { _on_state_timeout => 'db'} } ] } ] },

    dirty  => { ignore => [qw(on_hkd_stop)],
                transitions => { on_hkd_kill => 'stopped' } };

sub _calculate_attrs {
    my $self = shift;

    $self->SUPER::_calculate_attrs;

    $self->{lxc_name} = "qvd-$self->{vm_id}";
    my $rootfs_parent = $self->_cfg('path.storage.rootfs');
    $rootfs_parent =~ s|/*$|/|;
    $self->{os_rootfs_parent} = $rootfs_parent;
    $self->{os_rootfs} = "$rootfs_parent$self->{vm_id}-fs";

    if (defined(my $di_path = $self->{di_path})) {
        # this sub is called with just the vm_id loaded into the
        # object when reaping zombie containers
        $self->{os_image_path} = $self->_cfg('path.storage.images') .'/'. $di_path;
        my $base_dir = $di_path;
        $base_dir =~ s/\.(?:tar(?:\.(?:gz|bz2|xz))?|tgz|tbz|txz)$//;
        my $basefs_parent = $self->_cfg('path.storage.basefs');
        $basefs_parent =~ s|/*$|/|;
        # note that os_basefs may be changed later from
        # _detect_os_image_type!
        $self->{os_basefs} = "$basefs_parent/$base_dir";
        $self->{os_basefs_lockfn} = "$basefs_parent/lock.$base_dir";

        # FIXME: use a better policy for overlay allocation
        my $overlays_parent = $self->_cfg('path.storage.overlayfs');
        $overlays_parent =~ s|/*$|/|;
        $self->{os_overlayfs} = $overlays_parent . join('-', $self->{di_id}, $self->{vm_id}, 'overlayfs');
        unless ($self->_cfg('vm.overlay.persistent')) {
            $self->{os_overlayfs_old} = $overlays_parent . join('-',
                                                                'deleteme', $self->{di_id}, $self->{vm_id},
                                                                $$, rand(100000));
        }
    }

    if ($self->{user_storage_size}) {
        my $homefs_parent = $self->_cfg('path.storage.homefs');
        $homefs_parent =~ s|/*$|/|;
        if ($self->_cfg('vm.lxc.home.per.user')) {
            $self->{home_fs} = "$homefs_parent$self->{login}";
            $self->{home_fs_mnt} = "$self->{os_rootfs}/home/$self->{login}";
        }
        else {
            $self->{home_fs} = "$homefs_parent$self->{vm_id}-fs";
            $self->{home_fs_mnt} = "$self->{os_rootfs}/home";
        }
    }

    my $iface = $self->{iface} =
        $self->_cfg('internal.vm.network.device.prefix') . $self->{vm_id};
    # $self->_cfg('internal.vm.network.device.prefix') . $self->{vm_id} . 'r' . int(rand 10000);

    DEBUG("attributes for VM $self->{vm_id}: "
          . join(', ', map($_ . '=' . ($self->{$_} // '<undef>'),
                           qw(di_path os_image_path os_basefs os_overlayfs
                              os_overlayfs_old os_rootfs_parent os_rootfs
                              home_fs home_fs_mnt iface netmask_len gateway) ) ) );

    $self->_on_done;
}

sub _start_os_fs {
    my $self = shift;
    my $fs = QVD::HKD::VMHandler::LXC::FS->new(vm_id         => $self->{vm_id},
                                               config        => $self->{config},
                                               heavy         => $self->{heavy},
                                               on_error      => weak_method_callback($self, '_on_error'),
                                               on_running    => weak_method_callback($self, '_on_done'),
                                               image_path    => $self->{os_image_path},
                                               basefs        => $self->{os_basefs},
                                               basefs_lockfn => $self->{os_basefs_lockfn},
                                               overlayfs     => $self->{os_overlayfs},
                                               overlayfs_old => $self->{os_overlayfs_old},
                                               rootfs        => $self->{os_rootfs});
    $self->{os_fs} = $fs;
    $fs->run;
}

sub _allocate_home_fs {
    my $self = shift;

    my $homefs = $self->{home_fs};
    defined $homefs or return $self->_on_done;

    unless (mkpath $homefs) {
        ERROR "Unable to create directory '$homefs'";
        return $self->_on_error;
    }
    my $mount_point = $self->{home_fs_mnt};
    unless (mkpath $mount_point) {
        ERROR "Unable to create directory '$mount_point'";
        return $self->_on_error;
    }

    # let lxc mount the home file system for us
    DEBUG "Setting up homefs fstab entry as '$homefs $mount_point none defaults,bind'";
    $self->{home_fstab} = "$homefs $mount_point none defaults,bind";

    $self->_on_done
}

sub _create_lxc {
    my $self = shift;
    my $lxc_name = $self->{lxc_name};

    my $lxc_root = $self->_cfg('path.run.lxc');
    unless (-d $lxc_root or mkdir $lxc_root) {
        ERROR "Unable to create directory $lxc_root: $!";
        return $self->_on_error;
    }

    my $lxc_dir = "$lxc_root/$lxc_name";
    unless (-d $lxc_dir or mkdir $lxc_dir) {
        ERROR "Unable to create directory '$lxc_dir': $!";
        return $self->_on_error;
    }

    my $fn = "$lxc_dir/config";
    DEBUG "Saving lxc configuration to '$fn'";
    open my $cfg_fh, '>', $fn;
    unless ($cfg_fh) {
        ERROR "Unable to create file '$fn': $!";
        return $self->_on_error;
    }

    my $bridge = $self->_cfg('vm.network.bridge');
    my $console;
    if ($self->_cfg('vm.serial.capture')) {
        my $captures_dir = $self->_cfg('path.serial.captures');
        mkdir $captures_dir, 0700;
        my $err = $!;
        if (-d $captures_dir) {
            my @t = gmtime; $t[5] += 1900; $t[4] += 1;
            my $ts = sprintf("%04d-%02d-%02d-%02d:%02d:%2d-GMT0", @t[5,4,3,2,1,0]);
            $console = "$captures_dir/capture-$self->{name}-$ts.txt";
            DEBUG "Console output will be saved in '$console'";
        }
        else {
            ERROR "Captures directory '$captures_dir' does not exist and can not be created: $!";
            return $self->_on_error;
        }
    }
    else {
        $console = '/dev/null';
        DEBUG 'Console output will not be saved';
    }

    my $iface = $self->{iface};
    DEBUG "Local endpoint of the network device, connected to the bridge '$bridge': '$iface'";

    my $lxc_version = $self->_cfg('command.version.lxc');
    my $qvd_lxc_autodev = $self->_cfg('command.qvd-lxc-autodev');

    # FIXME: make this template-able or configurable in some way
    print $cfg_fh <<EOC;
lxc.autodev=1
lxc.hook.autodev=$qvd_lxc_autodev
lxc.utsname=$self->{name}
lxc.network.type=veth
lxc.network.veth.pair=$iface
lxc.network.name=eth0
lxc.network.flags=up
lxc.network.hwaddr=$self->{mac}
lxc.network.link=$bridge
lxc.console=$console
lxc.tty=3
lxc.pts=1
lxc.rootfs=$self->{os_rootfs}
lxc.mount.entry=$self->{home_fstab}
lxc.pivotdir=qvd-pivot
lxc.cgroup.cpu.shares=1024

#lxc.cap.drop=sys_module audit_control audit_write linux_immutable mknod net_admin net_raw sys_admin sys_boot sys_resource sys_time

# Deny access to all devices, except...
lxc.cgroup.devices.deny = a

# Allow any mknod (but not using the node)
lxc.cgroup.devices.allow = c *:* m
lxc.cgroup.devices.allow = b *:* m
# /dev/null and zero
lxc.cgroup.devices.allow = c 1:3 rwm
lxc.cgroup.devices.allow = c 1:5 rwm
# consoles /dev/tty, /dev/console
lxc.cgroup.devices.allow = c 5:1 rwm
lxc.cgroup.devices.allow = c 5:0 rwm
# /dev/{,u}random
lxc.cgroup.devices.allow = c 1:9 rwm
lxc.cgroup.devices.allow = c 1:8 rwm
lxc.cgroup.devices.allow = c 136:* rwm
lxc.cgroup.devices.allow = c 5:2 rwm
# rtc
lxc.cgroup.devices.allow = c 254:0 rwm
#fuse
lxc.cgroup.devices.allow = c 10:229 rwm
#tun
lxc.cgroup.devices.allow = c 10:200 rwm
#full
lxc.cgroup.devices.allow = c 1:7 rwm
#hpet
lxc.cgroup.devices.allow = c 10:228 rwm
#kvm
lxc.cgroup.devices.allow = c 10:232 rwm
EOC

    if (!$self->_cfg('vm.network.use_dhcp')) {
        print $cfg_fh <<EOC;
lxc.network.ipv4 = $self->{ip}/$self->{netmask_len}
EOC
        if ($lxc_version >= 0.8) {
            print $cfg_fh <<EOC;
lxc.network.ipv4.gateway = $self->{gateway}
EOC
        }
    }

    my $meta = $self->{os_fs}->image_metadata_dir;
    if (defined $meta) {
	my $config_extra = "$meta/lxc/config-extra";
	if (-f $config_extra) {
	    print $cfg_fh "lxc.extra=$config_extra\n"
	}
	my $fstab = "$meta/lxc/fstab";
	if (-f $fstab) {
	    print $cfg_fh "lxc.mount=$fstab\n";
	}
    }

    print $cfg_fh $self->_cfg('internal.vm.lxc.conf.extra'), "\n";
    close $cfg_fh;

    $self->_on_done;
}

sub _start_lxc {
    my $self = shift;

    my $hv_out = $self->_hypervisor_output_redirection;

    $self->_run_cmd( { save_pid_to => 'vm_pid',
                       ignore_errors => 1,
                       outlives_state => 1,
                       on_done => weak_method_callback($self, '_on_lxc_done'),
                       '<' => '/dev/null',
                       '>' => $hv_out,
                       '2>' => $hv_out,
                     },
                     'lxc-start', -n => $self->{lxc_name}, -P => $self->_cfg('path.run.lxc'));
    $self->_on_done;
}

sub _check_lxc {
    my $self = shift;
    if ($self->{vm_pid}) {
        $self->_on_done;
    }
    else {
        $self->_on_error;
    }
}

sub _stop_lxc {
    my $self = shift;
    if (defined $self->{vm_pid}) {
        $self->_run_cmd( { kill_after => $self->_cfg('internal.hkd.command.timeout.lxc-stop'),
                           run_and_forget => 1 },
                         'lxc-stop', -n => $self->{lxc_name}, -P => $self->_cfg('path.run.lxc'));
    }
    $self->_on_done;
}

sub _check_dirty_flag {
    my $self = shift;
    if ($self->_cfg("internal.hkd.lxc.does.not.cleanup")) {
        $debug and $self->_debug("going dirty because internal.hkd.lxc.does.not.cleanup is set");
        return $self->_on_error;
    }
    return $self->_on_done;
}

sub _kill_lxc {
    my $self = shift;
    my @pids;
    my $cgroup_cpu_lxc = $self->_cfg('path.cgroup.cpu.lxc');
    my $fn = "$cgroup_cpu_lxc/$self->{lxc_name}/cgroup.procs";
    if (open my $fh, '<', $fn) {
        chomp(@pids = <$fh>);
    }
    else {
        $debug and $self->_debug("unable to open $fn: $!");
        INFO "Unable to open '$fn': $!";
    }
    my $vm_pid = $self->{vm_pid};
    push @pids, $vm_pid if defined $vm_pid;
    if (@pids) {
        $debug and $self->_debug("killing zombie processes and then trying again, pids: @pids");
        DEBUG "Killing zombie processes and then trying again, PIDs: @pids";
        if ($self->{killer_count}++ > $self->_cfg('internal.hkd.lxc.killer.retries')) {
            $debug and $self->_debug("too many retries, no more killing, peace!");
            WARN "Too many retries when killing cointainer processes: @pids";
            # $self->_abort_cmd($vm_pid);
            return $self->_on_error;
        }
        kill KILL => @pids;
        $self->_call_after(2 => '_kill_lxc');
    }
    else {
        $debug and $self->_debug("all processes killed");
        DEBUG "All processes killed";
        return $self->_on_done;
    }
}

sub _destroy_lxc {
    my $self = shift;
    my $lxc_name = $self->{lxc_name};
    my $lxc_dir = $self->_cfg('path.run.lxc'). "/$lxc_name";
    unlink "$lxc_dir/config" or DEBUG "unable to unlink '$lxc_dir/config': $!";
    rmdir $lxc_dir or DEBUG "unable to delete '$lxc_dir': $!";
    $self->_on_done;
}

sub _unlink_iface {
    my $self = shift;
    # FIXME: check that the interface has been really removed or return error
    $self->_run_cmd( { ignore_errors => 1 },
                     'ip', 'link', 'del', $self->{iface});
}

sub _unmount_filesystems {
    my $self = shift;
    $self->{unmounted} //= {};
    my $rootfs = $self->{os_rootfs};
    my $mi = Linux::Proc::Mountinfo->read;
    DEBUG "Unmounting filesystems under '$rootfs'";
    if (my $at = $mi->at($rootfs)) {
        my @mnts = map $_->mount_point, @{$at->flatten};
        $debug and $self->_debug("mnts behind $rootfs: @mnts");
        my @remaining = grep !$self->{unmounted}{$_}, @mnts;
        if (@remaining) {
            my $next = $remaining[-1];
            $self->{unmounted}{$next} = 1;
            return $self->__unmount_filesystem($next);
        }
        else {
            $debug and $self->_debug("Some filesystems could not be unmounted: @mnts");
            ERROR sprintf 'Some filesystems could not be unmounted: %s', join ', ', @mnts;
            delete $self->{unmounted};
            return $self->_on_error;
        }
    }
    else {
        $debug and $self->_debug("No filesystem mounted at $rootfs found");
        DEBUG "No filesystem mounted at '$rootfs' found";
    }
    delete $self->{unmounted};
    $self->_on_done
}

sub __unmount_filesystem {
    my ($self, $mnt) = @_;
    $self->_run_cmd( { timeout => $self->_cfg('internal.hkd.lxc.killer.umount.timeout'),
                       ignore_errors => 1,
                       on_done => '_unmount_filesystems' },
                     umount => $mnt);
}

sub _hook_args {
    my $self = shift;
    map { $_ => $self->{$_} } qw( use_overlay
                                  mac
                                  name
                                  ip
                                  os_rootfs
                                  os_overlayfs
                                  lxc_name );
}

sub _run_hook {
    my ($self, $name) = @_;
    my $meta = $self->{os_fs}->image_metadata_dir;
    if (defined $meta) {
        my $hook = "$meta/hooks/$name";
        if (-f $hook) {
            my @args = ( id      => $self->{vm_id},
                         hook    => $name,
                         state   => $self->_main_state,
                         os_meta => $meta,
                         $self->_hook_args );

            $debug and $self->_debug("running hook $hook< for $name");
            DEBUG "Running hook '$hook' for '$name'";
            $self->_run_cmd( { skip_cmd_lookup => 1 },
                             $hook => @args);
            return;
        } else {
            WARN "Hook '$hook' for '$name' not found";
        }
    }
    $debug and $self->_debug("no hooks for $name");
    DEBUG "No hooks for '$name'";
    $self->_on_done;
}

sub _run {
	my @cmd = @_;
	my $cmd_str = join(" ", @cmd);

	DEBUG "Running command:  $cmd_str\n";

	my $ret = system(@cmd);

	if ( $? == -1 ) {
		ERROR "Failed to execute '$cmd_str': $!";
		return undef;
	} elsif ( $? & 127 ) {
		ERROR sprintf("Command '$cmd_str' died with signal %d, %s coredump\n", ($? & 127),  ($? & 128) ? 'with' : 'without');
		return undef;
	} elsif ( ($? >> 8) > 0 )  {
		ERROR sprintf("Command '$cmd_str' exited with signal %d", $? >> 8);
		return undef;
	} else {
		DEBUG "Command executed successfully";
	}

	return $ret;
}

1;
