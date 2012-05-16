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

sub new {
    my ($class, %opts) = @_;
    my $on_cmd = delete $opts{on_cmd};

    my $self = $class->SUPER::new(%opts);
    $self->{on_cmd} = $on_cmd;
    $self->{cmd} = undef;
    $self;
}

sub run { shift->_load_cmd }

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
        $debug and $self->_debug("going to delete HKD command $self->{cmd}");
        $self->_delete_cmd;
    }
    else {
        $self->_loop;
    }
}

sub _on_load_cmd_error { shift->_loop }

sub _delete_cmd {
    my $self = shift;
    $self->_query_1('update host_runtimes set cmd=NULL where host_id=$1 and cmd=$2', $self->{node_id}, $self->{cmd});
}

sub _on_delete_cmd_result {
    my ($self, $res) = @_;
    $self->_maybe_callback('on_cmd', $self->{cmd});
}

sub _on_delete_cmd_done { shift->_loop }

sub _on_delete_cmd_error { shift->_loop }

sub _loop {
    my $self = shift;
    my $delay = $self->_cfg('internal.hkd.agent.command_handler.delay');
    $debug and $self->_debug("will be looking for new commands in $delay seconds");
    $self->_call_after($delay, '_load_cmd');
}

sub on_hkd_stop {
    my $self = shift;
    $self->_abort_all;
    $self->_maybe_callback('on_stopped');
}


1;
