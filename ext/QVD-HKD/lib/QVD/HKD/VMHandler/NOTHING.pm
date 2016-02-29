package QVD::HKD::VMHandler::NOTHING;

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
use QVD::HKD::VMHandler::LXC::FS;

use parent qw(QVD::HKD::VMHandler);

use Class::StateMachine::Declarative
    __any__   => { ignore => [qw(_on_cmd_start on_expired)],
                   delay => [qw(on_hkd_kill
                                _on_cmd_stop)],
                   on => { on_hkd_stop => 'on_hkd_kill' } },


    new       => { transitions => { _on_cmd_start        => 'starting',
                                    _on_cmd_stop         => 'stopping/db',
                                    _on_cmd_catch_zombie => 'stopping/db' } },

    starting  => { on => { on_hkd_kill => '_on_error' },
                   transitions => { _on_error => 'stopping/db',
                                    _on_done  => 'running' },
                   advance => '_on_done',
                   substates => [ db       => { substates => [ loading_row        => { enter => '_load_row' },
                                                               searching_di       => { enter => '_search_di' },
                                                               calculating_attrs  => { enter => '_calculate_attrs' },
                                                               saving_runtime_row => { enter => '_save_runtime_row' },
                                                               updating_stats     => { enter => '_incr_run_attempts' } ] },
                                  nothing1 => { enter => '_do_nothing' },
                                  heavy    => { enter => '_heavy_down' },
                                  nothing2 => { enter => '_do_nothing' } ] },

    running   => { on => { on_hkd_kill => '_on_error',
                           on_expired => '_on_error',
                           _on_cmd_stop => '_on_error' },
                   transitions => { _on_error => 'stopping' },
                   advance => '_on_done',
                   substates => [ saving_state   => { enter => '_save_state' },
                                  updating_stats => { enter => '_incr_run_ok' },
                                  nothing        => { enter => '_do_nothing' },
                                  unheavy        => { enter => '_heavy_up' },
                                  monitoring     => { enter => '_do_nothing_forever' } ] },

    stopping  => { transitions => { _on_error => 'zombie',
                                    _on_done => 'stopped' },
                   advance => '_on_done',
                   substates => [ shutdown => { substates => [ saving_state => { enter => '_save_state' },
                                                               heavy        => { enter => '_heavy_down' },
                                                               nothing      => { enter => '_do_nothing' } ] },

                                  stop     => { substates => [ saving_state => { enter => '_save_state' },
                                                               heavy        => { enter => '_heavy_down' },
                                                               nothing      => { enter => '_do_nothing' } ] },

                                  cleanup  => { substates => [ saving_state => { enter => '_save_state' },
                                                               heavy        => { enter => '_heavy_down' },
                                                               nothing      => { enter => '_do_nothing' } ] },

                                  db       => { enter => '_clear_runtime_row' } ] },

    stopped => { enter => '_on_stopped' },

    zombie  => { advance => '_on_done',
                 ignore => [qw(on_hkd_stop)],
                 transitions => { on_hkd_kill => 'stopped',
                                  _on_error => 'delaying' },
                 substates => [ clearing_runtime_row => { enter => '_clear_runtime_row',
                                                          transitions => { _on_done => 'stopped' } },
                                '(delaying)'         => { enter => '_do_nothing',
                                                          transitions => { _on_done => 'clearing_runtime_row' } } ] };

sub _do_nothing {
    my $self = shift;
    my $state = $self->state;
    $state =~ s|/|.|g;
    while (1) {
        my $delay = $self->_cfg("internal.hkd.$self->{hypervisor}.timeout.on_state.$state", 0);
        if ($delay > 0) {
            DEBUG "config for internal.hkd.$self->{hypervisor}.timeout.on_state.$state is $delay";

            $delay = 0.7 * $delay + 0.6 * rand($delay); # $delay +/- 30%
            $self->_call_after($delay, '_on_done');
            return;
        }
        DEBUG "no config entry found for internal.hkd.$self->{hypervisor}.timeout.on_state.$state";
        $state =~ s/\.[^\.]*$// or last;
    }
    LOGDIE "timeout for state ".$self->state." not found";
}

sub _do_nothing_forever {
    my $self = shift;
    WARN "do nothing forever";
    return;
}

sub _calculate_attrs {
    my $self = shift;
    $self->SUPER::_calculate_attrs;
    $self->_on_done;
}

1;
