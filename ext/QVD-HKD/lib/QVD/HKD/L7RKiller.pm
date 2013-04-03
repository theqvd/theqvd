package QVD::HKD::L7RKiller;

use strict;
use warnings;
no warnings 'redefine';

use 5.010;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);
use QVD::Log;

use QVD::StateMachine::Declarative
    new               => { transitions => { _on_run                     => 'idle' } },

    getting_user_cmd  => { enter       => '_get_user_cmd',
                           transitions => { _on_get_user_cmd_done       => 'deleting_user_cmd',
                                            _on_get_user_cmd_error      => 'idle'             } },

    deleting_user_cmd => { enter       => '_delete_user_cmd',
                           transitions => { _on_delete_user_cmd_done    => 'killing_l7r',
                                            _on_delete_user_cmd_error   => 'idle'             } },

    killing_l7r       => { enter       => '_kill_l7r',
                           transitions => { _on_kill_l7r_done           => 'getting_user_cmd',
                                            _on_kill_l7r_error          => 'getting_user_cmd' } },

    idle              => { enter       => '_set_timer',
                           leave       => '_abort_call_after',
                           transitions => { _on_timeout                 => 'getting_user_cmd',
                                            _on_qvd_cmd_for_user_notify => 'getting_user_cmd',
                                            on_hkd_stop                 => 'stopped'          } },

    stopped           => { enter       => '_on_stopped'                                         },

    __any__           => { delay_once => [qw(_on_qvd_cmd_for_user_notify
                                             _on_hkd_stop)]                                     };


sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    $self->_listen("qvd_user_cmd_for_host$self->{node_id}" => '_on_qvd_cmd_for_user_notify');
    $self;
}

sub _set_timer {
    my $self = shift;
    $self->_call_after($self->_cfg('internal.hkd.agent.l7rkiller.delay' ), '_on_timeout');
}

sub _get_user_cmd {
    my $self = shift;
    delete $self->{_vm_to_be_disconnected};
    $self->_query_1(<<'EOQ', $self->{node_id});
select vm_id, l7r_pid
  where l7r_host=$1
    and user_state = 'connected'
    and user_cmd   = 'abort'
  limit 1
EOQ
}

sub _on_get_user_cmd_result {
    my ($self, $res) = @_;
    if ($res->rows) {
        my %row;
        @row{qw(vm_id l7r_pid)} = $res->row;
        INFO "User cmd 'abort' received for VM $row{vm_id}";
        $self->{_vm_to_be_disconnected} = \%row;
    }
}

sub _delete_user_cmd {
    my $self = shift;
    my $vm = $self->{_vm_to_be_disconnected};
    $self->_query_1(<<'EOQ', $self->{node_id}, $vm->{vm_id}, $vm->{l7r_pid});
update vm_runtimes set user_cmd=NULL
  where l7r_host=$1
    and vm_id = $2
    and l7r_pid = $3
    and user_state='connected'
    and user_cmd='abort'
EOQ
}

sub _kill_l7r {
    my $self = shift;
    if (my $vm = $self->{_vm_to_be_disconnected}) {
        if ($vm->{l7r_pid}) {
            if (kill TERM => $vm->{l7r_pid}) {
                INFO "L7R process $vm->{l7r_pid} for VM $vm->{vm_id} killed";
                return $self->_on_kill_l7r_done;
            }
            else {
                ERROR "Unable to kill L7R process $vm->{l7r_pid} for VM $vm->{vm_id}: $!";
            }
        }
        else {
            ERROR "Internal error: $self->_kill_l7r called but l7r_pid is unknown";
        }
    }
    else {
        ERROR "Internal error: $self->_kill_l7r called without _vm_to_be_disconnected set";
    }
    $self->_on_kill_l7r_error;
}

1;
