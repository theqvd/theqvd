#!/usr/bin/perl
package QVD::CommandInterpreter::Client;
use strict;
use warnings;
use IO::Socket::INET;
use Log::Log4perl;

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

	$self->{log}  = Log::Log4perl->get_logger('QVD::CommandInterpreter::Client');
	$self->{host} = $opts{host} // 'localhost:2000';
	bless $self, $class;

	$self->_connect();
	return $self;
}

sub _connect {
	my ($self) = @_;

	my $addr = $self->{host};

	$self->{log}->debug("Connecting to QVD::CommandInterpreter on $addr");

	$self->{sock} = IO::Socket::INET->new(PeerAddr => $addr );
	if ( !$self->{sock} ) {
		die "Failed to connect to $addr";
	}
	$self->{log}->debug("Connected");
	$self->{sock}->autoflush(1);
	$self->_wait_prompt();
	return;
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

	$self->{log}->debug("Sending command: socat $port");
	print $sock "socat $port\n";

	$self->{log}->debug("Waiting for answer");
	my $answer = $self->_read();

	$self->{log}->debug("Answer is: $answer");
	if ( $answer =~ /^OK/ ) {
		$self->{log}->debug("Remote socat successful");
		return $self->{sock};
	} else {
		$self->{log}->error("Remote socat error: $answer");
		die "Server refused to connect port: $answer";
	}
}

=head2 ppproute

Returns the results of the "ppproute" command.



=cut

sub ppproute {
	my ($self, $route) = @_;
	return $self->_send_cmd('ppproute', $route);
}


=head2 ppprestartservice

Returns the results of the "ppprestartservice" command.


=cut

sub ppprestartservice {
	my ($self, $service) = @_;
	return $self->_send_cmd('ppprestartservice', $service);
}


=head2 pppd args

Asks the remote QVD::CommandInterpreter to connect pppd with the indicated
arguments

Returns an IO::Socket connected to socat on the other side, this socat
is tipically connected to an execution of pppd. Something like

 /usr/bin/socat -lf/tmp/socatppp_recv.log tcp-listen:9999,nonblock,reuseaddr,retry=5 exec:"/usr/sbin/pppd notty noauth lcp-echo-interval 0 asyncmap 0 nodefaultroute nodetach 192.168.0.1\:192.168.0.2"

And the equivalent qvdconnect command line is:

 qvdconnect --remote localhost:$pppdport --log-socat --pppd \"notty noauth lcp-echo-interval 0 asyncmap 0 nodefaultroute nodetach\"

Basics about pppd:

=over 4

=item * You need root, setuid, or similar to be able to start pppd either on the client or in the users VM. That means that you probably need to run qvd-gui-client as root, or in some distributions, the user must be in the "dip" or dialout group. See the permissions for /usr/sbin/pppd or your distributbion doc.

=item * If you are using LXC virtualization, then it is probable that you need to verify also if you have the required capabilities to start pppd in the container.

=item * Currently the path defined is /usr/sbin/pppd, see the L<QVD::CommandInterpreter> how to change this in the config file

=item * In the example above the IP negotiation is done in the VM

=back
=cut

# FIXME refactor with _send_cmd and with socat

sub pppd {
	my ($self, @args) = @_;
	my $sock = $self->{sock};

	$self->{log}->debug("Sending command: pppd ", join(" ", @args));
	print $sock "pppd ".join(" ", @args)."\n";

	$self->{log}->debug("Waiting for answer");
	my $answer = $self->_read();

	$self->{log}->debug("Answer is: $answer");
	if ( $answer =~ /^OK/ ) {
		$self->{log}->debug("Remote pppd successful");
		return $self->{sock};
	} else {
		$self->{log}->error("Remote pppd error: $answer");
		die "Server refused to connect port: $answer";
	}
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
	my $cmdstr = join(' ', @cmd); 

	$self->{log}->debug("Sending command: $cmdstr");

	print $sock "$cmdstr\n";
	return $self->_wait_prompt();
}

sub _read {
	my ($self) = @_;
	my $sock = $self->{sock};
	my $ret = <$sock>;

	$self->{log}->logdie("Failed to read from socket: $!") if (!defined $ret);
	#$self->{log}->logdie("Socket closed") if ( !$ret );

	return $ret;
}
sub _wait_prompt {
	my ($self) = @_;


	my $sock = $self->{sock};
	my $status; # read() status

	my $buf;              # accumulated output
	my $whole_lines = ""; # entirely received lines
	my $data;             # received block of data

	$self->{log}->debug("Waiting for prompt");
	while( 1 ) {
		$status = $sock->recv($data, 512);
		$self->{log}->debug("READ: '$data', status " . (defined $status ? "'$status'" : 'undef') . ", err $!, connected " . $sock->connected . "\n");
		last if (!$data);

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
			$self->{log}->debug("Prompt found");
			return $whole_lines;
		}

	}

	$self->{log}->debug("Last status " . (defined $status ? "'$status'" : 'undef') . ", err $!, data '$data'\n");

	chomp $whole_lines;
	chomp $whole_lines;
	$self->{log}->debug("Socket was closed");
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
