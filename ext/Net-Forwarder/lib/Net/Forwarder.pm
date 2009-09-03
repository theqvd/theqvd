package Net::Forwarder;

use warnings;
use strict;

our $VERSION = '0.01';

use constant default_buffer_size => 64 * 1024;
use constant default_io_chunk_size => 16 * 1024;

sub new {
    my ($class, $s1, $s2, %opts) = @_;

    my $self = { s1 => $s1,
		 s2 => $s2,
		 opts => \%opts };
    bless $self, $class;
    $self;
}

sub run {
    my $self = shift;
    my $s1 = $self->{s1};
    my $s2 = $self->{s2};
    my $fn1 = fileno $s1;
    my $fn2 = fileno $s2;
    my $b1to2 = '';
    my $b2to1 = '';
    my $buffer_size = $self->{buffer_size} || default_buffer_size;
    my $io_chunk_size = $self->{io_chunk_size} || default_io_chunk_size;

    while (1) {
	my $wtr1 = length $b1to2 < $buffer_size;
	my $wtr2 = length $b2to1 < $buffer_size;
	my $wtw1 = length $b2to1;
	my $wrw2 = length $b1to2;

	my $bitsr = '';
	vec($bitsr, $fn1, 1) = 1 if $wtr1;
	vec($bitsr, $fn2, 1) = 1 if $wtr2;
	my $bitsw = '';
	vec($bitsw, $fn1, 1) = 1 if $wrw1;
	vec($bitsw, $fn2, 1) = 1 if $wtw2;

	my $n = select($bitsr, $bitsw, undef, undef);
	if ($n > 0) {
	    if (vec($bitsr, $fn1, 1)) {
		sysread($s1, $b1to2, $io_chunk_size, length $b1to2);
		# working here!!!
	    }
	}

}

1;

__END__

=head1 NAME

Net::Forwarder - bidirectionally forward data between two sockets

=head1 SYNOPSIS

  use Net::Forwarder;

  my $fwd = Net::Forwarder->new($sock1, $sock2, %opts);
  $fwd->run();

=head1 DESCRIPTION

This module can forward data between two sockets bidirectionally.

=head1 BUGS AND SUPPORT

Please report any bugs or feature requests through the web interface
at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Forwarder> or
just send my an email with the details.

=head1 AUTHOR

Salvador FandiE<ntilde>o (sfandino@yahoo.com).

=head1 COPYRIGHT & LICENSE

Copyright E<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
