package QVD::H5GW::DockerManager;
use strict;
use warnings FATAL => 'all';

use Moo;
use Mojo::UserAgent;
use Mojo::URL;

use constant {
    RESP_DEFAULT  => 'DEFAULT',
    RESP_LIST     => 'LIST',
    RESP_CREATE   => 'CREATE',
    RESP_EMPTY    => 'EMPTY',
};

has uri     => (is => 'ro');
has ua      => (is => 'lazy');

sub BUILD {
    my ($self, $args) = @_;
    $args->{uri} =~ s/\/+$//g;
    $self->{uri} = $args->{uri}
}

sub _build_ua {
    my $self = shift;
    my $ua = Mojo::UserAgent->new;
    return $ua;
}

sub _parse {
    my ($self, $verb, $path, $params, $action, $cb) = @_;
    $params //= {};
    my $header = {
        Host => 'localhost',
    };
    my ($custom_cb, $async) = _gen_callback($cb, $action);

    my $url = $self->{uri} . $path;
    
    my $tx = $self->ua->start($self->ua->build_tx($verb => "$url" => $header => json => $params), $async ? $custom_cb : undef);
    
    if($async) {
        return 1;
    } else {
        return $custom_cb->($self->ua, $tx);
    }

}

sub _gen_callback {
    my ($cb, $action) = @_;
    my $custom_cb;
    my $async;
    if(defined($cb)){
        $async = 1;
        $custom_cb = sub {
            my ($ua, $tx) = @_;
            return $cb->(_gen_response($tx->res, $action));
        };
    } else {
        $async = 0;
        $custom_cb = sub {
            my ($ua, $tx) = @_;
            return _gen_response($tx->res, $action);
        };
    }

    return ($custom_cb, $async);
}

sub _gen_response {
    my ($response, $action) = @_;
    $action //= RESP_DEFAULT;
    my $output = {
        _status => 0
    };
    
    if ($response->error) {
        $output->{_status} = 1;
        $output->{_message} = $response->error->{message};
    } else {
        if($action eq RESP_EMPTY) {
            # Nothing to do in this case
        } elsif ($action eq RESP_CREATE) {
            $output->{_id} = $response->json->{Id};
        } elsif ($action eq RESP_LIST) {
            $output->{_list} = $response->json;
        } else {
            my %json = %{$response->json // {}};
            @{$output}{keys %json} = values %json;
        }
    }
    
    return $output;

}

sub create {
    my ($self, $image, $params, $cb) = @_;
    my %custom_params = %{$params // {}};
    $custom_params{Image} = $image;
    return $self->_parse('POST', '/containers/create', \%custom_params, RESP_CREATE, $cb);
}

sub remove {
    my ($self, $container, $params, $cb) = @_;
    return $self->_parse('DELETE', '/containers/'.$container, $params, RESP_EMPTY, $cb);
}

sub start {
    my ($self, $container, $params, $cb) = @_;
    return $self->_parse('POST', '/containers/'.$container.'/start', $params, RESP_EMPTY, $cb);
}

sub stop {
    my ($self, $container, $params, $cb) = @_;
    return $self->_parse('POST', '/containers/'.$container.'/stop', $params, RESP_EMPTY, $cb);
}

sub images {
    my ($self, $params, $cb) = @_;
    return $self->_parse('GET', '/images/json', $params, RESP_LIST, $cb);
}

sub ps {
    my ($self, $params, $cb) = @_;
    return $self->_parse('GET', '/containers/json', $params, RESP_LIST, $cb);
}

sub inspect {
    my ($self, $container, $params, $cb) = @_;
    return $self->_parse('GET', '/containers/'.$container.'/json', $params, RESP_DEFAULT, $cb);
}

sub ip_address_from_inspect {
    my ($self, $inspect) = @_;
    return $inspect->{NetworkSettings}->{IPAddress};
}

sub ports_from_inspect {
    my ($self, $inspect) = @_;
    my @ports = keys %{$inspect->{NetworkSettings}->{Ports}};
    return \@ports;
}

1;