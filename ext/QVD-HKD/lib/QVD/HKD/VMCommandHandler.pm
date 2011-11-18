package QVD::HKD::VMCommandHandler;

use strict;
use warnings;
use Carp;
use AnyEvent;
use Pg::PQ qw(:pgres);


# BEGIN { *debug = \$QVD::HKD::debug }
our $debug = 1;

use parent qw(QVD::HKD::Agent);

sub new {
    my ($class, %opts) = @_;
    my $on_cmd = delete $opts{on_cmd};

    my $self = $class->SUPER::new(%opts);
    $self->{on_cmd} = $on_cmd;
    $self;
}

sub run { shift->_load_cmd }

sub _load_cmd {
    my $self = shift;
    $self->{vm_id} = undef;
    $self->{vm_cmd} = undef;
    $self->_query('select vm_id, vm_cmd from vm_runtimes where host_id = $1 and vm_cmd is not null limit 1',
                  $self->{node_id});
}

sub _on_load_cmd_result {
    my ($self, $res) = @_;
    @{$self}{qw(vm_id vm_cmd)} = $res->row;
}

sub _on_load_cmd_done {
    my $self = shift;
    if (defined $self->{vm_id}) {
        $self->_delete_cmd;
    }
    else {
        $self->_loop;
    }
}

sub _on_load_cmd_bad_result {}

sub _on_load_cmd_error { shift->_loop }

sub _delete_cmd {
    my $self = shift;
    # TODO: deleting the command and setting the new state should be
    # an atomic operation
    $self->_query_1('update vm_runtimes set vm_cmd=NULL where vm_id=$1 and vm_cmd=$2',
                    $self->{vm_id}, $self->{vm_cmd});
}

sub _on_delete_cmd_result {
    my ($self, $res) = @_;
    $self->_maybe_callback('on_cmd', $self->{vm_id}, $self->{vm_cmd});
}

sub _on_delete_cmd_bad_result {}

sub _on_delete_cmd_error {
    # FIXME:
    # nothing to do until we have commands that are harmful when repeated
    shift->loop
}

sub _on_delete_cmd_done { shift->_load_cmd }

sub _loop {
    my $self = shift;
    my $delay = $self->_cfg('internal.hkd.agent.vm_command_handler.delay');
    $self->_call_after($delay, '_load_cmd');
}

1;
