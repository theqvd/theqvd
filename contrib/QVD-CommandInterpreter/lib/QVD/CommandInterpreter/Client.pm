#!/usr/bin/perl -w
package QVD::CommandInterpreter::Client;
use strict;
use IO::Socket::INET;

=head1 NAME

QVD::CommandInterpreter::Client - Client for QVD command interpreter

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Talks to qvdcmd over a TCP socket. Currently offers serial port forwarding,
other functionality is expected in the future.

This module is used by the commandline B<qvdconnect> application.

=head1 EXAMPLE

 $ ./qvdconnect --interpreter localhost:2000 --getversion
 0.01

=head1 SUBROUTINES/METHODS


=head2 new HOST, PORT

Connects to a QVD::CommandInterpreter running on the indicated HOST and PORT,
waits for the command prompt to be received, and returns.

=cut

sub new {
	my ($class, %opts) = @_;
	my $self = {};

	$self->{host} = $opts{host} // 'localhost';
	$self->{port} = $opts{port} // 2000;
	bless $self, $class;

	$self->_connect();
	return $self;
}

sub _connect {
	my ($self) = @_;

	my $addr = $self->{host} . ( $self->{port} ? ":" . $self->{port} : "");

	$self->{sock} = new IO::Socket::INET(PeerAddr => $addr );
	if ( !$self->{sock} ) {
		die "Failed to connect to $addr";
	}

	$self->{sock}->autoflush(1);
	$self->_wait_prompt();
}

=head2 version

Returns the version of the remote QVD::CommandInterpreter

=cut

sub version {
	my ($self) = @_;
	return $self->_send_cmd('version');
}

=head2 help

Returns the results of the "help" command.

The result describes the protocol level commands, which
is of little use in practical usage.

=cut

sub help {
	my ($self) = @_;
	return $self->_send_cmd('help');
}

=head2 socat PORT

Asks the remote QVD::CommandInterpreter to connect socat to the indicated
port.

Returns an IO::Socket connected to socat on the other side.

=cut


sub socat {
	my ($self, $port) = @_;
	my $sock = $self->{sock};

	print $sock "socat $port\n";
	return $self->{sock};
}


=head2 quit

Disconnects from the remote QVD::CommandInterpreter.

Returns the parting message, normally "Bye."

=cut

sub quit {
	my ($self, $port) = @_;
	return $self->_send_cmd('quit');
}

sub _send_cmd {
	my ($self, @cmd) = @_;
	my $sock = $self->{sock};
	print $sock join(' ', @cmd) . "\n";
	return $self->_wait_prompt();
}

sub _wait_prompt {
	my ($self) = @_;


	my $sock = $self->{sock};
	my $status; # read() status

	my $buf;              # accumulated output
	my $whole_lines = ""; # entirely received lines
	my $data;             # received block of data

	while(defined ($status = $sock->recv($data, 512))) {
		#print STDERR "READ: '$data'\n";

		$buf .= $data;

		# If we have a \n, then everything before it makes a complete line,
		# which goes into $whole_lines. That is the output of the commands we run
		while ( $buf =~ /(.*?)\n/ ) {
			$whole_lines .= "$1\n";
			$buf =~ s/^.*?\n//;
		}

		if ( $buf =~ /^> / ) {
			# First one to remove the blank line in the protocol, second to remove
			# the \n after the last line of output

			chomp $whole_lines;
			chomp $whole_lines;
			return $whole_lines;
		}

	}

	chomp $whole_lines;
	chomp $whole_lines;
	return $whole_lines;
}

=head1 SEE ALSO

L<QVD::CommandInterpreter>

=head1 AUTHOR

QVD Team, C<< <qvd at qindel.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-commandinterpreter at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-CommandInterpreter>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::CommandInterpreter::Client


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=QVD-CommandInterpreter>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/QVD-CommandInterpreter>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/QVD-CommandInterpreter>

=item * Search CPAN

L<http://search.cpan.org/dist/QVD-CommandInterpreter/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 QVD Team.

This program is released under the following license: GPL3


=cut

1;