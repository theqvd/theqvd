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

use parent qw(QVD::HKD::VMHandler);

use QVD::StateMachine::Declarative
    'new'                             => { transitions => { _on_cmd_start                => 'starting',
                                                            _on_cmd_catch_zombie         => 'zombie/beating_to_death'          } },

    'starting'                        => { jump        => 'starting/saving_state'                                                },

    'starting/saving_state'           => { enter       => '_save_state',
                                           transitions => { _on_save_state_done          => 'starting/loading_row',
                                                            _on_save_state_error         => 'stopped'                          } },

    'starting/loading_row'            => { enter       => '_load_row',
                                           transitions =>  { _on_load_row_done           => 'starting/updating_stats',
                                                             _on_load_row_error          => 'stopping/clearing_runtime_row'    } },

    'starting/updating_stats'         => { enter       => '_incr_run_attempts',
                                           transitions =>  { _on_incr_run_attempts_done  => 'starting/searching_di',
                                                             _on_incr_run_attempts_error => 'stopping/clearing_runtime_row'} },

    'starting/searching_di'           => { enter       => '_search_di',
                                           transitions => { _on_search_di_done           => 'starting/saving_runtime_row',
                                                            _on_search_di_error          => 'stopping/clearing_runtime_row'     } },

    'starting/saving_runtime_row'     => { enter       => '_save_runtime_row',
                                           transitions => { _on_save_runtime_row_done    => 'starting/deleting_cmd',
                                                            _on_save_runtime_row_error   => 'stopping/clearing_runtime_row'  },
                                           ignore      => ['_on_save_runtime_row_result']                                         },

    'starting/deleting_cmd'           => { enter       => '_delete_cmd',
                                           transitions => { _on_delete_cmd_done          => 'starting/calculating_attrs',
                                                            _on_delete_cmd_error         => 'starting/calculating_attrs'        } },

    'starting/calculating_attrs'      => { enter       => '_calculate_attrs',
                                           transitions => { _on_calculate_attrs_done     => 'starting/setting_heavy_mark'       } },

    'starting/setting_heavy_mark'     => { enter       => '_set_heavy_mark',
                                           transitions => { _on_set_heavy_mark_done      => 'starting/untaring_os_image',
                                                            _on_set_heavy_mark_error     => 'starting/delaying'                 } },

    'starting/delaying'               => { transitions => { _on_cmd_go_heavy             => 'starting/setting_heavy_mark'       } },

    'starting/untaring_os_image'      => { enter       => '_untar_os_image',
                                           transitions => { _on_untar_os_image_done      => 'starting/placing_os_image',
                                                            _on_untar_os_image_eagain    => 'starting/delaying_untar_os_image',
                                                            _on_untar_os_image_error     => 'stopping/releasing_untar_lock'     } },

    'starting/delaying_untar_os_image'=> { enter       => '_delay_untar_os_image',
                                           transitions => { on_hkd_stop                  => 'stopping/releasing_untar_lock',
                                                            _on_delay_untar_os_image_done=> 'starting/setting_heavy_mark'       },
                                           leave       => '_abort_call_after'                                                     },

    'starting/placing_os_image'       => { enter       => '_place_os_image',
                                           transitions => { _on_place_os_image_done      => 'starting/detecting_os_image_type',
                                                            _on_place_os_image_error     => 'stopping/releasing_untar_lock'     } },

    'starting/detecting_os_image_type'=> { enter       => '_detect_os_image_type',
                                           transitions => { _on_detect_os_image_type_done  => 'starting/killing_old_lxc',
                                                            _on_detect_os_image_type_error => 'stopping/releasing_untar_lock'   } },

    'starting/killing_old_lxc'        => { enter       => '_kill_lxc',
                                           transitions => { _on_kill_lxc_done            => 'starting/unlinking_iface',
                                                            _on_kill_lxc_error           => 'zombie/beating_to_death'          } },

    'starting/unlinking_iface'        => { enter       => '_unlink_iface',
                                           transitions => { _on_unlink_iface_done        => 'starting/destroying_old_lxc',
                                                            _on_unlink_iface_error       => 'zombie/beating_to_death'          } },

    'starting/destroying_old_lxc'     => { enter       => '_destroy_lxc',
                                           transitions => { _on_destroy_lxc_done         => 'starting/allocating_os_overlayfs' } },

    'starting/allocating_os_overlayfs'=> { enter       => '_allocate_os_overlayfs',
                                           transitions => { _on_allocate_os_overlayfs_done  => 'starting/allocating_os_rootfs',
                                                            _on_allocate_os_overlayfs_error => 'stopping/releasing_untar_lock' } },

    'starting/allocating_os_rootfs'   => { enter       => '_allocate_os_rootfs',
                                           transitions => { _on_allocate_os_rootfs_done  => 'starting/allocating_home_fs',
                                                            _on_allocate_os_rootfs_error => 'stopping/unmounting_filesystems' } },

    'starting/allocating_home_fs'     => { enter       => '_allocate_home_fs',
                                           transitions => { _on_allocate_home_fs_done    => 'starting/creating_lxc',
                                                            _on_allocate_home_fs_error   => 'stopping/unmounting_filesystems' } },

    'starting/creating_lxc'           => { enter       => '_create_lxc',
                                           transitions => { _on_create_lxc_done          => 'starting/removing_old_fw_rules',
                                                            _on_create_lxc_error         => 'stopping/destroying_lxc'         } },

    'starting/removing_old_fw_rules'  => { enter       => '_remove_fw_rules',
                                           transitions => { _on_remove_fw_rules_done     => 'starting/configuring_lxc',
                                                            _on_remove_fw_rules_error    => 'zombie/beating_to_death',        } },

    'starting/configuring_lxc'        => { enter       => '_configure_lxc',
                                           transitions => { _on_configure_lxc_done       => 'starting/running_prestart_hook',
                                                            _on_configure_lxc_error      => 'stopping/destroying_lxc'         } },

    'starting/running_prestart_hook'  => { enter       => '_run_prestart_hook',
                                           transitions => { _on_run_hook_done            => 'starting/setting_fw_rules',
                                                            _on_run_hook_error           => 'stopping/running_poststop_hook'  } },

    'starting/setting_fw_rules'       => { enter       => '_set_fw_rules',
                                           transitions => { _on_set_fw_rules_done        => 'starting/launching',
                                                            _on_set_fw_rules_error       => 'stopping/removing_fw_rules'      } },

    'starting/launching'              => { enter       => '_start_lxc',
                                           transitions => { _on_start_lxc_done           => 'starting/waiting_for_vma',
                                                            _on_start_lxc_error          => 'stopping/killing_lxc'            } },

    'starting/waiting_for_vma'        => { enter       => '_start_vma_monitor',
                                           leave       => '_stop_vma_monitor',
                                           transitions => { _on_alive                    => 'running/saving_state',
                                                            _on_dead                     => 'stopping/stopping_lxc',
                                                            _on_goto_debug               => 'debugging/saving_state',
                                                            _on_stop_cmd                 => 'stopping/deleting_cmd',
                                                            on_hkd_stop                  => 'stopping/saving_state',
                                                            on_hkd_kill                  => 'stopping/killing_lxc',
                                                            _on_lxc_done                 => 'stopping/killing_lxc'            } },

    'running/saving_state'            => { enter       => '_save_state',
                                           transitions => { _on_save_state_done          => 'running/updating_stats',
                                                            _on_save_state_error         => 'stopping/saving_state'           },
                                           delay       => [qw(_on_lxc_done)]                                                    },

    'running/updating_stats'          => { enter       => '_incr_run_ok',
                                           transitions =>  { _on_incr_run_ok_done        => 'running/running_poststart_hook',
                                                             _on_incr_run_ok_error       => 'running/running_poststart_hook'  },
                                           delay       => [qw(_on_lxc_done)],
                                           ignore      => [qw(_on_incr_run_ok_result)]                                          },

    'running/running_poststart_hook'  => { enter       => '_run_poststart_hook',
                                           transitions => { _on_run_hook_done            => 'running/unsetting_heavy_mark',
                                                            _on_run_hook_error           => 'stopping/saving_state'           },
                                           delay       => [qw(_on_lxc_done)]                                                    },

    'running/unsetting_heavy_mark'    => { enter       => '_unset_heavy_mark',
                                           transitions => { _on_unset_heavy_mark_done    => 'running/monitoring'              } },

    'running/monitoring'              => { enter       => '_start_vma_monitor',
                                           leave       => '_stop_vma_monitor',
                                           transitions => { _on_cmd_stop                 => 'stopping/deleting_cmd',
                                                            on_hkd_stop                  => 'stopping/saving_state',
                                                            on_hkd_kill                  => 'stopping/killing_lxc',
                                                            _on_dead                     => 'stopping/stopping_lxc',
                                                            _on_goto_debug               => 'debugging/saving_state',
                                                            _on_lxc_done                 => 'stopping/killing_lxc'            } },

    'debugging/saving_state'          => { enter       => '_save_state',
                                           transitions => { _on_save_state_done          => 'debugging/unsetting_heavy_mark',
                                                            _on_save_state_error         => 'stopping/saving_state'           },
                                           delay       => [qw(_on_lxc_done)]                                                    },

    'debugging/unsetting_heavy_mark'  => { enter       => '_unset_heavy_mark',
                                           transitions => { _on_unset_heavy_mark_done    => 'debugging/waiting_for_vma'      } },

    'debugging/waiting_for_vma'       => { enter       => '_start_vma_monitor',
                                           leave       => '_stop_vma_monitor',
                                           transitions => { _on_alive                    => 'running/saving_state',
                                                            _on_cmd_stop                 => 'stopping/deleting_cmd',
                                                            on_hkd_stop                  => 'stopping/saving_state',
                                                            on_hkd_kill                  => 'stopping/killing_lxc',
                                                            _on_lxc_done                 => 'stopping/killing_lxc' },
                                           ignore      => [qw(_on_dead
                                                              _on_goto_debug)] },

    'stopping/deleting_cmd'           => { enter       => '_delete_cmd',
                                           transitions => { _on_delete_cmd_done          => 'stopping/saving_state'           } },

    'stopping/saving_state'           => { enter       => '_save_state',
                                           transitions => { _on_save_state_done          => 'stopping/setting_heavy_mark',
                                                            _on_save_state_error         => 'stopping/setting_heavy_mark'     } },

    'stopping/setting_heavy_mark'     => { enter       => '_set_heavy_mark',
                                           transitions => { _on_set_heavy_mark_done      => 'stopping/powering_off',
                                                            _on_set_heavy_mark_error     => 'stopping/delaying'               } },

    'stopping/delaying'               => { transitions => { _on_cmd_go_heavy             => 'stopping/setting_heavy_mark'     } },

    'stopping/powering_off'           => { enter       => '_poweroff',
                                           leave       => '_abort_all',
                                           transitions => { _on_rpc_poweroff_error       => 'stopping/stopping_lxc',
                                                            _on_lxc_done                 => 'stopping/killing_lxc',
                                                            _on_rpc_poweroff_result      => 'stopping/waiting_for_lxc_to_exit',
                                                            on_hkd_kill                  => 'stopping/killing_lxc' } },

    'stopping/waiting_for_lxc_to_exit'=> { enter       => '_set_state_timer',
                                           leave       => '_abort_all',
                                           transitions => { _on_lxc_done                 => 'stopping/killing_lxc',
                                                            _on_state_timeout            => 'stopping/stopping_lxc',
                                                            on_hkd_kill                  => 'stopping/killing_lxc'            } },

    'stopping/stopping_lxc'           => { enter       => '_stop_lxc',
                                           transitions => { _on_stop_lxc_done            => 'stopping/waiting_for_lxc_to_stop'},
                                           delay       => ['_on_lxc_done']                                                      },

    'stopping/waiting_for_lxc_to_stop'=> { enter       => '_set_state_timer',
                                           leave       => '_abort_all',
                                           transitions => { _on_lxc_done                 => 'stopping/killing_lxc',
                                                            _on_state_timeout            => 'stopping/killing_lxc',
                                                            on_hkd_kill                  => 'stopping/killing_lxc'            } },

    'stopping/killing_lxc'            => { enter       => '_kill_lxc',
                                           transitions => { _on_kill_lxc_done            => 'stopping/unlinking_iface',
                                                            _on_kill_lxc_error           => 'zombie/beating_to_death',
                                                            _on_dirty                    => 'dirty'                           },
                                           ignore      => ['_on_lxc_done',
                                                           'on_hkd_kill']                                                       },

    'stopping/unlinking_iface'        => { enter       => '_unlink_iface',
                                           transitions => { _on_unlink_iface_done        => 'stopping/removing_fw_rules',
                                                            _on_unlink_iface_error       => 'zombie/beating_to_death'         } },

    'stopping/removing_fw_rules'      => { enter       => '_remove_fw_rules',
                                           transitions => { _on_remove_fw_rules_done     => 'stopping/running_poststop_hook',
                                                            _on_remove_fw_rules_error    => 'zombie/beating_to_death'         } },

    'stopping/running_poststop_hook'  => { enter       => '_run_poststop_hook',
                                           transitions => { _on_run_hook_done            => 'stopping/destroying_lxc',
                                                            _on_run_hook_error           => 'stopping/destroying_lxc'         } },

    'stopping/destroying_lxc'         => { enter       => '_destroy_lxc',
                                           transitions => { _on_destroy_lxc_done         => 'stopping/unmounting_filesystems' } },

    'stopping/unmounting_filesystems' => { enter       => '_unmount_filesystems',
                                           transitions => { _on_unmount_filesystems_done  => 'stopping/releasing_untar_lock',
                                                            _on_unmount_filesystems_error => 'zombie/beating_to_death'        } },

    'stopping/releasing_untar_lock'   => { enter       => '_release_untar_lock',
                                           transitions => { _on_release_untar_lock_done  => 'stopping/clearing_runtime_row'   } },

    'stopping/clearing_runtime_row'   => { enter       => '_clear_runtime_row',
                                           transitions => { _on_clear_runtime_row_done   => 'stopped',
                                                            _on_clear_runtime_row_error  => 'zombie/beating_to_death'         } },

    'stopped'                         => { enter       => '_call_on_stopped'                                                    },

    'zombie/beating_to_death'         => { jump        => 'zombie/saving_state'                                                   },

    'zombie/saving_state'             => { enter       => '_save_state',
                                           transitions => { _on_save_state_done          => 'zombie/calculating_attrs',
                                                            _on_save_state_error         => 'zombie/calculating_attrs',       } },

    'zombie/calculating_attrs'        => { enter       => '_calculate_attrs',
                                           transitions => { _on_calculate_attrs_done     => 'zombie/stopping_lxc'            } },

    'zombie/stopping_lxc'             => { enter       => '_stop_lxc',
                                           transitions => { _on_stop_lxc_done            => 'zombie/waiting_for_lxc_to_stop' } },

    'zombie/waiting_for_lxc_to_stop'  => { enter       => '_wait_for_zombie_lxc',
                                           transitions => { _on_wait_for_zombie_lxc_done => 'zombie/killing_lxc'             } },

    'zombie/killing_lxc'              => { enter       => '_kill_lxc',
                                           transitions => { _on_kill_lxc_done            => 'zombie/unlinking_iface',
                                                            _on_kill_lxc_error           => 'zombie/unsetting_heavy_mark',
                                                            _on_dirty                    => 'dirty'                          } },

    'zombie/unlinking_iface'          => { enter       => '_unlink_iface',
                                           transitions => { _on_unlink_iface_done        => 'zombie/removing_fw_rules',
                                                            _on_unlink_iface_error       => 'zombie/unsetting_heavy_mark'    } },

    'zombie/removing_fw_rules'        => { enter       => '_remove_fw_rules',
                                           transitions => { _on_remove_fw_rules_done     => 'zombie/destroying_lxc',
                                                            _on_remove_fw_rules_error    => 'zombie/unsetting_heavy_mark'    } },

    'zombie/destroying_lxc'           => { enter       => '_destroy_lxc',
                                           transitions => { _on_destroy_lxc_done         => 'zombie/unmounting_filesystems',
                                                            _on_destroy_lxc_error        => 'zombie/unmounting_filesystems'  } },

    'zombie/unmounting_filesystems'   => { enter       => '_unmount_filesystems',
                                           transitions => { _on_unmount_filesystems_done => 'zombie/releasing_untar_lock',
                                                            _on_unmount_filesystems_error=> 'zombie/unsetting_heavy_mark'    } },

    'zombie/releasing_untar_lock'     => { enter       => '_release_untar_lock',
                                           transitions => { _on_release_untar_lock_done  => 'zombie/clearing_runtime_row'    } },

    'zombie/clearing_runtime_row'     => { enter       => '_clear_runtime_row',
                                           transitions => { _on_clear_runtime_row_done   => 'stopped',
                                                            _on_clear_runtime_row_error  => 'zombie/unsetting_heavy_mark'    } },

    'zombie/unsetting_heavy_mark'     => { enter       => '_unset_heavy_mark',
                                           transitions => { _on_unset_heavy_mark_done    => 'zombie'                         } },

    'zombie'                          => { enter       => '_set_state_timer',
                                           leave       => '_abort_all',
                                           transitions => { _on_state_timeout            => 'zombie/killing_lxc',
                                                            on_hkd_kill                  => 'stopped'                        },
                                           ignore      => [qw(on_hkd_stop)]                                                    },

    'dirty'                           => { transitions => { on_hkd_stop                  => 'stopped',
                                                            on_hkd_kill                  => 'stopped'                        } },


    '__any__'                         => { delay_once  => [qw( _on_cmd_stop
                                                               _on_lxc_done
                                                               on_hkd_stop
                                                               on_hkd_kill )],                                                 };

