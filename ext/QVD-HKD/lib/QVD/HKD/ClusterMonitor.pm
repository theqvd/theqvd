package QVD::HKD::ClusterMonitor;

use strict;
use warnings;
use Carp;
use QVD::Log;
use DateTime;
use AnyEvent;
use Pg::PQ qw(:pgres);

use QVD::HKD::Helpers;

use parent qw(QVD::HKD::Agent);

use QVD::StateMachine::Declarative
    new           => { transitions => { _on_run             => 'checking'      } },
    checking      => { enter => '_check',
                       transitions => { _on_check_done      => 'delaying',
                                        _on_kill_hosts      => 'killing_hosts' } },
    killing_hosts => { enter => '_kill_hosts',
                       transitions => { _on_kill_hosts_done => 'stopping_vms'  } },
    stopping_vms  => { enter => '_stop_vms',
                       transitions => { _on_stop_vms_done   => 'delaying'      } },
    delaying      => { enter => '_set_timer',
                       transitions => { _on_timeout         => 'checking',
                                        on_hkd_stop         => 'stopped'       },
                       leave => '_abort_all'                                     },
    stopped       => { enter => '_on_stopped'                                    },

    __any__       => { delay => [qw(on_hkd_Stop)] };

sub new {
    my ($class, %opts) = @_;

    my $on_checked = delete $opts{on_checked};
    my $on_error = delete $opts{on_error};

    my $self = $class->SUPER::new(%opts);

    $self->{on_checked} = $on_checked;
    $self->{on_error} = $on_error;
    $self;
}

## ==========================================================================================
## ==========================================================================================

sub _check {
    my $self = shift;
    DEBUG 'Checking other nodes';
    $self->_query(q(select host_id, extract('epoch' from (now() - ok_ts)) as ok_ts from host_runtimes where state='running' and host_id!=$1 and not blocked),
                  $self->{node_id});
}

sub _on_check_error {
    my $self = shift;
    WARN 'Error on checking other nodes';
    $self->_maybe_callback('on_error');
    $self->_on_check_done;
}

sub _on_check_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_TUPLES_OK) {
        my $cluster_node_timeout = $self->_cfg('internal.hkd.cluster.node.timeout');
        my $time = time;
        for ($res->rows) {
            my ($host_id, $ok_ts) = @$_;

            # TODO: esto esta muy justo! habria que darle algun tiempo extra
            # al noded del nodo caido para matar sus maquinas virtuales.
            if ($ok_ts >= $cluster_node_timeout) {
                push @{ $self->{'_down_hosts'} }, $host_id;
            }
        }
    } else {
        $self->_maybe_callback('on_error')
    }
    if ($self->{'_down_hosts'}) {
        INFO sprintf 'Found %s down hosts: %s', scalar @{ $self->{'_down_hosts'} }, join ', ', @{ $self->{'_down_hosts'} };
        $self->_on_kill_hosts;
    }
}

sub _on_check_bad_result { shift->_maybe_callback('on_error') }

sub _on_check_done { }

## ==========================================================================================
## ==========================================================================================

sub _kill_hosts {
    my ($self) = @_;

    my $plh = join ',', map { "\$$_" } 1 .. @{ $self->{'_down_hosts'} };
    INFO sprintf 'Killing hosts %s', join ', ', @{ $self->{'_down_hosts'} };
    $self->_query ("update host_runtimes set state = 'lost', blocked = true where host_id in ($plh)", @{ $self->{'_down_hosts'} });
}

sub _on_kill_hosts_error {
    my $self = shift;
    WARN 'Error on killing hosts';
    $self->_maybe_callback('on_error');
    $self->_on_check_done;
}

sub _on_kill_hosts_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_COMMAND_OK and $res->cmdRows) {
        INFO 'Successfully killed hosts';
    }
    else {
        $self->_maybe_callback('on_error')
    }
}

sub _on_kill_hosts_bad_result { shift->_maybe_callback('on_error') }

sub _on_kill_hosts_done { }

## ==========================================================================================
## ==========================================================================================

sub _stop_vms {
    my ($self) = @_;

    my $plh = join ',', map { "\$$_" } 1 .. @{ $self->{'_down_hosts'} };
    INFO sprintf 'Stopping VMs on hosts %s', join ', ', @{ $self->{'_down_hosts'} };
    $self->_query ("update vm_runtimes set vm_state = 'stopped', blocked = true where host_id in ($plh)", @{ $self->{'_down_hosts'} });
}

sub _on_stop_vms_error {
    my $self = shift;
    ERROR 'Error on stopping VMs';
    $self->_maybe_callback('on_error');
    $self->_on_check_done;
}

sub _on_stop_vms_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_COMMAND_OK) {
        if ($res->cmdRows) {
            INFO 'Successfully stopped VMs';
            # TODO: en este caso, seria interesante regenerar los overlays de la maquina que se recupera de manera que:
            # - el filesystem puede estar corrupto, el fsck automatico podria fallar.
            # - realmente nos aseguramos de que en ningun caso pueda haber dos maquinas virtuales corriendo contra la misma imagen.
        }
    }
    else {
        $self->_maybe_callback('on_error')
    }
}

sub _on_stop_vms_bad_result { shift->_maybe_callback('on_error') }

sub _on_stop_vms_done { }

## ==========================================================================================
## ==========================================================================================

sub _set_timer {
    my $self = shift;
    undef $self->{'_down_hosts'};
    $self->_maybe_callback('on_checked');
    $self->_call_after($self->_cfg('internal.hkd.agent.cluster_monitor.delay'), '_on_timeout');
}

1;
