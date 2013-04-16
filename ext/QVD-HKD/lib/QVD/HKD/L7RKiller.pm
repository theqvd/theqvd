package QVD::HKD::L7RKiller;

use strict;
use warnings;
no warnings 'redefine';

use 5.010;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);
use QVD::Log;

use Class::StateMachine::Declarative
    __any__ => { transitions => { on_hkd_stop => 'stopped' },
                 delay => [qw(_on_qvd_cmd_for_user_notify)] },

    new     => { transitions => { _on_run => 'idle' } },

    running => { advance => '_on_done',
                 transitions => { _on_error => 'idle' },
                 substates => [ getting_user_cmd  => { enter => '_get_user_cmd' },
                                deleting_user_cmd => { enter => '_delete_user_cmd' },
                                killing_l7r       => { enter => '_kill_l7r' } ] },

    idle    => { enter       => '_set_timer',
                 transitions => { _on_timeout                 => 'running',
                                  _on_qvd_cmd_for_user_notify => 'running' } },

    stopped => { enter => '_on_stopped' };

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    $self->_listen({on_notify => '_on_qvd_cmd_for_user_notify'},
                   "qvd_user_cmd_for_host$self->{node_id}");
    $self;
}

sub _set_timer {
    my $self = shift;
    $self->_call_after($self->_cfg('internal.hkd.agent.l7rkiller.delay' ), '_on_timeout');
}

sub _get_user_cmd {
    my $self = shift;
    delete $self->{_vm_to_be_disconnected};
    $self->_query({save_to_self => 1},
                  <<'EOQ', $self->{node_id});
select vm_id, l7r_pid
  from vm_runtimes
  where l7r_host=$1
    and user_state = 'connected'
    and user_cmd   = 'abort'
  limit 1
EOQ
}

sub _delete_user_cmd {
    my $self = shift;
    $self->_query(<<'EOQ', $self->{node_id}, $self->{vm_id}, $self->{l7r_pid});
select vm_id, l7r_pid
  from vm_runtimes
  where l7r_host=$1
    and vm_id = $2
    and l7r_pid = $3
    and user_state='connected'
    and user_cmd='abort'
EOQ
}

sub _delete_user_cmd {
    my $self = shift;
    my $vm = $self->{_vm_to_be_disconnected};
    $self->_query_1(<<'EOQ', $self->{node_id}, $vm->{vm_id}, $vm->{l7r_pid});
update vm_runtimes set user_cmd=NULL
  where l7r_host=$1
    and vm_id = $2
    and l7r_pid = $3
    and user_state='connected'
    and user_cmd='abort'
EOQ
}

sub _kill_l7r {
    my $self = shift;
    if (defined (my $pid = $self->{l7r_pid})) {
        if (kill TERM => $pid) {
            INFO "L7R process $pid for VM $self->{vm_id} killed";
            return $self->_on_done;
        }
        else {
            WARN "Unable to kill L7R process $pid for VM $self->{vm_id}: $!";
        }
    }
    else {
        WARN "Internal error: $self->_kill_l7r called without a valid PID";
    }
    $self->_on_error;
}

1;
