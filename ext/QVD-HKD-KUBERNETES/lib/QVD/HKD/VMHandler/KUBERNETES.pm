package QVD::HKD::VMHandler::KUBERNETES;

BEGIN { *debug = \$QVD::HKD::VMHandler::debug }
our $debug;

use strict;
use warnings;
use 5.010;

use POSIX;
use AnyEvent;
use AnyEvent::Util;
use QVD::Log;
use File::Temp qw(tempfile);
use Linux::Proc::Mountinfo;
use File::Spec;
use Fcntl ();
use Fcntl::Packer ();
use Method::WeakCallback qw(weak_method_callback);
use QVD::HKD::Helpers qw(mkpath);

use parent qw(QVD::HKD::VMHandler);


use Class::StateMachine::Declarative
    __any__   => { ignore => [qw(_on_cmd_start on_expired _on_kubernetes_done)],
                   delay => [qw(on_hkd_kill
                                _on_cmd_stop)],
                   on => { on_hkd_stop => 'on_hkd_kill' },
                   transitions => { _on_dirty => 'dirty' } },

    new       => { transitions => { _on_cmd_start        => 'starting',
                                    _on_cmd_stop         => 'stopping/db',
                                    _on_cmd_catch_zombie => 'zombie' } },

    starting  => { advance => '_on_done',
                   on => { on_hkd_kill => '_on_error' },
                   substates => [ db              => { transitions => { _on_error   => 'stopping/db' },
                                                       substates => [ loading_row        => { enter => '_load_row' },
                                                                      searching_di       => { enter => '_search_di' },
                                                                      checking_hypervisor=> { enter => '_check_hypervisor' },
                                                                      # We should probably recalculate ip
                                                                      calculating_attrs  => { enter => '_calculate_attrs' },
                                                                      saving_runtime_row => { enter => '_save_runtime_row' },
                                                                      updating_stats     => { enter => '_incr_run_attempts' } ] },

                                  clean_old       => { transitions => { _on_error => 'zombie/reap',
                                                                        on_hkd_kill => 'stopping/db' },
                                                       substates => [ killing_kubernetes     => { enter => '_kill_kubernetes' },
                                                                      destroying_kubernetes  => { enter => '_destroy_kubernetes' } ] },

                                  heavy           => { enter => '_heavy_down',
                                                       transitions => { _on_error    => 'stopping/db',
                                                                        _on_cmd_stop => 'stopping/db' } },

                                  setup           => { transitions => { _on_error   => 'stopping/cleanup' },
                                                       substates => [ allocating_home_fs      => { enter => '_allocate_home_fs' },
                                                                      create_kubernetes       => { enter => '_create_kubernetes' },
                                                                      running_prestart_hook   => { enter => '_run_prestart_hook' },
                                                                      launching               => { enter => '_start_kubernetes' },
                                                                      # Update the IP and save it
                                                                      wait_for_kubernetes     => { enter => '_wait_for_kubernetes',
                                                                                                   substates => [
                                                                                                                     _on_waiting         => { enter => '_wait_for_kubernetes' },
                                                                                                                     _on_running         => { enter => 'starting/setup/calculating_attrs' },
                                                                                                                     _on_dead            => { enter => 'stopping/stop' },
                                                                                                                     on_cmd_stop         => { enter => 'stopping/stop' },
                                                                                                                     _on_kubernetes_done => { enter => 'stopping/cleanup' },
                                                                                                                     on_hkd_kill         => { enter => 'stopping/stop' },
                                                                                                                     _on_goto_debug      => { enter => 'debugging' }
                                                                                                                ]
                                                                                                 },
                                                                      calculating_attrs  => { enter => '_calculate_attrs' },
                                                                      saving_runtime_row => { enter => '_save_runtime_row' },

                                                           ] },
                                  waiting_for_vma => { enter => '_start_vma_monitor',
                                                       transitions => { _on_alive           => 'running',
                                                                        _on_dead            => 'stopping/stop',
                                                                        _on_cmd_stop        => 'stopping/stop',
                                                                        _on_kubernetes_done => 'stopping/cleanup',
                                                                        on_hkd_kill         => 'stopping/stop',
                                                                        _on_goto_debug      => 'debugging' } } ] },

    running   => { advance => '_on_done',
                   delay => [qw(_on_kubernetes_done)],
                   transitions => { _on_error => 'stopping/stop' },
                   substates => [ saving_state           => { enter => '_save_state' },
                                  updating_stats         => { enter => '_incr_run_ok' },
                                  running_poststart_hook => { enter => '_run_poststart_hook' },
                                  unheavy                => { enter => '_heavy_up' },
                                  monitoring             => { enter       => '_start_vma_monitor',
                                                              ignore      => [qw(_on_alive)],
                                                              transitions => { _on_dead            => 'stopping/stop',
                                                                               _on_cmd_stop        => 'stopping/shutdown',
                                                                               _on_kubernetes_done => 'stopping/cleanup',
                                                                               on_hkd_kill         => 'stopping/stop',
                                                                               _on_goto_debug      => 'debugging',
                                                                               on_expired          => 'expiring' } },
                                  '(expiring)'           => { enter => '_expire',
                                                              transitions => { _on_done => 'monitoring' } } ] },

    debugging => { advance => '_on_done',
                   delay => [qw(_on_kubernetes_done)],
                   transitions => { _on_error => 'stopping/stop' },
                   substates => [ saving_state => { enter => '_save_state' },
                                  unheavy      => { enter => '_heavy_up' },
                                  monitoring   => { enter => '_start_vma_monitor',
                                                    ignore => [qw(_on_dead
                                                                  _on_goto_debug)],
                                                    transitions => { _on_alive           => 'running',
                                                                     _on_cmd_stop        => 'stopping/stop',
                                                                     _on_kubernetes_done => 'stopping/cleanup',
                                                                     on_hkd_kill         => 'stopping/stop' } } ] },

    stopping  => { advance => '_on_done',
                   transitions => { _on_error => 'zombie/reap' },
                   delay => [qw(_on_kubernetes_done)],
                   substates => [ shutdown => { transitions => { on_hkd_kill => 'stop' },
                                                substates => [ saving_state    => { enter => '_save_state' },
                                                               heavy           => { enter => '_heavy_down' },
                                                               shuttingdown    => { enter => '_shutdown',
                                                                                    transitions => { _on_error           => 'stop',
                                                                                                     _on_kubernetes_done => 'cleanup' } },
                                                               waiting_for_kubernetes => { enter => '_set_state_timer',
                                                                                    transitions => { _on_kubernetes_done  => 'cleanup',
                                                                                                     _on_state_timeout    => 'stop' } } ] },
                                  stop     => { substates => [ saving_state       => { enter => '_save_state' },
                                                               heavy              => { enter => '_heavy_down' },
                                                               running_stop       => { enter => '_stop_kubernetes' },
                                                               waiting_for_kubernetes => { enter => '_set_state_timer',
                                                                                    transitions => { _on_kubernetes_done      => 'cleanup',
                                                                                                     _on_state_timeout => 'cleanup' } } ] },
                                  cleanup  => { ignore => [qw(_on_kubernetes_done)], # FIXME: is there really a reason for that?
                                                substates => [ saving_state           => { enter => '_save_state' },
                                                               checking_dirty         => { enter => '_check_dirty_flag' },
                                                               heavy                  => { enter => '_heavy_down' },
                                                               killing_kubernetes     => { enter => '_kill_kubernetes' },
                                                               running_poststop_hook  => { enter => '_run_poststop_hook',
                                                                                           transitions => { _on_error => 'destroying_kubernetes' } },
                                                               destroying_kubernetes      => { enter => '_destroy_kubernetes' } ] },

                                  db       => { enter => '_clear_runtime_row',
                                                transitions => { _on_error => 'zombie/db',
                                                                 _on_done  => 'stopped' } } ] },

    stopped => { enter => '_on_stopped' },

    zombie  => { advance => '_on_done',
                 delay => [qw(_on_kubernetes_done)],
                 ignore => [qw(on_hkd_stop)],
                 transitions => { on_hkd_kill => 'stopped' },
                 substates => [ config => { transitions => { _on_error => 'delaying' },
                                            substates => [ saving_state      => { enter => '_save_state',
                                                                                  on => { _on_error => '_on_done' } },
                                                           calculating_attrs => { enter => '_calculate_attrs',
                                                                                  transitions => { _on_error => 'delaying' } },
                                                           '(delaying)'      => { enter => '_set_state_timer',
                                                                                  transitions => { _on_timeout => 'config' } } ] },

                                reap   => { transitions => { _on_error => 'delaying' },
                                            substates => [ saving_state           => { enter => '_save_state',
                                                                                       on => { _on_error => '_on_done' } },
                                                           dirty                  => { enter => '_check_dirty_flag',
                                                                                       transitions => { _on_error => '/dirty' } },
                                                           heavy                  => { enter => '_heavy_down' },
                                                           checking_kubernetes    => { enter => '_check_kubernetes',
                                                                                      transitions => { _on_error => 'killing_kubernetes' } },
                                                           stopping_kubernetes    => { enter => '_stop_kubernetes' },
                                                           waiting_for_kubernetes => { enter => '_set_state_timer',
                                                                                       transitions => { _on_kubernetes_done   => 'killing_kubernetes',
                                                                                                        _on_state_timeout => 'killing_kubernetes'} },
                                                           killing_kubernetes     => { enter => '_kill_kubernetes' },
                                                           destroying_kubernetes  => { enter => '_destroy_kubernetes',
                                                                                       transitions => { _on_error => 'unheavy'  } },
                                                           unheavy                => { enter => '_heavy_up' },
                                                           '(delaying)'           => { enter => '_set_state_timer',
                                                                                       transitions => { _on_state_timeout => 'reap'} } ] },

                                db     => { transitions => { _on_error => 'delaying' },
                                            substates => [ clearing_runtime_row => { enter => '_clear_runtime_row',
                                                                                     transitions => { _on_done => 'stopped' } },
                                                           '(delaying)'         => { enter => '_set_state_timer',
                                                                                     transitions => { _on_state_timeout => 'db'} } ] } ] },

    dirty  => { ignore => [qw(on_hkd_stop)],
                transitions => { on_hkd_kill => 'stopped' } };

