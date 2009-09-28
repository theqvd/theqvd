package QVD::VMAS::Client;

use strict;
use warnings;

use parent 'QVD::SimpleRPC::Client';

sub new {
    my $class = shift;
    $class->SUPER::new('http://localhost:8080/vmas/');
}

1;

__END__

=head1 NAME

QVD::VMAS::Client - client side for VMAS service

=head1 DESCRIPTION

Currently this class is just a hack that calls the VMA service directly

=cut


