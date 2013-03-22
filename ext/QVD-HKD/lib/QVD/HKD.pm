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
use Fcntl qw(LOCK_EX LOCK_NB);
use File::Slurp qw(slurp);
use Pg::PQ qw(:pgres);
use QVD::Log;
use AnyEvent::Impl::Perl;
# use AnyEvent::Impl::EV;
use AnyEvent;
use AnyEvent::Pg::Pool;
use Linux::Proc::Net::TCP;

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

use QVD::HKD::Config::Network qw(netvms netnodes net_aton net_ntoa netstart_n network_n);

use parent qw(QVD::HKD::Agent);

use QVD::StateMachine::Declarative
    'new'                            => { transitions => { _on_run                    => 'starting/acquiring_lock'        } },

    'starting/acquiring_lock'        => { enter       => '_acquire_lock',
                                          transitions => { _on_acquire_lock_done      => 'starting/checking_tcp_ports',
                                                           _on_acquire_lock_error     => 'failed'                         } },
    'starting/checking_tcp_ports'    => { enter       => '_check_tcp_ports',
                                          transitions => { _on_check_tcp_ports_done   => 'starting/connecting_to_db',
                                                           _on_check_tcp_ports_error  => 'failed'                         } },

    'starting/connecting_to_db'      => { enter       => '_start_db',
                                          transitions => { _on_db_connected           => 'starting/loading_db_config',
                                                           _on_dead_db                => 'failed'                         } },

    'starting/loading_db_config'     => { enter       => '_start_config',
                                          transitions => { _on_config_reload_done     => 'starting/loading_host_row',
                                                           _on_config_reload_error    => 'failed',
                                                           _on_dead_db                => 'failed'                         } },

    'starting/loading_host_row'      => { enter       => '_load_host_row',
                                          transitions => { _on_load_host_row_done     => 'starting/saving_state',
                                                           _on_load_host_row_error2   => 'failed'                         } },

    'starting/saving_state'          => { enter       => '_save_state',
                                          transitions => { _on_save_state_done        => 'starting/checking_address',
                                                           _on_save_state_error       => 'failed'                         } },

    'starting/checking_address'      => { enter       => '_check_address',
                                          transitions => { _on_check_address_done     => 'starting/preparing_storage',
                                                           _on_check_address_error    => 'failed'                         } },

    'starting/preparing_storage'     => { enter       => '_prepare_storage',
                                          transitions => { _on_prepare_storage_done   => 'starting/removing_old_fw_rules',
                                                           _on_prepare_storage_error  => 'failed'                         } },

    'starting/removing_old_fw_rules' => { enter       => '_remove_fw_rules',
                                          transitions => { _on_remove_fw_rules_done   => 'starting/setting_fw_rules'      } },

    'starting/setting_fw_rules'      => { enter       => '_set_fw_rules',
                                          transitions => { _on_set_fw_rules_done      => 'starting/saving_loadbal_data',
                                                           _on_set_fw_rules_error     => 'failed'                         } },

    'starting/saving_loadbal_data'   => { enter       => '_save_loadbal_data',
                                          transitions => { _on_save_loadbal_data_done => 'starting/ticking',
                                                           _on_save_loadbal_data_error => 'stopping/removing_fw_rules'    } },

    'starting/ticking'               => { enter       => '_start_ticking',
                                          transitions => { _on_ticked                 => 'starting/catching_zombies',
                                                           _on_ticker_error           => 'stopping/removing_fw_rules'     } },

    'starting/catching_zombies'      => { enter       => '_catch_zombies',
                                          transitions => { _on_catch_zombies_done     => 'starting/agents',
                                                           _on_catch_zombies_error    => 'stopping/removing_fw_rules'     } },

    'starting/agents'                => { enter       => '_start_agents',
                                          transitions => { _on_agents_started         => 'running/saving_state'           } },

    'running/saving_state'           => { enter       => '_save_state',
                                          transitions => { _on_save_state_done        => 'running/agents',
                                                           _on_save_state_error       => 'stopping/killing_all_vms'       } },

    'running/agents'                 => { enter       => '_start_vm_command_handler',
                                          transitions => { _on_start_vm_command_handler_done => 'running'                 } },

    'running'                        => { transitions => { _on_cmd_stop               => 'stopping',
                                                           _on_dead_db                => 'stopping/killing_all_vms',
                                                           _on_ticker_error           => 'stopping/killing_all_vms'       } },

    'stopping'                       => { jump        => 'stopping/saving_state'                                            },

    'stopping/saving_state'          => { enter       => '_save_state',
                                          transitions => { _on_save_state_done        => 'stopping/stopping_all_vms',
                                                           _on_save_state_error       => 'stopping/killing_all_vms'       } },

    'stopping/stopping_all_vms'      => { enter       => '_stop_all_vms',
                                          leave       => '_abort_all',
                                          transitions => { _on_stop_all_vms_done      => 'stopping/stopping_all_agents',
                                                           _on_state_timeout          => 'stopping/killing_all_vms'       } },

    'stopping/killing_all_vms'       => { enter       => '_kill_all_vms',
                                          leave       => '_abort_all',
                                          transitions => { _on_stop_all_vms_done      => 'stopping/stopping_all_agents'   } },

    'stopping/stopping_all_agents'   => { enter       => '_stop_all_agents',
                                          transitions => { _on_all_agents_stopped     => 'stopping/removing_fw_rules'     } },

    'stopping/removing_fw_rules'     => { enter       => '_remove_fw_rules',
                                          transitions => { _on_remove_fw_rules_done   => 'stopped/saving_state'           } },

    'stopped/saving_state'           => { enter       => '_save_state',
                                          transitions => { _on_save_state_done        => 'stopped/bye',
                                                           _on_save_state_error       => 'stopped/bye'                    } },

    'stopped/bye'                    => { enter       => '_say_goodbye'                                                   },

    failed                           => { enter       => '_say_goodbye'                                                   },

    __any__                          => { ignore      => [qw(_on_ticked
                                                             _on_stop_all_vms_done
                                                             _on_transient_db_error
                                                             _on_config_reload_done
                                                             _on_config_reload_error )],
                                          delay_once  => [qw(_on_cmd_stop
                                                             _on_dead_db
                                                             _on_ticker_error)]                                                  };

