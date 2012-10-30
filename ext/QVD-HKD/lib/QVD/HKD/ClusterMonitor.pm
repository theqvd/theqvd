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
    new           => { transitions => { _on_run               => 'long_delaying'    } },

    killing_hosts => { enter       => '_kill_hosts',
                       transitions => { _on_kill_hosts_done   => 'stopping_vms',
                                        _on_kill_hosts_error  => 'stopping_vms'     } },

    stopping_vms  => { enter       => '_stop_vms',
                       transitions => { _on_stop_vms_done     => 'delaying',
                                        _on_stop_vms_error    => 'delaying',        } },

    delaying      => { enter       => '_set_timer',
                       transitions => { _on_timeout           => 'killing_hosts',
                                        on_hkd_stop           => 'stopped',         } },

    long_delaying => { enter       => '_set_timer',
                       transitions => { _on_timeout           => 'killing_hosts',
                                        on_hkd_stop           => 'stopped',         } },

    stopped       => { enter       => '_on_stopped'                                 },

    __any__       => { delay       => [qw(on_hkd_stop )],
                       transitions => { on_transient_db_error => 'long_delaying' },
                       leave       => '_abort_all'                                  };

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
update host_runtimes set state = 'lost', blocked = true
    where state = 'running'
      and host_id != $1
      and not blocked
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

sub _stop_vms {
    my ($self) = @_;
    $self->_query(<<EOQ);
update vm_runtimes
    set vm_state = 'stopped',
        blocked  = true,
        host_id  = NULL
    from host_runtimes
    where vm_state != 'stopped'
      and host_runtimes.host_id = vm_runtimes.host_id
      and host_runtimes.state = 'lost'
    returning vm_id
EOQ
}

sub _on_stop_vms_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_COMMAND_OK and $res->cmdRows) {
        my @vms = $res->column(0);
        INFO "Succesfully recovered ".$res->cmdRows." in hosts marked as lost: @vms";
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
