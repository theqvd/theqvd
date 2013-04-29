package QVD::HKD::VMHandler::KVM;

BEGIN { *debug = \$QVD::HKD::VMHandler::debug }
our $debug;

use strict;
use warnings;
use 5.010;

use POSIX;
use AnyEvent;
use AnyEvent::Util;
use QVD::Log;

use parent qw(QVD::HKD::VMHandler);

use Class::StateMachine::Declarative
    __any__  => { delay => [qw(on_hkd_stop
                               on_hkd_kill)],
                  ignore => [qw(_on_cmd_start)] },

    new      => { transitions => { _on_cmd_start        => 'starting',
                                   _on_cmd_catch_zombie => 'zombie' } },

    starting => { advance => '_on_done',
                  delay => [qw(on_hkd_stop
                               on_hkd_kill)],
                  substates => [ saving_state   => { enter => '_save_state',
                                                     transitions => { _on_error => 'stopped' } },

                                 db             => { transitions => { _on_error => 'stopping/db' },
                                                     substates => [ deleting_cmd       => { enter => '_delete_cmd_busy',
                                                                                            on => { _on_error => '_on_done' } },
                                                                    loading_row        => { enter => '_load_row' },
                                                                    searching_di       => { enter => '_search_di' },
                                                                    calculating_attrs  => { enter => '_calculate_attrs' },
                                                                    saving_runtime_row => { enter => '_save_runtime_row' },
                                                                    updating_stats     => { enter => '_incr_run_attempts' } ] },

                                 clean_old       => { transitions => { _on_error => 'zombie' },
                                                      substates => [ removing_fw_rules => { enter => '_remove_fw_rules' } ] },

                                 heavy           => { enter => '_set_heavy_mark' },

                                 setup           => { transitions => { _on_error   => 'stopping/cleanup',
                                                                       on_hkd_stop => 'stopping/cleanup',
                                                                       on_hkd_kill => 'stopping/cleanup' },
                                                      substates => [ allocating_os_disk    => { enter => '_allocate_os_disk' },
                                                                     allocating_user_disk  => { enter => '_allocate_user_disk' },
                                                                     allocating_tap        => { enter => '_allocate_tap' },
                                                                     running_prestart_hook => { enter => '_run_prestart_hook' },
                                                                     setting_fw_rules      => { enter => '_set_fw_rules' },
                                                                     enabling_iface        => { enter => '_enable_iface' },
                                                                     launching             => { enter => '_start_kvm' } ] },

                                 waiting_for_vma => { enter => '_start_vma_monitor',
                                                      transitions => { _on_alive      => 'running',
                                                                       _on_dead       => 'stopping/stop',
                                                                       _on_cmd_stop   => 'stopping/cmd',
                                                                       _on_kvm_done   => 'stopping/cleanup',
                                                                       on_hkd_stop    => 'stopping/stop',
                                                                       on_hkd_kill    => 'stopping/cleanup',
                                                                       _on_goto_debug => 'debugging' } } ] },
    running => { advance => '_on_done',
                 delay => [qw(_on_kvm_done)],
                 transitions => { _on_error => 'stopping/stop' },
                 substates => [ saving_state           => { enter => '_save_state' },
                                updating_stats         => { enter => '_incr_run_ok' },
                                running_poststart_hook => { enter => '_run_poststart_hook' },
                                unsetting_heavy_mark   => { enter => '_unset_heavy_mark' },
                                monitoring             => { enter => '_start_vma_monitor',
                                                            transitions => { _on_dead       => 'stopping/stop',
                                                                             _on_cmd_stop   => 'stopping/cmd',
                                                                             _on_kvm_done   => 'stopping/cleanup',
                                                                             on_hkd_stop    => 'stopping/stop',
                                                                             on_hkd_kill    => 'stopping/stop',
                                                                             _on_goto_debug => 'debugging' } } ] },

    debugging => { advance => '_on_done',
                   delay => [qw(_on_kvm_done)],
                   transitions => { _on_error => 'stopping/stop' },
                   substates => [ saving_state          => { enter => '_save_state' },
                                  unsetting_heavy_mark  => { enter => '_unset_heavy_mark' },
                                  waiting_for_vma       => { enter => '_start_vma_monitor',
                                                             ignore => [qw(_on_dead
                                                                           _on_goto_debug)],
                                                             transitions => { _on_alive    => 'running',
                                                                              _on_cmd_stop => 'stopping/cmd',
                                                                              _on_kvm_done => 'stopping/cleanup',
                                                                              on_hkd_stop  => 'stopping/stop',
                                                                              on_hkd_kill  => 'stopping/stop' } } ] },

    stopping => { advance => '_on_done',
                  delay => [qw(_on_kvm_done)],
                  substates => [ cmd      => { advance => '_on_error',
                                               substates => [ saving_state => { enter => '_save_state' },
                                                              deleting_cmd    => { enter => '_delete_cmd_busy' } ] },

                                 shutdown => { substates => [ saving_state    => { enter => '_save_state' },
                                                              heavy           => { enter => '_set_heavy_mark' },
                                                              shuttingdown    => { enter => '_shutdown',
                                                                                   transitions => { _on_error    => 'stop',
                                                                                                    _on_kvm_done => 'cleanup' } },
                                                              waiting_for_kvm => { enter => '_set_state_timer',
                                                                                   transitions => { _on_kvm_done      => 'cleanup',
                                                                                                    _on_state_timeout => 'stop' } } ] },
                                 stop     => { substates => [ saving_state => { enter => '_save_state' },
                                                              killing      => { enter => '_kill_kvm',
                                                                                transitions => { _on_error => 'cleanup' } },
                                                              waiting      => { enter => '_set_state_timer',
                                                                                transitions => { _on_kvm_done => 'cleanup',
                                                                                                 _on_state_timeout => 'zombie' } } ] },

                                 cleanup  => { substates => [ saving_state => { enter => '_save_state' },
                                                              removing_fw_rules     => { enter => '_remove_fw_rules' },
                                                              running_poststop_hook => { enter => '_run_prestart_hook' } ] },
                                 db => { enter => '_clear_runtime_row',
                                         transitions => { _on_error => 'zombie',
                                                          _on_done  => 'stopped' } } ] },

    stopped => { enter => '_on_stopped' },

    # TODO: improve the zombie handling
    zombie  => { advance => '_on_done',
                 delay => [qw(_on_kvm_done)],
                 ignore => [qw(on_hkd_stop)],
                 transitions => { _on_error => 'unsetting_heavy_mark' },
                 substates => [ saving_state          => { enter => 'save_state' },
                                calculating_attrs     => { enter => '_calculate_attrs' },
                                killing_kvm           => { enter => '_kill_kvm',
                                                           transitions => { on_error => 'removing_fw_rules' } },
                                waiting_for_kvm       => { enter => '_set_state_timer',
                                                           on => { _on_kvm_done      => '_on_done',
                                                                   _on_state_timeout => '_on_error' } },
                                removing_fw_rules    => { enter => '_remove_fw_rules' },
                                configuring_dhcpd    => { enter => '_rm_from_dhcpd' },
                                clearing_runtime_row => { enter => '_clear_runtime_row',
                                                          transitions => { _on_done => 'stopped' } },
                                unsetting_heavy_mark => { enter => '_unset_heavy_mark' },
                                idle                 => { enter => '_set_state_timer',
                                                          transitions => { _on_state_timeout => 'killing_kvm',
                                                                           on_hkd_kill       => 'stopped' } } ] };



