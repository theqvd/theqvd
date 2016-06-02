package QVD::HKD::ClusterMonitor;

use strict;
use warnings;
use Carp;
use QVD::Log;

use QVD::HKD::Helpers;

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative
    __any__       => { advance => '_on_done',
                       transitions => { on_transient_db_error => 'long_delaying',
                                        on_hkd_stop => 'stopped' } },

    new           => { transitions => { _on_run => 'long_delaying'     } },

    running       => { transitions => { _on_error => 'idle' },
                       substates => [ killing_hosts    => { enter => '_kill_hosts' },
                                      # mark nodes that have not touched the database for too long as lost

                                      unassigning_vms  => { enter => '_unassign_vms' },
                                      # unassign VMs on nodes marked as lost

                                      unassigning_l7rs => { enter => '_unassign_l7rs' },
                                      # unassign L7R processes running in nodes marked as lost

                                      aborting_l7rs    => { enter => '_abort_l7rs' },
                                      # abort L7R processes corresponding to machines that are not running

                                      notifying_hkds   => { enter => '_notify_hkds' }
                                      # notify HKDs in other nodes they should handle the abort requests
                                    ] },

    idle          => { enter => '_set_timer',
                       transitions => { _on_timeout => 'running' } },

    # don't do anything for a while if we have had problems connecting to the database
    long_delaying => { enter       => '_set_timer',
                       transitions => { _on_timeout => 'running' } },

    stopped       => { enter       => '_on_stopped' };


sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self->{queue_priority} = 30;
    $self;
}

sub _kill_hosts {
    my ($self) = @_;
    INFO "looking for lost hosts";
    $self->_query(<<'EOQ', $self->{node_id}, $self->_cfg('internal.hkd.cluster.node.timeout'));
update host_runtimes set state = 'lost'
    where state != 'stopped'
      and state != 'starting'
      and state != 'lost'
      and not blocked
      and host_id != $1
      and $2 < extract('epoch' from (now() - ok_ts))
    returning host_id
EOQ
}

sub _on_kill_hosts_result {
    my ($self, $res) = @_;
    WARN "host $_ marked as lost!" for $res->column;
}

sub _unassign_vms {
    my ($self) = @_;
    $self->_query(<<EOQ);
update vm_runtimes
    set vm_state       = 'stopped',
        host_id        = NULL,
        vm_vma_port    = NULL,
        vm_x_port      = NULL,
        vm_vnc_port    = NULL,
        vm_ssh_port    = NULL,
        vm_serial_port = NULL,
        vm_mon_port    = NULL,
        vm_address     = NULL,
        vm_expiration_soft = NULL,
        vm_expiration_hard = NULL,
        vma_ok_ts      = NULL,
        current_di_id  = NULL
    from host_runtimes
    where vm_state != 'stopped'
      and host_runtimes.host_id = vm_runtimes.host_id
      and host_runtimes.state = 'lost'
    returning vm_id
EOQ
}

sub _on_unassign_vms_result {
    my ($self, $res) = @_;
    WARN "VM $_ unassigned from host in state lost" for $res->column;
}

sub _unassign_l7rs {
    my ($self) = @_;
    $self->_query(<<'EOQ', time);
update vm_runtimes
    set user_state  = 'disconnected',
        user_state_ts = $1,
        user_cmd    = NULL,
        l7r_host_id = NULL,
        l7r_pid     = NULL
   from host_runtimes
   where user_state != 'disconnected'
     and host_runtimes.host_id = vm_runtimes.l7r_host_id
     and host_runtimes.state = 'lost'
   returning vm_id
EOQ
}

sub _on_unassign_l7rs_result {
    my ($self, $res) = @_;
    WARN "User connection to VM $_ going through lost host removed" for $res->column;
}

sub _abort_l7rs {
    my ($self) = @_;
    $self->_query({ save_to => 'hosts_to_be_notified' },
                  <<EOQ);
update vm_runtimes
    set user_cmd = 'abort'
    where user_state = 'connected'
      and vm_state = 'stopped'
      and user_cmd = NULL
    returning l7r_host_id
EOQ
}

sub _notify_hkds {
    my $self = shift;
    if (my $hosts = delete $self->{hosts_to_be_notified}) {
        my %hosts;
        $hosts{$_->{l7r_host_id}} = 1 for @$hosts;
        $self->_notify("qvd_user_cmd_for_host$_") for keys %hosts;
    }
    $self->_on_done;
}

sub _set_timer {
    my $self = shift;
    my $long = ($self->state =~ /^long_/ ? 'long_' : '');
    my $delay = $self->_cfg("internal.hkd.agent.cluster_monitor.${long}delay") +
        int rand $self->_cfg("internal.hkd.agent.cluster_monitor.fuzzy_delay");
    $self->_call_after($delay, '_on_timeout');
}

1;
