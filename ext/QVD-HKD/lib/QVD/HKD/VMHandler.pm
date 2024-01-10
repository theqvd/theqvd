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
use Method::WeakCallback qw(weak_method_callback);
use QVD::HKD::VMAMonitor;
use QVD::HKD::Config::Network qw(netmask_len);

use parent qw(QVD::HKD::Agent);

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

sub _gen_random_mac_suffix {
    my $self = shift;
    my $mac_suffix; $mac_suffix .= sprintf("%x", rand 16) for 1..6;
    $mac_suffix =~ s/(..)/$1:/g;
    $mac_suffix =~ s/:$//r;
    my $mac_prefix = $self->_cfg('vm.network.mac.prefix');
    join(':', $mac_prefix, $mac_suffix);
}

sub new {
    my ($class, %opts) = @_;
    my $vm_id = delete $opts{vm_id};

    my $dhcpd_handler = delete $opts{dhcpd_handler};
    my $vhci_handler = delete $opts{vhci_handler};
    my $vm_lock_fh = delete $opts{vm_lock_fh};
    my $hypervisor = delete $opts{hypervisor};
    my $self = $class->SUPER::new(%opts);
    $self->{vm_id} = $vm_id;
    $self->{dhcpd_handler} = $dhcpd_handler;
    $self->{vhci_handler} = $vhci_handler;
    $self->{vm_lock_fh} = $vm_lock_fh;
    $self->{hypervisor} = $hypervisor;
    $self;
}

sub on_cmd {
    my ($self, $cmd) = @_;
    my $method = $self->can("_on_cmd_$cmd");
    if ($method) {
        $method->($self);
        INFO "Command $cmd received by vm $self->{vm_id}";
    }
    else {
        $debug and $self->_debug("unsupported command $cmd received by vm $self->{vm_id}");
        WARN "Unsupported command '$cmd' received by vm '$self->{vm_id}' on state ". $self->state;
    }
}

sub _save_state {
    my $self = shift;
    my $state = $self->_main_state;
    my $vm_id = $self->{vm_id};
    $debug and $self->_debug("changing database state to $state");
    DEBUG "Changing database state to '$state' for VM $vm_id";
    $self->_query({n => 1,
                   log_error => "Unable to change state to $state for VM $vm_id in table vm_runtimes" },
                  'update vm_runtimes set vm_state = $1, vm_state_ts = $2 where vm_id = $3 and host_id = $4',
                  $state, time, $vm_id, $self->{node_id});
}

sub _load_row {
    my $self = shift;
    $self->_query({save_to_self => 1}, <<'EOQ', $self->{vm_id});
select name, user_id, osf_id,
       di_tag, ip, storage,
       login, parameters
  from vms, users, user_auth_parameters
  where vms.id = $1
    and users.id = vms.user_id
    and user_auth_parameters.id in
  (select max(auth_params_id) from user_tokens where vm_id = vms.id)
EOQ
}

sub _check_hypervisor {
    my $self = shift;
    if ($self->{hypervisor}->ok) {
        $self->_on_done;
    }
    else {
        DEBUG "Aborting VM because hypervisor is not ok";
        $self->_on_error;
    }
}

sub _calculate_attrs {
    my $self = shift;
    $self->{vma_port}    = $self->_cfg('internal.vm.port.vma');
    $self->{x_port}      = $self->_cfg('internal.nxagent.display') + 4000;
    $self->{ssh_port}    = $self->_cfg('internal.vm.port.ssh');
    $self->{vnc_port}    = $self->_cfg('vm.vnc.redirect')              ? $self->_allocate_tcp_port(5900) : 0;
    $self->{serial_port} = $self->_cfg('vm.serial.redirect')           ? $self->_allocate_tcp_port : 0;
    $self->{mon_port}    = $self->_cfg('internal.vm.monitor.redirect') ? $self->_allocate_tcp_port : 0;
    $self->{gateway}     = $self->_cfg('vm.network.gateway');
    $self->{netmask_len} = $self->netmask_len;

    # When you need to run lxc containers inside a hypervisor like VMware you must configure lxc.net.type as macvlan. 
    if ( $self->_cfg('vm.lxc.net.type') eq "macvlan" ) {
      $self->{mac}         = $self->_gen_random_mac_suffix();
    } else {	    
      $self->{mac}         = $self->_ip_to_mac($self->{ip});
    }

    $self->{rpc_service} = sprintf("http://%s:%d/vma", $self->{ip}, $self->{vma_port});

    # Load vm session parameters, these parameters are necessary at some point
    my $parameters = decode_json($self->{parameters});
    $self->{user_name} = $parameters->{'qvd.vm.user.name'};
    $self->{user_home} = $parameters->{'qvd.vm.user.home'};
    $self->{user_uid} = $parameters->{'qvd.vm.user.uid'};
    $self->{user_gid} = $parameters->{'qvd.vm.user.gid'};
}

