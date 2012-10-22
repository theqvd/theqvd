package QVD::HKD::Ticker;

use strict;
use warnings;
use Carp;
use AnyEvent;
use QVD::Log;
use Pg::PQ qw(:pgres);

use QVD::HKD::Helpers;

use parent qw(QVD::HKD::Agent);

use QVD::StateMachine::Declarative
    new      => { transitions => { _on_run       => 'ticking'  } },
    ticking  => { enter => '_tick',
                  transitions => { _on_delay     => 'delaying' } },
    delaying => { enter => '_set_timer',
                  transitions => { _on_timeout   => 'ticking',
                                   on_hkd_stop   => 'stopped'  },
                  leave => '_abort_all'                          },
    stopped  => { enter => '_on_stopped'                         };

sub on_hkd_stop { shift->delay_until_next_state }

sub new {
    my ($class, %opts) = @_;

    my $on_ticked = delete $opts{on_ticked};
    my $on_error = delete $opts{on_error};

    my $self = $class->SUPER::new(%opts);

    $self->{on_ticked} = $on_ticked;
    $self->{on_error} = $on_error;
    $self->{query_retry_count} = 1;
    $self;
}

sub _tick {
    my $self = shift;
    INFO 'Ticking';
    $self->_query_1(q(update host_runtimes set ok_ts=now(), pid=$1 where host_id=$2 and state != 'lost')
                    $$, $self->{node_id});
}

sub _on_tick_done {
    my $self = shift;
    DEBUG 'Ticking ok';
    $self->{failed_ticks} = 0;
    $self->_on_delay;
}

sub _on_tick_error {
    my $self = shift;
    WARN 'Error on ticking';
    if (++$self->{failed_ticks} >= $self->_cfg('internal.hkd.agent.ticker.retries')) {
        $self->_maybe_callback('on_error')
    };
    $self->_on_delay;
}

sub _on_tick_result {
    INFO "Database ticked";
    shift->_maybe_callback('on_ticked');
}

sub _set_timer {
    my $self = shift;
    $self->_call_after($self->_cfg('internal.hkd.agent.ticker.delay'), '_on_timeout');
}

1;