sub _calculate_attrs {
    my $self = shift;

    DEBUG "QVD::HKD::VMHandler::_calculate_attrs";
    $self->SUPER::_calculate_attrs;

    $self->{kubernetes_name} = "qvd-$self->{vm_id}";

# TODO recalculate
#                 'rpc_service' => 'http://10.0.0.254:3030/vma',
#                 'ip' => '10.0.0.254',

    # my $homefs_parent = $self->_cfg('path.storage.homefs');
    # $homefs_parent =~ s|/*$|/|;
    #  if ($self->_cfg('vm.container.home.per.user')) {
	# $self->{home_fs} = "$homefs_parent$self->{login}";
	# $self->{home_fs_mnt} = "/home/$self->{login}";
    # }
    # else {
	# $self->{home_fs} = "$homefs_parent$self->{vm_id}-fs";
	# $self->{home_fs_mnt} = "/home";
    # }


    $self->_on_done;
}

sub _allocate_home_fs {
    my $self = shift;

    DEBUG "QVD::HKD::VMHandler::_allocate_home_fs";
    # TODO, for now no home allocation
    # my $homefs = $self->{home_fs};
    # defined $homefs or return $self->_on_done;

    # unless (mkpath $homefs) {
    #     ERROR "Unable to create directory '$homefs'";
    #     return $self->_on_error;
    # }

    $self->_on_done
}



