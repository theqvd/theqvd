package QVD::HKD;

our $VERSION = '3.00';

use 5.010;

our $debug = 1;

$Class::StateMachine::debug ||= -1;
$AnyEvent::Pg::debug ||= ~0;

use strict;
use warnings;
no warnings 'redefine';

use Carp;
use File::Slurp qw(slurp);
use File::Spec;
use Pg::PQ qw(:pgres);
use QVD::Log;
use AnyEvent::Impl::Perl;
# use AnyEvent::Impl::EV;
use AnyEvent;
use AnyEvent::Semaphore;
use AnyEvent::Pg::Pool;
use Linux::Proc::Net::TCP;
use Linux::Proc::Mountinfo;

use Time::HiRes ();

use QVD::HKD::Helpers;

use QVD::HKD::Config;
use QVD::HKD::Ticker;
use QVD::HKD::ClusterMonitor;
use QVD::HKD::DHCPDHandler;
use QVD::HKD::CommandHandler;
use QVD::HKD::VMCommandHandler;
use QVD::HKD::VMHandler;
use QVD::HKD::L7RMonitor;
use QVD::HKD::L7RKiller;
use QVD::HKD::ExpirationMonitor;

use QVD::HKD::Config::Network qw(netvms netnodes net_aton net_ntoa netstart_n network_n);

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative
    __any__        => { advance => '_on_done',
                        on => { _on_dead_db => '_on_error',
                                _on_ticker_error => '_on_error' },
                        ignore => [qw(_on_db_ticked
                                      _on_transient_db_error
                                      _on_config_reload_done)],
                        delay => [qw(_on_cmd_stop)],
                        before => {_on_config_reload_done => '_sync_db_config' } },

    new            => { transitions => { _on_run => 'starting'} },

    starting       => { substates => [ zero => { transitions => { _on_error => 'exit',
                                                                  _on_cmd_stop => 'exit' },
                                                 substates => [ acquiring_lock => { enter => '_acquire_lock' },
                                                                connecting_to_db      => { enter => '_start_db' },
                                                                checking_db_version   => { enter => '_check_db_version' },
                                                                loading_db_config     => { enter => '_start_config',
                                                                                           on => { _on_config_reload_done => '_on_done' } },
                                                                loading_host_row      => { enter => '_load_host_row' },
                                                                checking_tcp_ports    => { enter => '_check_tcp_ports' },
                                                                checking_address      => { enter => '_check_address' },
                                                                checking_cgroups      => { enter => '_check_cgroups' } ] },

                                       setup => { transitions => { _on_error => 'stopping',
                                                                   _on_cmd_stop => 'stopping' },
                                                  substates => [ saving_state          => { enter => '_save_state' },
                                                                 preparing_storage     => { enter => '_prepare_storage' },
                                                                 removing_old_fw_rules => { enter => '_remove_fw_rules' },
                                                                 setting_fw_rules      => { enter => '_set_fw_rules' },
                                                                 saving_loadbal_data   => { enter => '_save_loadbal_data' },
                                                                 ticking               => { enter => '_start_ticker',
                                                                                            on => { _on_db_ticked => '_on_done' } },
                                                                 searching_zombies     => { enter => '_search_zombies' },
                                                                 catching_zombies      => { enter => '_catch_zombies',
                                                                                            on => { _on_no_vms_are_running => '_on_done' } },
                                                                 agents                => { enter => '_start_agents' } ] } ] },

    running        => { transitions => { _on_error   => 'stopping' },
                        ignore => [qw(_on_no_vms_are_running) ],
                        substates => [ saving_state => { enter => '_save_state' },
                                       agents       => { enter => '_start_vm_command_handler' },
                                       main         => { on => { _on_cmd_stop => '_on_done' } } ] },

    stopping       => { on => { _on_error => '_on_done' },
                        ignore => [qw(_on_ticker_error _on_dead_db)],
                        substates => [ stopping_vm_command_handler => { enter => '_stop_vm_command_handler',
                                                                        on => { _on_vm_command_handler_stopped => '_on_done' } },
                                       saving_state                => { enter => '_save_state' },
                                       stopping_all_vms            => { enter => '_stop_all_vms',
                                                                        on => { _on_no_vms_are_running => '_on_done',
                                                                                _on_state_timeout     => '_on_error' },
                                                                        transitions => { _on_error => 'killing_all_vms' } },
                                       '(killing_all_vms)'         => { enter => '_kill_all_vms',
                                                                        on => { _on_no_vms_are_running => '_on_done' } },

                                       stopping_all_agents         => { enter => '_stop_all_agents',
                                                                        on => {_on_all_agents_stopped => '_on_done' } },
                                       removing_fw_rules           => { enter => '_remove_fw_rules' } ] },

    stopped        => { enter => '_save_state',
                        on => { _on_error => '_on_done' } },

    exit           => { enter => '_say_goodbye' };

