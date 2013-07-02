package QVD::HKD::CommandHandler;

use 5.010;

use strict;
use warnings;
use Carp;
use QVD::Log;
use AnyEvent;
use Pg::PQ qw(:pgres);

use QVD::HKD::Helpers;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative
    __any__     => { advance => '_on_done',
                     delay => [qw(_on_qvd_cmd_for_host_notify)],
                     transitions => { on_hkd_stop => 'stopped',
                                      _on_error => 'idle' } },

    new         => { transitions => { _on_run => 'idle' } },

    loading_cmd => { enter => '_load_cmd',
                     before => { _on_done => '_deliver_cmd' } },

    delete_cmd  => { enter => '_delete_cmd' },

    idle        => { enter => '_set_timer',
                     transitions => { _on_qvd_cmd_for_host_notify => 'loading_cmd',
                                      _on_timeout                 => 'loading_cmd' } },

    stopped     => { enter => '_on_stopped' };


sub new {
    my ($class, %opts) = @_;
    my $on_cmd = delete $opts{on_cmd};

    my $self = $class->SUPER::new(%opts);
    $self->{on_cmd} = $on_cmd;
    $self->{query_priority} = 10;
    $self->_listen({on_notify => '_on_qvd_cmd_for_host_notify' },
                   "qvd_cmd_for_host$self->{node_id}");
    $self;
}

sub _set_timer {
    my $self = shift;
    my $delay = $self->_cfg('internal.hkd.agent.command_handler.delay');
    $debug and $self->_debug("will be looking for new commands in $delay seconds");
    $self->_call_after($delay, '_on_timeout');
}

sub _load_cmd {
    my $self = shift;
    $self->_query({save_to_self => 1},
                  'select cmd from host_runtimes where host_id = $1',
                  $self->{node_id});
}

sub _delete_cmd {
    my $self = shift;
    $self->_query({ n => 1 },
                  'update host_runtimes set cmd=NULL where host_id=$1 and cmd=$2',
                  $self->{node_id}, $self->{cmd});
}

sub _deliver_cmd {
    my $self = shift;
    $self->_maybe_callback('on_cmd', $self->{cmd});
}

1;