sub _create_kubernetes {
    my $self = shift;


    DEBUG "QVD::HKD::VMHandler::_allocate_home_fs";

    my $kubernetes_name = $self->{kubernetes_name};
    
    my $kubernetes_root = $self->_cfg('path.run.kubernetes');
    unless (-d $kubernetes_root or mkdir $kubernetes_root) {
        ERROR "Unable to create directory $kubernetes_root: $!";
        return $self->_on_error;
    }

    my $kubernetes_dir = "$kubernetes_root/$kubernetes_name";
    unless (-d $kubernetes_dir or mkdir $kubernetes_dir) {
        ERROR "Unable to create directory '$kubernetes_dir': $!";
        return $self->_on_error;
    }

    my $fn = "$kubernetes_dir/config";
    DEBUG "Saving kubernetes configuration to '$fn'";
    open my $cfg_fh, '>', $fn;
    unless ($cfg_fh) {
        ERROR "Unable to create file '$fn': $!";
        return $self->_on_error;
    }

    # TODO
    #my $docker_image = $self->di_path.':'.$self->di_version;

    # FIXME: make this template-able or configurable in some way
    print $cfg_fh <<EOC;
apiVersion: apps/v1beta2
kind: Deployment
metadata:
  name: "qvd-deployment-$self->{vm_id}"
  labels:
    qvdid: "$self->{vm_id}"
spec:
  replicas: 1
  selector:
    matchLabels:
      qvdid: "$self->{vm_id}"
  template:
    metadata:
      labels:
        qvdid: "$self->{vm_id}"
    spec:
      hostname: $kubernetes_name
      containers:
      - name: $kubernetes_name
        image: theqvd/qvdimage-minimal-ubuntu-1604
        livenessProbe:
          httpGet:
            path: /vma/ping
            port: 3030
          initialDelaySeconds: 5
          periodSeconds: 3600
          timeoutSeconds: 5
        readinessProbe:
          httpGet:
            path: /vma/ping
            port: 3030
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 5
EOC

#    print $cfg_fh $self->_cfg('internal.vm.lxc.conf.extra'), "\n";
#    close $cfg_fh;

    $self->_on_done;
}