# FIXME: move this out of here, maybe into a module:
use constant TUNNEL_DEV => '/dev/net/tun';
use constant STRUCT_IFREQ => "Z16 s";
use constant IFF_NO_PI => 0x1000;
use constant IFF_TAP => 2;
use constant TUNSETIFF => 0x400454ca;

sub _calculate_attrs {
    my $self = shift;
    $self->SUPER::_calculate_attrs;

    # TODO: move attribute calculation here!

    $self->_on_done
}



sub _allocate_tap {
    my $self = shift;
    eval {
        open my $tap_fh, '+<', TUNNEL_DEV() or LOGDIE "Can't open ".TUNNEL_DEV().": $!";
        $self->{tap_fh} = $tap_fh;
        my $ifreq = pack(STRUCT_IFREQ(), 'qvdtap%d', IFF_TAP()|IFF_NO_PI());
        ioctl $tap_fh, TUNSETIFF(), $ifreq or LOGDIE "Can't create tap interface: $!";
        $self->{iface} = unpack STRUCT_IFREQ(), $ifreq;
    };
    if ($@) {
        ERROR "Allocating TAP device: $@";
        return $self->_on_error;
    }

    # FIXME: add the ebtables thing back again
    # $noded->_make_ebtables_tap_chain($tap_if);

    $self->_run_cmd('brctl',
                    addif => $self->_cfg('vm.network.bridge'),
                    $self->{iface});
}

