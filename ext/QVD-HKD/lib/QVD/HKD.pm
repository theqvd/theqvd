package QVD::HKD;

our $VERSION = '3.00';

use 5.010;

our $debug = 1;

$Class::StateMachine::debug ||= -1;
$AnyEvent::Pg::debug ||= 0;

use strict;
use warnings;
no warnings 'redefine';

use Carp;
use File::Slurp qw(slurp);
use File::Spec;
use Pg::PQ qw(:pgres);
use QVD::Log;
# use AnyEvent::Impl::Perl;
use AnyEvent::Impl::EV;
use AnyEvent;
use AnyEvent::Semaphore;
use AnyEvent::Pg::Pool;
use Linux::Proc::Net::TCP;
use Linux::Proc::Net::UDP;
use Method::WeakCallback qw(weak_method_callback);
use Time::HiRes ();

use QVD::HKD::Helpers;

use QVD::HKD::Config;
use QVD::HKD::Ticker;
use QVD::HKD::ClusterMonitor;
use QVD::HKD::DHCPDHandler;
use QVD::HKD::CommandHandler;
use QVD::HKD::VMCommandHandler;
use QVD::HKD::L7RListener;
use QVD::HKD::L7R;
use QVD::HKD::L7RKiller;
use QVD::HKD::ExpirationMonitor;

