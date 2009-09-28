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

QVD::VMA::Client - RPC client for the Virtual Machine Agent.

=head1 SYNOPSIS

	use QVD::VMA::Client;
	my $vma_client = QVD::VMA::Client->new('localhost', 3030);

=head1 DESCRIPTION

This module implements the VMA RPC client. See the documentation of the VMA RPC
server (QVD::VMA) to see what calls are available.

=head2 API

=over

=item new(host, port)

Create a vma client that connects to the VMA running at the given host and port.

=back

=head1 AUTHOR

Joni Salonen, C<< <jsalonen at qindel.es> >>

=head1 COPYRIGHT & LICENSE

Copyright C<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

