package QVD::HKD::VMHandler;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use strict;
use warnings;

use POSIX;
use AnyEvent;
use AnyEvent::Util;
use Linux::Proc::Net::TCP;
use QVD::Log;
use Carp;

use QVD::HKD::VMAMonitor;
use QVD::HKD::Config::Network qw(netmask_len);

use parent qw(QVD::HKD::Agent);

my %hypervisor_class = map { $_ => __PACKAGE__ . '::' . uc $_ } qw(kvm lxc);

my $off = 0;
sub _allocate_tcp_port {
    my $self = shift;
    my $base = shift // 2000;
    my $tcp = Linux::Proc::Net::TCP->read;
    my %used = map { $_ => 1 } $tcp->listener_ports;
    while (1) {
	$off++;
	my $port = $base + $off;
	unless ($used{$port}) { DEBUG "Allocating port '$port'"; return $port; }
    }
}

sub _ip_to_mac {
    my ($self, $ip) = @_;
    my (undef, @hex) = map sprintf('%02x', $_), split /\./, $ip;
    my $mac_prefix = $self->_cfg('vm.network.mac.prefix');
    join(':', $mac_prefix, @hex);
}

sub new {
    my ($class, %opts) = @_;
    my $vm_id = delete $opts{vm_id};
    my $on_stopped = delete $opts{on_stopped};
    my $on_delete_cmd = delete $opts{on_delete_cmd};
    my $on_heavy = delete $opts{on_heavy};

    my $dhcpd_handler = delete $opts{dhcpd_handler};
    my $self = $class->SUPER::new(%opts);
    $self->{vm_id} = $vm_id;
    $self->{dhcpd_handler} = $dhcpd_handler;
    $self->{on_stopped} = $on_stopped;
    $self->{on_heavy} = $on_heavy;
    $self->{on_delete_cmd} = $on_delete_cmd;

    my $hypervisor = $self->_cfg('vm.hypervisor');
    DEBUG "Using hypervisor type '$hypervisor'";
    my $hypervisor_class = $hypervisor_class{$hypervisor} // croak "unsupported hypervisor $hypervisor";
    eval "require $hypervisor_class; 1" or croak "unable to load module $hypervisor_class:\n$@";
    $self->bless($hypervisor_class);
    $self->_init_hypervisor;
    $self;
}

sub _init_hypervisor {}

sub on_cmd {
    my ($self, $cmd) = @_;
    my $method = $self->can("_on_cmd_$cmd");
    if ($method) {
        $method->($self);
        INFO "Command $cmd received by vm $self->{vm_id}";
    }
    else {
        $debug and $self->_debug("unsupported command $cmd received by vm $self->{vm_id}");
        WARN "Unsupported command '$cmd' received by vm '$self->{vm_id}'";
    }
}

sub _delete_cmd {
    my $self = shift;
    $self->_maybe_callback('on_delete_cmd');
    $self->_on_delete_cmd_done;
}

sub _save_state {
    my $self = shift;
    my $state = $self->_main_state;
    $debug and $self->_debug("changing database state to $state");
    DEBUG "Changing database state to '$state'";
    $self->_query('update vm_runtimes set vm_state = $1 where vm_id = $2 and host_id = $3',
                  $state, $self->{vm_id}, $self->{node_id});
}

sub _on_save_state_result {}

sub _load_row {
    my $self = shift;
    $self->_query_1(<<'EOQ', $self->{vm_id});
select name, user_id, osf_id,
       di_tag, ip, storage,
       login
  from vms, users
  where vms.id = $1
    and users.id = vms.user_id
EOQ
}

sub _on_load_row_result {
    my ($self, $res) = @_;
    @{$self}{qw(name user_id osf_id di_tag ip storage login)} = $res->row;
    INFO "Successfully loaded row for VM '$self->{vm_id}'";
    $self->{mac} = $self->_ip_to_mac($self->{ip});
    my $dhcpd_handler = $self->{dhcpd_handler};
    $dhcpd_handler->register_mac_and_ip(@$self{qw(vm_id mac ip)}) if $dhcpd_handler;
}

