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

    loading_cmd => { enter => '_load_cmd',
                     transitions => { _on_cmd_loaded    => 'locking_cmd',
                                      _on_cmd_not_found => 'idle' } },

    locking_cmd => { enter => '_lock_cmd',
                     before => { _on_done => '_send_cmd' },
                     transitions => { _on_done => 'loading_cmd' } },

    idle        => { enter       => '_set_timer',
                     transitions => { _on_timeout               => 'loading_cmd',
                                      _on_qvd_cmd_for_vm_notify => 'loading_cmd' } },

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

sub _load_cmd {
    my $self = shift;
    $self->{vm_id} = undef;
    $self->{vm_cmd} = undef;
    $debug and $self->_debug("loading command for virtual machines running in host $self->{node_id}");
    DEBUG "Loading commands for virtual machines running in host '$self->{node_id}'";
    $self->_query( { save_to_self => 1 },
                  q(select vm_id, vm_cmd from vm_runtimes where host_id = $1 and vm_cmd is not null and vm_cmd != 'busy' limit 1),
                  $self->{node_id});
}

sub _lock_cmd {
    my $self = shift;
    $debug and $self->_debug("locking command, vm_id: $self->{vm_id}, vm_cmd: $self->{vm_cmd}");
    DEBUG "Locking command, vm_id: '$self->{vm_id}', vm_cmd: '$self->{vm_cmd}'";
    $self->_query ( {n => 1,
                     log_error => 'unable to lock VM command',
                     ignore_errors => 1 },
                  q(update vm_runtimes set vm_cmd='busy' where vm_id=$1 and vm_cmd=$2),
                  $self->{vm_id}, $self->{vm_cmd});
}

sub _send_cmd {
    my ($self, $res) = @_;
    $self->_maybe_callback(on_cmd => $self->{vm_id}, $self->{vm_cmd});
}

sub _set_timer {
    my $self = shift;
    my $delay = $self->_cfg('internal.hkd.agent.vm_command_handler.delay');
    $self->_call_after($delay, '_on_timeout');
}

1;
