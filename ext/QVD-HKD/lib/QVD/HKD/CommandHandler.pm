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

use QVD::StateMachine::Declarative
    new            => { transitions => { _on_run                     => 'idle'        } },

    idle           => { enter       => '_set_timer',
                        transitions => { _on_qvd_cmd_for_host_notify => 'loading_cmd',
                                         _on_timeout                 => 'loading_cmd',
                                         on_hkd_stop                 => 'stopped'     },
                        leave       => '_abort_all'                                     },

    loading_cmd    => { enter       => '_load_cmd',
                        transitions => { _on_load_cmd_error          => 'idle',
                                         _on_cmd_loaded              => 'delivering_cmd',
                                         _on_no_more_cmds            => 'idle'        } },

    delivering_cmd => { enter       => '_deliver_cmd',
                        transitions => { _on_deliver_cmd_error       => 'idle',
                                         _on_deliver_cmd_done        => 'loading_cmd' } },

    stopped      => { enter       => '_on_stopped'                                    },

    __any__ =>   => { delay_once  => [qw(_on_qvd_cmd_for_host_notify
                                         on_hkd_stop)]                                  };


sub new {
    my ($class, %opts) = @_;
    my $on_cmd = delete $opts{on_cmd};

    my $self = $class->SUPER::new(%opts);
    $self->{on_cmd} = $on_cmd;
    $self->{cmd} = undef;
    $self->_listen("qvd_cmd_for_host$self->{node_id}" => '_on_qvd_cmd_for_host_notify');
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
    $self->{cmd} = undef;
    $self->_query_1('select cmd from host_runtimes where host_id = $1', $self->{node_id});
}

sub _on_load_cmd_result {
    my ($self, $res) = @_;
    $self->{cmd} = $res->row(0);
    $debug and $self->_debug("host command ".($self->{cmd}//'<undef>')." loaded from database");
    DEBUG "host command '$self->{cmd}' loaded from database" if length $self->{cmd};
}

sub _on_load_cmd_done {
    my $self = shift;
    if (defined $self->{cmd}) {
        $self->_on_cmd_loaded;
    }
    else {
        $self->_on_no_more_cmds;
    }
}

sub _deliver_cmd {
    my $self = shift;
    $self->_query_1('update host_runtimes set cmd=NULL where host_id=$1 and cmd=$2', $self->{node_id}, $self->{cmd});
}

sub _on_deliver_cmd_result {
    my ($self, $res) = @_;
    $self->_maybe_callback('on_cmd', $self->{cmd});
}

1;
