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

use parent 'QVD::HKD::Agent';

use QVD::StateMachine::Declarative
    idle      => { transitions => { _on_qvd_config_changed_notify => 'reloading' } },

    reloading => { enter       => '_reload',
                   transitions => { _goto_idle                    => 'idle'      },
                   delay       => [qw(_on_qvd_config_changed_notify)]              };

sub new {
    my ($class, %opts) = @_;
    my $config_file = delete $opts{config_file};
    my $on_reload_error = delete $opts{on_reload_error};
    my $on_reload_done = delete $opts{on_reload_done};

    my $self = $class->SUPER::new(%opts);

    $self->{config_file} = $config_file;
    $self->{on_reload_error} = $on_reload_error;
    $self->{on_reload_done} = $on_reload_done;

    $self->{props} = $self->_load_base_config;
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
    my $value = $self->{props}->getProperty(@_);
    unless (defined $value) {
        $debug and $self->_debug("configuration entry for key $_[0] missing");
        LOGDIE "configuration entry $_[0] missing";
    }
    $value =~ s/\${(.*?)}/$1 eq '{' ? '${' : $self->_cfg($1)/ge;
    $debug and $self->_debug("config: $_[0] = $value");
    $value;
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
    delete $self->{reload_failed};
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
                DEBUG "configuration set: $k=$v";
            }
        }
        $self->{props} = $props;
    }
    else {
        $self->{reload_failed} = 1;
    }
}

sub _on_reload_error {
    my $self = shift;
    $self->{reload_failed} = 1;
    $self->_on_reload_done;
}

sub _on_reload_done {
    my $self = shift;
    $self->_maybe_callback($self->{reload_failed}
                           ? 'on_reload_error'
                           : 'on_reload_done');
    $self->_goto_idle;
}
1;
