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

use parent qw(QVD::HKD::VMHandler);

use QVD::StateMachine::Declarative
    'new'                             => { transitions => { _on_cmd_start                => 'starting' } },

    'starting'                        => { jump        => 'starting/saving_state' },

    'starting/saving_state'           => { enter       => '_save_state',
                                           transitions => { _on_save_state_done          => 'starting/loading_row' },
                                           ignore      => ['_on_save_state_result'] },

    'starting/loading_row'            => { enter       => '_load_row',
                                           transitions =>  { _on_load_row_done           => 'starting/searching_di',
                                                             _on_load_row_bad_result     => 'failed' } },

    'starting/searching_di'           => { enter       => '_search_di',
                                           transitions => { _on_search_di_done           => 'starting/saving_runtime_row',
                                                            _on_search_di_bad_result     => 'failed' } },

    'starting/saving_runtime_row'     => { enter       => '_save_runtime_row',
                                           transitions => { _on_save_runtime_row_done    => 'starting/untaring_os_image',
                                                            _on_save_runtime_row_bad_result => 'failed' },
                                           ignore      => ['_on_save_runtime_row_result'] },

    'starting/untaring_os_image'      => { enter       => '_untar_os_image',
                                           transitions => { _on_untar_os_image_done      => 'starting/placing_os_image',
                                                            _on_untar_os_image_error     => 'failing/clearing_runtime_row' } },

    'starting/placing_os_image'       => { enter       => '_place_os_image',
                                           transitions => { _on_place_os_image_done      => 'starting/detecting_os_image_type',
                                                            _on_place_os_image_error     => 'failing/clearing_runtime_row' } },

    'starting/detecting_os_image_type'=> { enter       => '_detect_os_image_type',
                                           transitions => { _on_detect_os_image_type_done => 'starting/allocating_os_overlayfs',
                                                            _on_detect_os_image_type_error => 'failing/clearing_runtime_row' } },

    'starting/allocating_os_overlayfs'=> { enter       => '_allocate_os_overlayfs',
                                           transitions => { _on_allocate_os_overlayfs_done => 'starting/allocating_os_rootfs',
                                                            _on_allocate_os_overlayfs_error => 'failing/clearing_runtime_row' } },

    'starting/allocating_os_rootfs'   => { enter       => '_allocate_os_rootfs',
                                           transitions => { _on_allocate_os_rootfs_done  => 'starting/allocating_home_fs',
                                                            _on_allocate_os_rootfs_error => 'failing/unmounting_root_fs' } },

    'starting/allocating_home_fs'     => { enter       => '_allocate_home_fs',
                                           transitions => { _on_allocate_home_fs_done    => 'starting/destroying_old_lxc',
                                                            _on_allocate_home_fs_error   => 'failing/unmounting_root_fs' } },

    'starting/destroying_old_lxc'     => { enter       => '_destroy_old_lxc',
                                           transitions => { _on_destroy_old_lxc_done     => 'starting/creating_lxc',
                                                            _on_destroy_old_lxc_error    => 'starting/creating_lxc' } },

    'starting/creating_lxc'           => { enter       => '_create_lxc',
                                           transitions => { _on_create_lxc_done          => 'starting/configuring_lxc',
                                                            _on_create_lxc_error         => 'failing/destroying_lxc' } },

    'starting/configuring_lxc'        => { enter       => '_configure_lxc',
                                           transitions => { _on_configure_lxc_done       => 'starting/running_prestart_hook',
                                                            # _on_configure_lxc_done       => 'starting/allocating_tap',
                                                            _on_configure_lxc_error      => 'failing/destroying_lxc' } },

    'starting/running_prestart_hook'  => { enter       => '_run_prestart_hook',
                                           transitions => { _on_run_hook_done            => 'starting/launching',
                                                            _on_run_hook_error           => 'failing/running_poststop_hook' } },

    #'starting/allocating_tap'         => { enter       => '_allocate_tap',
    #                                       transitions => { _on_allocate_tap_done        => 'starting/setting_fw_rules',
    #                                                        _on_allocate_tap_error       => 'failing/unmounting_root_fs' } },

    #'starting/setting_fw_rules'       => { enter       => '_set_fw_rules',
    #                                       transitions => { _on_set_fw_rules_done        => 'starting/enabling_iface',
    #                                                        _on_set_fw_rules_error       => 'failing/unmounting_root_fs' } },

    #'starting/enabling_iface'         => { enter       => '_enable_iface',
    #                                       transitions => { _on_enable_iface_done        => 'starting/launching',
    #                                                        _on_enable_iface_error       => 'failing/unmounting_root_fs' } },

    'starting/launching'              => { enter       => '_start_lxc',
                                           transitions => { _on_start_lxc_done           => 'starting/waiting_for_vma',
                                                            _on_start_lxc_error          => 'failing/running_poststop_hook' } },

    'starting/waiting_for_vma'        => { enter       => '_start_vma_monitor',
                                           leave       => '_stop_vma_monitor',
                                           transitions => { _on_alive                    => 'running/saving_state',
                                                            _on_dead                     => 'stopping/stopping_lxc',
                                                            _on_goto_debug               => 'debugging/saving_state',
                                                            _on_lxc_done                 => 'stopping/destroying_lxc' } },

    'running/saving_state'            => { enter       => '_save_state',
                                           transitions => { _on_save_state_done          => 'running/running_poststart_hook',
                                                            # _on_save_state_done          => 'running/monitoring',
                                                            _on_save_state_bad_result    => 'stopping/powering_off' },
                                           delay       => [qw(_on_lxc_done)],
                                           ignore      => [qw(_on_save_state_result)] },

    'running/running_poststart_hook'  => { enter       => '_run_poststart_hook',
                                           transitions => { _on_run_hook_done            => 'running/monitoring',
                                                            _on_run_hook_error           => 'stopping/powering_off' },
                                           delay       => [qw(_on_lxc_done)] },

    'running/monitoring'              => { enter       => '_start_vma_monitor',
                                           leave       => '_stop_vma_monitor',
                                           transitions => { _on_cmd_stop                 => 'stopping/powering_off',
                                                            _on_dead                     => 'stopping/stopping_lxc',
                                                            _on_goto_debug               => 'debugging/saving_state',
                                                            # _on_lxc_done                 => 'stopping/destroying_lxc'
                                                            _on_lxc_done                 => 'stopping/running_poststop_hook' } },

    'debugging/saving_state'          => { enter       => '_save_state',
                                           transitions => { _on_save_state_done          => 'debugging/waiting_for_vma',
                                                            _on_save_state_bad_result    => 'stopping/powering_off' },
                                           delay       => [qw(_on_lxc_done)],
                                           ignore      => [qw(_on_save_state_result)] },

    'debugging/waiting_for_vma'       => { enter       => '_start_vma_monitor',
                                           leave       => '_stop_vma_monitor',
                                           transitions => { _on_alive                    => 'running/saving_state',
                                                            _on_cmd_stop                 => 'stopping/powering_off',
                                                            # _on_lxc_done                 => 'stopping/destroying_lxc' },
                                                            _on_lxc_done                 => 'stopping/running_poststop_hook' },
                                           ignore      => [qw(_on_dead
                                                              _on_goto_debug)] },

    'stopping/powering_off'           => { enter       => '_poweroff',
                                           leave       => '_abort_all',
                                           transitions => { _on_rpc_poweroff_error       => 'stopping/stopping_lxc',
                                                            _on_lxc_done                 => 'stopping/destroying_lxc',
                                                            _on_rpc_poweroff_result      => 'stopping/waiting_for_lxc_to_exit' } },

    'stopping/waiting_for_lxc_to_exit'=> { enter       => '_set_state_timer',
                                           leave       => '_abort_all',
                                           transitions => { _on_lxc_done                 => 'stopping/running_poststop_hook',
                                                            # _on_lxc_done                 => 'stopping/destroying_lxc',
                                                            _on_state_timeout            => 'stopping/stopping_lxc' } },

    'stopping/stopping_lxc'           => { enter       => '_stop_lxc',
                                           leave       => '_abort_all',
                                           transitions => { #_on_lxc_done                 => 'stopping/destroying_lxc' } },
                                                            _on_lxc_done                 => 'stopping/running_poststop_hook' } },

    'stopping/running_poststop_hook' => { enter       => '_run_poststop_hook',
                                           transitions => { _on_run_hook_done            => 'stopping/destroying_lxc',
                                                            _on_run_hook_error           => 'failed/destroying_lxc' } },

    'stopping/destroying_lxc'         => { enter       => '_destroy_lxc',
                                           transitions => { _on_destroy_lxc_done         => 'stopping/unmounting_root_fs',
                                                            _on_destroy_lxc_error        => 'failing/unmounting_root_fs' } },

    'stopping/unmounting_root_fs'     => { enter       => '_unmount_root_fs',
                                           transitions => { _on_unmount_root_fs_done     => 'stopping/clearing_runtime_row',
                                                            _on_unmount_root_fs_error    => 'failing/clearing_runtime_row' } },

    'stopping/clearing_runtime_row'   => { enter       => '_clear_runtime_row',
                                           transitions => { _on_clear_runtime_row_done   => 'stopped' },
                                           ignore      => ['_on_clear_runtime_row_result',
                                                           '_on_clear_runtime_row_bad_result'] },

    'stopped'                         => { enter       => '_call_on_stopped' },

    'failing/running_poststop_hook'   => { enter       => '_run_poststop_hook',
                                           transitions => { _on_run_hook_done            => 'failing/destroying_lxc',
                                                            _on_run_hook_error           => 'failing/destroying_lxc' } },

    'failing/destroying_lxc'          => { enter       => '_destroy_lxc',
                                           transitions => { _on_destroy_lxc_done         => 'failing/unmounting_root_fs',
                                                            _on_destroy_lxc_error        => 'failing/unmounting_root_fs' } },

    'failing/unmounting_root_fs'      => { enter       => '_unmount_root_fs',
                                           transitions => { _on_unmount_root_fs_done      => 'failing/clearing_runtime_row',
                                                            _on_unmount_root_fs_error     => 'failing/clearing_runtime_row'  } },

    'failing/clearing_runtime_row'    => { enter       => '_clear_runtime_row',
                                           transitions => { _on_clear_runtime_row_done   => 'failed',
                                                            _on_clear_runtime_row_error  => 'failed' },
                                           ignore      => ['_on_clear_runtime_row_result',
                                                           '_on_clear_runtime_row_bad_result'] },

    'failed'                          => { enter       => '_call_on_stopped' };

