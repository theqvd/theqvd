package QVD::HKD::L7RListener;

use strict;
use warnings;

use Method::WeakCallback qw(weak_method_callback);
use AnyEvent::Socket;
use parent 'QVD::HKD::Agent';

use Class::StateMachine::Declarative
    new     => { transitions => { _on_run => 'running' } },

    running => { enter => '_start_listener',
                 leave => '_stop_listener',
                 transitions => { on_hkd_stop => 'stopped' } },

    stopped => { enter => '_on_stopped' };


sub new {
    my ($class, %opts) = @_;
    my $on_connection = delete $opts{on_connection};
    my $self = $class->SUPER::new(%opts);
    $self->{on_connection} = $on_connection;
    $self;
}

sub _start_listener {
    my $self = shift;
    my $address = $self->_cfg('l7r.address');
    undef $address if $address eq '*';
    my $port = $self->_cfg('l7r.port');
    $self->{server} = tcp_server $address, $port,
        weak_method_callback($self, '_on_new_connection');
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
