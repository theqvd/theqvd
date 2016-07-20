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
use Method::WeakCallback qw(weak_method_callback);

use parent qw(QVD::HKD::VMHandler);

use Class::StateMachine::Declarative
    __any__  => { ignore => [qw(_on_cmd_start on_expired _on_kvm_done)],
                  delay => [qw(on_hkd_kill
                               _on_cmd_stop)],
                  on => { on_hkd_stop => 'on_hkd_kill' } },

    new      => { transitions => { _on_cmd_start        => 'starting',
                                   _on_cmd_stop         => 'stopping/db',
                                   _on_cmd_catch_zombie => 'zombie' } },

    starting => { advance => '_on_done',
                  on => { on_hkd_kill => '_on_error' },
                  substates => [ db             => { transitions => { _on_error => 'stopping/db' },
                                                     substates => [ loading_row        => { enter => '_load_row' },
                                                                    searching_di       => { enter => '_search_di' },
                                                                    calculating_attrs  => { enter => '_calculate_attrs' },
                                                                    saving_runtime_row => { enter => '_save_runtime_row' },
                                                                    updating_stats     => { enter => '_incr_run_attempts' } ] },

                                 clean_old       => { transitions => { _on_error   => 'zombie/reap',
                                                                       on_hkd_kill => 'stopping/db' },
                                                      substates => [ removing_fw_rules => { enter => '_remove_fw_rules' } ] },

                                 heavy           => { enter => '_heavy_down',
                                                      transitions => { _on_error    => 'stopping/db',
                                                                       _on_cmd_stop => 'stopping/db' } },

                                 setup           => { transitions => { _on_error   => 'stopping/cleanup' },
                                                      substates => [ allocating_os_disk    => { enter => '_allocate_os_disk' },
                                                                     allocating_user_disk  => { enter => '_allocate_user_disk' },
                                                                     allocating_tap        => { enter => '_allocate_tap' },
                                                                     configuring_dhcp      => { enter => '_add_to_dhcpd' },
                                                                     running_prestart_hook => { enter => '_run_prestart_hook' },
                                                                     setting_fw_rules      => { enter => '_set_fw_rules' },
                                                                     enabling_iface        => { enter => '_enable_iface' },
                                                                     launching             => { enter => '_start_kvm' } ] },

                                 waiting_for_vma => { enter => '_start_vma_monitor',
                                                      transitions => { _on_alive      => 'running',
                                                                       _on_dead       => 'stopping/stop',
                                                                       _on_cmd_stop   => 'stopping/shutdown',
                                                                       _on_kvm_done   => 'stopping/cleanup',
                                                                       on_hkd_stop    => 'stopping/shutdown',
                                                                       on_hkd_kill    => 'stopping/stop',
                                                                       _on_goto_debug => 'debugging' } } ] },
    running => { advance => '_on_done',
                 delay => [qw(_on_kvm_done)],
                 transitions => { _on_error => 'stopping/stop' },
                 substates => [ saving_state           => { enter => '_save_state' },
                                updating_stats         => { enter => '_incr_run_ok' },
                                running_poststart_hook => { enter => '_run_poststart_hook' },
                                unheavy                => { enter => '_heavy_up' },
                                monitoring             => { enter => '_start_vma_monitor',
                                                            ignore => [qw(_on_alive)],
                                                            transitions => { _on_dead       => 'stopping/stop',
                                                                             _on_cmd_stop   => 'stopping/shutdown',
                                                                             _on_kvm_done   => 'stopping/cleanup',
                                                                             on_hkd_stop    => 'stopping/shutdown',
                                                                             on_hkd_kill    => 'stopping/stop',
                                                                             _on_goto_debug => 'debugging',
                                                                             on_expired     => 'expiring'} },
                              '(expiring)'             => { enter => '_expire',
                                                            transitions => { _on_done => 'monitoring' } } ] },

    debugging => { advance => '_on_done',
                   delay => [qw(_on_kvm_done)],
                   transitions => { _on_error => 'stopping/stop' },
                   substates => [ saving_state    => { enter => '_save_state' },
                                  unheavy         => { enter => '_heavy_up' },
                                  waiting_for_vma => { enter => '_start_vma_monitor',
                                                       ignore => [qw(_on_dead
                                                                     _on_goto_debug)],
                                                       transitions => { _on_alive    => 'running',
                                                                        _on_cmd_stop => 'stopping/stop',
                                                                        _on_kvm_done => 'stopping/cleanup',
                                                                        on_hkd_kill  => 'stopping/stop' } } ] },

    stopping => { advance => '_on_done',
                  transitions => { _on_error => 'zombie/reap' },
                  delay => [qw(_on_kvm_done)],
                  substates => [ shutdown => { transitions => { on_hkd_kill => 'stop' },
                                               substates => [ saving_state    => { enter => '_save_state' },
                                                              heavy           => { enter => '_heavy_down' },
                                                              shuttingdown    => { enter => '_shutdown',
                                                                                   transitions => { _on_error    => 'stop',
                                                                                                    _on_kvm_done => 'cleanup' } },
                                                              waiting_for_kvm => { enter => '_set_state_timer',
                                                                                   transitions => { _on_kvm_done      => 'cleanup',
                                                                                                    _on_state_timeout => 'stop' } } ] },
                                 stop     => { substates => [ saving_state    => { enter => '_save_state' },
                                                              heavy           => { enter => '_heavy_down' },
                                                              killing         => { enter => '_kill_kvm',
                                                                                   on => { _on_error => '_on_done' } },
                                                              waiting_for_kvm => { enter => '_set_state_timer',
                                                                                   transitions => { _on_kvm_done => 'cleanup',
                                                                                                    _on_state_timeout => 'zombie/reap' } } ] },

                                 cleanup  => { substates => [ saving_state          => { enter => '_save_state' },
                                                              heavy                 => { enter => '_heavy_down' },
                                                              removing_fw_rules     => { enter => '_remove_fw_rules' },
                                                              running_poststop_hook => { enter => '_run_prestart_hook' },
                                                              configuring_dhcpd     => { enter => '_rm_from_dhcpd' } ] },

                                 db => { enter => '_clear_runtime_row',
                                         transitions => { _on_error => 'zombie/db',
                                                          _on_done  => 'stopped' } } ] },

    stopped => { enter => '_on_stopped' },

    # TODO: improve the zombie handling
    zombie  => { advance => '_on_done',
                 delay => [qw(_on_kvm_done)],
                 ignore => [qw(on_hkd_stop)],
                 transitions => { on_hkd_kill => 'stopped' },
                 substates => [ config => { transitions => { _on_error => 'delaying' },
                                            substates => [ saving_state      => { enter => '_save_state',
                                                                                  on => { _on_error => '_on_done' } },
                                                           calculating_attrs => { enter => '_calculate_attrs',
                                                                                  transitions => { _on_error => 'delaying' } },
                                                           '(delaying)'      => { enter => '_set_state_timer',
                                                                                  transitions => { _on_timeout => 'config' } } ] },
                                reap   => { transitions => { _on_error       => 'delaying' },
                                            substates => [ saving_state      => { enter => '_save_state',
                                                                                  on => { _on_error => '_on_done' } },
                                                           heavy             => { enter => '_heavy_down' },
                                                           killing_kvm       => { enter => '_kill_kvm',
                                                                                  transitions => { _on_error => 'removing_fw_rules' } },
                                                           waiting_for_kvm   => { enter => '_set_state_timer',
                                                                                  on => { _on_kvm_done      => '_on_done',
                                                                                          _on_state_timeout => '_on_error' } },
                                                           removing_fw_rules => { enter => '_remove_fw_rules' },
                                                           unheavy           => { enter => '_heavy_up' },
                                                           configuring_dhcpd => { enter => '_rm_from_dhcpd' },
                                                           '(delaying)'      => { enter => '_set_state_timer',
                                                                                  transitions => { _on_state_timeout => 'reap'} } ] },
                                db     => { transitions => { _on_error => 'delaying' },
                                            substates => [ clearing_runtime_row => { enter => '_clear_runtime_row',
                                                                                     transitions => { _on_done => 'stopped' } },
                                                           '(delaying)'         => { enter => '_set_state_timer',
                                                                                     transitions => { _on_state_timeout => 'db'} } ] } ] };



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
    my @kvm_args = ( -m => $self->{memory},
                     -name => "qvd/$self->{vm_id}/$self->{name}");

    my $use_virtio = $self->_cfg('vm.kvm.virtio');
    my $nic = "nic,macaddr=$self->{mac},vlan=0";
    $nic .= ',model=virtio' if $use_virtio;
    push @kvm_args, (-net => $nic, -net => 'tap,vlan=0,fd=3');

    if ($self->_cfg('vm.serial.capture')) {
        if (defined $self->{serial_port}) {
            DEBUG "Using serial port '$self->{serial_port}'";
            push @kvm_args, -serial => "telnet::$self->{serial_port},server,nowait,nodelay";
        } else {
            DEBUG 'No serial port allocated, redirecting to file';
            my $fn = $self->_capture_fn('serial');
            push @kvm_args, -serial => "file:$fn" if defined $fn;
        }
    }

    if ($self->{vnc_port}) {
        my $vnc_display = $self->{vnc_port} - 5900;
        my $vnc_opts = $self->_cfg('vm.vnc.opts');
        $vnc_display .= ",$vnc_opts" if $vnc_opts =~ /\S/;
        DEBUG "VNC is at display ':$vnc_display'";
        push @kvm_args, -vnc => ":$vnc_display";
    }
    else {
        DEBUG 'No VNC';
        push @kvm_args, '-nographic';
    }

    if ($self->{mon_port}) {
        push @kvm_args, -monitor, "telnet::$self->{mon_port},server,nowait,nodelay";
        DEBUG "Using monitor port '$self->{mon_port}'";
    } else {
        DEBUG 'No monitor port';
    }

    my $hda = "file=$self->{os_image_path}";
    $hda =~ s/,/,,/g;
    $hda .= ',index=0,media=disk';
    $hda .= ',if=virtio,boot=on' if $use_virtio;
    $hda .= ',readonly' unless $self->{use_overlay};
    push @kvm_args, -drive => $hda;

    if (defined $self->{user_image_path}) {
        my $hdb_index = $self->_cfg('vm.kvm.home.drive.index');
        my $hdb = "file=$self->{user_image_path},index=$hdb_index,media=disk";
        $hdb .= ',if=virtio' if $use_virtio;
        DEBUG "Using user storage '$self->{user_image_path}' ($hdb) for VM '$self->{vm_id}'";
        push @kvm_args, -drive => $hdb;
    }

    my $cpus = $self->_cfg('vm.kvm.cpus');
    push @kvm_args, -smp => "cpus=$cpus";

    my $hv_out = $self->_hypervisor_output_redirection;
    DEBUG "VM lock fd is ".fileno($self->{vm_lock_fh});
    $^F = 5;

    $self->_run_cmd({ save_pid_to => 'vm_pid',
                      ignore_errors => 1,
                      outlives_state => 1,
                      on_done => weak_method_callback($self, '_on_kvm_done'),
                      '<'  => '/dev/null',
                      '>'  => $hv_out,
                      '2>' => $hv_out,
                      '3>' => $self->{tap_fh},
                      '4>' => $self->{vm_lock_fh},
                      on_prepare => sub {
                          # run VMs with low priority so in case the
                          # machine gets overloaded, the hkd does not
                          # become unresponsive.
                          # (PRIO_PGRP => 1, current PGRP => 0)

                          setpriority(1, 0, 10);
                          setpgrp(0, 0);
                      } },
                    kvm => @kvm_args);
    $self->_on_done;
}

sub _kill_kvm {
    my $self = shift;
    unless ($self->{vm_pid}) {
        DEBUG "There is no process for VM $self->{vm_id}, can't kill!";
        return $self->_on_error;
    }

    INFO "Killing kvm process $self->{vm_pid} for VM $self->{vm_id}";
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