#sub leave_state :OnState('starting/waiting_for_vma') {
#    my ($self, undef, $target) = @_;
#    $debug and $self->_debug("leave_state target: $target");
#    unless ($target =~ /^running/) {
#        $self->_stop_vma_monitor;
#    }
#}

sub _on_cmd_stop :OnState('__any__') { shift->delay_until_next_state }

sub _untar_os_image {
    my $self = shift;
    my $image_path = $self->_cfg('path.storage.images') . '/' . $self->{di_path};
    unless (-f $image_path) {
        ERROR "Image $image_path attached to VM $self->{vm_id} does not exist on disk";
        return $self->_on_untar_os_image_error;
    }

    my $basefs_dir = $self->_cfg('path.storage.basefs');
    $basefs_dir =~ s|/*$|/|;
    my $basefs = $self->{os_basefs} = "$basefs_dir/$self->{di_path}";
    -d $basefs and return $self->_on_untar_os_image_done;
    my $tmp = $self->_cfg('path.storage.basefs') . "/untar-$$-" . rand(100000);
    $tmp++ while -e $tmp;
    mkdir $basefs_dir, 0755;
    mkdir $tmp, 0755;
    unless (-d $tmp) {
        ERROR "Unable to create directory $tmp";
        return $self->_on_untar_os_image_error;
    }
    $self->{os_basefs_tmp} = $tmp;

    my @cmd = ( $self->_cfg('command.tar'),
                'x',
                -f => $image_path,
                -C => $tmp );
    push @cmd, '-z' if $image_path =~ /\.(?:tgz|gz)$/;
    push @cmd, '-j' if $image_path =~ /\.(?:tbz|bz2)$/;

    $self->_run_cmd(\@cmd);
}

sub _place_os_image {
    my $self = shift;
    my $basefs = $self->{os_basefs};
    -d $basefs and return $self->_on_place_os_image_done;
    my $tmp = $self->{os_basefs_tmp};
    rename $tmp, $basefs
        or ERROR "rename of $tmp to $basefs failed: $!";
    unless (-d $basefs) {
        ERROR "$basefs does not exist or is not a directory";
        return $self->_on_place_os_image_error;
    }
    $self->_on_place_os_image_done;
}

sub _detect_os_image_type {
    my $self = shift;
    my $basefs = $self->{os_basefs};
    if (-d "$basefs/sbin/") {
        # FIXME: improve autodetection logic
        $debug and $self->_debug("os image is of type basic");
    }
    elsif (-d "$basefs/rootfs/sbin/") {
        $self->{os_meta} = $basefs;
        $self->{os_basefs} = "$basefs/rootfs";
        $debug and $self->_debug("os image is of type extended");
    }
    else {
        ERROR "sbin not found at $basefs/sbin or at $basefs/rootfs/sbin";
        return $self->_on_detect_os_image_type_error;
    }
    return $self->_on_detect_os_image_type_done;
}

sub _allocate_os_overlayfs {
    my $self = shift;
    my $basefs = $self->{os_basefs};

    # FIXME: use a better policy for overlay allocation
    my $overlays_dir = $self->_cfg('path.storage.overlayfs');
    $overlays_dir =~ s|/*$|/|;
    my $overlayfs = $self->{os_overlayfs} = $overlays_dir . join('-', $self->{di_id}, $self->{vm_id}, 'overlayfs');
    if (-d $overlayfs) {
        if ($self->_cfg('vm.overlay.persistent')) {
            return $self->_on_allocate_os_overlayfs_done;
        }
        my $deleteme =  $overlays_dir . join('-', 'deleteme', $self->{di_id}, $self->{vm_id}, $$, rand(100000));
        unless (rename $overlayfs, $deleteme) {
            ERROR "Unable to move old $overlayfs out of the way to $deleteme";
            return $self->_on_allocate_os_overlayfs_error;
        }
    }
    mkdir $overlays_dir, 0755;
    unless (mkdir $overlayfs, 0755) {
        ERROR "Unable to create overlay file system $overlayfs";
        return $self->_on_allocate_os_overlayfs_error;
    }
    $self->_on_allocate_os_overlayfs_done;
}

sub _allocate_os_rootfs {
    my $self = shift;
    my $rootfs_dir = $self->_cfg('path.storage.rootfs');
    $rootfs_dir =~ s|/*$|/|;
    my $rootfs = $self->{os_rootfs} = "$rootfs_dir$self->{vm_id}-fs";
    mkdir $rootfs_dir, 0755;
    mkdir $rootfs, 0755;
    unless (-d $rootfs) {
        ERROR "unable to create directory $rootfs";
        return $self->_on_allocate_os_rootfs_error;
    }
    system $self->_cfg('command.umount'), $rootfs; # just in case!
    if ((stat $rootfs)[0] != (stat $rootfs_dir)[0]) {
        ERROR "a file system is already mounted on top of $rootfs";
        return $self->_on_allocate_os_rootfs_error;
    }

    my $unionfs_type = $self->_cfg('vm.lxc.unionfs.type');

    given ($unionfs_type) {
        when('aufs') {
            if (system $self->_cfg('command.mount'),
                -t => 'aufs',
                -o => "br:$self->{os_overlayfs}:$self->{os_basefs}=ro", "aufs", $rootfs) {
                ERROR "unable to mount aufs (code: " . ($?>>8) . ")";
                return $self->_on_allocate_os_rootfs_error;
            }
        }
        when ('unionfs-fuse') {
            if (system $self->_cfg('command.unionfs-fuse'),
                -o => 'cow',
                -o => 'max_files=32000',
                -o => 'suid',
                -o => 'dev',
                -o => 'allow_other',
                "$self->{os_overlayfs}=RW:$self->{os_basefs}=RO", $rootfs) {
                ERROR "unable to mount unionfs-fuse (code: " . ($? >> 8) . ")";
                return $self->_on_allocate_os_rootfs_error;
            }
        }
        default {
            ERROR "unsupported unionfs type $unionfs_type";
            return $self->_on_allocate_os_rootfs_error;
        }
    }

    $self->_on_allocate_os_rootfs_done;
}

sub _allocate_home_fs {
    my $self = shift;

    my $size = $self->{user_storage_size};
    unless (defined $size) {
        return $self->_on_allocate_home_fs_done;
    }

    my $homefs_dir = $self->_cfg('path.storage.homefs');
    $homefs_dir =~ s|/*$|/|;
    my $homefs = $self->{home_fs} = "$homefs_dir$self->{vm_id}-fs";
    mkdir $homefs_dir, 0755;
    mkdir $homefs, 0755;
    unless (-d $homefs) {
        ERROR "unable to create directory $homefs";
        return $self->_on_allocate_home_fs_error;
    }
    my $mount_point = "$self->{os_rootfs}/home";

    mkdir $mount_point, 0755;
    unless (-d $mount_point) {
        ERROR "unable to create directory $mount_point";
        return $self->_on_allocate_home_fs_error;
    }

    # let lxc mount the home file system for us
    $self->{home_fstab} = "$homefs $self->{os_rootfs}/home none defaults,bind";
    #    if (system $self->_cfg('command.mount'), '--bind', $homefs, $mount_point) {
    #        ERROR "unable to bind $homefs into $mount_point, mount failed (code: ".($?>>8).")";
    #        return $self->_on_allocate_os_rootfs_error;
    #    }

    $self->_on_allocate_home_fs_done
}

sub _destroy_old_lxc {
    my $self = shift;
    my $lxc_name = $self->{lxc_name} = "qvd-$self->{vm_id}";
    $self->_run_cmd([$self->_cfg('command.lxc-destroy'),
                     -n => $lxc_name]);
}

sub _create_lxc {
    my $self = shift;
    my $lxc_name = $self->{lxc_name};

    my ($fh, $fn) = tempfile(UNLINK => 0);
    $debug and $self->_debug("saving lxc configuration to $fn");
    my $bridge = $self->_cfg('vm.network.bridge');
    my $console;
    if ($self->_cfg('vm.serial.capture')) {
        my $captures_dir = $self->_cfg('path.serial.captures');
        mkdir $captures_dir, 0700;
        if (-d $captures_dir) {
            my @t = gmtime; $t[5] += 1900; $t[4] += 1;
            my $ts = sprintf("%04d-%02d-%02d-%02d:%02d:%2d-GMT0", @t[5,4,3,2,1,0]);
            $console = "$captures_dir/capture-$self->{name}-$ts.txt";
        }
        else {
            ERROR "Unable to create captures directory $captures_dir";
            return $self->_on_create_lxc_error;
        }
    }
    else {
        $console = '/dev/null';
    }

    my $pair = $self->_cfg('vm.network.device.prefix') . $self->{vm_id};
    
    my ($r1, $r2) = map int rand 10000, 0..1;
    
    # FIXME: make this template-able or configurable in some way
    print $fh <<EOC;
lxc.network.type=veth
lxc.network.veth.pair=${pair}r$r1
lxc.network.name=eth0
lxc.network.flags=up
lxc.network.hwaddr=$self->{mac}
lxc.network.link=$bridge
lxc.console=$console
lxc.tty=3
lxc.rootfs=$self->{os_rootfs}
lxc.mount.entry=$self->{home_fstab}
#lxc.cap.drop=sys_module audit_control audit_write linux_immutable mknod net_admin net_raw sys_admin sys_boot sys_resource sys_time

EOC
    close $fh;
    $self->_run_cmd([$self->_cfg('command.lxc-create'),
                     -n => $lxc_name,
                     -f => $fn]);
}

sub _configure_lxc { shift->_on_configure_lxc_done }

sub _lxc {
    my $self = shift;
    $self->_run_cmd([$self->_cfg('command.lxc-start'),
                     -n => $self->{lxc_name}]);
}

sub _on_lxc_error { shift->_on_lxc_done }

sub _start_lxc {
    my $self = shift;
    $self->_lxc;
    $self->_on_start_lxc_done;
}

sub _stop_lxc {
    my $self = shift;
    system ($self->_cfg('command.lxc-stop'), -n => $self->{lxc_name});
    $self->_call_after($self->_cfg("internal.hkd.vmhandler.killer.delay"), '_stop_lxc');
}

sub _destroy_lxc {
    my $self = shift;
    if ($self->_cfg('internal.hkd.lxc.does.not.cleanup')) {
        $debug and $self->_debug("aborting lxc destruction because internal.hkd.lxc.does.not.cleanup is set");
        return $self->_on_destroy_lxc_error
    }
    if (system $self->_cfg('command.lxc-destroy'), -n => $self->{lxc_name}) {
        $debug and $self->_debug("destroying lxc $self->{lxc_name} failed");
        ERROR "destroying lxc $self->{lxc_name} failed";
        return $self->_on_destroy_lxc_error
    }
    $self->_on_destroy_lxc_done;
}

sub _unmount_root_fs {
    my $self = shift;
    if ($self->_cfg('internal.hkd.lxc.does.not.cleanup')) {
        $debug and $self->_debug("aborting rootfs unmounting because internal.hkd.lxc.does.not.cleanup is set");
        return $self->_on_unmount_root_fs_error
    }
    my $rootfs = $self->{os_rootfs};
    if (system $self->_cfg('command.umount'), $rootfs) {
        $debug and $self->_debug("unmounting $rootfs failed");
        ERROR "Unable to unmount rootfs at $rootfs for VM $self->{vm_id}";
        return $self->_on_unmount_root_fs_error
    }

    $self->_on_unmount_root_fs_done;
}

sub _run_prestart_hook { shift->_run_hook('prestart') }
sub _run_poststart_hook { shift->_run_hook('poststart') }
sub _run_poststop_hook { shift->_run_hook('poststop') }

sub _run_hook {
    my ($self, $name) = @_;
    my $meta = $self->{os_meta};
    if (defined $meta) {
        my $hook = "$meta/hooks/$name";
        if (-f $hook) {
            my @args = ( id    => $self->{vm_id},
                         hook  => $name,
                         state => $self->_main_state,
                         map { $_ => $self->{$_} } qw( use_overlay
                                                       os_meta
                                                       mac
                                                       name
                                                       ip
                                                       os_rootfs
                                                       lxc_name ));

            $debug and $self->_debug("running hook $hook for $name");
            return $self->_run_cmd([$hook => @args]);
        }
    }
    $debug and $self->_debug("no hook for $name");
    $self->_on_run_hook_done;
}


1;