sub _incr_run_attempts {
    my $self = shift;
    DEBUG "Increasing run attempts counter for VM '$self->{vm_id}'";
    $self->_query('update vm_counters set run_attempts = run_attempts + 1 where vm_id = $1', $self->{vm_id});
}

sub _on_incr_run_attempts_result {}

sub _incr_run_ok {
    my $self = shift;
    DEBUG "Increasing run ok counter for VM '$self->{vm_id}'";
    $self->_query('update vm_counters set run_ok = run_ok + 1 where vm_id = $1', $self->{vm_id});
}

sub _search_di {
    my $self = shift;
    DEBUG "Searching DIs with tag '$self->{di_tag}' for OSF '$self->{osf_id}'";
    $self->_query_1(<<'SQL', @$self{qw(osf_id di_tag)});
select dis.id, dis.path, osfs.use_overlay, osfs.user_storage_size, memory
    from di_tags, dis, osfs
    where
        dis.osf_id = osfs.id    and
        di_tags.di_id = dis.id  and
        osfs.id = $1            and
        di_tags.tag = $2
SQL
}

sub _on_search_di_result {
    my ($self, $res) = @_;
    @{$self}{qw(di_id di_path use_overlay user_storage_size memory)} = $res->row;
    DEBUG "Found DI '$self->{di_id}'";
}

sub _on_search_dir_bad_result {
    my ($self, $res) = @_;
    my $rows = $res->rows || 0;
    ERROR "no DI found for OSF $self->{osf_id} with tag $self->{di_tag} as assigned to VM $self->{vm_id}";
    $self->{current_query_bad_result} = 1;
}

sub _save_runtime_row {
    my $self = shift;

    $self->{vma_port}    = $self->_cfg('internal.vm.port.vma');
    $self->{x_port}      = $self->_cfg('internal.nxagent.display') + 4000;
    $self->{ssh_port}    = $self->_cfg('internal.vm.port.ssh');
    $self->{vnc_port}    = $self->_cfg('vm.vnc.redirect') ?              $self->_allocate_tcp_port : 0;
    $self->{serial_port} = $self->_cfg('vm.serial.redirect') ?           $self->_allocate_tcp_port : 0;
    $self->{mon_port}    = $self->_cfg('internal.vm.monitor.redirect') ? $self->_allocate_tcp_port : 0;
    no warnings 'uninitialized';
    DEBUG sprintf "Saving runtime row for VM '%d': VMA port '%d', X11 port '%d', SSH port '%d', VNC port '%s', serial port '%s', monitor port '%s'",
        @{$self}{qw(vm_id vma_port x_port ssh_port vnc_port serial_port mon_port)};

    $self->_query_1(<<'SQL', @{$self}{qw(ip vma_port x_port ssh_port vnc_port serial_port mon_port vm_pid vm_id)});
update vm_runtimes
    set
        vm_address     = $1,
        vm_vma_port    = $2,
        vm_x_port      = $3,
        vm_ssh_port    = $4,
        vm_vnc_port    = $5,
        vm_serial_port = $6,
        vm_mon_port    = $7,
        vm_pid         = $8
    where
        vm_id          = $9
SQL
}

sub _fw_rules {
    my $self = shift;
    my $vm_id = $self->{vm_id};
    my $ip = $self->{ip};
    my $mac = $self->{mac};
    my $iface = $self->{iface};

    # this ebrules rules are just to forbid MAC or IP spoofing
    # everything else is done using global rules.

    my $INPUT   = "QVD_${vm_id}_INPUT";
    my $FORWARD = "QVD_${vm_id}_FORWARD";

    my $dhcp_accept = ($self->_cfg('vm.network.use_dhcp') ? 'ACCEPT' : 'DROP');

    return ( [-N => $INPUT,   -P => 'ACCEPT'],
             [-N => $FORWARD, -P => 'ACCEPT'],

             [-A => $FORWARD => -s => '!', $mac, -j => 'DROP'],
             [-A => $INPUT   => -s => '!', $mac, -j => 'DROP'],
             [-A => $FORWARD => -p => '0x800', '--ip-source' => '!', $ip, -j => 'DROP'],
             [-A => $INPUT   => -p => '0x800', '--ip-protocol' => '17',   # allow DHCP requests to host
                                               '--ip-source' => '0.0.0.0',
                                               '--ip-destination-port' => '67', -j => $dhcp_accept],
             [-A => $FORWARD => -p => '0x800', '--ip-protocol' => '17',   # do not let DHCP traffic leave the host
                                               '--ip-destination-port' => '67', -j => 'DROP'],
             [-A => $INPUT   => -p => '0x800', '--ip-source' => '!', $ip, -j => 'DROP'],

             [-A => INPUT    => -i => $iface, -j => $INPUT  ],
             [-A => FORWARD  => -i => $iface, -j => $FORWARD] );
}

