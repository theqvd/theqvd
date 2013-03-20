package QVD::HKD::L7RMonitor;

use strict;
use warnings;
no warnings 'redefine';

use 5.010;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);
use QVD::Log;

use QVD::StateMachine::Declarative
    new                => { transitions => { _on_run                   => 'searching_dead_l7r' } },

    searching_dead_l7r => { enter       => '_search_dead_l7r',
                            transitions => { _on_search_dead_l7r_done  => 'cleaning_dead_l7r',
                                             _on_search_dead_l7r_error => 'idle'               } },

    cleaning_dead_l7r  => { enter       => '_clean_dead_l7r',
                            transitions => { _on_clean_dead_l7r_done   => 'searching_dead_l7r',
                                             _on_clean_dead_l7r_error  => 'idle'               } },

    idle               => { enter       => '_set_timer',
                            leave       => '_abort_all',
                            transitions => { _on_timeout               => 'getting_user_cmd',
                                             on_hkd_stop               => 'stopped'            } },

    stopped            => { enter       => '_on_stopped'  },

    __any__            => { delay_once  => ['on_hkd_stop'] };


sub _search_dead_l7r {
    my $self = shift;
    DEBUG "searching for L7R processes running on this host $self->{node_id}";
    delete $self->{dead_l7r};
    $self->_query(<<'EOQ', $self->{node_id});
select vm_id, l7r_pid
  from vm_runtimes
  where l7r_host = $1
    and l7r_pid is not NULL
EOQ
}

sub _on_search_dead_l7r_result {
    my ($self, $res) = @_;
    for my $row ($res->rows) {
        my ($vm_id, $l7r_pid) = $res->row;
        DEBUG "checking L7R process $l7r_pid corresponding to VM $vm_id";
        unless (kill 0, $l7r_pid) {
            ERROR "L7R process $l7r_pid for VM $vm_id does not exist anymore";
            $self->{dead_l7r} = { vm_id => $vm_id, l7r_pid => $l7r_pid };
        }
    }
    return;
}

sub _clean_dead_l7r {
    my $self = shift;
    if (my $dead = delete $self->{dead_l7r}) {
        INFO "cleaning L7R data for VM $dead->{vm_id} running here, in host $self->{node_id}, L7R pid: $dead->{l7r_pid}";
        $self->_query_1(<<'EOQ', $dead->{vm_id}, $dead->{l7r_pid}, $self->{node_id}),
update vm_runtimes
  set (user_state, user_cmd, l7r_host, l7r_pid) = ('disconnected', NULL, NULL, NULL)
  where vm_id    = $1
    and l7r_pid  = $2
    and l7r_host = $3
EOQ
    }
    else {
        DEBUG "all the L7R processes on this host are alive and kicking!";
        $self->_on_clean_dead_l7r_error;
    }
}

sub _set_timer {
    my $self = shift;
    $self->_call_after($self->_cfg('internal.hkd.agent.l7rmonitor.delay' ), '_on_timeout');
}

1;
