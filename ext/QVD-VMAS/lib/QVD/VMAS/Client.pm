package QVD::VMAS::Client;

use strict;
use warnings;

use parent 'QVD::SimpleRPC::Client';

sub new {
    my $class = shift;
    $class->SUPER::new('http://localhost:3030/vma/');
}

1;
