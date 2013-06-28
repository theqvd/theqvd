package QVD::HKD::VMAMonitor;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use 5.010;
use strict;
use warnings;
use Carp qw(confess);
use QVD::Log;

use parent qw(QVD::HKD::Agent);
use Class::StateMachine::Declarative
    __any__       => { transitions => { _on_stop => 'stopped' } },

    new           => { transitions => { _on_run => 'pinging' } },

    pinging       => { enter => '_ping',
                       before => { _on_done => '_on_ping_ok',
                                   _on_error => '_on_ping_error' },
                       transitions => { _on_done  => 'idle',
                                        _on_error => 'idle' } },

    idle          => { enter => '_set_timer',
                       transitions => { _on_timeout => 'pinging' } },

    stopped       => { transitions => { _on_run => 'pinging' } };

sub new {
    my ($class, %opts) = @_;
    my $rpc_service = delete $opts{rpc_service};
    my $on_alive = delete $opts{on_alive};
    my $on_failed = delete $opts{on_failed};
    my $self = $class->SUPER::new(%opts);
    $self->{rpc_service} = $rpc_service;
    $self->{on_alive} = $on_alive;
    $self->{on_failed} = $on_failed;
    $self->{last} = 'error';
    $self;
}

sub stop {
    DEBUG 'Stopping VMA monitor';
    shift->_on_stop;
}

sub _ping { shift->_rpc({retry_count => 0}, 'ping') }

sub _on_ping_ok {
    my $self = shift;
    $self->_maybe_callback('on_alive');
    $self->{last} = 'ok';
}

sub _on_ping_error {
    my $self = shift;
    $self->_maybe_callback('on_failed');
    $self->{last} = 'error';
}

sub _set_timer {
    my $self = shift;
    $self->_call_after($self->_cfg("internal.hkd.vmhandler.vma_monitor.delay.after.$self->{last}"),
                       '_on_timeout');
}

1;
