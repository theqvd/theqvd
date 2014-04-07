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

    running => { enter => '_load_user_cmds',
                 before => { _on_done => '_abort_l7rs' },
                 transitions => { _on_done => 'idle' } },

    idle    => { enter       => '_set_timer',
                 transitions => { _on_timeout                 => 'running',
                                  _on_qvd_cmd_for_user_notify => 'running' } },

    stopped => { enter => '_on_stopped' };

sub new {
    my ($class, %opts) = @_;
    my $on_cmd_abort = delete $opts{on_cmd_abort};
    my $self = $class->SUPER::new(%opts);
    $self->{on_cmd_abort} = $on_cmd_abort;
    $self->_listen({on_notify => '_on_qvd_cmd_for_user_notify'},
                   "qvd_cmd_for_user_on_host$self->{node_id}");
    $self;
}

sub _set_timer {
    my $self = shift;
    $self->_call_after($self->_cfg('internal.hkd.agent.l7rkiller.delay' ), '_on_timeout');
}

sub _load_user_cmds {
    my $self = shift;
    $self->_query({ save_to => 'l7rs',
                   ignore_errors => 1 },
                  <<'EOQ', $self->{node_id});
update vm_runtimes
    set vm_cmd=NULL
  where l7r_host_id=$1
    and user_state = 'connected'
    and user_cmd   = 'abort'
  returning l7r_pid, vm_id
EOQ
}

sub _abort_l7rs {
    my $self = shift;
    if (defined(my $l7rs = delete $self->{l7rs})) {
        for (@$l7rs) {
            INFO "Aborting L7R for VM $_->{vm_id} (PID: $_->{l7r_pid})";
            $self->_maybe_callback(on_cmd_abort => $_->{l7r_pid});
        }
    }
}

1;