sub _on_transient_db_error :OnState('running') {
    shift->{cluster_monitor}->on_transient_db_error
}

sub new {
    my ($class, %opts) = @_;
    # $opts{$_} //= $defaults{$_} for keys %defaults;
    my $config_file = delete $opts{config_file} // croak "configuration file missing";

    my $self = $class->SUPER::new(%opts);
    $self->{config} = QVD::HKD::Config->new(config_file => $config_file,
                                            on_reload_done => sub { $self->_on_config_reload_done });
    $self->{vm} = {};
    $self->{heavy} = AnyEvent::Semaphore->new($self->_cfg('internal.hkd.max_heavy'));
    $self->{query_priority} = 30;
    $self;
}

sub _acquire_lock {
    my $self = shift;
    my $file = $self->_cfg('internal.hkd.lock.path');
    $self->_flock({ save_to => 'lock_file',
                    log_error => "Unable to lock file '$file'" },
                  $file);
}

sub _say_goodbye {
    my $self = shift;
    $self->{exit}->send;
    $debug and $self->_debug("GOODBYE!");
    DEBUG "GOODBYE!\n";

    exit(0);
}

sub _on_signal {
    my ($self, $name) = @_;
    print STDERR "foo!\n";
    $debug and $self->_debug("signal $name received");
    DEBUG "Signal $name received";
    if ($name eq 'USR1') {
        $self->_write_vm_report;
    }
    else {
        $debug and $self->_debug("stopping!");
        $self->_on_cmd_stop;
    }
}

sub run {
    my $self = shift;
    $self->{exit} = AnyEvent->condvar;

    $debug and $self->_debug("Using AnyEvent backend $AnyEvent::MODEL");

    for (qw(TERM INT USR1)) {
        my $name = $_;
        $self->{$_. "_watcher"} = AnyEvent->signal(signal => $_,
                                                   cb => sub { $self->_on_signal($name) });
    }

    if ($self->_cfg('internal.hkd.debugger.run')) {
        my $socket_path = $self->_cfg('internal.hkd.debugger.socket');
        require AnyEvent::Debug;
        require Data::Dumper;
        print STDERR "REPL debugger running at $socket_path\n";
        print STDERR "Connect as:\n    socat readline,history=/root/.hkd-debug unix:$socket_path\n\n";

        $self->{debug_shell} = AnyEvent::Debug::shell("unix/", $socket_path);
        no strict 'refs';
        *AnyEvent::Debug::shell::hkd = sub {
            $self
        };
        *AnyEvent::Debug::shell::x = sub {
            print Data::Dumper::Dumper(@_);
            ();
        };
        *AnyEvent::Debug::shell::set = sub {
            $self->{config}{props}->setProperty(@_);
            ()
        };
        *AnyEvent::Debug::shell::vm_cmd = sub {
            $self->_on_vm_cmd(@_);
            ()
        }
    }

    $self->_on_run;
    $self->{exit}->recv;
}