sub _add_to_dhcpd {
    my $self = shift;
    if (my $dhcpd_handler = $self->{dhcpd_handler}) {
        $dhcpd_handler->register_mac_and_ip(@$self{qw(vm_id mac ip)});
    }
    $self->_on_done;
}

sub _rm_from_dhcpd {
    my $self = shift;
    if (my $dhcpd_handler = $self->{dhcpd_handler}) {
        $dhcpd_handler->unregister_mac_and_ip($self->{vm_id});
    }
    $self->_on_done;
}

sub _incr_run_attempts {
    my $self = shift;
    DEBUG "Increasing run attempts counter for VM '$self->{vm_id}'";
    $self->_query('update vm_counters set run_attempts = run_attempts + 1 where vm_id = $1', $self->{vm_id});
}

sub _incr_run_ok {
    my $self = shift;
    DEBUG "Increasing run ok counter for VM '$self->{vm_id}'";
    $self->_query('update vm_counters set run_ok = run_ok + 1 where vm_id = $1', $self->{vm_id});
}

sub _search_di {
    my $self = shift;
    DEBUG "Searching DIs with tag '$self->{di_tag}' for OSF '$self->{osf_id}'";
    $self->_query( { save_to_self => [qw(di_id di_path use_overlay user_storage_size memory)] },
                   <<'SQL', @$self{qw(osf_id di_tag)});
select dis.id, dis.path, osfs.use_overlay, osfs.user_storage_size, memory
    from di_tags, dis, osfs
    where
        dis.osf_id = osfs.id            and
        di_tags.di_id = dis.id          and
        dis.blocked = false             and
        osfs.id = $1                    and
        di_tags.tag = $2               
SQL
}

sub _save_runtime_row {
    my $self = shift;
    DEBUG sprintf("Saving runtime row for VM '%d': VMA port '%d', X11 port '%d', ".
                  "SSH port '%d', VNC port '%s', serial port '%s', monitor port '%s'",
                  map { defined $_ ? $_ : '<undef>' }
                  @{$self}{qw(vm_id vma_port x_port ssh_port vnc_port serial_port mon_port)});

    my @args = @{$self}{qw(ip vma_port x_port ssh_port vnc_port serial_port mon_port vm_pid
                           di_id vm_id)};
    $self->_query({ n => 1}, <<'SQL', @args);
update vm_runtimes
    set
        vm_address     = $1,
        vm_vma_port    = $2,
        vm_x_port      = $3,
        vm_ssh_port    = $4,
        vm_vnc_port    = $5,
        vm_serial_port = $6,
        vm_mon_port    = $7,
        vm_pid         = $8,
        current_di_id  = $9
    where
        vm_id          = $10
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
                ERROR "Unable to add ebtables entry, rc: " . ($? >> 8);
                return $self->_on_error;
            }
        }
    }
    else {
        $debug and $self->_debug("setup of VM firewall rules skipped, do you really need to do that?");
        INFO "Setup of VM firewall rules skipped, do you really need to do that?";
    }
    $self->_on_done;
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
                    my $n = (split / /, $_)[0];
                    $debug and $self->_debug("deleting rule $_");
                    DEBUG "Deleting rule '$_'";
                    if (system $ebtables => -D => $chain => $n) {
                        $debug and $self->_debug("unable to delete rule, rc: " . ($? << 8));
                        WARN "Unable to delete ebtable";
                    }
                }
            }

	    DEBUG "flushing ebtables $target chain rules";
            if (system $ebtables => -F => $target) {
                $debug and $self->_debug("unable to flush rules in chain $target, rc: " . ($? << 8));
                WARN "Unable to flush rules in chain '$target', rc: " . ($? << 8);
            }

            DEBUG "deleting ebtables chain $target";
            if (system $ebtables => -X => $target) {
                $debug and $self->_debug("unable to delete chain $target, rc: " . ($? << 8));
                WARN "Unable to delete chain '$target', rc: " . ($? << 8);
            }

            unless (system "$ebtables -L $target >/dev/null 2>&1") {
                $debug and $self->_debug("deletion of chain $target failed");
                WARN "Deletion of chain '$target' failed";
                return $self->_on_error;
            }
        }
    }
    else {
        $debug and $self->_debug("cleanup of VM firewall rules skipped");
        DEBUG 'Cleanup of VM firewall rules skipped';
    }
    $self->_on_done
}