sub _on_transient_db_error :OnState('running') {
    shift->{cluster_monitor}->on_transient_db_error
}

sub new {
    my ($class, %opts) = @_;
    # $opts{$_} //= $defaults{$_} for keys %defaults;
    my $config_file = delete $opts{config_file} // croak "configuration file missing";

    my $self = $class->SUPER::new(%opts);
    $self->{config} = QVD::HKD::Config->new(config_file => $config_file,
                                            on_reload_done => sub { $self->_on_config_reload_done },
                                            on_reload_error => sub { $self->_on_config_reload_error });
    $self->{vm} = {};
    $self->{heavy} = {};
    $self->{delayed} = {};
    $self;
}

sub _acquire_lock {
    my $self = shift;
    my $lock_file = $self->_cfg('internal.hkd.lock.path');
    DEBUG "Trying to get lock at '$lock_file'";
    if (open my $lf, '>', $lock_file) {
        if (flock $lf, LOCK_EX|LOCK_NB) {
            $self->{lock_file} = $lf;
            DEBUG 'Lock acquired';
            return $self->_on_acquire_lock_done;
        }
        if ($self->{lock_retries}++ < $self->_cfg('internal.hkd.lock.retries')) {
            $debug and $self->_debug("lock busy, delaying... ($!)");
            DEBUG "Lock busy ($!), delaying...";
            return $self->_call_after($self->_cfg('internal.hkd.lock.delay'), sub { $self->_acquire_lock });
        }
        $debug and $self->_debug("unable to lock file, tried $self->{lock_retries} times: $!");
        ERROR "Unable to lock file, tried '$self->{lock_retries}' times: $!";
    }
    else {
        $debug and $self->_debug("unable to open lock file $lock_file: $!");
        ERROR "Unable to open lock file '$lock_file': $!";
    }
    $self->_on_acquire_lock_error;
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
        $self->_on_check_tcp_ports_error;
    }
    else {
        $self->_on_check_tcp_ports_done;
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
    $self->_on_db_connected;
}

