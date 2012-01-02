package QVD::HKD::Ticker;

use strict;
use warnings;
use Carp;
use AnyEvent;
use Pg::PQ qw(:pgres);

use QVD::HKD::Helpers;

use parent qw(QVD::HKD::Agent);

use QVD::StateMachine::Declarative
    new      => { transitions => { _on_run       => 'ticking'  } },
    ticking  => { enter => '_tick',
                  transitions => { _on_tick_done => 'delaying' } },
    delaying => { enter => '_set_timer',
                  transitions => { _on_timeout   => 'ticking',
                                   on_hkd_stop   => 'stopped'  },
                  leave => '_abort_all'                          },
    stopped  => { enter => '_on_stopped'                         };

sub new {
    my ($class, %opts) = @_;

    my $on_ticked = delete $opts{on_ticked};
    my $on_error = delete $opts{on_error};

    my $self = $class->SUPER::new(%opts);

    $self->{on_ticked} = $on_ticked;
    $self->{on_error} = $on_error;
    $self;
}

sub run { shift->_on_run }

sub _tick {
    my $self = shift;
    $self->_query(q(update host_runtimes set ok_ts=now(), pid=$1 where host_id=$2),
                  $$, $self->{node_id});
}

sub _on_tick_error {
    my $self = shift;
    $self->_maybe_callback('on_error');
    $self->_on_tick_done;
}

sub _on_tick_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_COMMAND_OK and $res->cmdRows) {
        # FIXME: check for blocked when cmdRows == 0
        shift->_maybe_callback('on_ticked')
    }
    else {
        shift->_maybe_callback('on_error')
    }
}

sub _on_tick_bad_result { shift->_maybe_callback('on_error') }

sub _set_timer {
    my $self = shift;
    $self->_call_after($self->_cfg('internal.hkd.agent.ticker.delay'), '_on_timeout');
}

sub _on_stopped {
    my $self = shift;
    $self->_maybe_callback('on_stopped');
}

1;
