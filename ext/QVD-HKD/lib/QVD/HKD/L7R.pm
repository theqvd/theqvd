package QVD::HKD::L7R;

use strict;
use warnings;
use Carp;
use Method::WeakCallback qw(weak_method_callback);
use AnyEvent::Util qw(fork_call);

use QVD::Log;
use parent 'QVD::HKD::Agent';

use Class::StateMachine::Declarative

    __any__ => { ignore => [qw(_on_kill)],
                 on => { on_hkd_stop => '_on_kill',
                         on_hkd_kill => '_on_kill' },
                 transitions => { _on_l7r_done => 'stopped' } },

    new     => { transitions => { '_on_run' => 'running' } },

    running => { enter => '_start',
                 transitions => { _on_kill => 'killing' } },

    killing => { enter => '_kill',
                 substates => [ waiting => { enter => '_set_state_timer',
                                             transitions => { _on_timeout => 'killing' } } ] },

    stopped => { enter => '_on_stopped' };

sub new {
    my ($class, %opts) = @_;
    my $self = $class->SUPER::new(%opts);
    $self;
}

sub run {
    my ($self, $fh) = @_;
    $self->{fh} = $fh;
    DEBUG "L7R fh: $fh, fileno: " . (eval {fileno($fh)} // '<undef>');
    $self->_on_run;
    DEBUG "New L7R process $self->{pid}";
    return $self->{saved_pid};
}

sub _set_env_perl5lib {

}

sub _start {
    my $self = shift;
    my $fh = delete $self->{fh};
    $self->{pid} and croak "L7R is already running!";
    $self->_run_cmd( { save_pid_to => 'pid',
                       ignore_errors => 1,
                       outlives_state => 1,
                       on_prepare => sub {
                           POSIX::dup2(fileno($fh), 0);
                           POSIX::dup2(0, 1);
                           $ENV{PERL5LIB} = ( join ':',
                                              map  { File::Spec->rel2abs($_) }
                                              grep { defined and not ref $_ } @INC);
                       },
                       on_done => weak_method_callback($self, '_on_l7r_done') },
                     'qvd-l7r-slave');
    # Agent::_run_cmd deletes the 'save_pid_to' entry automatically so
    # we have to duplicate it:
    $self->{saved_pid} = $self->{pid};
}

sub _kill {
    my $self = shift;
    my $signal = ($self->{hard}++ ? 'KILL' : 'TERM');
    kill $signal, $self->{pid};
}

sub _set_state_timer {
    my $self = shift;
    my $state = $self->state;
    $state =~ s|/|.|g;
    $self->_call_after($self->_cfg("internal.hkd.l7r.timeout.on_state.$state"), '_on_state_timeout');
}

sub pid { shift->{saved_pid} }


1;