# Wait until the system is up
sub _wait_for_kubernetes {
    my $self = shift;
    DEBUG "_wait_for_kubernetes";
    $self->_update_vm_ip;  
}

my $ip;
sub _vm_ip_obtained {
    my $self = shift;

    chomp $ip;
    DEBUG "_vm_ip_obtained: IP=$ip";

    my $ipno = qr/
       2(?:5[0-5] | [0-4]\d)
       |
       1\d\d
       |
       [1-9]?\d
    /x;

    if ( $ip =~ /^($ipno\.){3}$ipno$/ ) {
        DEBUG "_vm_ip_obtained: IP=$ip";
        $self->{ip} = $ip;
        $self->{rpc_service} = sprintf("http://%s:%d/vma", $self->{ip}, $self->{vma_port});
        return $self->_on_done;
    }

    # TODO setup timer and go to _on_error
    ERROR "_vm_ip_obtained: Invalid IP=$ip";
    $self->_update_vm_ip;
}

sub _update_vm_ip {
    my $self = shift;

    DEBUG "_update_vm_ip";
    my @kubernetes_cmd = ('kubectl', 'get', 'pod', '-l', 'qvdid='.$self->{vm_id},
                          '-o', "jsonpath={.items[*].status.podIP}");
    $ip = '';
    $self->_run_cmd({ 
                      '<' => '/dev/null',
                      '>' => \$ip,
                      '2>' => \$ip,
                      on_done => sub { $self->_vm_ip_obtained },
                    },
                    @kubernetes_cmd
        );

}

sub _start_kubernetes {
    my $self = shift;

    DEBUG "start_kubernetes";

    my $kubernetes_name = $self->{kubernetes_name};
    
    my $kubernetes_root = $self->_cfg('path.run.kubernetes');
    my $kubernetes_dir = "$kubernetes_root/$kubernetes_name";

    my $fn = "$kubernetes_dir/config";

    # kubernetes_cmd
    # TODO kubectl create -f pod
    # my @kubernetes_cmd = (
	# 'kubernetes', 'run',
	# '--name', $self->{kubernetes_name},
	# '--rm',
	# '--hostname', $self->{name},
	# "--add-host=$self->{name}:$self->{ip}",
	# "--cpu-shares=$default_cpushares",
	# "--memory-reservation=$memory",
	# "--cpuset-cpus=$cpuset_cpus",
	# '--network',  $self->_cfg('vm.network.bridge'),
	# '--ip', $self->{ip},
	# '--mac-address', $self->{mac},
	# '-v', $self->{home_fs}.":".$self->{home_fs_mnt},
	# $self->{di_description}
	# );

    my @kubernetes_cmd = ('kubectl', 'create', '-f', $fn);

    DEBUG "Running kubernetes:".join(" ", @kubernetes_cmd);
    $self->_run_cmd( { kill_after => $self->_cfg('internal.hkd.command.timeout.kubectl-create'),
                       run_and_forget => 1,
                     },
                     @kubernetes_cmd );

    $self->_on_done;
}

