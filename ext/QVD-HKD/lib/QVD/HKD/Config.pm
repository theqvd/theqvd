package QVD::HKD::Config;

#BEGIN { *debug = \$QVD::HKD::debug }
our $debug = 1;

use strict;
use warnings;
use Carp;
use Config::Properties;
use Pg::PQ qw(:pgres);
use QVD::Log;
use QVD::Config::Core::Defaults;
use QVD::HKD::Helpers;

use parent qw(QVD::HKD::Agent);

use Class::StateMachine::Declarative

    __any__ => { advance => '_on_done',
                 transitions => {  _on_qvd_config_changed_notify => 'reloading',
                                   on_hkd_stop => 'stopped' } },

    reloading => { enter => '_reload',
                   before => { _on_done => '_send_config_reloaded' },
                   transitions => { _on_error => 'delay' } },

    '(delay)' => { enter => '_set_timer',
                   transitions => { _on_timeout => 'reloading' } },

    idle      => {},

    stopped   => { enter => '_on_stopped' };


sub new {
    my ($class, %opts) = @_;
    my $config_file = delete $opts{config_file};
    my $on_reload_done = delete $opts{on_reload_done};

    my $self = $class->SUPER::new(%opts);

    $self->{config_file} = $config_file;
    $self->{on_reload_done} = $on_reload_done;

    $self->{props} = $self->_load_base_config;
    $self->{query_priority} = 20;
    $self->state('idle');
    $self;
}

sub _load_base_config {
    my $self = shift;
    my $props = Config::Properties->new(defaults => $QVD::Config::Core::defaults);
    my $file = $self->{config_file};
    DEBUG "Loading configuration from file '$file'";
    -f $file or croak "configuration file $file does not exist";
    open my $fh, '<', $file
        or croak "unable to open configuration file $file: $!";
    $props->load($fh);
    $props;
}

sub _cfg {
    my $self = shift;
    $self->_cfg_optional(@_) // LOGDIE "configuration entry $_[0] missing";
}

sub _cfg_optional {
    my $self = shift;
    my $value = $self->{props}->getProperty(@_);
    if (defined $value) {
        $value =~ s/\${(.*?)}/$1 eq '{' ? '${' : $self->_cfg($1)/ge;
        $debug and $self->_debug("config: $_[0] = $value");
    }
    else {
        $debug and $self->_debug("config: $_[0] is undef");
    }
    $value
}

sub set_db {
    my ($self, $db) = @_;
    $self->_db($db);
    # we depend on the listener calling back the
    # _on_qvd_config_changed_notify method here in order to get the
    # ball rolling:
    $self->_listen('qvd_config_changed');
}

sub _reload {
    my $self = shift;
    $self->_query('select key, value from configs');
}

sub _on_reload_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_TUPLES_OK) {
        my @rows = $res->rows;
        my $props = $self->_load_base_config;
        DEBUG 'Reloading configuration from database';
        for (@rows) {
            my ($k, $v) = @$_;
            if (defined $k and length $k) {
                $props->changeProperty($k, $v);
                $v = '*****' if $k =~ /passw(?:or)?d/;
                DEBUG "configuration set: $k=$v";
            }
        }
        $self->{props} = $props;
    }
}

sub _send_config_reloaded {
    my $self = shift;
    $self->_maybe_callback('on_reload_done');
}

sub _set_timer {
    my $self = shift;
    $self->_call_after($self->_cfg('internal.hkd.agent.config.delay' ), '_on_timeout');
}

1;