use QVD::HKD::Config::Network qw(netvms netnodes net_aton net_ntoa netstart_n network_n netmask_n);

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative
    __any__        => { advance => '_on_done',
                        on => { _on_dead_db => '_on_error',
                                _on_ticker_error => '_on_error' },
                        ignore => [qw(_on_db_ticked
                                      _on_transient_db_error
                                      _on_config_reload_done
                                      _on_no_vms_are_running
                                      _on_no_l7rs_are_running)],
                        delay => [qw(_on_cmd_stop)],
                        before => {_on_config_reload_done => '_sync_db_config' } },

    new            => { before => { _on_run => '_say_hello' },
                        transitions => { _on_run => 'starting'} },

    starting       => { substates => [ zero => { transitions => { _on_error => 'exit',
                                                                  _on_cmd_stop => 'exit' },
                                                 substates => [ acquiring_hkd_lock    => { enter => '_acquire_hkd_lock' },
                                                                acquiring_vm_lock     => { enter => '_acquire_vm_lock' },
                                                                connecting_to_db      => { enter => '_start_db' },
                                                                checking_db_version   => { enter => '_check_db_version' },
                                                                loading_db_config     => { enter => '_start_config',
                                                                                           on => { _on_config_reload_done => '_on_done' } },
                                                                loading_host_row      => { enter => '_load_host_row' },
                                                                checking_net_ports    => { enter => '_check_net_ports' },
                                                                checking_address      => { enter => '_check_address' },
                                                                checking_bridge_fw    => { enter => '_check_bridge_fw' },
                                                                starting_hypervisor   => { enter => '_start_hypervisor' } ] },

                                       setup => { transitions => { _on_error => 'stopping',
                                                                   _on_cmd_stop => 'stopping' },
                                                  substates => [ saving_state          => { enter => '_save_state' },
                                                                 setting_process_limits=> { enter => '_set_process_limits' },
                                                                 preparing_storage     => { enter => '_prepare_storage' },
                                                                 removing_old_fw_rules => { enter => '_remove_fw_rules' },
                                                                 setting_fw_rules      => { enter => '_set_fw_rules' },
                                                                 saving_loadbal_data   => { enter => '_save_loadbal_data' },
                                                                 ticking               => { enter => '_start_ticker',
                                                                                            on => { _on_db_ticked => '_on_done' } },
                                                                 cleaningup_zombie_l7rs=> { enter => '_cleanup_zombie_l7rs' },
                                                                 searching_zombie_vms  => { enter => '_search_zombie_vms' },
                                                                 catching_zombie_vms   => { enter => '_catch_zombie_vms',
                                                                                            on => { _on_no_vms_are_running => '_on_done' } },
                                                                 agents                => { enter => '_start_agents' } ] } ] },

    running        => { transitions => { _on_error   => 'stopping' },
                        substates => [ saving_state => { enter => '_save_state' },
                                       agents       => { enter => '_start_later_agents' },
                                       main         => { on => { _on_cmd_stop => '_on_done' } } ] },

    stopping       => { on => { _on_error => '_on_done' },
                        ignore => [qw(_on_ticker_error _on_dead_db)],
                        substates => [ stopping_l7r_listener       => { enter => '_stop_l7r_listener',
                                                                        on => { _on_l7r_listener_stopped => '_on_done' } },
                                       stopping_vm_command_handler => { enter => '_stop_vm_command_handler',
                                                                        on => { _on_vm_command_handler_stopped => '_on_done' } },
                                       saving_state                => { enter => '_save_state' },
                                       stopping_all_l7rs           => { enter => '_stop_all_l7rs',
                                                                      on => { _on_no_l7rs_are_running => '_on_done',
                                                                              _on_state_timeout       => '_on_error'} },
                                       stopping_all_vms            => { enter => '_stop_all_vms',
                                                                        on => { _on_no_vms_are_running => '_on_done',
                                                                                _on_state_timeout      => '_on_error' },
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
    $self->{l7r} = {};
    $self->{vm} = {};
    $self->{heavy} = AnyEvent::Semaphore->new($self->_cfg('internal.hkd.max_heavy'));
    $self->{query_priority} = 30;
    $self;
}

sub _say_hello { INFO "HKD starting, PID: $$" }

sub _acquire_hkd_lock {
    my $self = shift;
    my $file = $self->_cfg('internal.hkd.lock.path');
    $self->_flock({ save_to => 'hkd_lock_fh',
                    log_error => "Unable to lock file '$file'",
                    retries => 3 },
                  $file);
}

sub _acquire_vm_lock {
    my $self = shift;
    my $file = $self->_cfg('internal.hkd.vm.lock.path');
    $self->_flock({ save_to => 'vm_lock_fh',
                    log_error => "Unable to lock file '$file', some VM processes may still be running ".
                                 "from a previous invocation of the HKD",
                    retries => 1 },
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

sub _check_net_ports {
    my $self = shift;
    my $n_n = network_n($self);
    my $nm_n = netmask_n($self);
    my $any_n = net_aton('0.0.0.0');

    # UDP port for bootps (67) is not checked because dnsmasq binds to
    # 0.0.0.0 with reuse port and address options set and then uses
    # the SO_BINDTODEVICE to only receive packets on the designated
    # interface.

    my @ports = (53); # 67

    INFO "checking for free TCP ports " . join(", ", @ports);
    for my $listener (Linux::Proc::Net::TCP->read->listeners) {
        if ($listener->ip4) {
            for my $port (@ports) {
                if ($listener->local_port == $port) {
                    my $la = $listener->local_address;
                    my $la_n = net_aton($la);
                    if ($la_n == $any_n or
                        ($la_n & $nm_n) == $n_n) {
                        ERROR "TCP port $port is already in use for IP $la";
                        $self->_on_error;
                        return;
                    }
                }
            }
        }
    }

    INFO "checking for free UDP ports " . join(", ", @ports);
    for my $listener (@{Linux::Proc::Net::UDP->read}) {
        if ($listener->ip4) {
            for my $port (@ports) {
                if ($listener->local_port == $port) {
                    my $la = $listener->local_address;
                    my $la_n = net_aton($la);
                    if ($la_n == $any_n or
                        ($la_n & $nm_n) == $n_n) {
                        ERROR "UDP port $port is already in use for IP $la";
                        $self->_on_error;
                        return;
                    }
                }
            }
        }
    }

    $self->_on_done;
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

    for my $agent_name (qw(l7r_listener hypervisor)) {
        if (my $agent = $self->{$agent_name}) {
            $agent->on_config_changed;
        }
    }
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
    DEBUG "checking the node has configured IP $self->{address}";
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

sub _check_bridge_fw {
    my $self = shift;
    if ($self->_cfg('internal.vm.network.firewall.enable')) {
        DEBUG "checking kernel module br_netfilter is loaded and working";
        for my $i (0, 1) {
            my $out = `sysctl net.bridge.bridge-nf-call-iptables 2>&1`;
            $out =~ /\s*=\s*\d+$/ and last;

            if ($i) {
                ERROR "br_netfilter module is not loaded";
                return $self->_on_error;
            }

            system modprobe => 'br_netfilter';
        }
    }

    $self->_on_done;
}

my %hypervisor_class = map { $_ => __PACKAGE__ . '::Hypervisor::' . uc $_ } qw(kvm lxc nothing);

sub _start_hypervisor {
    my $self = shift;

    my $hypervisor = $self->_cfg('vm.hypervisor');
    my $hypervisor_class = $hypervisor_class{$hypervisor} // croak "unsupported hypervisor $hypervisor";
    eval "require $hypervisor_class; 1" or LOGDIE "unable to load module $hypervisor_class:\n$@";
    $self->{hypervisor} = $hypervisor_class->new(config     => $self->{config},
                                                 db         => $self->{db},
                                                 on_stopped => weak_method_callback($self, '_on_agent_stopped'));
    DEBUG 'Starting hypervisor';
    $self->{hypervisor}->run;
    return $self->_on_done;
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
    $self->{ticker} = QVD::HKD::Ticker->new( config     => $self->{config},
                                             db         => $self->{db},
                                             node_id    => $self->{node_id},
                                             on_ticked  => weak_method_callback($self, '_on_db_ticked'),
                                             on_error   => weak_method_callback($self, '_on_ticker_error'),
                                             on_stopped => weak_method_callback($self, '_on_agent_stopped') );
    DEBUG 'Starting ticker';
    $self->{ticker}->run;
}

sub _start_agents {
    my $self = shift;
    my %opts = ( config     => $self->{config},
                 db         => $self->{db},
                 node_id    => $self->{node_id},
                 on_stopped => weak_method_callback($self, '_on_agent_stopped') );

    $self->{command_handler}    = QVD::HKD::CommandHandler->new(%opts,
                                                                on_cmd => sub { $self->_on_cmd($_[1]) });
    $self->{expiration_monitor} = QVD::HKD::ExpirationMonitor->new(%opts,
                                                                  on_expired_vm => sub { $self->_on_expired_vm(@_[1..3])});
    $self->{l7r_killer}         = QVD::HKD::L7RKiller->new(%opts,
                                                           on_cmd_abort => sub { $self->_on_l7r_cmd_abort($_[1])});
    $self->{cluster_monitor}    = QVD::HKD::ClusterMonitor->new(%opts);
    $self->{dhcpd_handler} = QVD::HKD::DHCPDHandler->new(%opts)
        if $self->_cfg("vm.network.use_dhcp");

    DEBUG 'Starting command handler';
    $self->{command_handler}->run;

    DEBUG 'Starting ExpirationMonitor';
    $self->{expiration_monitor}->run;

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

sub _start_later_agents {
    my $self = shift;
    my %opts = ( config     => $self->{config},
                 db         => $self->{db},
                 node_id    => $self->{node_id});

    DEBUG 'Starting VM command handler';
    $self->{vm_command_handler} =
                 QVD::HKD::VMCommandHandler->new(%opts,
                                                 on_cmd => sub { $self->_on_vm_cmd($_[1], $_[2]) },
                                                 on_stopped => weak_method_callback($self, '_on_vm_command_handler_stopped'));
    $self->{vm_command_handler}->run;

    DEBUG 'Starting L7R listener';
    $self->{l7r_listener} =
        QVD::HKD::L7RListener->new(%opts,
                                   on_connection => sub { $self->_on_l7r_connection($_[1]) },
                                   on_stopped => weak_method_callback($self, '_on_l7r_listener_stopped'));
    $self->{l7r_listener}->run;
    $self->_on_done;
}

# vm_command_handler does not appear in the following list because it
# is handled by specific code
my @agent_names = qw(command_handler
                     dhcpd_handler
                     ticker
                     l7r_killer
                     expiration_monitor
                     cluster_monitor
                     hypervisor
                   );

sub _check_all_agents_have_stopped {
    my $self = shift;
    $debug and $self->_debug("Agents running: ", join ", ", grep defined($self->{$_}), @agent_names);
    DEBUG "Still running agents: ", join ', ', grep defined($self->{$_}), @agent_names;
    return 0 if grep defined ($self->{$_}), @agent_names;
    $self->_on_all_agents_stopped;
    return 1;
}

sub _stop_l7r_listener {
    my $self = shift;
    my $agent = $self->{l7r_listener}
        or return $self->_on_done;
    $agent->on_hkd_stop;
}

sub _stop_vm_command_handler {
    my $self = shift;
    my $agent = $self->{vm_command_handler}
        or return $self->_on_done;
    $agent->on_hkd_stop;
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

sub _on_l7r_connection {
    my ($self, $fh) = @_;
    my $l7r = QVD::HKD::L7R->new(config => $self->{config},
                                 db => $self->{db},
                                 node_id => $self->{node_id},
                                 on_stopped => weak_method_callback($self, '_on_l7r_stopped')) or
              die "Couldn't create new L7R object";
    if (my $pid = $l7r->run($fh)) {
        INFO "New L7R process started, PID: $pid";
        $self->{l7r}{$pid} = $l7r;
    }
}

sub _on_l7r_stopped {
    my ($self, $l7r) = @_;
    DEBUG "L7R agent $l7r is stopped";
    my $pid = $l7r->pid;
    INFO "L7R process finished, PID: $pid";
    my $l7r1 = delete $self->{l7r}{$pid};
    $l7r == $l7r1 or ERROR "Internal error, L7R caller is different from the cached one: $l7r != $l7r1";
    keys %{$self->{l7r}} or $self->_on_no_l7rs_are_running;
}

sub _on_l7r_cmd_abort {
    my ($self, $l7r_pid) = @_;
    DEBUG "aborting L7R with PID $l7r_pid";
    if (my $l7r = $self->{l7r}{$l7r_pid}) {
        $l7r->abort;
    }
    else {
        WARN "I know nothing about an L7R with PID $l7r_pid";
    }
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
    my $vm = $self->{vm}{$vm_id} =
        $self->{hypervisor}->new_vm_handler(config => $self->{config},
                                            vm_id =>  $vm_id,
                                            node_id => $self->{node_id},
                                            db => $self->{db},
                                            vm_lock_fh => $self->{vm_lock_fh},
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

sub _hash_apply_method {
    my ($self, $hash, $method) = @_;
    my $count = 0;
    for my $key (keys %{$self->{$hash}}) {
        if (defined (my $entry = $self->{$hash}{$key})) {
            $entry->$method;
            $count++;
        }
        else {
            delete $self->{$hash}{$key}
        }
    }
    $count;
}

sub _call_for_all_vms {
    my ($self, $method) = @_;
    my $count = 0;
    for my $key (keys %{$self->{vm}}) {
        if (defined (my $vm = $self->{vm}{$key})) {
            $vm->$method;
            $count++;
        }
        else {
            delete $self->{vm}{$key}
        }
    }
    $count;
}

sub _stop_all_l7rs {
    my $self = shift;
    _hash_apply_method($self, 'l7r', 'on_hkd_stop')
        or return $self->_on_no_l7rs_are_running;

    $self->_call_after($self->_cfg("internal.hkd.stopping.l7rs.timeout"), '_on_state_timeout');
}

sub _stop_all_vms {
    my $self = shift;
    _hash_apply_method($self, 'vm', 'on_hkd_stop')
        or return $self->_on_no_vms_are_running;

    $self->_call_after($self->_cfg("internal.hkd.stopping.vms.timeout"), '_on_state_timeout');
}

sub _kill_all_vms {
    my $self = shift;
    _hash_apply_method($self, 'vm', 'on_hkd_kill')
        or return $self->_on_no_vms_are_running;

    # FIXME: what to do when not all machines can be killed? nothing? repeat?
    $self->_call_after($self->_cfg("internal.hkd.killing.vms.retry.timeout"), '_kill_all_vms');
}

sub _cleanup_zombie_l7rs {
    # FIXME: is that enough? should we try to actually kill the process?
    my $self = shift;
    $self->_query( { log_error => 'unable to clean up old l7r connections' },
                   <<'EOQ', $self->{node_id});
update vm_runtimes
   set user_cmd = NULL,
       l7r_host_id = NULL,
       l7r_pid = NULL,
       user_state = 'disconnected'
   where l7r_host_id = $1
EOQ
}

sub _search_zombie_vms {
    my $self = shift;
    $self->_query( { save_to => 'zombie_vms',
                     log_error => 'unable to retrieve list of zombie vms from table vm_runtimes' },
                   q(select vm_id from vm_runtimes where host_id=$1 and vm_state != 'stopped'), $self->{node_id});
}

sub _catch_zombie_vms {
    my $self = shift;
    my $zombie_vms = delete $self->{zombie_vms};
    if (@$zombie_vms) {
        for my $row (@$zombie_vms) {
            my $vm = $self->_new_vm_handler($row->{vm_id});
            $vm->on_cmd('catch_zombie');
        }
    }
    else {
        $self->_on_done;
    }
}

sub _set_process_limits {
    my $self = shift;
    for my $name (qw(as core data fsize memlock nice nofile stack)) {
        if (defined (my $soft_limit = $self->_cfg_optional("hkd.process.limit.$name"))) {
            my $hard_limit = $self->_cfg_optional("hkd.process.limit.hard.$name") // $soft_limit;
            DEBUG "Setting limit $name to soft $soft_limit, hard $hard_limit";
            my $resource = 'RLIMIT_' . uc($name);
            require BSD::Resource;
            BSD::Resource::setrlimit($resource, $soft_limit, $hard_limit) or
                    WARN "Setting limit $name to soft $soft_limit and hard $hard_limit failed: $!";
        }
    }
    $self->_on_done;
}

sub _prepare_storage {
    my $self = shift;
    if ($self->_cfg('vm.hypervisor') eq 'lxc') {
        # Initializing the unionfs backend here is quite ugly but it
        # allows us to catch some fatal errors during startup.
        my $driver = $self->_cfg('vm.lxc.unionfs.type');
        $driver =~ s/-/_/g;
        my $class = "QVD::HKD::VMHandler::LXC::FS::$driver";
        local $@;
        unless ($driver =~ /^\w+$/ and eval "require $class; 1") {
            ERROR "bad storage type $driver or unable to load backend module: $@";
            return $self->_on_error;
        }

        if (defined (my $init = $class->can('init_backend'))) {
            DEBUG "initializing unionfs $driver backend";
            return $init->($self, '_on_done', '_on_error');
        }
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
        # FIXME: investigate why sometimes undefs appear here!
        if (defined $vm) {
            $state{$vm->state}++;
        }
        else {
            DEBUG 'internal error: undef found inside %{hkd->{vm}}';
        }
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

Salvador Fandino, David Serrano.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011-2012 by Qindel Formación y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.


=cut