sub _on_cmd_start :OnState('__any__') { shift->_maybe_callback('on_delete_cmd') }


sub _mkpath {
    my ($path, $mask) = @_;
    $mask ||= 0755;
    my @dirs;
    my @parts = File::Spec->splitdir(File::Spec->rel2abs($path));
    while (@parts) {
        my $dir = File::Spec->join(@parts);
        if (-d $dir) {
            -d $_ or mkdir $_, $mask or return for @dirs;
            return -d $path;
        }
        unshift @dirs, $dir;
        pop @parts;
    }
    return;
}

sub _calculate_attrs {
    my $self = shift;
    $self->{lxc_name} = "qvd-$self->{vm_id}";

    $self->{netmask_len} = $self->netmask_len;
    $self->{gateway} = $self->_cfg('vm.network.gateway');

    my $rootfs_parent = $self->_cfg('path.storage.rootfs');
    $rootfs_parent =~ s|/*$|/|;
    $self->{os_rootfs_parent} = $rootfs_parent;
    $self->{os_rootfs} = "$rootfs_parent$self->{vm_id}-fs";

    if (defined $self->{di_path}) {
        # this sub is called with just the vm_id loaded into the
        # object when reaping zombie containers
        my $basefs_parent = $self->_cfg('path.storage.basefs');
        $basefs_parent =~ s|/*$|/|;
        # note that os_basefs may be changed later from
        # _detect_os_image_type!
        $self->{os_basefs} = "$basefs_parent/$self->{di_path}";
        $self->{os_basefs_lockfn} = "$basefs_parent/lock.$self->{di_path}";

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

    if ($debug) {
        for (qw(di_path os_basefs os_overlayfs os_overlayfs_old os_rootfs_parent os_rootfs
                home_fs home_fs_mnt iface netmask_len gateway)) {
            my $path = $self->{$_} // '<undef>';
            $self->_debug("attribute $_: $path");
            DEBUG "Attribute $_: $path";
        }
    }

    $self->_on_calculate_attrs_done;
}

sub _untar_os_image {
    my $self = shift;
    my $image_path = $self->_cfg('path.storage.images') . '/' . $self->{di_path};
    $debug and $self->_debug("image_path=$image_path");
    unless (-f $image_path) {
        ERROR "Image '$image_path' attached to VM '$self->{vm_id}' does not exist on disk";
        return $self->_on_untar_os_image_error;
    }

    my $basefs = $self->{os_basefs};
    my $lockfn = $self->{os_basefs_lockfn};
    my $lock;
    unless (open $lock, '>>', $lockfn) {
        ERROR "Unable to create or open lock file '$lockfn': $!";
        return $self->_on_untar_os_image_error;
    }
    $debug and $self->_debug("lock is $lock");
    unless (flock($lock, Fcntl::LOCK_EX()|Fcntl::LOCK_NB())) {
        if ($! == POSIX::EAGAIN()) {
            DEBUG "Waiting for lock $lockfn...";
            return $self->_on_untar_os_image_eagain
        }
        ERROR "Unable to acquire lock for $lockfn: $!";
        return $self->_on_untar_os_image_error;
    }

    if (-d $basefs) {
        DEBUG 'Image already untarred';
        return $self->_on_untar_os_image_done;
    }

    $self->{untar_lock} = $lock;

    my $tmp = $self->_cfg('path.storage.basefs') . "/untar-$$-" . rand(100000);
    $tmp++ while -e $tmp;

    if ($self->_cfg('vm.lxc.unionfs.type') eq 'btrfs') {
        if (_run($self->_cfg('command.btrfs'),
                 'subvolume', 'create', $tmp)) {
            ERROR "Unable to create btrfs subvolume at '$tmp'";
            return $self->_on_untar_os_image_error;
        }
    }
    else {
        unless (_mkpath $tmp) {
            ERROR "Unable to create directory '$tmp': $!";
            return $self->_on_untar_os_image_error;
        }
    }

    $self->{os_basefs_tmp} = $tmp;

    INFO "Untarring image to '$tmp'";
    my @cmd = ( $self->_cfg('command.tar'),
                'x',
                -f => $image_path,
                -C => $tmp );
    push @cmd, '-z' if $image_path =~ /\.(?:tgz|gz)$/;
    push @cmd, '-j' if $image_path =~ /\.(?:tbz|bz2)$/;
    push @cmd, '-J' if $image_path =~ /\.(?:txz|xz)$/;

    $self->_run_cmd(\@cmd);
}

sub _delay_untar_os_image {
    my $self = shift;
    $self->_maybe_callback(on_heavy => 0);
    $self->_call_after($self->_cfg('internal.hkd.lxc.acquire.untar.lock.delay'), '_on_delay_untar_os_image_done')
}

sub _release_untar_lock {
    my $self = shift;
    if ($self->{untar_lock}) {
        DEBUG "Releasing untar lock";
        delete $self->{untar_lock};
    }
    return $self->_on_release_untar_lock_done
}

sub _place_os_image {
    my $self = shift;
    my $basefs = $self->{os_basefs};
    if (-d $basefs) {
        DEBUG "image already on place";
        return $self->_on_place_os_image_done;
    }
    my $tmp = $self->{os_basefs_tmp};
    INFO "Renaming '$tmp' to '$basefs'";
    rename $tmp, $basefs
        or ERROR "Rename of '$tmp' to '$basefs' failed: $!";
    unless (-d $basefs) {
        ERROR "'$basefs' does not exist or is not a directory";
        return $self->_on_place_os_image_error;
    }
    DEBUG "OS placement done, releasing untar lock";
    delete $self->{untar_lock};
    $self->_on_place_os_image_done;
}

sub _detect_os_image_type {
    my $self = shift;
    my $basefs = $self->{os_basefs};
    if (-d "$basefs/sbin/") {
        # FIXME: improve autodetection logic
        $debug and $self->_debug("os image is of type basic");
        DEBUG 'OS image is of type basic';
    }
    elsif (-d "$basefs/rootfs/sbin/") {
        $self->{os_meta} = $basefs;
        $self->{os_base_subdir} = '/rootfs';
        $debug and $self->_debug("os image is of type extended");
        DEBUG 'OS image is of type extended';
    }
    else {
        ERROR "sbin not found at $basefs/sbin or at $basefs/rootfs/sbin";
        return $self->_on_detect_os_image_type_error;
    }
    return $self->_on_detect_os_image_type_done;
}

sub _allocate_os_overlayfs {
    my $self = shift;
    my $overlayfs = $self->{os_overlayfs};
    my $overlayfs_old =  $self->{os_overlayfs_old};
    my $unionfs_type = $self->_cfg('vm.lxc.unionfs.type');

    if (-d $overlayfs) {
        if (defined $overlayfs_old) {
            if ($unionfs_type eq 'btrfs') {
                if (_run($self->_cfg('command.btrfs'),
                             'subvolume', 'delete', $overlayfs)) {
                    ERROR "Unable to delete old btrfs snapshot at $overlayfs";
                    return $self->_on_allocate_os_overlayfs_error;
                }
                DEBUG "Old btrfs snapshot at $overlayfs removed";
            }
            else {
                $debug and $self->_debug("deleting old overlay directory");
                unless (rename $overlayfs, $overlayfs_old) {
                    ERROR "Unable to move old '$overlayfs' out of the way to '$overlayfs_old'";
                    return $self->_on_allocate_os_overlayfs_error;
                }
                DEBUG "Renamed old overlayfd '$overlayfs' to '$overlayfs_old'";
            }
            if (-d $overlayfs) {
                ERROR "Overlay directory still exists at '$overlayfs'";
                return $self->_on_allocate_os_overlayfs_error;
            }
        }
        else {
            $debug and $self->_debug("reusing existing overlay directory");
            DEBUG 'Reusing existing overlay directory';
            # TODO: add some sanity checks here for btrfs!
            return $self->_on_allocate_os_overlayfs_done
        }
    }
    if ($unionfs_type eq 'btrfs') {
        if (_run($self->_cfg('command.btrfs'),
                 'subvolume', 'snapshot',
                 $self->{os_basefs}, $overlayfs)) {
            ERROR "Unable to create btrfs snapshort at $overlayfs";
            $self->_on_allocate_os_overlayfs_error;
        }
        DEBUG "Btrfs snapshort created at $overlayfs";
    }
    else {
        unless (_mkpath $overlayfs) {
            ERROR "Unable to create overlay file system '$overlayfs': $!";
            return $self->_on_allocate_os_overlayfs_error;
        }
        DEBUG "overlay directory $overlayfs created";
    }
    $self->_on_allocate_os_overlayfs_done;

}

sub _allocate_os_rootfs {
    my $self = shift;

    my $basefs    = $self->{os_basefs}    . ($self->{os_base_subdir} // '');
    my $overlayfs = $self->{os_overlayfs} . ($self->{os_base_subdir} // '');

    my $rootfs = $self->{os_rootfs};
    unless (_mkpath $rootfs) {
        ERROR "Unable to create directory '$rootfs'";
        return $self->_on_allocate_os_rootfs_error;
    }
    _run($self->_cfg('command.umount'), $rootfs); # just in case!
    $debug and $self->_debug("rootfs: $rootfs, rootfs_parent: $self->{os_rootfs_parent}");
    DEBUG "rootfs: '$rootfs', rootfs_parent: '$self->{os_rootfs_parent}'";
    if ((stat $rootfs)[0] != (stat $self->{os_rootfs_parent})[0]) {
        ERROR "A file system is already mounted on top of $rootfs";
        return $self->_on_allocate_os_rootfs_error;
    }

    my $unionfs_type = $self->_cfg('vm.lxc.unionfs.type');
    DEBUG "Unionfs type: '$unionfs_type'";


    given ($unionfs_type) {
        when('overlayfs') {
            if(_run($self->_cfg('command.modprobe'), "overlayfs")) {
                WARN "Failed to load aufs kernel module. Mounting will probably fail.";
            }
            # mount -t overlayfs -o rw,uppderdir=x,lowerdir=y overlayfs /mount/point
            if (_run($self->_cfg('command.mount'),
                     -t => 'overlayfs',
                     -o => "rw,upperdir=$overlayfs,lowerdir=$basefs", "overlayfs", $rootfs)) {
                ERROR "Unable to mount overlayfs (code: " . ($?>>8) . ")";
                return $self->_on_allocate_os_rootfs_error;
            }
        }
        when('aufs') {
            if(_run($self->_cfg('command.modprobe'), "aufs")) {
                WARN "Failed to load aufs kernel module. Mounting will probably fail.";
            }

            if (_run($self->_cfg('command.mount'),
                -t => 'aufs',
                -o => "br:$overlayfs:$basefs=ro", "aufs", $rootfs)) {
                ERROR "Unable to mount aufs (code: " . ($?>>8) . ")";
                return $self->_on_allocate_os_rootfs_error;
            }
        }
        when ('unionfs-fuse') {
            if(_run($self->_cfg('command.modprobe'), "fuse")) {
                ERROR "Failed to load fuse kernel module. Mounting will probably fail.";
            }

            if (_run($self->_cfg('command.unionfs-fuse'),
                -o => 'cow',
                -o => 'max_files=32000',
                -o => 'suid',
                -o => 'dev',
                -o => 'allow_other',
                "$overlayfs=RW:$basefs=RO", $rootfs)) {
                ERROR "Unable to mount unionfs-fuse (code: " . ($? >> 8) . ")";
                return $self->_on_allocate_os_rootfs_error;
            }
        }
        when ('bind') {
            if (_run($self->_cfg('command.mount'),
                '--bind', $basefs, $rootfs)) {
                ERROR "Unable to mount bind '$basefs' into '$rootfs', mount rc: " . ($? >> 8);
                return $self->_on_allocate_os_rootfs_error;
            }
            if ($self->_cfg('vm.lxc.unionfs.bind.ro')) {
                if (_run($self->_cfg('command.mount'),
                    -o => 'remount,ro', $rootfs)) {
                    ERROR "Unable to remount bind mount '$rootfs' as read-only, mount rc: ". ($? >> 8);
                    return $self->_on_allocate_os_rootfs_error;
                }
            }
        }
        when ('btrfs') {
            if (_run($self->_cfg('command.mount'),
                     '--bind', $overlayfs, $rootfs)) {
                ERROR "Unable to mount bind '$overlayfs' into '$rootfs', mount rc: " . ($? >> 8);
                return $self->_on_allocate_os_rootfs_error;
            }
        }
        default {
            ERROR "Unsupported unionfs type '$unionfs_type'";
            return $self->_on_allocate_os_rootfs_error;
        }
    }
    $self->_on_allocate_os_rootfs_done;
}

sub _allocate_home_fs {
    my $self = shift;

    my $homefs = $self->{home_fs};
    defined $homefs or return $self->_on_allocate_home_fs_done;

    unless (_mkpath $homefs) {
        ERROR "Unable to create directory '$homefs'";
        return $self->_on_allocate_home_fs_error;
    }
    my $mount_point = $self->{home_fs_mnt};
    unless (_mkpath $mount_point) {
        ERROR "Unable to create directory '$mount_point'";
        return $self->_on_allocate_home_fs_error;
    }

    # let lxc mount the home file system for us
    $self->{home_fstab} = "$homefs $mount_point none defaults,bind";
    DEBUG "Setting up homefs fstab entry as '$homefs $mount_point none defaults,bind'";
    #    if (system $self->_cfg('command.mount'), '--bind', $homefs, $mount_point) {
    #        ERROR "unable to bind $homefs into $mount_point, mount failed (code: ".($?>>8).")";
    #        return $self->_on_allocate_os_rootfs_error;
    #    }

    $self->_on_allocate_home_fs_done
}

sub _create_lxc {
    my $self = shift;
    my $lxc_name = $self->{lxc_name};

    my ($fh, $fn) = tempfile(UNLINK => 0);
    $debug and $self->_debug("saving lxc configuration to $fn");
    DEBUG "Saving lxc configuration to '$fn'";
    my $bridge = $self->_cfg('vm.network.bridge');
    my $console;
    if ($self->_cfg('vm.serial.capture')) {
        my $captures_dir = $self->_cfg('path.serial.captures');
        mkdir $captures_dir, 0700 or WARN "mkdir: '$captures_dir': $!";
        if (-d $captures_dir) {
            my @t = gmtime; $t[5] += 1900; $t[4] += 1;
            my $ts = sprintf("%04d-%02d-%02d-%02d:%02d:%2d-GMT0", @t[5,4,3,2,1,0]);
            $console = "$captures_dir/capture-$self->{name}-$ts.txt";
            DEBUG "Console output will be saved in '$console'";
        }
        else {
            ERROR "Captures directory '$captures_dir' does not exist";
            return $self->_on_create_lxc_error;
        }
    }
    else {
        $console = '/dev/null';
        DEBUG 'Console output will not be saved';
    }

    my $iface = $self->{iface};
    DEBUG "Local endpoint of the network device, connected to the bridge '$bridge': '$iface'";

    my $lxc_version = $self->_cfg('command.version.lxc');

    # FIXME: make this template-able or configurable in some way
    print $fh <<EOC;
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
        print $fh <<EOC;
lxc.network.ipv4 = $self->{ip}/$self->{netmask_len}
EOC
        if ($lxc_version >= 0.8) {
            print $fh <<EOC;
lxc.network.ipv4.gateway = $self->{gateway}
EOC
        }
    }

    print $fh, $self->_cfg('internal.vm.lxc.conf.extra'), "\n";
    close $fh;

    $self->_run_cmd([$self->_cfg('command.lxc-create'),
                     -n => $lxc_name,
                     -f => $fn,
                     ($lxc_version >= 0.9 ? (-B => 'dir') : ())
                     ]);
}

sub _configure_lxc {
    # FIXME: anything to do here?
    shift->_on_configure_lxc_done
}

sub _start_lxc {
    my $self = shift;
    $self->{lxc_pid} = $self->_run_cmd([$self->_cfg('command.lxc-start'), -n => $self->{lxc_name}],
                                       ignore_errors => 1,
                                       on_done => sub {
                                           delete $self->{lxc_pid};
                                           $self->_on_lxc_done;
                                       });
    $self->{vm_pid} = $self->{lxc_pid}; # this is the field that goes into the database
    $self->_on_start_lxc_done;
}

sub _stop_lxc {
    my $self = shift;
    $self->_run_cmd([$self->_cfg('command.lxc-stop'), -n => $self->{lxc_name}],
                    kill_after => $self->_cfg('internal.hkd.command.timeout.lxc-stop'),
                    ignore_errors => 1);

    #_run($self->_cfg('command.lxc-stop'), -n => $self->{lxc_name});
    #$self->_on_stop_lxc_done;
}

sub _wait_for_zombie_lxc {
    # FIXME: implement me!
    shift->_on_wait_for_zombie_lxc_done
}

sub _kill_lxc {
    my $self = shift;

    if ($self->_cfg("internal.hkd.lxc.does.not.cleanup") and $self->state =~ /^(?:stopping|zombie)\b/) {
        $debug and $self->_debug("making machine dirty at _kill_lxc because internal.hkd.lxc.does.not.cleanup is set");
        return $self->_on_dirty;
    }

    my @pids;
    my $cgroup = $self->_cfg('path.cgroup');
    my $fn = "$cgroup/$self->{lxc_name}/cgroup.procs";
    if (open my $fh, '<', $fn) {
        chomp(@pids = <$fh>);
    }
    else {
        $debug and $self->_debug("unable to open $fn: $!");
        ERROR "Unable to open '$fn': $!";
    }
    my $lxc_pid = $self->{lxc_pid};
    push @pids, $lxc_pid if defined $lxc_pid;
    if (@pids) {
        $debug and $self->_debug("killing zombie processes and then trying again, pids: @pids");
        DEBUG "Killing zombie processes and then trying again, PIDs: @pids";
        if ($self->{killer_count}++ > $self->_cfg('internal.hkd.lxc.killer.retries')) {
            $debug and $self->_debug("too many retries, no more killing, peace!");
            WARN "Too many retries when killing cointainer processes: @pids";
            $self->_abort_cmd($lxc_pid);
            return $self->_on_kill_lxc_error;
        }
        kill KILL => @pids;
        $self->_call_after(2 => '_kill_lxc');
    }
    else {
        $debug and $self->_debug("all processes killed");
        DEBUG "All processes killed";
        return $self->_on_kill_lxc_done;
    }
}

sub _destroy_lxc {
    my $self = shift;
    $self->_run_cmd([$self->_cfg('command.lxc-destroy'), -n => $self->{lxc_name}],
                    ignore_errors => 1);
}

sub _unlink_iface {
    my $self = shift;
    # FIXME: check that the interface has been really removed or return error
    $self->_run_cmd(['ip', 'link', 'del', $self->{iface}],
                    ignore_errors => 1);
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
            return $self->_unmount_filesystem($next);
        }
        else {
            $debug and $self->_debug("Some filesystems could not be unmounted: @mnts");
            ERROR sprintf 'Some filesystems could not be unmounted: %s', join ', ', @mnts;
            delete $self->{unmounted};
            return $self->_on_unmount_filesystems_error;
        }
    }
    else {
        $debug and $self->_debug("No filesystem mounted at $rootfs found");
        DEBUG "No filesystem mounted at '$rootfs' found";
    }
    delete $self->{unmounted};
    $self->_on_unmount_filesystems_done
}

sub _unmount_filesystem {
    my ($self, $mnt) = @_;
    $self->_run_cmd([$self->_cfg('command.umount'), $mnt],
                    timeout => $self->_cfg('internal.hkd.lxc.killer.umount.timeout'),
                    ignore_errors => 1,
                    on_done => '_unmount_filesystems');
}

sub _hook_args {
    my $self = shift;
    map { $_ => $self->{$_} } qw( use_overlay
                                  os_meta
                                  mac
                                  name
                                  ip
                                  os_rootfs
                                  os_overlayfs
                                  lxc_name );
}

sub _run_hook {
    my ($self, $name) = @_;
    my $meta = $self->{os_meta};
    if (defined $meta) {
        my $hook = "$meta/hooks/$name";
        if (-f $hook) {
            my @args = ( id    => $self->{vm_id},
                         hook  => $name,
                         state => $self->_main_state,
                         $self->_hook_args );

            $debug and $self->_debug("running hook $hook for $name");
            DEBUG "Running hook '$hook' for '$name'";
            return $self->_run_cmd([$hook => @args],
                                   save_old_watcher => 1);
        } else {
            WARN "Hook '$hook' for '$name' not found";
        }
    }
    $debug and $self->_debug("no hooks for $name");
    DEBUG "No hooks for '$name'";
    $self->_on_run_hook_done;
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
