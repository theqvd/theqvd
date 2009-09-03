package QVD::VMAS::Client;

use strict;
use warnings;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub start_vm_listener {
    my ($self, $id) = @_;
    return ("localhost", 3030);

    
}

sub error {
    return 0;
}

1;
