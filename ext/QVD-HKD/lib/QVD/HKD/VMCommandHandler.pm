package QVD::HKD::VMCommandHandler;

use strict;
use warnings;
use Carp;
use QVD::Log;
use AnyEvent;
use Pg::PQ qw(:pgres);


BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);

use QVD::StateMachine::Declarative
    new            => { transitions => { _on_run                   => 'idle'            } },

    idle           => { enter       => '_set_timer',
                        leave       => '_abort_call_after',
                        transitions => { _on_timeout               => 'loading_cmd',
                                         _on_delete_cmd            => 'deleting_cmds',
                                         _on_qvd_cmd_for_vm_notify => 'loading_cmd',
                                         on_hkd_stop               => 'stopped'         } },

    loading_cmd    => { enter       => '_load_cmd',
                        transitions => { _on_cmd_loaded            => 'locking_cmd',
                                         _on_cmd_not_found         => 'deleting_cmds',
                                         _on_load_cmd_error        => 'idle'            } },

    locking_cmd    => { enter       => '_lock_cmd',
                        transitions => { '_on_lock_cmd_done'       => 'delivering_cmd',
                                         '_on_lock_cmd_error'      => 'idle'            } },

    delivering_cmd => { enter       => '_deliver_cmd',
                        transitions => { _on_deliver_cmd_done      => 'loading_cmd'     } },

    deleting_cmds  => { enter       => '_delete_cmds',
                        transitions => { _on_delete_cmds_done      => 'idle',
                                         _on_delete_cmds_error     => 'idle'            } },

    stopped        => { enter       => '_on_stopped'                                      },

    __any__        => { delay_once  => [qw(_on_delete_cmd
                                           _on_qvd_cmd_for_vm_notify
                                           on_hkd_stop)]                                  };


sub new {
    my ($class, %opts) = @_;
    my $on_cmd = delete $opts{on_cmd};

    my $self = $class->SUPER::new(%opts);
    $self->{vm_ids_with_cmd_done} = [];
    $self->{on_cmd} = $on_cmd;
    $self->_listen("qvd_cmd_for_vm_on_host$self->{node_id}" => '_on_qvd_cmd_for_vm_notify');
    $self;
}

sub _load_cmd {
    my $self = shift;
    $self->{vm_id} = undef;
    $self->{vm_cmd} = undef;
    $debug and $self->_debug("loading command for virtual machines running in host $self->{node_id}");
    DEBUG "Loading commands for virtual machines running in host '$self->{node_id}'";
    $self->_query('select vm_id, vm_cmd from vm_runtimes where host_id = $1 and vm_cmd is not null and vm_cmd != \'busy\' limit 1',
                  $self->{node_id});
}

sub _on_load_cmd_result {
    my ($self, $res) = @_;
    if ($res->rows) {
        @{$self}{qw(vm_id vm_cmd)} = $res->row;
        $debug and $self->_debug("VM command loaded, vm_id: $self->{vm_id}, vm_cmd: $self->{vm_cmd}");
        DEBUG "VM command loaded, vm_id: '$self->{vm_id}', vm_cmd: '$self->{vm_cmd}'";
    }
}

sub _on_load_cmd_done {
    my $self = shift;
    if (defined $self->{vm_id}) {
        $debug and $self->_debug("vm command found");
        DEBUG 'VM command found';
        $self->_on_cmd_loaded;
    }
    else {
        $debug and $self->_debug("vm command *not* found");
        DEBUG 'VM command *not* found';
        $self->_on_cmd_not_found;
    }
}

sub _lock_cmd {
    my $self = shift;
    $debug and $self->_debug("locking command, vm_id: $self->{vm_id}, vm_cmd: $self->{vm_cmd}");
    DEBUG "Locking command, vm_id: '$self->{vm_id}', vm_cmd: '$self->{vm_cmd}'";
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

sub _set_timer {
    my $self = shift;
    my $delay = $self->_cfg('internal.hkd.agent.vm_command_handler.delay');
    $self->_call_after($delay, '_on_timeout');
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

1;
