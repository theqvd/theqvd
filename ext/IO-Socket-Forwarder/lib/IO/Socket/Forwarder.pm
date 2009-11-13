package IO::Socket::Forwarder;

our $VERSION = '0.02';

use warnings;
use strict;
use Carp;

use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(forward_sockets);

use constant default_io_buffer_size => 64 * 1024;
use constant default_io_chunk_size => 16 * 1024;

# lazy accessors to IO::Socket::SSL
# we use it but don't depend on it!
sub _ssl_error { $IO::Socket::SSL::SSL_ERROR }
sub _ssl_want_read { IO::Socket::SSL::SSL_WANT_READ() }
sub _ssl_want_write { IO::Socket::SSL::SSL_WANT_WRITE() }

sub forward_sockets {

    my ($s1, $s2, %opts) = @_;

    my $debug = delete $opts{debug};
    my $io_buffer_size = delete $opts{io_buffer_size} || default_io_buffer_size;
    my $io_chunk_size = delete $opts{io_chunk_size} || default_io_chunk_size;

    my $fn1 = fileno $s1;
    defined $fn1 or croak "socket 1 is not a valid file handle";
    my $fn2 = fileno $s2;
    defined $fn1 or croak "socket 2 is not a valid file handle";

    my $ssl1 = IO::Socket::SSL->isa($s1);
    my $ssl2 = IO::Socket::SSL->isa($s2);

    my $b1to2 = '';
    my $b2to1 = '';

    my $s1_in_closed;
    my $s1_out_closed;
    my $s2_in_closed;
    my $s2_out_closed;

    my ($ssl_wtr1, $ssl_wtw1, $ssl_wtr2, $ssl_wtw2);

    fcntl($s1, F_SETFL, fcntl($s1, F_GETFL, 0) | O_NONBLOCK)
	or croak "unable to make socket 1 non-blocking";
    fcntl($s2, F_SETFL, fcntl($s2, F_GETFL, 0) | O_NONBLOCK)
	or croak "unable to make socket 2 non-blocking";

    while (1) {
	my $wtr1 = (not $s1_in_closed and length $b1to2 < $io_buffer_size);
	my $wtr2 = (not $s2_in_closed and length $b2to1 < $io_buffer_size);
	my $wtw1 = (not $s1_out_closed and length $b2to1);
	my $wtw2 = (not $s2_out_closed and length $b1to2);

	$debug and warn "wtr1: $wtr1, wtr2: $wtr2, wtw1: $wtw1, wtw2: $wtw2\n";

	$wtr1 or $wtr2 or $wtw1 or $wtw2 or last;

	$wtr1 ||= $ssl_wtr1;
	$wtr2 ||= $ssl_wtr2;
	$wtw1 ||= $ssl_wtw1;
	$wtw2 ||= $ssl_wtw2;

	my $bitsr = '';
	vec($bitsr, $fn1, 1) = 1 if $wtr1;
	vec($bitsr, $fn2, 1) = 1 if $wtr2;
	my $bitsw = '';
	vec($bitsw, $fn1, 1) = 1 if $wtw1;
	vec($bitsw, $fn2, 1) = 1 if $wtw2;

	$debug and warn "calling select...\n";

	my $n = select($bitsr, $bitsw, undef, undef);

	$debug and warn "select done, n: $n\n";

	if ($n > 0) {
	    if ($wtr1 and vec($bitsr, $fn1, 1)) {
		undef $ssl_wtr1;
		$debug and warn "reading from s1...\n";
		my $bytes = sysread($s1, $b1to2, $io_chunk_size, length $b1to2);
		$debug and warn "bytes: $bytes\n";
		if ($bytes) {
		    $debug and warn "s1 read:\n" . substr($b1to2, -$bytes) . "*\n";
		}
		elsif ($ssl1 and not defined $bytes) {
		    $ssl_wtw1 ||= (_ssl_error == _ssl_want_write);
		}
		else {
		    $debug and warn "shutting down s1-in\n";
		    shutdown($s1, 0) unless $ssl1;
		    $s1_in_closed = 1;
		    unless ($s2_out_closed or length $b1to2) {
			$debug and warn "shutting down s2-out\n";
			shutdown($s2, 1) unless $ssl2;
			$s2_out_closed = 1;
		    }
		}
	    }
	    if ($wtr2 and vec($bitsr, $fn2, 1)) {
		undef $ssl_wtr2;
		$debug and warn "reading from s2...\n";
		my $bytes = sysread($s2, $b2to1, $io_chunk_size, length $b2to1);
		$debug and warn "bytes: $bytes\n";
		if ($bytes) {
		    $debug and warn "s2 read:\n" . substr($b2to1, -$bytes) . "*\n";
		}
		elsif ($ssl2 and not defined $bytes) {
		    $ssl_wtw2 ||= (_ssl_error == _ssl_want_write);
		}
		else {
		    $debug and warn "shutting down s2-in\n";
		    shutdown($s2, 0) unless $ssl2;
		    $s2_in_closed = 1;
		    unless ($s1_out_closed or length $b2to1) {
			$debug and warn "shutting down s1-out\n";
			shutdown($s1, 1) unless $ssl1;
			$s1_out_closed = 1;
		    }
		}
	    }
	    if ($wtw1 and vec $bitsw, $fn1, 1) {
		undef $ssl_wtw1;
		$debug and warn "writting to s1...\n";
		my $bytes = syswrite($s1, $b2to1, $io_chunk_size);
		$debug and warn "bytes: $bytes\n";
		if ($bytes) {
		    $debug and warn "s1 wrote...\n" . substr($b2to1, 0, $bytes) . "*\n";
		    substr($b2to1, 0, $bytes, "");
		    if ($s2_in_closed and !length $b2to1) {
			$debug and warn "buffer exhausted and s2-in is closed, shutting down s1-out\n";
			shutdown($s1, 1) unless $ssl1;
			$s1_out_closed = 1;
		    }
		}
		elsif ($ssl1 and not defined $bytes) {
		    $ssl_wtr1 ||= (_ssl_error == _ssl_want_read);
		}
		else {
		    $debug and warn "shutting down s1-out\n";
		    shutdown($s1, 1) unless $ssl1;
		    $s1_out_closed = 1;
		    unless ($s2_in_closed) {
			$debug and warn "shutting down s2-in\n";
			shutdown($s2, 0) unless $ssl2;
			$s2_in_closed = 1;
		    }
		}
	    }
	    if ($wtw2 and vec $bitsw, $fn2, 1) {
		undef $ssl_wtw2;
		$debug and warn "writting to s2...\n";
		my $bytes = syswrite($s2, $b1to2, $io_chunk_size);
		$debug and warn "bytes: $bytes\n";
		if ($bytes) {
		    $debug and warn "s2 wrote...\n" . substr($b1to2, 0, $bytes) . "*\n";
		    substr($b1to2, 0, $bytes, "");
		    if ($s1_in_closed and length $b1to2) {
			$debug and warn "buffer exhausted and s2-in is closed, shutting down s1-out\n";
			shutdown($s2, 1) unless $ssl2;
			$s2_out_closed = 1;
		    }
		}
		elsif ($ssl2 and not defined $bytes) {
		    $ssl_wtr2 ||= (_ssl_error == _ssl_want_read);
		}
		else {
		    $debug and warn "shutting down s2-in\n";
		    shutdown($s2, 1) unless $ssl2;
		    $s2_out_closed = 1;
		    unless ($s1_in_closed) {
			$debug and warn "shutting down s1-out\n";
			shutdown($s1, 0) unless $ssl1;
			$s1_in_closed = 1;
		    }
		}
	    }
	}
    }
    shutdown($s1, 2);
    shutdown($s2, 2);
}

