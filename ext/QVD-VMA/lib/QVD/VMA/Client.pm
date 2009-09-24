package QVD::VMA::Client;

use strict;
use warnings;

use parent 'QVD::SimpleRPC::Client';

sub new {
    my ($class, $host, $port) = @_;
    $class->SUPER::new("http://$host:$port/vma/");
}

1;

__END__

=head1 NAME

QVD::VMA::Client - client side for VMA service

=head1 DESCRIPTION

=cut