sub _set_fw_rules {
    my $self = shift;
    if ($self->_cfg('internal.vm.network.firewall.enable')) {
        my $ebtables = $self->_cfg('command.ebtables');
        for my $rule ($self->_fw_rules) {
            $debug and $self->_debug("adding ebtables entry @$rule");
            DEBUG "Adding ebtables entry '@$rule'";
            if (system $ebtables => @$rule) {
                $debug and $self->_debug("unable to add ebtables entry, rc: " . ($? >> 8));
                DEBUG "Unable to add ebtables entry, rc: " . ($? >> 8);
                return $self->_on_set_fw_rules_error;
            }
        }
    }
    else {
        $debug and $self->_debug("setup of VM firewall rules skipped, do you really need to do that?");
        INFO "Setup of VM firewall rules skipped, do you really need to do that?";
    }
    $self->_on_set_fw_rules_done;
}

sub _remove_fw_rules {
    my $self = shift;
    if ($self->_cfg('internal.vm.network.firewall.enable')) {
        my $vm_id = $self->{vm_id};
        my $ebtables = $self->_cfg('command.ebtables');
        for my $chain (qw(INPUT FORWARD)) {
            my $target = "QVD_${vm_id}_${chain}";
            my $j = quotemeta $target;
            $j = qr/\b$j$/;
            $debug and $self->_debug("retrieving list of ebtables entries for $chain");
            DEBUG "Retrieving list of ebtables entries for chain '$chain'";
            for (`$ebtables -L $chain --Ln`) {
                chomp;
                if ($_ =~ $j) {
                    my ($n) = split /\./;
                    $debug and $self->_debug("deleting rule $_");
                    DEBUG "Deleting rule '$_'";
                    if (system $ebtables => -D => $chain, $n) {
                        $debug and $self->_debug("unable to delete rule, rc: " . ($? << 8));
                        ERROR "Unable to delete ebtable";
                    }
                }
            }
            DEBUG "deleting ebtables chain $target";
            if (system $ebtables => -X => $target) {
                $debug and $self->_debug("unable to delete chain $target, rc: " . ($? << 8));
                ERROR "Unable to delete chain '$target', rc: " . ($? << 8);
            }

            unless (system "$ebtables -L $target >/dev/null 2>&1") {
                $debug and $self->_debug("deletion of chain $target failed");
                ERROR "Deletion of chain '$target' failed";
                return $self->_on_remove_fw_rules_error;
            }
        }
    }
    else {
        $debug and $self->_debug("cleanup of VM firewall rules skipped");
        DEBUG 'Cleanup of VM firewall rules skipped';
    }
    $self->_on_remove_fw_rules_done
}

sub _vma_url {
    my $self = shift;
    sprintf "http://%s:%d/vma", $self->{ip}, $self->{vma_port};
}

sub _start_vma_monitor {
    my $self = shift;
    my $vma_monitor = $self->{vma_monitor} = QVD::HKD::VMAMonitor->new(config => $self->{config},
                                                                       on_failed => sub { $self->_on_failed_vma_monitor },
                                                                       on_alive => sub { $self->_on_alive },
                                                                       rpc_service => $self->_vma_url);
    $self->{last_seen_alive} = time;
    $vma_monitor->run;
}

