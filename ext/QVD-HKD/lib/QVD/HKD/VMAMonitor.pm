package QVD::HKD::VMAMonitor;

BEGIN { *debug = \$QVD::HKD::debug }

use 5.010;
use strict;
use warnings;
use Carp qw(confess);

use AnyEvent;

use parent qw(QVD::HKD::Agent);

our $debug;

sub new {
    my ($class, %opts) = @_;
    my $rpc_service = delete $opts{rpc_service};
    my $on_alive = delete $opts{on_alive};
    my $on_failed = delete $opts{on_failed};
    my $self = $class->SUPER::new(%opts);
    $self->{rpc_service} = $rpc_service;
    $self->{on_alive} = $on_alive;
    $self->{on_failed} = $on_failed;
    $self;
}

sub run {
    my $self = shift;
    $self->state('unknown');
    $self->{run} = 1;
    $self->_monitor_vma
}

sub stop {
    my $self = shift;
    $self->{run} = 0;
    $self->_abort_rpc;
    $self->_abort_call_after;
}

sub _monitor_vma {
    my $self = shift;
    unless ($self->{run}) {
        require Data::Dumper;
        $debug and $self->_debug("self:\n", Data::Dumper::Dumper($self));
        confess "internal error: _monitor_vma called but not running";
    }
    $self->{rpc_retry_count} = 0;
    $self->_rpc('ping') }

sub _on_rpc_ping_result {
    my $self = shift;
    $self->_maybe_callback('on_alive');
    $self->_on_rpc_ping_done
}

sub _on_rpc_ping_error {
    my $self = shift;
    $self->_maybe_callback('on_failed');
    $self->_on_rpc_ping_done
}

sub _on_rpc_ping_done {
    my $self = shift;
    if ($self->{run}) {
        my $delay = $self->_cfg('internal.hkd.vmhandler.vma_monitor.delay');
        $debug and $self->_debug("will be checking the VMA in $delay seconds");
        $self->_call_after($delay, '_monitor_vma');
    }
}

1;
