package QVD::HKD::L7RListener;

use strict;
use warnings;

use Method::WeakCallback qw(weak_method_callback);
use AnyEvent::Socket;
use File::Spec;
use QVD::Log;
use QVD::HKD::Helpers qw(mkpath);

use parent 'QVD::HKD::Agent';

use Class::StateMachine::Declarative
    __any__ => { delay => [qw(on_config_changed)],
                 on => { _on_error => '_on_done' } },

    new      => { transitions => { _on_run => 'config' } },

    config   => { enter => '_load_ssl_config',
                  before => { _on_done => '_save_ssl_config' },
                  transitions => { _on_done => 'running' } },

    running  => { enter => '_start_listener',
                  transitions => { on_hkd_stop => 'stopping',
                                   on_config_changed => 'config' } },

    stopping => { enter => '_on_done',
                  leave => '_stop_listener',
                  transitions => { _on_done => 'stopped' } },

    stopped  => { enter => '_on_stopped' };


sub new {
    my ($class, %opts) = @_;
    my $on_connection = delete $opts{on_connection};
    my $self = $class->SUPER::new(%opts);
    $self->{on_connection} = $on_connection;
    $self;
}

sub _load_ssl_config {
    my $self = shift;
    delete $self->{ssl_data};
    $self->_query({save_pairs_to => 'ssl_data'},
                  'select key, value from ssl_configs');
}

sub _write_file {
    my ($self, $fn, $contents) = @_;
    unlink $fn;
    if (-e $fn) {
        ERROR "Unable to remove old file '$fn'";
        return;
    }
    if (defined $contents) {
        my ($vol, $dir) = File::Spec->splitpath($fn);
        my $path = File::Spec->join($vol, $dir);
        mkpath $path, 0700;
        unless (-d $path) {
            ERROR "Unable to create directory '$path'";
            return;
        }
        my ($mode, $uid) = (stat $path)[2, 4];
        unless ($uid == $> or $uid == 0) {
            WARN "Directory '$path' has the wrong owner (uid: $uid), changing to $>";
            if (!chown $>, -1, $path) {
                ERROR "chown: '$path': $!";
                return;
            }
        }
        if ($mode & 0077) {
            WARN sprintf("Directory '%s' has the wrong permissions (%04o), changing to 0700", $path, ($mode & 0777));
            if (!chmod 0700, $path) {
                ERROR "chmod: '$path': $!";
                return;
            }
        }

        my $fh;
        unless ( open $fh, '>', $fn  and
                 binmode $fh         and
                 print $fh $contents and
                 close $fh) {
            ERROR "Unable to write file '$fn': $!";
            return;
        }
    }
    1;
}

sub _save_ssl_config {
    my $self = shift;
    my $use_ssl = $self->_cfg('l7r.use_ssl');
    my $ok = 1;
    for my $file (qw(key cert ca crl)) {
        my $fn = $self->_cfg("path.l7r.ssl.$file");
        if ($use_ssl) {
            $ok &&= $self->_write_file($fn, $self->{ssl_data}{"l7r.ssl.$file"});
        }
        else {
            unlink $fn;
        }
    }
    $self->{configured} = $ok;
}

sub _start_listener {
    my $self = shift;
    $self->_stop_listener;
    if ($self->{configured}) {
        my $port = $self->_cfg('l7r.port');
        my $address = $self->_cfg('l7r.address');
        my $address1 = ($address eq '*' ? undef : $address);
        $self->{server} = tcp_server $address1, $port,
            weak_method_callback($self, '_on_new_connection');
        INFO "L7RListener started on $address:$port";
    }
    else {
        ERROR "L7RListener not started because of previous errors";
    }
}

sub _stop_listener {
    my $self = shift;
    delete $self->{server};
}

sub _on_new_connection {
    my $self = shift;
    $self->_maybe_callback('on_connection', @_)
}


1;
