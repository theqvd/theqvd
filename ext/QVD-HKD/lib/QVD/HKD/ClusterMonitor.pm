package QVD::HKD::ClusterMonitor;

use strict;
use warnings;
use Carp;
use QVD::Log;
use DateTime;
use AnyEvent;
use Pg::PQ qw(:pgres);

use QVD::HKD::Helpers;

use parent qw(QVD::HKD::Agent);

use QVD::StateMachine::Declarative
    new              => { transitions => { _on_run                 => 'long_delaying'     } },

    # mark nodes that have not touched the database for too long as lost:
    killing_hosts    => { enter       => '_kill_hosts',
                          transitions => { _on_kill_hosts_done     => 'unassigning_vms',
                                           _on_kill_hosts_error    => 'unassigning_vms'   } },

    # unassign VMs on nodes marked as lost
    unassigning_vms  => { enter       => '_unassign_vms',
                          transitions => { _on_unassign_vms_done   => 'unassigning_l7rs',
                                           _on_unassign_vms_error  => 'unassigning_l7rs'  } },

    # unassign L7R processes running in nodes marked as lost
    unassigning_l7rs => { enter       => '_unassign_l7rs',
                          transitions => { _on_unassign_l7rs_done  => 'aborting_l7rs',
                                           _on_unassign_l7rs_error => 'aborting_l7rs'     } },

    # abort L7R processes corresponding to machines that are not running
    aborting_l7rs    => { enter       => '_abort_l7rs',
                          transitions => { _on_abort_l7rs_done     => 'delaying',
                                           _on_abort_l7rs_error    => 'delaying'          } },

    delaying         => { enter       => '_set_timer',
                          transitions => { _on_timeout             => 'killing_hosts',
                                           on_hkd_stop             => 'stopped',          } },

    # don't do anything for a while if we have had problems connecting to the database
    long_delaying    => { enter       => '_set_timer',
                          transitions => { _on_timeout             => 'killing_hosts',
                                           on_hkd_stop             => 'stopped'           } },

    stopped          => { enter       => '_on_stopped'                                      },

    __any__          => { delay_once  => [qw(on_hkd_stop )],
                          transitions => { on_transient_db_error   => 'long_delaying'     },
                          leave       => '_abort_all'                                       };

sub new {
    my ($class, %opts) = @_;

    my $on_checked = delete $opts{on_checked};
    my $on_error = delete $opts{on_error};

    my $self = $class->SUPER::new(%opts);

    $self->{on_checked} = $on_checked;
    $self->{on_error} = $on_error;
    $self;
}

sub _kill_hosts {
    my ($self) = @_;
    INFO "looking for lost hosts";
    $self->_query(<<'EOQ', $self->{node_id}, $self->_cfg('internal.hkd.cluster.node.timeout'));
update host_runtimes set state = 'lost'
    where state != 'stopped'
      and state != 'starting'
      and not blocked
      and host_id != $1
      and $2 < extract('epoch' from (now() - ok_ts))
    returning host_id
EOQ
}

sub _on_kill_hosts_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_COMMAND_OK and $res->cmdRows) {
        my @lost = $res->column(0);
        INFO 'Successfully marked as lost '.$res->cmdRows.' hosts: @lost';
    }
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
        vma_ok_ts      = NULL
    from host_runtimes
    where vm_state != 'stopped'
      and host_runtimes.host_id = vm_runtimes.host_id
      and host_runtimes.state = 'lost'
    returning vm_id
EOQ
}

sub _on_unassign_vms_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_COMMAND_OK and $res->cmdRows) {
        my @vms = $res->column(0);
        INFO "Succesfully recovered ".$res->cmdRows." VMs in hosts marked as lost: @vms";
    }
}

sub _unassign_l7rs {
    my ($self) = @_;
    $self->_query(<<EOQ);
update vm_runtimes
    set user_state = 'disconnected',
        user_cmd = NULL,
        l7r_host = NULL,
        l7r_pid  = NULL
   from host_runtimes
   where user_state != 'disconnected'
     and host_runtimes.host_id = vm_runtimes.l7r_host
     and host_runtimes.state = 'lost'
   returning vm_id
EOQ
}

sub _on_unassign_l7rs_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_COMMAND_OK and $res->cmdRows) {
        my @vms = $res->column(0);
        INFO "Succesfully recovered ".$res->cmdRows." L7Rs in hosts marked as lost: @vms";
    }
}

sub _abort_l7rs {
    my ($self) = @_;
    $self->_query(<<EOQ);
update vm_runtimes
    set user_cmd = 'abort'
    where user_state = 'connected'
      and vm_state   = 'stopped'
    returning vm_id
EOQ
}

sub _on_abort_l7rs_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_COMMAND_OK and $res->cmdRows) {
        my @vms = $res->column(0);
        INFO "Aborting ".$res->cmdRows." L7Rs processes for VMs not running: @vms";
    }
}

sub _set_timer {
    my $self = shift;
    my $long = ($self->state =~ /^long_/ ? 'long_' : '');
    my $delay = $self->_cfg("internal.hkd.agent.cluster_monitor.${long}delay") +
        int rand $self->_cfg("internal.hkd.agent.cluster_monitor.fuzzy_delay");
    $self->_call_after($delay, '_on_timeout');
}

sub on_transient_db_error :OnState('long_delaying') {
    my $self = shift;
    $self->_abort_all;
    $self->_set_timer;
}

1;
