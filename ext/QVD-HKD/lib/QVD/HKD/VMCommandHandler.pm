package QVD::HKD::VMCommandHandler;

use strict;
use warnings;
use Carp;
use QVD::Log;
use AnyEvent;
use Pg::PQ qw(:pgres);


BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);
use Class::StateMachine::Declarative

    __any__     => { advance => '_on_done',
                     delay => [qw(_on_qvd_cmd_for_vm_notify)],
                     transitions => { _on_error   => 'idle',
                                      on_hkd_stop => 'stopped' } },

    new         => { transitions => { _on_run => 'idle' } },

    loading => { delay => [qw(on_hkd_stop)],
                 substates => [ stops  => { enter => '_load_stop_cmds',
                                            before => { _on_done => '_send_stop_cmds' } },
                                starts => { enter => '_load_start_cmds',
                                            before => { _on_done => '_send_start_cmds' } } ] },

    idle        => { enter       => '_set_timer',
                     transitions => { _on_timeout               => 'loading',
                                      _on_qvd_cmd_for_vm_notify => 'loading' } },

    stopped     => { enter       => '_on_stopped' };

sub new {
    my ($class, %opts) = @_;
    my $on_cmd = delete $opts{on_cmd};
    my $self = $class->SUPER::new(%opts);
    $self->{on_cmd} = $on_cmd;
    $self->_listen( { on_notify => '_on_qvd_cmd_for_vm_notify' },
                    "qvd_cmd_for_vm_on_host$self->{node_id}" );
    $self;
}

sub _load_stop_cmds {
    my $self = shift;
    $self->_query( { save_to => 'vms_to_be_stopped' },
                   <<'EOQ', $self->{node_id});
update vm_runtimes
    set vm_cmd=NULL
    where host_id=$1 and
          vm_cmd='stop'
    returning vm_id
EOQ
}

sub _load_start_cmds {
    my $self = shift;
    $self->_query( { save_to => 'vms_to_be_started' },
                   <<'EOQ', $self->{node_id});
update vm_runtimes
    set vm_cmd=NULL,
        vm_state='starting'
    where host_id=$1 and
          vm_cmd='start' and
          vm_state='stopped'
    returning vm_id
EOQ
}

sub _send_cmds {
    my ($self, $rows, $cmd) = @_;
    if (defined $rows) {
        $self->_maybe_callback(on_cmd => $_->{vm_id}, $cmd) for @$rows;
    }
}

sub _send_stop_cmds {
    my $self = shift;
    $self->_send_cmds(delete($self->{vms_to_be_stopped}), 'stop');
}

sub _send_start_cmds {
    my $self = shift;
    $self->_send_cmds(delete($self->{vms_to_be_started}), 'start');
}

sub _set_timer {
    my $self = shift;
    my $delay = $self->_cfg('internal.hkd.agent.vm_command_handler.delay');
    $self->_call_after($delay, '_on_timeout');
}

1;
