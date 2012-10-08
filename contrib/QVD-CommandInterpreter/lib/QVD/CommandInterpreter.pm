package QVD::CommandInterpreter;

use warnings;
use strict;

=head1 NAME

QVD::CommandInterpreter - Command interpreter for serial port forwarding

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Safetly runs socat for serial port forwarding. Expected to be extended
for other functions in the future.

This module is used by the commandline B<qvdcmd.pl> application.

=head1 EXAMPLE

 $ ./qvdcmd.pl
                                                                                                                                                                                  
 > version
 0.01
                                                                                                                                                                                  
 > socat /dev/ttyS0

=head1 SUBROUTINES/METHODS


=head2 new( config => $config, options => $options )

Creates the QVD::CommandInterpreter. Optionally takes a hash as an argument:

 my $cmd = new QVD::CommandInterpreter( config = $config, options = $options )

Where:

$config is the configuration file, with the following stucture:

 my $config = {
 	socat => '/usr/bin/socat',
 	allowed_ports => [ qr#^/dev/ttyS\d+#,
 	                   qr#^/dev/ttyUSB/\d+# ]
 };

$options are command-line options, currently:

 my $options = {
 	debug => $debug
 }


=cut

sub new {
	my ($class, %args) = @_;
	my $self = {};

	bless $self, $class;

	$self->{commands} = {
		version => \&cmd_version,
		help    => \&cmd_help,
		quit    => \&cmd_quit,
		socat   => \&cmd_socat
	};

	$self->{config} = {
		socat => '/usr/bin/socat',
		allowed_ports => [ qr#^/dev/ttyS\d+#,
		                   qr#^/dev/ttyUSB/\d+# ]
	};

	foreach my $key (keys %args) {
		$self->{$key} = $args{$key};
	}
	
	return $self;
}

=head2 run

Reads and executes commands from stdin until done

=cut

sub run {
	my ($self) = @_;

	undef $self->{done};

	while(!$self->{done}) {
		$self->_out( "\n> " );
		my $line = <STDIN>;
		chomp $line;
		my ($command, @args) = split(/\s+/, $line);
		next unless ($command);
	
		$self->run_command($command, @args);
	}

}

=head2 run_command($command, @args)

Executes a single command with the specified arguments

=cut

sub run_command {
	my ($self, $command, @args) = @_;
	if ( exists $self->{commands}->{$command} ) {
		$self->{commands}->{$command}->($self, @args);
	} else {
		$self->_err("ERROR: Unknown command '$command'. Try 'help'.\n");
	}
}


=head1 COMMANDS

These are the commands the interpreter implements

=cut

=head2 cmd_help

Shows the help

=cut

sub cmd_help {
	my ($self, @args) = @_;

	$self->_out("Commands:\n");
	$self->_out("\thelp          Shows this help\n");
	$self->_out("\tsocat <port>  Connects socat on the indicated port\n");
	$self->_out("\tquit          Quits the interpreter\n");
	$self->_out("\tversion       Shows the version number\n");
}

=head2 cmd_quit

Quits the interpreter if called from whithin L</run>

=cut

sub cmd_quit {
	my ($self, @args) = @_;

	$self->_out("Bye.\n");
	$self->{done} = 1;
}


=head2 cmd_socat( $port )

Runs socat on the indicated $port.

Performs checks to ensure the port is allowed and exists.

If the checks succeed, runs socat to connect the indicated port with stdin. At
that point, the interpreter uses 'exec' to call socat, and no more commands
are possible.

=cut

sub cmd_socat {
	my ($self, @args) = @_;

	my $port = $args[0];
	my $cport = $self->_check_port($port);

	if ( !$cport ) {
		$self->_err("ERROR: Port '$port' is not allowed\n");
	} else {
		if ( ! -e $cport ) {
			$self->_err("ERROR: Port '$port' doesn't exist\n");
		} else {
			my @extra_args;
			if ( $self->{debug} ) {
				push @extra_args, "-v", "-lf/tmp/qvdcmd-socat.log";
			}

			exec($self->{config}->{socat}, @extra_args, "-", "$cport,nonblock,raw,echo=0");
		}
	}
}

=head2 cmd_version

Returns the module's version

=cut

sub cmd_version {
	my ($self, @args) = @_;

	$self->_out("$VERSION\n");
}


sub _check_port {
	my ($self, $port) = @_;
	foreach my $reg ( @{$self->{config}->{allowed_ports}} ) {
		return $& if ( $port =~ m/$reg/ );
	}

	return undef;
}

sub _out {
	my ($self, $msg) = @_;
	print $msg;
}

sub _err {
	my ($self, $msg) = @_;
	print $msg;
}

=head1 AUTHOR

QVD Team, C<< <qvd at qindel.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-qvd-commandinterpreter at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=QVD-CommandInterpreter>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc QVD::CommandInterpreter


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

This program is released under the following license: GLP3


=cut

1; # End of QVD::CommandInterpreter
