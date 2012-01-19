package QVD::HKD::VMCommandHandler;

use strict;
use warnings;
use Carp;
use AnyEvent;
use Pg::PQ qw(:pgres);


BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);

use QVD::StateMachine::Declarative
    new            => { transitions => { _on_run               => 'loading_cmd'     } },
    loading_cmd    => { enter       => '_load_cmd',
                        transitions => { _on_cmd_found         => 'locking_cmd',
                                         _on_cmd_not_found     => 'deleting_cmds',
                                         _on_load_cmd_error    => 'waiting'         } },
    locking_cmd    => { enter       => '_lock_cmd',
                        transitions => { '_on_lock_cmd_done'   => 'delivering_cmd',
                                         '_on_lock_cmd_error'  => 'waiting'         } },

    delivering_cmd => { enter       => '_deliver_cmd',
                        transitions => { _on_deliver_cmd_done  => 'loading_cmd'     } },

    deleting_cmds  => { enter       => '_delete_cmds',
                        transitions => { _on_delete_cmds_done  => 'waiting',
                                         _on_delete_cmds_error => 'waiting'         },
                        ignore      => [qw(_on_delete_cmds_result
                                           _on_delete_cmds_bad_result)]               },

    waiting        => { enter       => '_start_timer',
                        leave       => '_abort_call_after',
                        transitions => { _on_timer             => 'loading_cmd',
                                         _on_delete_cmd        => 'deleting_cmds',
                                         on_hkd_stop          => 'stopped'         } },
    stopped        => { enter       => '_on_stopped'                                  };


sub _on_delete_cmd :OnState(__any__) {}

sub on_hkd_stop :OnState(__any__) { shift->delay_until_next_state }

sub new {
    my ($class, %opts) = @_;
    my $on_cmd = delete $opts{on_cmd};

    my $self = $class->SUPER::new(%opts);
    $self->{vm_ids_with_cmd_done} = [];
    $self->{on_cmd} = $on_cmd;
    $self;
}

sub _load_cmd {
    my $self = shift;
    $self->{vm_id} = undef;
    $self->{vm_cmd} = undef;
    $debug and $self->_debug("loading command for virtual machines running in host $self->{node_id}");
    $self->_query('select vm_id, vm_cmd from vm_runtimes where host_id = $1 and vm_cmd is not null and vm_cmd != \'busy\' limit 1',
                  $self->{node_id});
}

sub _on_load_cmd_result {
    my ($self, $res) = @_;
    if ($res->rows) {
        @{$self}{qw(vm_id vm_cmd)} = $res->row;
        $debug and $self->_debug("command loaded, vm_id: $self->{vm_id}, vm_cmd: $self->{vm_cmd}");
    }
}

sub _on_load_cmd_bad_result {}

sub _on_load_cmd_done {
    my $self = shift;
    if (defined $self->{vm_id}) {
        $debug and $self->_debug("vm command found");
        $self->_on_cmd_found;
    }
    else {
        $debug and $self->_debug("vm command *not* found");
        $self->_on_cmd_not_found;
    }
}

sub _lock_cmd {
    my $self = shift;
    $debug and $self->_debug("locking command, vm_id: $self->{vm_id}, vm_cmd: $self->{vm_cmd}");
    $self->_query_1('update vm_runtimes set vm_cmd=\'busy\' where vm_id=$1 and vm_cmd=$2',
                    $self->{vm_id}, $self->{vm_cmd});
}

sub _on_lock_cmd_result {}

sub _on_lock_cmd_bad_result {}

sub _deliver_cmd {
    my ($self, $res) = @_;
    $self->_maybe_callback('on_cmd', $self->{vm_id}, $self->{vm_cmd});
    $self->_on_deliver_cmd_done;
}

sub _start_timer {
    my $self = shift;
    my $delay = $self->_cfg('internal.hkd.agent.vm_command_handler.delay');
    $self->_call_after($delay, '_on_timer');
}

sub _on_cmd_done {
    my ($self, $vm_id) = @_;
    push @{$self->{vm_ids_with_cmd_done}}, $vm_id;
    $self->_on_delete_cmd
}

sub _delete_cmds {
    my $self = shift;
    my $vm_ids = $self->{vm_ids_with_cmd_done};
    @$vm_ids or return $self->_on_delete_cmds_done;
    my $in = join ",", @$vm_ids;
    $self->_query("update vm_runtimes set vm_cmd=NULL where vm_cmd='busy' and vm_id in ($in)");
}

sub _on_stopped {
    my $self = shift;
    $self->_maybe_callback('on_stopped');
}

1;