sub _enable_iface {
    my $self = shift;
    $self->_run_cmd(ifconfig => $self->{iface}, 'up');
}

sub _allocate_os_disk {
    # FIXME: move attribute calculation to its proper place

    my $self = shift;
    my $image_path = $self->_cfg('path.storage.images') . '/' . $self->{di_path};
    unless (-f $image_path) {
        ERROR "Image '$image_path' attached to VM '$self->{vm_id}' does not exist on disk";
        return $self->_on_error;
    }
    unless ($self->{use_overlay}) {
        DEBUG "Image path for VM $self->{vm_id} set to $image_path";
        $self->{os_image_path} = $image_path;
        return $self->_on_done;
    }

    # FIXME: use a better policy for overlay allocation
    my $overlays_dir = $self->_cfg('path.storage.overlays');
    $overlays_dir =~ s|/*$|/|;
    my $overlay_path = $self->{os_image_path} = $overlays_dir . join('-', $self->{di_id}, $self->{vm_id}, 'overlay.qcow2');
    if (-f $overlay_path) {
        if ($self->_cfg('vm.overlay.persistent')) {
            DEBUG "Reusing persistent overlay '$overlay_path'";
            return $self->_on_done;
        }
        DEBUG "Discarding old overlay '$overlay_path'";
        unlink $overlay_path;
    }
    mkdir $overlays_dir, 0755 or DEBUG "mkdir 'overlays_dir' failed: $!";
    unless (-d $overlays_dir) {
        ERROR "Overlays directory '$overlays_dir' does not exist";
        return $self->_on_error;
    }

    # FIXME: use a relative path to the base image?
    #my $image_relative = File::Spec->abs2rel($image, $overlays_path);
    $self->_run_cmd('kvm-img',
                    'create',
                    -f => 'qcow2',
                    -b => $image_path,
                    $overlay_path);
}

sub _allocate_user_disk {
    my $self = shift;
    my $size = $self->{user_storage_size};
    unless (defined $size) {
        DEBUG 'Not allocating user storage';
        return $self->_on_done;
    }

    my $homes_dir = $self->_cfg('path.storage.homes');
    $homes_dir =~ s|/*$|/|;
    my $image_path = $self->{user_image_path} = "$homes_dir$self->{vm_id}-data.qcow2";
    if (-f $image_path) {
        DEBUG "Reusing user storage at '$image_path'";
        return $self->_on_done;
    }
    mkdir $homes_dir, 0755 or DEBUG "mkdir '$homes_dir' failed: $!";
    unless (-d $homes_dir) {
        ERROR "Homes directory '$homes_dir' does not exist";
        return $self->_on_error;
    }

    $self->_run_cmd('kvm-img',
                    'create',
                    -f => 'qcow2',
                    $image_path,
                    $size);
}

sub _start_kvm {
    my $self = shift;
    my @cmd = ( $self->_cfg('kvm'),
                -m => $self->{memory},
                -name => "qvd/$self->{vm_id}/$self->{name}");

    my $use_virtio = $self->_cfg('vm.kvm.virtio');
    my $nic = "nic,macaddr=$self->{mac},vlan=0";
    $nic .= ',model=virtio' if $use_virtio;
    push @cmd, (-net => $nic, -net => 'tap,vlan=0,fd=3');

    my $redirect_io = $self->_cfg('vm.serial.capture');
    if (defined $self->{serial_port}) {
        DEBUG "Using serial port '$self->{serial_port}'";
        push @cmd, -serial => "telnet::$self->{serial_port},server,nowait,nodelay";
        undef $redirect_io;
    } else {
        DEBUG 'No serial port';
    }

    if ($redirect_io) {
        my $captures_dir = $self->_cfg('path.serial.captures');
        mkdir $captures_dir, 0700 or WARN "mkdir: '$captures_dir': $!";
        if (-d $captures_dir) {
            my @t = gmtime; $t[5] += 1900; $t[4] += 1;
            my $ts = sprintf("%04d-%02d-%02d-%02d:%02d:%2d-GMT0", @t[5,4,3,2,1,0]);
            DEBUG "Redirecting I/O to '$captures_dir/capture-$self->{name}-$ts.txt'";
            push @cmd, -serial => "file:$captures_dir/capture-$self->{name}-$ts.txt";
        }
        else {
            ERROR "Captures directory '$captures_dir' does not exist";
        }
    }

    if ($self->{vnc_port}) {
        my $vnc_display = $self->{vnc_port} - 5900;
        my $vnc_opts = $self->_cfg('vm.vnc.opts');
        $vnc_display .= ",$vnc_opts" if $vnc_opts =~ /\S/;
        DEBUG "VNC is at display ':$vnc_display'";
        push @cmd, -vnc => ":$vnc_display";
    }
    else {
        DEBUG 'No VNC';
        push @cmd, '-nographic';
    }

    if ($self->{mon_port}) {
        push @cmd, -monitor, "telnet::$self->{mon_port},server,nowait,nodelay";
        DEBUG "Using monitor port '$self->{mon_port}'";
    } else {
        DEBUG 'No monitor port';
    }

    my $hda = "file=$self->{os_image_path},index=0,media=disk";
    $hda .= ',if=virtio,boot=on' if $use_virtio;
    push @cmd, -drive => $hda;

    if (defined $self->{user_image_path}) {
        my $hdb_index = $self->_cfg('vm.kvm.home.drive.index');
        my $hdb = "file=$self->{user_image_path},index=$hdb_index,media=disk";
        $hdb .= ',if=virtio' if $use_virtio;
        DEBUG "Using user storage '$self->{user_image_path}' ($hdb) for VM '$self->{vm_id}'";
        push @cmd, -drive => $hdb;
    }

    $self->_run_cmd({ save_pid_to => 'vm_pid',
                      ignore_erros => 1,
                      outlives_state => 1,
                      on_done => weak_method_callback($self, '_on_kvm_done'),
                      '>'  => '/dev/null',
                      '<'  => '/dev/null',
                      '2>' => '/dev/null',
                      on_prepare => sub {
                          # run VMs with low priority so in case the machine gets overloaded,
                          # the noded and hkd daemons do not become unresponsive.
                          # (PRIO_PGRP => 1, current PGRP => 0)
                          setpriority(1, 0, 10);

                          $^F = 3;
                          if (fileno $self->{tap_fh} == 3) {
                              POSIX::fcntl($self->{tap_fh}, F_SETFD, fcntl($self->{tap_fh}, F_GETFD, 0) & ~FD_CLOEXEC)
                                      or LOGDIE "fcntl failed: $!";
                          }
                          else {
                              POSIX::dup2(fileno $self->{tap_fh}, 3) or LOGDIE "dup2 failed: $!";
                          }
                      } },
                    @cmd);
    $self->_on_done;
}

sub _kill_kvm {
    my $self = shift;
    DEBUG "killing VM process";
    if ($self->_kill_cmd(TERM => $self->{vm_pid})) {
        $self->_on_done;
    }
    else {
        WARN "VM process has dissapeared";
        $self->_on_error;
    }
}

sub _run_hook {
    my ($self, $name) = @_;
    # FIXME: where are hooks stored when using images?
    $self->_on_done;
}

1;
