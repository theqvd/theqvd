package QVD::HKD::Ticker;

use strict;
use warnings;
use Carp;
use AnyEvent;
use Pg::PQ qw(:pgres);

use QVD::HKD::Helpers;

use parent qw(QVD::HKD::Agent);

sub new {
    my ($class, %opts) = @_;

    my $on_ticked = delete $opts{on_ticked};
    my $on_error = delete $opts{on_error};

    my $self = $class->SUPER::new(%opts);

    $self->{on_ticked} = $on_ticked;
    $self->{on_error} = $on_error;
    $self;
}

sub run { shift->_tick }

sub _tick {
    my $self = shift;
    $self->_query(q(update host_runtimes set ok_ts=now(), state='running', pid=$1 where host_id=$2 and not blocked),
                  $$, $self->{node_id});
}

sub _on_tick_error { shift->_maybe_callback('on_error') }

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

sub _on_tick_done {
    my $self = shift;
    $self->{timer} = AnyEvent->timer(after => $self->_cfg('internal.hkd.agent.ticker.delay'),
                                     cb => sub { $self->_tick } );
}

1;