sub _check_tcp_ports {
    my $self = shift;
    INFO 'checking TCP ports are free';
    my $tcp = Linux::Proc::Net::TCP->read;
    if (grep $_ == 53, $tcp->listener_ports) {
        ERROR "TCP port 53 is already in use";
        $self->_on_error;
    }
    else {
        $self->_on_done;
    }
}

sub _start_db {
    my $self = shift;
    INFO 'Connecting to database';
    my $db = AnyEvent::Pg::Pool->new( {host     => $self->_cfg('database.host'),
                                       dbname   => $self->_cfg('database.name'),
                                       user     => $self->_cfg('database.user'),
                                       password => $self->_cfg('database.password') },
                                      timeout            => $self->_cfg('internal.database.pool.connection.timeout'),
                                      global_timeout     => $self->_cfg('internal.database.pool.connection.global_timeout'),
                                      connection_delay   => $self->_cfg('internal.database.pool.connection.delay'),
                                      connection_retries => $self->_cfg('internal.database.pool.connection.retries'),
                                      size               => $self->_cfg('internal.database.pool.size'),
                                      on_connect_error   => sub { $self->_on_dead_db },
                                      on_transient_error => sub { $self->_on_transient_db_error },
                                    );
    $self->_db($db);
    $db->push_query(initialization => 1,
                    query => "set session time zone 'UTC'");
    $self->_on_done;
}

sub _check_db_version {
    my $self = shift;
    my $schema_version = '3.3.0';
    $self->_query( { n => 1,
                     log_error => "Bad database schema. Upgrade it to version $schema_version" },
                   <<'EOQ', $schema_version);
select version
    from versions
    where component='schema'
      and version=$1
EOQ
}

sub _sync_db_config {
    my $self = shift;
    if (my $db = $self->_db) {
        $db->set(timeout            => $self->_cfg('internal.database.pool.connection.timeout'),
                 global_timeout     => $self->_cfg('internal.database.pool.connection.global_timeout'),
                 connection_delay   => $self->_cfg('internal.database.pool.connection.delay'),
                 connection_retries => $self->_cfg('internal.database.pool.connection.retries'),
                 size               => $self->_cfg('internal.database.pool.size') );
    }
    $self->{heavy}->size($self->_cfg('internal.hkd.max_heavy'));
}

sub _start_config {
    my $self = shift;
    DEBUG 'Loading configuration';
    $self->{config}->set_db($self->{db});
    # not _on_done or _on_error generation because the db config reload events trigger them.
}

sub _load_host_row {
    my $self = shift;
    my $host = $self->_cfg('nodename');
    DEBUG "Loading entry for host '$host' from DB";
    $self->_query({n => 1,
                   save_to_self => [qw(node_id address)],
                   log_error => 'Unable to retrieve node data from database' },
                  'select id, address from hosts where name=$1', $host);
}

sub _check_address {
    my $self = shift;
    my $address_q = quotemeta $self->{address};
    my $ifaces = `ip -f inet addr show`;
    unless ($ifaces =~ /inet $address_q\b/) {
        ERROR "IP address $self->{address} not configured on node";
        return $self->_on_error;
    }
    $self->_debug("some interface has IP $self->{address}:\n$ifaces");

    my $address_n = net_aton($self->{address});
    my $start_n = netstart_n($self);
    my $net_n = network_n($self);
    if ($address_n <= $net_n or $address_n >= $start_n) {
        ERROR sprintf("Host IP address is outside of the network range reserved for hosts (IP: %s, range: %s-%s)",
                      $self->{address}, net_ntoa($net_n), net_ntoa($start_n));
        return $self->_on_error;
    }
    $self->_on_done;
}

sub _check_cgroups {
    my $self = shift;

    return $self->_on_done
        unless $self->_cfg('vm.hypervisor') eq 'lxc';

    my $mi = Linux::Proc::Mountinfo->read;
    my $dir = $self->_cfg('path.cgroup.cpu.lxc');
    my @parts = File::Spec->splitdir(File::Spec->rel2abs($dir));
    while (@parts) {
        my $dir = File::Spec->join(@parts);
        if (defined(my $mie = $mi->at($dir))) {
            if ($mie->fs_type eq 'cgroup') {
                INFO "cgroup found at $dir";
                return $self->_on_done;
            }
            last;
        }
        pop @parts;
    }
    ERROR "$dir does not lay inside a cgroups file system";
    $self->_on_error;
}