sub _start_config {
    my $self = shift;
    DEBUG 'Loading configuration';
    $self->{config}->set_db($self->{db});
}

sub _load_host_row {
    my $self = shift;
    my $host = $self->_cfg('nodename');
    DEBUG "Loading entry for host '$host' from DB";
    $self->_query_1('select id, address from hosts where name=$1', $host);
}

sub _on_load_host_row_error {
    my ($self, $res) = @_;
    $self->_debug("node row not found in database");
    ERROR "Unable to retrieve node data from database";
    $self->_on_load_host_row_error2
}

sub _on_load_host_row_result {
    my ($self, $res) = @_;
    @{$self}{qw(node_id address)} = $res->row;
}

sub _check_address {
    my $self = shift;
    my $address_q = quotemeta $self->{address};
    my $ifaces = `ip -f inet addr show`;
    unless ($ifaces =~ /inet $address_q\b/) {
        ERROR "IP address $self->{address} not configured on node";
        return $self->_on_check_address_error
    }
    $self->_debug("some interface has IP $self->{address}:\n$ifaces");

    my $address_n = net_aton($self->{address});
    my $start_n = netstart_n($self);
    my $net_n = network_n($self);
    if ($address_n <= $net_n or $address_n >= $start_n) {
        ERROR sprintf("Host IP address is outside of the network range reserved for hosts (IP: %s, range: %s-%s)",
                      $self->{address}, net_ntoa($net_n), net_ntoa($start_n));
        return $self->_on_check_address_error;
    }
    $self->_on_check_address_done;
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

sub _save_state {
    my $self = shift;
    my $state = $self->_main_state;
    $debug and $self->_debug("changing database state to $state");
    $self->_query('update host_runtimes set state = $1 where host_id = $2',
                  $state, $self->{node_id});
}

sub _on_save_state_result {}

sub _save_loadbal_data {
    my $self = shift;
    my ($cpu, $ram) = _calc_load_balancing_data;
    $self->_query(q(update host_runtimes set usable_cpu=$1, usable_ram=$2 where host_id=$3),
                  $cpu, $ram, $self->{node_id});
}

sub _on_save_loadbal_data_bad_result {
    # FIXME
    exit(1);
}

sub _on_save_loadbal_data_error {
    # FIXME
    exit(1);
}

sub _on_save_loadbal_data_result {}

sub _start_ticking {
    my $self = shift;
    $self->{ticker} = QVD::HKD::Ticker->new( config => $self->{config},
                                             db => $self->{db},
                                             node_id => $self->{node_id},
                                             on_ticked => sub { $self->_on_ticked },
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

    $self->{command_handler}    = QVD::HKD::CommandHandler->new(%opts, on_cmd => sub { $self->_on_cmd($_[1]) });
    $self->{vm_command_handler} = QVD::HKD::VMCommandHandler->new(%opts, on_cmd => sub { $self->_on_vm_cmd($_[1], $_[2]) });
    $self->{l7r_monitor}        = QVD::HKD::L7RMonitor->new(%opts);
    $self->{cluster_monitor}    = QVD::HKD::ClusterMonitor->new(%opts);
    $self->{dhcpd_handler} = QVD::HKD::DHCPDHandler->new(%opts)
        if $self->_cfg("vm.network.use_dhcp");

    DEBUG 'Starting command handler';
    $self->{command_handler}->run;

    DEBUG 'Starting L7R Monitor';
    $self->{l7r_monitor}->run;

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

    $self->_on_agents_started;
}

sub _start_vm_command_handler {
    my $self = shift;
    DEBUG 'Starting VM command handler';
    $self->{vm_command_handler}->run;
    $self->_on_start_vm_command_handler_done;
}

my @agent_names = qw(vm_command_handler
                     command_handler
                     dhcpd_handler
                     ticker
                     l7r_monitor
                     cluster_monitor);

sub _check_all_agents_have_stopped {
    my $self = shift;
    $debug and $self->_debug("Agents running: ", join ", ", grep defined($self->{$_}), @agent_names);
    DEBUG "Still running agents: ", join ', ', grep defined($self->{$_}), @agent_names;
    return 0 if grep defined ($self->{$_}), @agent_names;
    $self->_on_all_agents_stopped;
    return 1;
}

sub _stop_all_agents {
    my $self = shift;
    unless ($self->_check_all_agents_have_stopped) {
        for my $agent_name (@agent_names) {
            my $agent = $self->{$agent_name};
            if (defined $agent) {
                $agent->on_hkd_stop
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
                                                            dhcpd_handler => $self->{dhcpd_handler},
                                                            on_stopped => sub { $self->_on_vm_stopped($vm_id) },
                                                            on_delete_cmd => sub { $self->_on_vm_cmd_done($vm_id) },
                                                            on_heavy => sub { $self->_on_vm_heavy($vm_id, @_) } );
    $debug and $self->_debug_vm_stats;
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
        if ($self->state eq 'running') {
            $debug and $self->_debug("creating VM handler agent");
            DEBUG 'Creating VM handler agent';
            $vm = $self->_new_vm_handler($vm_id);
        }
        else {
            $debug and $self->_debug("dropping command $cmd for vm $vm_id while on state " . $self->state);
            WARN "Dropping command '$cmd' received for '$vm_id' while on state " . $self->state;
            return $self->_on_vm_cmd_done($vm_id);
        }
    }
    unless (defined $vm) {
        $debug and $self->_debug("cmd $cmd received for unknown vm $vm_id");
        WARN "Cmd '$cmd' received for unknown vm '$vm_id'";
        return;
    }
    $vm->on_cmd($cmd);
    $debug and $self->_debug_vm_stats;
}

sub _on_vm_stopped {
    my ($self, $vm_id) = @_;

    $debug and $self->_debug("releasing handler for VM $vm_id");
    DEBUG "Releasing handler for VM '$vm_id'";
    delete $self->{vm}{$vm_id};
    my $all_done = not keys %{$self->{vm}};
    $debug and $self->_debug("all VM done: $all_done");
    delete $self->{delayed}{$vm_id};
    if (delete $self->{heavy}{$vm_id}) {
        $debug and $self->_debug("VM was in a heavy state");
        $self->_run_delayed;
    }
    $debug and $self->_debug_vm_stats;
    $self->_on_stop_all_vms_done if $all_done;
}

sub _debug_vm_stats {
    my $self = shift;
    my $ts = Time::HiRes::time();
    my $running = keys %{$self->{vm}};
    my $heavy = keys %{$self->{heavy}};
    my $delayed = keys %{$self->{delayed}};
    $self->_debug("VMs in this host: $running, heavy: $heavy, delayed: $delayed, time: $ts");

    my %state;
    for my $vm (values %{$self->{vm}}) {
        $state{$vm->state}++;
    }
    $self->_debug("VM states: " . join ', ', map "$_: $state{$_}", sort keys %state);
}

sub _on_vm_heavy {
    my ($self, $vm_id, undef, $set) = @_;
    $debug and $self->_debug("_on_vm_heavy($vm_id, $set) called");
    if ($set) {
        if ($self->{heavy}{$vm_id}) {
            $debug and $self->_debug("VM $vm_id is already marked as heavy");
            return 1;
        }
        if (keys %{$self->{heavy}} <= $self->_cfg('internal.hkd.max_heavy')) {
            $debug and $self->_debug("VM $vm_id marked as heavy");
            $self->{heavy}{$vm_id} = 1;
            $debug and $self->_debug_vm_stats;
            return 1;
        }
        else {
            $debug and $self->_debug("Can't mark VM $vm_id as heavy, there are already too many");
            $self->{delayed}{$vm_id} = 1;
            $debug and $self->_debug_vm_stats;
            return;
        }
    }
    else {
        $debug and $self->_debug("Removing heavy mark for VM $vm_id");
        delete $self->{heavy}{$vm_id};
        $debug and $self->_debug_vm_stats;
        $self->_run_delayed;
    }
}

sub _run_delayed {
    my $self = shift;
    while (keys %{$self->{delayed}} and
           keys %{$self->{heavy}} <= $self->_cfg('internal.hkd.max_heavy')) {
        $debug and $self->_debug_vm_stats;
        my $vm_id = each %{$self->{delayed}};
        delete $self->{delayed}{$vm_id};
        $self->_on_vm_cmd($vm_id, 'go_heavy');
    }
}

sub _on_vm_cmd_done {
    my ($self, $vm_id) = @_;
    $self->{vm_command_handler}->_on_cmd_done($vm_id);
}

sub _on_failed { croak "something come completely wrong, aborting...\n" }

sub _stop_all_vms {
    my $self = shift;
    values %{$self->{vm}}
        or return $self->_on_stop_all_vms_done;
    $_->on_hkd_stop for values %{$self->{vm}};
    $self->_call_after($self->_cfg("internal.hkd.stopping.vms.timeout"), '_on_state_timeout');
}

sub _kill_all_vms {
    my $self = shift;
    values %{$self->{vm}}
        or return $self->_on_stop_all_vms_done;
    $_->on_hkd_kill for values %{$self->{vm}};
    # FIXME: what to do when not all machines can be killed? nothing? repeat?
    $self->_call_after($self->_cfg("internal.hkd.killing.vms.retry.timeout"), '_kill_all_vms');
}

sub _catch_zombies {
    my $self = shift;
    $self->_query('select vm_id from vm_runtimes where host_id=$1 and vm_state != \'stopped\'', $self->{node_id});
}

sub _on_catch_zombies_bad_result { }

sub _on_catch_zombies_result {
    my ($self, $res) = @_;
    for my $i (0 .. $res->rows - 1) {
        my $vm_id = $res->row($i);
        my $vm = $self->_new_vm_handler($vm_id);
        $vm->on_cmd('catch_zombie');
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
            $self->_on_prepare_storage_error;
        }
        DEBUG "$fn opened";
        $self->{btrfs_lock} = $fh;
    }
    $self->_on_prepare_storage_done
}

sub _fw_rules {
    my $self = shift;
    my $netnodes = $self->netnodes;
    my $netvms   = $self->netvms;

    ( # forbind opening TCP connections from the VMs to the hosts:
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
}

sub _set_fw_rules {
    my $self = shift;
    if ($self->_cfg('internal.vm.network.firewall.enable')) {
        my $iptables = $self->_cfg('command.iptables');
        DEBUG 'Setting up firewall rules';
        for my $rule ($self->_fw_rules) {
            $debug and $self->_debug("setting iptables entry @$rule");
            if (system $iptables => -A => @$rule) {
                $debug and $self->_debug("iptables command failed, rc: " . ($? >> 8));
                return $self->_on_set_fw_rules_error;
            }
        }
    }
    else {
        $debug and $self->_debug("setup of global firewall rules skipped, do you really need to do that?");
        INFO 'Setup of global firewall rules skipped, do you really need to do that?';
    }
    $self->_on_set_fw_rules_done;
}

sub _remove_fw_rules {
    my $self = shift;
    if ($self->_cfg('internal.vm.network.firewall.enable')) {
        my $iptables = $self->_cfg('command.iptables');
        DEBUG 'Removing firewall rules';
        for my $rule (reverse $self->_fw_rules) {
            $debug and $self->_debug("removing iptables entry @$rule");
            if (system $iptables => -D => @$rule) {
                $debug and $self->_debug("iptables command failed, rc: " . ($? >> 8));
            }
        }
    }
    else {
         $debug and $self->_debug("cleanup of global firewall rules skipped");
    }
    $self->_on_remove_fw_rules_done;
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
        $debug and $self->_debug("VM states report written to '/tmp/hkd-vm-states");
    }
    else {
        ERROR "unable to open '/tmp/hkd-vm-states': $!";
    }
}

1;

__END__

# HKD tasks:
#
# * keep connection to the database open
# * (re)load config
# * periodically check for commands and launch/stop virtual machines
# * update Host_Runtimes table
# * monitor other HKDs
# * clean shutdown
# * run and monitor DHCP
# * run and monitor L7R
# * kill dangling L7R processes for disconnected VMs

# VM tasks:
#
# * start/stop
# * monitor processes
# * keep internal state
# * keep public info in VM_Runtimes table

# Concerns
#
# * DB may be a bottleneck, should we use some kind of priority system
# or whatever? add timeouts for push_query into AnyEvent::Pg?
#




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
