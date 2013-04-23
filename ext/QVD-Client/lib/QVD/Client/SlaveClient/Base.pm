package QVD::Client::SlaveClient::Base;

use strict;
use warnings;

use QVD::HTTPC;
use QVD::Log;

sub new {
    my ($class, $target, %opts) = @_;

    INFO "Slave client to $target";

    my $self = { 
        httpc => QVD::HTTPC->new($target, %opts)
    };
    bless $self, $class;
    $self
}

1;