sub _save_state {
    my $self = shift;
    my $state = $self->_main_state;
    $debug and $self->_debug("changing database state to $state");
    $self->_query({n => 1,
                   log_error => "Unable to update host_runtimes table in database" },
                  'update host_runtimes set state = $1 where host_id = $2', $state, $self->{node_id});
}

sub _calc_load_balancing_data {   ## taken from was_QVD-HKD/lib/QVD/HKD.pm, _update_load_balancing_data
    my $bogomips;

    open my $fh, '<', '/proc/cpuinfo';
    (/^bogomips\s*: (\d*\.\d*)/ and $bogomips += $1) foreach <$fh>;
    close $fh;

    $bogomips *= 0.80; # 20% se reserva para el hipervisor

    # TODO: move this code into an external module!
    my $meminfo_lines = slurp('/proc/meminfo', array_ref => 1);
    my %meminfo = map { /^([^:]+):\s*(\d+)/; $1 => $2 } @$meminfo_lines;
    DEBUG sprintf "Load balancing data: '%s' bogomips, '%s' memtotal", $bogomips, $meminfo{MemTotal}/1000;

    return $bogomips, $meminfo{MemTotal}/1000;
}

sub _save_loadbal_data {
    my $self = shift;
    my ($cpu, $ram) = _calc_load_balancing_data;
    $self->_query({n => 1,
                   log_error => 'Unable to update load balancing data on host_runtimes table' },
                  'update host_runtimes set usable_cpu=$1, usable_ram=$2 where host_id=$3',
                  $cpu, $ram, $self->{node_id});
}

sub _start_ticker {
    my $self = shift;
    $self->{ticker} = QVD::HKD::Ticker->new( config => $self->{config},
                                             db => $self->{db},
                                             node_id => $self->{node_id},
                                             on_ticked => sub { $self->_on_db_ticked },
                                             on_error => sub { $self->_on_ticker_error },
                                             on_stopped => sub { $self->_on_agent_stopped(@_) } );
    DEBUG 'Starting ticker';
    $self->{ticker}->run;
}

sub _start_agents {
    my $self = shift;
    my %opts = ( config     => $self->{config},
                 db         => $self->{db},
                 node_id    => $self->{node_id},
                 on_stopped => sub { $self->_on_agent_stopped(@_) } );

    $self->{command_handler}    = QVD::HKD::CommandHandler->new(%opts,
                                                                on_cmd => sub { $self->_on_cmd($_[1]) });
    $self->{expiration_monitor} = QVD::HKD::ExpirationMonitor->new(%opts,
                                                                  on_expired_vm => sub { $self->_on_expired_vm(@_[1..3])});
    $self->{l7r_monitor}        = QVD::HKD::L7RMonitor->new(%opts);
    $self->{l7r_killer}         = QVD::HKD::L7RKiller->new(%opts);
    $self->{cluster_monitor}    = QVD::HKD::ClusterMonitor->new(%opts);
    $self->{dhcpd_handler} = QVD::HKD::DHCPDHandler->new(%opts)
        if $self->_cfg("vm.network.use_dhcp");

    DEBUG 'Starting command handler';
    $self->{command_handler}->run;

    DEBUG 'Starting ExpirationMonitor';
    $self->{expiration_monitor}->run;

    DEBUG 'Starting L7R Monitor';
    $self->{l7r_monitor}->run;

    DEBUG 'Starting L7RKiller';
    $self->{l7r_killer}->run;

    DEBUG 'Starting Cluster Monitor';
    $self->{cluster_monitor}->run;

    # DEBUG 'Starting VM command handler';
    # $self->{vm_command_handler}->run;

    if ($self->{dhcpd_handler}) {
        DEBUG 'Starting DHCPD handler';
        $self->{dhcpd_handler}->run;
    }
    else {
        $debug and $self->_debug("use_dhcp is off");
        INFO "DHCP server is administratively disabled, not running";
    }

    $self->_on_done;
}

