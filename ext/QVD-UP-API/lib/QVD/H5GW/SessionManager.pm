package QVD::H5GW::SessionManager;
use Moo;
use MooX::Types::MooseLike::Base qw(:all);
use QVD::H5GW::DockerManager;
use QVD::Config;
use Mojo::Log;

our $log = Mojo::Log->new(path => cfg('log.up-api.filename'));

has 'host'    => (is => 'ro', isa => Str, required => 1);
has 'port'    => (is => 'ro', isa => Int, required => 1);
has 'id'      => (is => 'rw', isa => AnyOf[Undef, Str], default => sub { return undef; } );
has 'inspect' => (is => 'ro' );

my $docker_image = cfg('up-api.docker.image.h5gw');
my $manager = QVD::H5GW::DockerManager->new(uri => cfg('up-api.docker.uri'));

sub start_tunnel_with_login {
    my $self = shift;
    my $vm_id = shift;
    my $user_login = shift;
    my $password = shift;
    my $cb = shift // sub {};

    $manager->create(
        $docker_image,
        {
            PublishAllPorts => \1,
            Cmd             => [
                "--host", $self->host,
                "--port", $self->port,
                "--vm-id", $vm_id,
                "--login", $user_login,
                "--password", $password
            ],
        },
        sub {
            my ($json) = @_;
            if ($json->{_status} == 0) {
                $self->{id} = $json->{_id};
                $manager->start( $self->{id}, { }, sub {
                        my ($json) = @_;
                        if ($json->{_status} == 0) {
                            $manager->inspect($self->{id}, {}, sub {
                                    my ($json) = @_;
                                    $self->{inspect} = $json;
                                    $log->debug("Container ".$self->{id}." started");
                                    $cb->();
                                }
                            );
                        } else {
                            $log->error("Cannot start container: " . $json->{_message});
                        }
                    }
                );
            } else {
                $log->error("Cannot create container: " . $json->{_message});
            }
        }
    );

    return 1;
}

sub start_tunnel_with_token {
    my $self = shift;
    my $vm_id = shift;
    my $token = shift;
    my $cb = shift // sub {};

    $manager->create(
        $docker_image,
        {
            PublishAllPorts => \1,
            Cmd             => [
                "--host", $self->host,
                "--port", $self->port,
                "--vm-id", $vm_id,
                "--token", $token
            ],
        },
        sub {
            my ($json) = @_;
            if ($json->{_status} == 0) {
                $self->{id} = $json->{_id};
                $manager->start( $self->{id}, { }, sub {
                        my ($json) = @_;
                        if ($json->{_status} == 0) {
                            $manager->inspect($self->{id}, {}, sub {
                                    my ($json) = @_;
                                    $self->{inspect} = $json;
                                    $log->debug("Container ".$self->{id}." started");
                                    $cb->();
                                }
                            );
                        } else {
                            $log->error("Cannot start container: " . $json->{_message});
                        }
                    }
                );
            } else {
                $log->error("Cannot create container: " . $json->{_message});
            }
        }
    );

    return 1;
}

sub stop_tunnel {
    my $self = shift;
    if(defined($self->id)) {
        $manager->stop($self->id, {}, sub {
                my ($stop_res) = @_;
                if($stop_res->{_status} == 0) {
                    $manager->remove($self->id, {}, sub {
                            my ($remove_res) = @_;
                            if($remove_res->{_status} == 0) {
                                $log->debug("Container ".$self->{id}." removed");
                                $self->{id} = undef;
                            } else {
                                $log->error("Cannot remove container: " . $remove_res->{_message});
                            }
                        }
                    );
                } else {
                    $log->error("Cannot stop container: " . $stop_res->{_message});
                }
            }
        );
    } else {
        $log->error("Container is not started");
    }
    
    return 1;
}

sub tunnel_address {
    my $self = shift;

    if (defined($self->inspect)){
        return $manager->ip_address_from_inspect($self->inspect);
    } else {
        $log->error("Container is not started");
        return undef;
    }
}

sub tunnel_port {
    my $self = shift;

    if (defined($self->inspect)) {
        my %ports = map { $1 => $2 if $_ =~ /(\d+)\/(\w+)/ } @{$manager->ports_from_inspect($self->inspect)};
        if (%ports) {
            return (keys %ports)[0];
        }
    } else {
        $log->error("Container is not started");
    }
    return undef;
}

1;