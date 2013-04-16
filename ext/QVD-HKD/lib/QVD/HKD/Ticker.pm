package QVD::HKD::Ticker;

use strict;
use warnings;
use Carp;
use AnyEvent;
use QVD::Log;
use Pg::PQ qw(:pgres);

use QVD::HKD::Helpers;

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative
    __any__  => { transitions => { on_hkd_stop => 'stopped' } },

    new      => { transitions => { _on_run => 'ticking'  } },

    ticking  => { enter => '_tick',
                  before => { _on_error => '_tick_error',
                              _on_done => '_tick_done' },
                  transitions => { _on_done => 'delaying',
                                   _on_error => 'delaying' } },

    delaying => { enter => '_set_timer',
                  transitions => { _on_timeout   => 'ticking' } },

    stopped  => { enter => '_on_stopped' };

sub stop { shift->_on_stop }

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
    $self->_query(q(update host_runtimes set ok_ts=now(), pid=$1 where host_id=$2 and state != 'lost' returning extract('epoch' from ok_ts)),
                  $$, $self->{node_id});
}

sub _on_tick_result {
    my ($self, $res) = @_;
    $self->{last_ts_ok} = $res->row;
    DEBUG "Ticking ok at $self->{last_ts_ok} (localtime: ".time.")";

}

sub _tick_error {
    my $self = shift;
    WARN "Ticker failed";
    if (defined (my $last = $self->{last_ts_ok})) {
        if (time - $last > $self->_cfg('internal.hkd.agent.ticker.timeout')) {
            $self->_maybe_callback('on_error');
        }
    }
}

sub _tick_done {
    my $self = shift;
    $self->_maybe_callback('on_ticked');
}

sub _set_timer {
    my $self = shift;
    $self->_call_after($self->_cfg('internal.hkd.agent.ticker.delay'), '_on_timeout');
}

1;