sub _start_vm_command_handler {
    my $self = shift;
    DEBUG 'Starting VM command handler';
    $self->{vm_command_handler} = QVD::HKD::VMCommandHandler->new(config => $self->{config},
                                                                  db         => $self->{db},
                                                                  node_id    => $self->{node_id},
                                                                  on_stopped => sub { $self->_on_vm_command_handler_stopped },
                                                                  on_cmd => sub { $self->_on_vm_cmd($_[1], $_[2]) });
    $self->{vm_command_handler}->run;
    $self->_on_done;
}

# vm_command_handler does not appear in the following list because it
# is handled by specific code
my @agent_names = qw(command_handler
                     dhcpd_handler
                     ticker
                     l7r_monitor
                     l7r_killer
                     expiration_monitor
                     cluster_monitor);

sub _check_all_agents_have_stopped {
    my $self = shift;
    $debug and $self->_debug("Agents running: ", join ", ", grep defined($self->{$_}), @agent_names);
    DEBUG "Still running agents: ", join ', ', grep defined($self->{$_}), @agent_names;
    return 0 if grep defined ($self->{$_}), @agent_names;
    $self->_on_all_agents_stopped;
    return 1;
}

sub _stop_vm_command_handler {
    my $self = shift;
    if (defined(my $agent = $self->{vm_command_handler})) {
        $agent->on_hkd_stop;
    }
    else {
        $self->_on_done;
    }
}

sub _stop_all_agents {
    my $self = shift;
    unless ($self->_check_all_agents_have_stopped) {
        for my $agent_name (@agent_names) {
            if (defined (my $agent = $self->{$agent_name})) {
                $agent->on_hkd_stop;
            }
        }
    }
}

sub _on_agent_stopped {
    my ($self, $agent) = @_;
    for my $mine (@{$self}{@agent_names}) {
        undef $mine if defined $mine and $mine == $agent;
    }
    $self->_check_all_agents_have_stopped
}

sub _on_cmd {
    my ($self, $cmd) = @_;
    my $name = "_on_cmd_$cmd";
    my $method = $self->can($name);
    if ($method) {
        $debug and $self->_debug("calling method $name");
        $method->($self);
    }
    else {
        $debug and $self->_debug("no method $name defined");
    }
}

sub _new_vm_handler {
    my ($self, $vm_id) = @_;
    my $vm = $self->{vm}{$vm_id} = QVD::HKD::VMHandler->new(config => $self->{config},
                                                            vm_id =>  $vm_id,
                                                            node_id => $self->{node_id},
                                                            db => $self->{db},
                                                            heavy => $self->{heavy},
                                                            dhcpd_handler => $self->{dhcpd_handler},
                                                            on_stopped => sub { $self->_on_vm_stopped($vm_id) });
    $vm;
}

sub _on_vm_cmd {
    my ($self, $vm_id, $cmd) = @_;
    my $vm = $self->{vm}{$vm_id};

    $debug and $self->_debug("command $cmd received for vm $vm_id");
    INFO "Command '$cmd' received for vm '$vm_id'";

    if ($cmd eq 'start') {
        if (defined $vm) {
            $debug and $self->_debug("start cmd received for live vm $vm_id");
            DEBUG "'start' cmd received for live vm '$vm_id'";
            return;
        }
        else {
            $debug and $self->_debug("creating VM handler agent");
            DEBUG 'Creating VM handler agent';
            $vm = $self->_new_vm_handler($vm_id);

            if ($self->state !~ /^running\b/) {
                # there is a race condition between this HKD setting
                # its state to stopping and other programs sending it a
                # start command for some virtual machine. At this
                # point the VMCommandHandler has already marked the VM
                # as starting so we can not just ignore the
                # command. Instead we make it into a "stop" command.
                $cmd = 'stop';
            }
        }
    }
    unless (defined $vm) {
        $debug and $self->_debug("cmd $cmd received for unknown vm $vm_id");
        WARN "Cmd '$cmd' received for unknown vm '$vm_id'";
        return;
    }
    $vm->on_cmd($cmd);
}

