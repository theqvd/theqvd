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

sub new {
    my ($class, %opts) = @_;
    my $config_file = delete $opts{config_file};
    my $on_reload_error = delete $opts{on_reload_error};
    my $on_reload_done = delete $opts{on_reload_done};

    my $self = $class->SUPER::new(%opts);

    $self->{config_file} = $config_file;
    $self->{props} = Config::Properties->new(defaults => $QVD::Config::Core::defaults);
    $self->{on_reload_error} = $on_reload_error;
    $self->{on_reload_done} = $on_reload_done;

    $self->_reload_base_config;
    $self;
}

sub _reload_base_config {
    my $self = shift;
    my $props = $self->{props};
    my $file = $self->{config_file};
    DEBUG "(re-)Loading configuration from file '$file'";
    -f $file or croak "configuration file $file does not exist";
    open my $fh, '<', $file
        or croak "unable to open configuration file $file: $!";
    $props->load($fh);
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

sub set_db_and_reload {
    my ($self, $db) = @_;
    $self->_db($db);
    $self->reload;
}

sub reload { shift->_query('select key, value from configs') }

sub _on_reload_result {
    my ($self, $res) = @_;
    if ($res->status == PGRES_TUPLES_OK) {
        my @rows = $res->rows;
        $self->_reload_base_config;
        my $props = $self->{props};
        DEBUG 'Reloading configuration from database';
        for (@rows) {
            my ($k, $v) = @$_;
            $props->changeProperty($k, $v) if $k;
        }
    }
    else {
        $self->_cancel_current_query;
        $self->_maybe_callback('on_reload_error');

        # FIXME:
        croak "bad result from database: " . $res->status . ", " . $res->errorMessage;
    }
}

sub _on_reload_error { shift->_maybe_callback('on_reload_error') }

sub _on_reload_done { shift->_maybe_callback('on_reload_done') }

1;