sub _start_vma_monitor {
    my $self = shift;
    my $vma_monitor = $self->{vma_monitor} //= QVD::HKD::VMAMonitor->new(config => $self->{config},
                                                                         on_failed => weak_method_callback($self, '_on_vma_monitor_failed'),
                                                                         on_alive  => weak_method_callback($self, '_on_vma_monitor_ok'),
                                                                         rpc_service => $self->{rpc_service});
    $self->{last_seen_alive} = time;
    $self->{failed_vma_count} = 0;
    $vma_monitor->run;
    $self->on_leave_state('__stop_vma_monitor');
}

sub __stop_vma_monitor {
    my $self = shift;
    if (my $vma_monitor = $self->{vma_monitor}) {
        DEBUG "stopping VMA monitor";
        $vma_monitor->stop;
    }
}

sub _on_vma_monitor_ok {
    my $self = shift;
    $self->{last_seen_alive} = time;
    $self->{failed_vma_count} = 0;
    $self->_on_alive;
}

sub _on_vma_monitor_failed {
    my $self = shift;
    my $failed_vma_count = ++$self->{failed_vma_count};
    my $state_key = ($self->state =~ /^starting/ ? 'starting' : 'running');
    my $max = $self->_cfg("internal.hkd.vmhandler.vma.failed.max_count.on.$state_key");

    $debug and $self->_debug("vma_monitor_failed for vm '$self->{vm_id}', tries: $failed_vma_count/$max");
    WARN "vma_monitor_failed for vm '$self->{vm_id}', tries: $failed_vma_count/$max";

    if ($failed_vma_count >= $max) {
        my $max_time = $self->_cfg("internal.hkd.vmhandler.vma.failed.max_time.on.$state_key");
        $debug and $self->_debug("vma_monitor_failed for vm '$self->{vm_id}', time: " .(time - $self->{last_seen_alive}). "/$max_time");
        WARN "vma_monitor_failed for vm '$self->{vm_id}', time: " .(time - $self->{last_seen_alive}). "/$max_time";
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

sub _shutdown {
    my $self = shift;
    $self->_rpc('poweroff');
}

my $hv_re = __PACKAGE__ .'::(\w+)\b';
sub _set_state_timer {
    my $self = shift;
    my $state = $self->state;
    $state =~ s|/|.|g;
    my $hypervisor_name = $self->{hypervisor}->name;
    $self->_call_after($self->_cfg("internal.hkd.$hypervisor_name.timeout.on_state.$state"), '_on_state_timeout');
}

sub _capture_fn {
    my ($self, $key) = @_;
    my $fn = '/dev/null';
    if ($self->_cfg("vm.$key.capture")) {
        my $path = $self->_cfg("path.$key.captures");
        if (-d $path or mkdir $path, 0700) {
            my @t = gmtime;
            my $ts = sprintf("%04d-%02d-%02d-%02d:%02d:%02d-GMT0",
                             $t[5] + 1900, $t[4] + 1, @t[3,2,1,0]);
            $fn = "$path/$key-$self->{vm_id}-$ts.txt";
            DEBUG "Redirecting VM $self->{vm_id} $key I/O to '$fn'";
            return $fn;
        }
        else {
            WARN "Unable to create $key captures directory '$path': $!";
        }
    }
    DEBUG "Output for $key on VM $self->{vm_id} is not being redirected";
    ()
}

sub _hypervisor_output_redirection {
    my $self = shift;
    if (defined (my $fn = $self->_capture_fn('hypervisor'))) {
        open my $hv_out, '>>', $fn;
        return $hv_out if defined $hv_out;
        WARN "Unable to redirect hypervisor output for VM $self->{vm_id} to $fn";
    }
    '/dev/null';

}

sub _clear_runtime_row {
    my $self = shift;
    my $state = $self->_main_state;
    DEBUG "Clearing runtime row for VM '$self->{vm_id}'";
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
        vm_cmd         = NULL,
        vm_expiration_soft = NULL,
        vm_expiration_hard = NULL,
        current_di_id  = NULL
    where
        vm_id   = $1  and
        host_id = $2
SQL
}

sub _expire {
    my ($self, $expiration_soft, $expiration_hard) = @_;
    my @args;
    push @args, 'vm.expiration.soft' => $expiration_soft if defined $expiration_soft;
    push @args, 'vm.expiration.hard' => $expiration_hard if defined $expiration_hard;
    $self->_rpc( { retry_count => 0, ignore_errors => 1 }, expire => @args );
}

sub _run_prestart_hook { shift->_run_hook('prestart') }
sub _run_poststart_hook { shift->_run_hook('poststart') }
sub _run_poststop_hook { shift->_run_hook('poststop') }

1;
