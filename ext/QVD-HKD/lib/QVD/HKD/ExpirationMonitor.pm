package QVD::HKD::ExpirationMonitor;

use strict;
use warnings;
use Carp;
use QVD::Log;

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative
    __any__ => { advance => '_on_done',
                 transitions => { _on_error => 'idle',
                                  on_hkd_stop => 'stopped' } },

    new     => { transitions => { _on_run => 'idle' } },

    running => { enter => '_load_vm_expirations',
                 before => { _on_done => '_expire_vms' } },

    idle    => { enter => '_set_timer',
                 transitions => { _on_timeout => 'running' } },

    stopped => { enter => '_on_stopped' };

sub new {
    my ($class, %opts) = @_;
    my $on_expired_vm = delete $opts{on_expired_vm};
    my $self = $class->SUPER::new(%opts);
    $self->{on_expired_vm} = $on_expired_vm;
    $self;
}

sub _load_vm_expirations {
    my $self = shift;
    $self->_query({ save_to => 'vms_to_be_expired' },
                  <<'EOQ', $self->{node_id});
select vm_id,
       (vm_expiration_hard < now()) as hard,
       vm_expiration_soft, vm_expiration_hard,
       now() as really_now
    from vm_runtimes
    where vm_state = 'running'
      and ( vm_expiration_soft < now()
         or vm_expiration_hard < now() )
      and host_id = $1
EOQ

}

sub _expire_vms {
    my $self = shift;
    for (@{$self->{vms_to_be_expired}}) {
        DEBUG join('', map { $_ // '<undef>' }
                   "VM is expired, hard: ", $_->{hard},
                   ", expiration_soft: ", $_->{vm_expiration_soft},
                   ", expiration_hard: ", $_->{vm_expiration_hard},
                   ", now: ", $_->{really_now});
        $self->_maybe_callback(on_expired_vm => @{$_}{qw(vm_id hard vm_expiration_soft vm_expiration_hard)});
    }
}

sub _set_timer {
    my $self = shift;
    my $delay = $self->_cfg('internal.hkd.agent.expiration_monitor.delay') * (1 - rand 0.05);
    $self->_call_after($delay, '_on_timeout');
}

1;
