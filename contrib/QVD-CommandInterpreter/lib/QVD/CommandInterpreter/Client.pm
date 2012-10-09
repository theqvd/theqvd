#!/usr/bin/perl -w
package QVD::CommandInterpreter::Client;
use strict;
use IO::Socket::INET;




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

sub version {
	my ($self) = @_;
	return $self->_send_cmd('version');
}

sub help {
	my ($self) = @_;
	return $self->_send_cmd('help');
}

sub socat {
	my ($self, $port) = @_;
	my $sock = $self->{sock};

	print $sock "socat $port\n";
	return $self->{sock};
}

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


1;