sub _on_expired_vm {
    my ($self, $vm_id, $is_hard, $soft_expiration, $hard_expiration) = @_;
    my $vm = $self->{vm}{$vm_id} or return;

    if ($is_hard) {
        INFO "VM $vm_id has expired (hard), stopping it";
        $vm->on_cmd('stop');
    }
    else {
        INFO "VM $vm_id has expired (soft), telling the user";
        $vm->on_expired($soft_expiration, $hard_expiration);
    }
}

sub _on_vm_stopped {
    my ($self, $vm_id) = @_;

    $debug and $self->_debug("releasing handler for VM $vm_id");
    DEBUG "Releasing handler for VM '$vm_id'";
    delete $self->{vm}{$vm_id};
    keys %{$self->{vm}} or $self->_on_no_vms_are_running;
}

sub _stop_all_vms {
    my $self = shift;
    values %{$self->{vm}}
        or return $self->_on_no_vms_are_running;
    $_->on_hkd_stop for values %{$self->{vm}};
    $self->_call_after($self->_cfg("internal.hkd.stopping.vms.timeout"), '_on_state_timeout');
}

sub _kill_all_vms {
    my $self = shift;
    values %{$self->{vm}}
        or return $self->_on_no_vms_are_running;
    $_->on_hkd_kill for values %{$self->{vm}};
    # FIXME: what to do when not all machines can be killed? nothing? repeat?
    $self->_call_after($self->_cfg("internal.hkd.killing.vms.retry.timeout"), '_kill_all_vms');
}

sub _search_zombies {
    my $self = shift;
    $self->_query( { save_to => 'zombies',
                     log_error => 'unable to retrieve list of zombie vms from table vm_runtimes' },
                   q(select vm_id from vm_runtimes where host_id=$1 and vm_state != 'stopped'), $self->{node_id});
}

sub _catch_zombies {
    my $self = shift;
    my $zombies = delete $self->{zombies};
    if (@$zombies) {
        for my $row (@$zombies) {
            my $vm = $self->_new_vm_handler($row->{vm_id});
            $vm->on_cmd('catch_zombie');
        }
    }
    else {
        $self->_on_done;
    }
}

sub _prepare_storage {
    my $self = shift;

    if ($self->_cfg('vm.hypervisor')       eq 'lxc'  and
        $self->_cfg('vm.lxc.unionfs.type') eq 'btrfs') {
        my $fn = $self->_cfg('path.storage.btrfs.root') . '/qvd_btrfs_lock';
        my $fh;
        unless (open $fh, '>>', $fn) {
            ERROR "Unable to create or open file $fn to work around LXC make-btrfs-ro-on-exit bug: $!";
            $self->_on_error;
        }
        DEBUG "$fn opened";
        $self->{btrfs_lock} = $fh;
    }
    $self->_on_done
}

