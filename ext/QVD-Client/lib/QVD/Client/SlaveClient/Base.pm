package QVD::Client::SlaveClient::Base;

use strict;
use warnings;

use QVD::HTTPC;
use QVD::Log;

sub new {
    my ($class, $target, %opts) = @_;

    my $self = { 
        httpc => QVD::HTTPC->new($target, %opts)
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

sub handle_usage {
    # FIXME
    print "** Write usage doc!\n";
}

1;
