package QVD::HKD::L7RMonitor;

use strict;
use warnings;
no warnings 'redefine';

use 5.010;

our $debug = 1;

use parent qw(QVD::HKD::Agent);

use QVD::StateMachine::Declarative
    new                => { transitions => { _on_run => 'getting_user_cmd' }},
    getting_user_cmd   => { enter       => '_get_user_cmd',
                            transitions => { _on_get_user_cmd_done     => 'disconnecting_user',
                                             _on_get_user_cmd_error    => 'searching_dead_l7r' } },
    disconnecting_user => { enter       => '_disconnect_user',
                            transitions => { _on_disconnect_user_done  => 'searching_dead_l7r',
                                             _on_disconnect_user_error => 'searching_dead_l7r' } },
    searching_dead_l7r => { enter       => '_search_dead_l7r',
                            transitions => { _on_search_dead_l7r_done  => 'cleaning_dead_l7r',
                                             _on_search_dead_l7r_error => 'delaying' } },
    cleaning_dead_l7r  => { enter       => '_clean_dead_l7r',
                            transitions => { _on_clean_dead_l7r_done   => 'delaying',
                                             _on_clean_dead_l7r_error  => 'delaying' } },
    delaying           => { enter       => '_set_timer',
                            leave       => '_abort_all',
                            transitions => { _on_timeout               => 'getting_user_cmd',
                                             on_hkd_stop               => 'stopped'           } },
    stopped            => { enter       => '_on_stopped'  },

    __any__            => { delay       => ['on_hkd_stop'] };


sub _get_user_cmd {
    my $self = shift;
    $self->_query_1(<<'EOQ', $self->{node_id});
select vm_id, vm_address, vm_vma_port
  from vm_runtimes
  where l7r_host=$1
    and user_state='connected'
    and user_cmd='abort'
    and vm_state='running'
  limit 1
EOQ
}

sub _on_get_user_cmd_result {
    my ($self, $res) = @_;
    if ($res->rows) {
        my ($vm_id, $ip, $port) = $res->row;
        ($self->{_vm_to_be_disconnected}) = { vm_id => $vm_id, ip => $ip, vma_port => $port };
    }
}

sub _disconnect_user {
    my $self = shift;
    if (my $vm = $self->{_vm_to_be_disconnected}) {
        $self->{_rpc_service} = sprintf "http://%s:%d/vma", $vm->{ip}, $vm->{vma_port};
        $self->_rpc('x_suspend');
        delete $self->{_vm_to_be_disconnected}
    }
    else {
        $self->_on_disconnect_user_done
    }
}

sub _on_rpc_x_suspend_result { shift->{actions_done}++ }

sub _on_rpc_x_suspend_done  { shift->_on_disconnect_user_done }
sub _on_rpc_x_suspend_error { shift->_on_disconnect_user_done }


sub _search_dead_l7r {
    my $self = shift;
    $self->_query(<<'EOQ', $self->{node_id});
select vm_id, l7r_pid
  from vm_runtimes
  where l7r_host = $1
    and l7r_pid != NULL
  limit 1
EOQ
}

sub _on_search_dead_l7r_result {
    my ($self, $res) = @_;
    for my $row ($res->rows) {
        my ($vm_id, $l7r_pid) = $res->row;
        unless (kill 0, $l7r_pid) {
            $self->{_dead_l7r_vm_id} = $vm_id;
            last;
        }
    }
    return;
}

sub _clean_dead_l7r {
    my $self = shift;
    if (defined(my $vm_id = $self->{_dead_l7r_vm_id})) {
        $self->_query_1(<<'EOQ', $vm_id, $self->{node_id}),
update vm_runtimes
  set    ('user_state'  , 'user_cmd', 'l7r_host', 'l7r_pid')
  values ('disconnected', NULL      , NULL      , NULL     )
  where vm_id    = $1
    and l7r_host = $2
EOQ
    }
    else {
        $self->_on_clean_dead_l7r_done
    }
}

sub _on_clean_dead_l7r_result { shift->{actions_done}++ }

sub _set_timer {
    my $self = shift;
    my $delay = (delete($self->{_actions_done})
                 ? $self->_cfg('internal.hkd.agent.l7rmonitor.delay.short')
                 : $self->_cfg('internal.hkd.agent.l7rmonitor.delay.long'));
    $self->_call_after($delay, '_on_timeout');
}

1;
