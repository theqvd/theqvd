package QVD::NxBroker;
use Moose;

has 'host' => (is => 'ro', isa => 'Str', required => 1);
has 'port'    => (is => 'ro', isa => 'Int', required => 1);
has 'id'      => (is => 'rw', isa => 'Str | Undef', default => sub { return undef; } );

my $docker_image = "registry.qindel.com:5000/qvd/qvd-nx2v-gateway:latest";

sub start_tunnel_with_login {
    my $self = shift;
    my $vm_id = shift;
    my $user_login = shift;
    my $password = shift;

    if(system("docker", "run", "-d", "-P", $docker_image,
        "/start_nx2v.pl",
        "--host", $self->host,
        "--port", $self->port,
        "--vm-id", $vm_id,
        "--login", $user_login,
        "--password", $password ) == 0) 
    {
        chomp($self->{id} = `docker ps -aql`);
        sleep(10);
    }

    return $self->id; 
}

sub start_tunnel_with_token {
    my $self = shift;
    my $vm_id = shift;
    my $token = shift;

    if(system("docker", "run", "-d", "-P", $docker_image,
        "/start_nx2v.pl",
        "--host", $self->host,
        "--port", $self->port,
        "--vm-id", $vm_id,
        "--token", $token ) == 0)
    {
        chomp($self->{id} = `docker ps -aql`);
        sleep(10);
    }

    return $self->id;
}

sub stop_tunnel {
    my $self = shift;
    if(defined($self->id) && system("docker", "rm", "-f", $self->id) == 0){
        $self->{id} = undef;
        return 1;
    }
    return 0;
}

sub tunnel_address {
    my $self = shift;
    my $id = $self->id;
    chomp(my $container_address = `docker inspect $id --format='{{.NetworkSettings.IPAddress}}'`);
    return $container_address;
}

sub tunnel_port {
    my $self = shift;
    return 5900;
}

1;