1;

__END__

=head1 NAME

IO::Socket::Forwarder - bidirectionally forward data between two sockets

=head1 SYNOPSIS

  use IO::Socket::Forwarder qw(foward_sockets);

  forward_sockets($sock1, $sock2);

  forward_sockets($sock3, $sock4, debug => 1);


=head1 DESCRIPTION

This module allows to forward data between two sockets bidirectionally.

IO::Socket::SSL sockets are also supported.

=head2 FUNCTIONS

=over 4

=item forward_sockets($sock1, $sock2, %opts)

Reads and writes data from both sockets simultaneously forwarding it.

On return both sockets will be closed.

This function automatically detects if any of the sockets is of type
L<IO::Socket::SSL> and doesn't require any extra configuration to
handle them.

The following options are accepted:

=over 4

=item debug => 1

turn on debugging. I

=item io_chunk_size => $size

maximun number of bytes allowed in IO operations

=item io_buffer_size => $size

size of the buffers used internally to transfer data between both sockets

=back

=back

=head1 SEE ALSO

L<IO::Socket>, L<IO::Socket::SSL>.

The samples directory contains a couple of scripts showing how to use
this module.

=head1 BUGS AND SUPPORT

Please report any bugs or feature requests through the web interface
at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=IO-Socket-Forwarder>
or just send my an email with the details.

=head1 AUTHOR

Salvador FandiE<ntilde>o (sfandino@yahoo.com).

=head1 COPYRIGHT & LICENSE

Copyright E<copy> 2009 Qindel Formacion y Servicios S.L., all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
