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
                         on_hkd_kill => '_on_kill',
                         _on_abort   => '_on_kill' },

                 transitions => { _on_l7r_done => 'cleanup' } },

    new     => { transitions => { '_on_run' => 'running' } },

    running => { enter => '_start',
                 transitions => { _on_kill => 'killing' } },

    killing => { enter => '_kill',
                 substates => [ waiting => { enter => '_set_state_timer',
                                             transitions => { _on_timeout => 'killing' } } ] },

    cleanup => { enter => '_clean_row',
                 transitions => { _on_done => 'stopped' } },

    stopped => { enter => '_on_stopped' };

sub abort { shift->_on_abort }

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
    DEBUG "New L7R process $self->{saved_pid}";
    return $self->{saved_pid};
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
    DEBUG "Killing L7R process $self->{pid} with signal $signal";
    kill $signal, $self->{pid} if $self->{pid};
}

sub _set_state_timer {
    my $self = shift;
    my $state = $self->state;
    $state =~ s|/|.|g;
    $self->_call_after($self->_cfg("internal.hkd.l7r.timeout.on_state.$state"), '_on_state_timeout');
}

sub pid { shift->{saved_pid} }

sub _clean_row {
    my $self = shift;
    my $pid = $self->{saved_pid};
    defined $pid or return $self->_on_done;

    $self->_query({ ignore_errors => 1 },
                  <<'EOQ', $self->{node_id}, $pid);
update vm_runtimes
   set user_cmd = NULL,
       l7r_host_id = NULL,
       l7r_pid  = NULL,
       user_state = 'disconnected'
   where l7r_host_id = $1
     and l7r_pid = $2
EOQ
}

1;