sub _stop_vma_monitor {
    my $self = shift;
    $debug and $self->_debug('stopping vma monitor');
    DEBUG 'Stopping VMA monitor';
    my $vma_monitor = delete $self->{vma_monitor};
    $vma_monitor->stop;
}

sub _on_alive {
    my $self = shift;
    $self->{last_seen_alive} = time;
    $self->{failed_vma_count} = 0;
}

sub _on_failed_vma_monitor {
    my $self = shift;
    my $failed_vma_count = ++$self->{failed_vma_count};
    my $state_key = ($self->state =~ /^starting/ ? 'starting' : 'running');
    my $max = $self->_cfg("internal.hkd.vmhandler.vma.failed.max_count.on.$state_key");

    $debug and $self->_debug("failed_vma_monitor for vm '$self->{vm_id}', tries: $failed_vma_count/$max");
    WARN "failed_vma_monitor for vm '$self->{vm_id}', tries: $failed_vma_count/$max";

    if ($failed_vma_count >= $max) {
        my $max_time = $self->_cfg("internal.hkd.vmhandler.vma.failed.max_time.on.$state_key");
        $debug and $self->_debug("failed_vma_monitor for vm '$self->{vm_id}', time: " .(time - $self->{last_seen_alive}). "/$max_time");
        WARN "failed_vma_monitor for vm '$self->{vm_id}', time: " .(time - $self->{last_seen_alive}). "/$max_time";
        if (time - $self->{last_seen_alive} > $max_time) {
            WARN "VMA didn't start, stopping VM '$self->{vm_id}'";
            if ($self->_cfg('internal.vm.debug.enable')) {
                $debug and $self->_debug("calling _on_goto_debug");
                $self->_on_goto_debug;

            }
            else {
                $debug and $self->_debug("calling _on_dead");
                $self->_on_dead;
            }
        }
    }
}

sub _poweroff {
    my $self = shift;
    $self->{rpc_service} = $self->_vma_url;
    DEBUG "Invoking RPC 'poweroff' method";
    $self->_rpc('poweroff');
}

sub _set_state_timer {
    my $self = shift;
    my $state = $self->_main_state;
    $self->_call_after($self->_cfg("internal.hkd.vmhandler.timeout.on_state.$state"), '_on_state_timeout');
}

sub _clear_runtime_row {
    my $self = shift;
    my $state = $self->_main_state;
    DEBUG "Clearing runtime row for VM '$self->{vm_id}'";

    my $dhcpd_handler = $self->{dhcpd_handler};
    $dhcpd_handler->unregister_mac_and_ip($self->{vm_id}) if $dhcpd_handler;

    # FIXME: final state could also be 'failed', currently 'stopped'
    # is hard-coded here.
    $self->_query(<<'SQL', $self->{vm_id}, $self->{node_id});
update vm_runtimes
    set
        vm_state       = 'stopped',
        host_id        = NULL,
        vm_vma_port    = NULL,
        vm_x_port      = NULL,
        vm_ssh_port    = NULL,
        vm_vnc_port    = NULL,
        vm_serial_port = NULL,
        vm_mon_port    = NULL,
        vm_address     = NULL,
        vm_cmd         = NULL
    where
        vm_id   = $1  and
        host_id = $2
SQL
}

sub _set_heavy_mark {
    my $self = shift;
    if ($self->_maybe_callback(on_heavy => 1)) {
        $self->_on_set_heavy_mark_done;
    }
    else {
        $self->_on_set_heavy_mark_error;
    }
}

sub _unset_heavy_mark {
    my $self = shift;
    $self->_maybe_callback(on_heavy => 0);
    $self->_on_unset_heavy_mark_done;
}

sub _on_clear_runtime_row_result {}
sub _on_clear_runtime_row_bad_result {}

sub _call_on_stopped { shift->_maybe_callback('on_stopped') }

sub _run_prestart_hook { shift->_run_hook('prestart') }
sub _run_poststart_hook { shift->_run_hook('poststart') }
sub _run_poststop_hook { shift->_run_hook('poststop') }

1;
