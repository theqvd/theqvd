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

QVD::VMAS::Client - RPC client for Virtual Machine Administration Services.

=head1 SYNOPSIS

	use QVD::VMAS::Client;
	my $vmas_client = QVD::VMAS::Client->new();

=head1 DESCRIPTION

This module implements the VMAS RPC client. See the documentation of the VMAS
RPC server (QVD::VMAS) to see which calls are available.

=head2 API

=over

=item new()

Create an RPC client that connects to the VMAS running at localhost.

=back

=head1 AUTHOR

Salvador Fandiño, C<< <sfandino at yahoo.com> >>

Joni Salonen, C<< <jsalonen at qindel.es> >>.

=head1 COPYRIGHT & LICENSE

Copyright C<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