sub _fw_rules {
    my $self = shift;
    my $netnodes = $self->netnodes;
    my $netvms   = $self->netvms;

    my @rules = ( # forbind opening TCP connections from the VMs to the hosts:
                 [FORWARD => -m => 'iprange', '--src-range' => $netvms, '--dst-range' => $netnodes, '-p' => 'tcp', '--syn', '-j' => 'DROP'],
                 [INPUT   => -m => 'iprange', '--src-range' => $netvms, '-p' => 'tcp', '--syn', '-j', 'DROP'],

                 # otherwise, allow traffic between the hosts and the VMs:
                 [FORWARD => -m => 'iprange', '--src-range' => $netvms, '--dst-range' => $netnodes, '-p' => 'tcp', '-j', 'ACCEPT'],
                 [INPUT   => -m => 'iprange', '--src-range' => $netvms, '-p' => 'tcp', '-j', 'ACCEPT'],

                 # allow DHCP and DNS traffic between the VMs and this host:
                 [INPUT   => -m => 'iprange', '--src-range' => $netvms, '-p' => 'udp', '-m' => 'multiport', '--dports' => '67,53', '-j', 'ACCEPT'],
                 [INPUT   => -m => 'iprange', '--src-range' => $netvms, '-p' => 'tcp', '--dport' => '53',    '-j', 'ACCEPT'],

                 # disallow non-tcp protocols between the VMs and the hosts:
                 [FORWARD => -m => 'iprange', '--src-range' => $netvms, '--dst-range' => $netnodes, '-j', 'DROP'],
                 [INPUT   => -m => 'iprange', '--src-range' => $netvms, '-j', 'DROP'],

                 # forbid traffic between virtual machines:
                 [FORWARD => -m => 'iprange', '--src-range' => $netvms, '--dst-range' => $netvms, '-j', 'DROP'] );

    my $nat_iface = $self->_cfg('vm.network.firewall.nat.iface');
    push @rules, [-t => 'nat', POSTROUTING => -m => 'iprange', '--src-range' => $netvms, -o => $nat_iface, -j => 'MASQUERADE']
        if length $nat_iface;

    @rules;
}

sub _set_fw_rules {
    my $self = shift;
    if ($self->_cfg('internal.vm.network.firewall.enable')) {
        my $iptables = $self->_cfg('command.iptables');
        DEBUG 'Setting up firewall rules';
        for my $rule ($self->_fw_rules) {
            DEBUG "setting iptables entry @$rule";
            my @table = ($rule->[0] eq '-t' ? splice(@$rule, 0, 2) : ());
            if (system $iptables => @table, -A => @$rule) {
                my $rc = $? >> 8;
                ERROR "Unable to set firewall rule, command failed, rc: $rc, cmd: $iptables @table -A @$rule";
                return $self->_on_error;
            }
        }
    }
    else {
        WARN 'Setup of global firewall rules skipped, do you really need to do that?';
    }
    $self->_on_done;
}

sub _remove_fw_rules {
    my $self = shift;
    if ($self->_cfg('internal.vm.network.firewall.enable')) {
        my $iptables = $self->_cfg('command.iptables');
        DEBUG 'Removing firewall rules';
        for my $rule (reverse $self->_fw_rules) {
            DEBUG and $self->_debug("removing iptables entry @$rule");
            my @table = ($rule->[0] eq '-t' ? splice(@$rule, 0, 2) : ());
            if (system $iptables => @table, -D => @$rule) {
                my $rc = $? >> 8;
                INFO "Unable to remove firewall rule, command failed, rc: $rc, cmd: $iptables @table -D @$rule";
            }
        }
    }
    else {
        INFO "cleanup of global firewall rules skipped";
    }
    $self->_on_done;
}

sub _write_vm_report {
    my $self = shift;
    my %state;
    for my $vm (values %{$self->{vm}}) {
        $state{$vm->state}++;
    }
    if (open my $fh, '>', '/tmp/hkd-vm-states') {
        print $fh "HKD Internal VM states report\n", ('-' x 80), "\n";
        for my $state (sort { $state{$b} <=> $state{$a} } keys %state) {
            printf $fh "%5d %s\n", $state{$state}, $state;
        }
    }
    else {
        ERROR "unable to open '/tmp/hkd-vm-states': $!";
    }
}

1;

__END__

=head1 NAME

QVD::HKD - QVD House Keeping Daemon.

=head1 SYNOPSIS

  $ qvd-hkd

=head1 DESCRIPTION

This module implements the main agent for the HKD daemon.

=head1 AUTHOR

Salvador Fandiño, David Serrano.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2012 by Qindel Formación y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.


=cut