sub _check_kubernetes {
    my $self = shift;


    DEBUG "_check_kubernetes";
    # TODO check that pod is running
    # kubectl get pod...
    # kubectl get pod -l app=qvddb -o jsonpath='{.items[*].status.podIP}'

    my @kubernetes_cmd = ('kubectl', 'get', 'pod', '-l', 'qvdid='.$self->{vm_id});

    my $hv_out = $self->_hypervisor_output_redirection;

    $self->_run_cmd( { kill_after => $self->_cfg('internal.hkd.command.timeout.kubectl-get'),
                       '<' => '/dev/null',
                       '>' => $hv_out,
                       '2>' => $hv_out
                     },
                      @kubernetes_cmd
	               );

    $self->_on_done;
}

sub _stop_kubernetes {
    my $self = shift;

    DEBUG "_stop_kubernetes";
    # my @kubernetes_cmd = ('kubectl', 'stop', $self->{kubernetes_name} );

    # $self->_run_cmd( { kill_after => $self->_cfg('internal.hkd.command.timeout.kubernetes-kill'),
    #                    ignore_errors => 1,
    #                    run_and_forget => 1
    #                  },
    #                  @kubernetes_cmd
	#            );

    $self->_on_done;
}

sub _check_dirty_flag {
    my $self = shift;

    # if ($self->_cfg("internal.hkd.kubernetes.does.not.cleanup")) {
    #     $debug and $self->_debug("going dirty because internal.hkd.kubernetes.does.not.cleanup is set");
    #     return $self->_on_error;
    # }

    return $self->_on_done;
}

sub _kill_kubernetes {
    my $self = shift;

    DEBUG "_kill_kubernetes";
    # Delete pod and/or service
    # kubectl delete service ...
    # kubectl delete pod -> Get POD IP
    # my @kubernetes_cmd = ('kubernetes', 'kill', $self->{kubernetes_name} );

    # $self->_run_cmd( { kill_after => $self->_cfg('internal.hkd.command.timeout.kubectl-kill'),
    #                    ignore_errors => 1,
	# 	       run_and_forget => 1
    #                  },
	# 	     @kubernetes_cmd
	#            );

    $self->_on_done;
}

sub _destroy_kubernetes {
    my $self = shift;


    DEBUG "_destroy_kubernetes";
    # kubectl delete pod -> Get POD IP
    
    # my @kubernetes_cmd = ('kubernetes', 'rm', $self->{kubernetes_name} );
    # $self->_run_cmd( { kill_after => $self->_cfg('internal.hkd.command.timeout.kubernetes-rm'),
	# 	       ignore_errors => 1
	# 	     },
	# 	     @kubernetes_cmd
	#            );

    $self->_on_done;
}

sub _hook_args {
    my $self = shift;
    map { $_ => $self->{$_} } qw( mac
                                  name
                                  ip );
}

sub _run_hook {
    my ($self, $name) = @_;

    # FIXME: where are hooks stored when using kubernetes?
    $self->_on_done;
}


sub _on_vma_monitor_failed {
    my $self = shift;
    # TODO refresh pod ip from kubernetes
    $debug and $self->_debug("Invoking QVD::HKD::VMHandler::KUBERNETES vma_monitor_failed for vm '$self->{vm_id}' and ip '$self->{ip}'");

    # TODO refresh pod ip from kubernetes
    # Optionally refresh ip

    $self->SUPER::_on_vma_monitor_failed;
}
1;
