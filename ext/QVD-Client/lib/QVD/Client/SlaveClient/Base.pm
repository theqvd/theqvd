package QVD::Client::SlaveClient::Base;

use strict;
use warnings;

use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTPC;
use QVD::Log;

sub new {
    my ($class, %opts) = @_;

    my $host = delete $opts{'slave.host'};
    my $port = delete $opts{'slave.port'};
    my $key = delete $opts{'slave.key'};

    my $self = { 
        auth_key => $key,
        httpc => QVD::HTTPC->new("$host:$port", %opts)
    };
    bless $self, $class;
    $self
}

sub dispatch {
    my ($self, $command, $help, @args) = @_;
    
    my $method = $self->can($help? "help_$command": "handle_$command");
    if (defined $method) {
        $self->$method(@args);
    } else {
        $self->handle_usage();
    }
}

sub help_share {
    print "Syntax: share /path/to/folder

    Forwards the specified folder to the virtual machine.\n"
}

sub handle_share {
}

sub help_open {
}

sub handle_open {
    my ($self, $path, $ticket) = @_;

    $ticket = 'ROOT' unless defined $ticket;

    my ($code, $msg, $headers, $data) =
    $self->{httpc}->make_http_request(POST => '/open/'.$path,
        headers => [
            "Authorization: Basic $self->{auth_key}",
            "X-QVD-Share-Ticket: $ticket"
        ]);
    
    if ($code != HTTP_OK) {
        die "Server replied $code $msg $data";
    }
}

sub handle_usage {
    # FIXME
    print "** Write usage doc!\n";
}

1;
