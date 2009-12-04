package QVD::VMAS::RCClient;

use strict;
use warnings;

use parent 'QVD::SimpleRPC::Client';

sub new {
    my ($class, $host, $port) = @_;
    $port //= 8080;
    $class->SUPER::new("http://$host:$port/qvd/rc/", timeout => 5);
}

1;

__END__

=head1 NAME

QVD::VMAS::RCClient - RPC client for the Virtual Machine Agent.

=head1 SYNOPSIS

	use QVD::VMAS::RCClient;
	my $vma_client = QVD::VMAS::RCClient->new('localhost', 3030);

=head1 DESCRIPTION

This module implements the RC RPC client. See the documentation of the RC RPC
server (QVD::RC) to see what calls are available.

=head2 API

=over

=item new($host, $port = 8080)

Create a vma client that connects to the RC running at the given host and port.
The default value for port is 8080.

=back

=head1 AUTHOR

Joni Salonen, C<< <jsalonen at qindel.es> >>

=head1 COPYRIGHT & LICENSE

Copyright C<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

