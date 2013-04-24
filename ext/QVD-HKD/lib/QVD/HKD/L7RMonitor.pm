package QVD::HKD::L7RMonitor;

use strict;
use warnings;
no warnings 'redefine';

use 5.010;

BEGIN { *debug = \$QVD::HKD::debug }
our $debug;

use parent qw(QVD::HKD::Agent);
use QVD::Log;

use Class::StateMachine::Declarative

    __any__ => { transitions => { 'on_hkd_stop' => 'stopped' } },

    new     => { transitions => { _on_run => 'idle' } },

    running => { advance => '_on_done',
                 transitions => { _on_error => 'idle' },
                 substates => [ searching_l7rs    => { enter => '_search_l7rs' },
                                checking_l7rs     => { enter => '_check_l7rs' },
                                cleaning_dead_l7r => { enter => '_clean_dead_l7r' },
                                redo              => { jump => 'cleaning_dead_l7r' } ] },

    idle    => { enter => '_set_state_timer',
                 transitions => { _on_timeout => 'running' } },

    stopped => { enter => '_on_stopped'  };


sub _search_l7rs {
    my $self = shift;
    DEBUG "searching for L7R processes running on this host $self->{node_id}";
    $self->_query({save_to => 'l7rs'},
                  <<'EOQ', $self->{node_id});
select vm_id, l7r_pid
  from vm_runtimes
  where l7r_host = $1
    and l7r_pid is NOT NULL
EOQ
}

sub _check_process {
    my $pid = shift;
    DEBUG "checking process $pid";
    if (kill 0, $pid) {
        DEBUG "L7R process $pid is running";
    }
    elsif ($! == Errno::ESRCH()) {
        WARN "L7R process $pid died unexpectedly";
        return;
    }
    else {
        WARN "Unable to check L7R process $pid: $!"
    }
    return 1;
}

sub _check_l7rs {
    my $self = shift;
    my $l7rs = $self->{l7rs};
    @$l7rs = grep(!_check_process($_->{l7r_pid}), @$l7rs);
    unless (@$l7rs) {
        DEBUG "all the L7R processes on this host are alive and kicking!";
        return $self->_on_error; # shortcut to idle state
    }
    $self->_on_done;
}

sub _clean_dead_l7r {
    my $self = shift;
    if (defined(my $l7r = shift @{$self->{l7rs}})) {
        $self->_query({n => 1},
                      <<'EOQ', $l7r->{vm_id}, $l7r->{l7r_pid}, $self->{node_id}),
update vm_runtimes
  set (user_state, user_cmd, l7r_host, l7r_pid) = ('disconnected', NULL, NULL, NULL)
  where vm_id    = $1
    and l7r_pid  = $2
    and l7r_host = $3
EOQ
    }
    else {
        $self->_on_error;
    }
}

sub _set_state_timer {
    my $self = shift;
    $self->_call_after($self->_cfg('internal.hkd.agent.l7rmonitor.delay' ), '_on_timeout');
}

1;
