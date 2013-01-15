package QVD::CommandInterpreter;

use strict;
use warnings;
use Log::Log4perl;


=head1 NAME

QVD::CommandInterpreter - Command interpreter for serial port forwarding

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';


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
        pppd  => '/usr/sbin/pppd',
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

	$self->{log} = Log::Log4perl->get_logger('QVD::CommandInterpreter');

	$self->{commands} = {
		version            => \&cmd_version,
		help               => \&cmd_help,
		quit               => \&cmd_quit,
		socat              => \&cmd_socat,
		pppd               => \&cmd_pppd,
		ppproute           => \&cmd_ppp_route,
		ppprestartservice  => \&cmd_ppp_restart_service
	};

	$self->{ppd} = {
		routes          => [],
		systemd_restart => [],
		upstart_restart => [],
		sysv_restart    => []
	};

	$self->{config} = {
		paths => {
			ip          => '/bin/ip',
			socat       => '/usr/bin/socat',
			pppd        => '/usr/sbin/pppd',
			systemctl   => '/usr/bin/systemctl',
			initctl     => '/sbin/initctl',
			sysv_dir    => '/etc/init.d/' # To allow overriding for testing
		},

		socat => {
			allowed_ports => [ qr#^/dev/ttyS\d+#,
					   qr#^/dev/ttyUSB/\d+#,
					   qr#^/dev/ttyUSB\d+#,
					   qr#^/dev/ttyACM\d+#,
					   qr#^/dev/usblp\d+#]
			},
		pppd => {
			# Allow commands in the form of:
			# (ip route add) to $IP via $GW [src $IP]
			allow             => 1,

			# Allow any route command. Only alphanumeric characters are allowed,
			# but any arguments to "ip route add" are possible. 
			allow_any_command => 0,

			# Where to write the script that will be executed by ppd
			script_path       => "/etc/ppp/ip-up.d/qvd",
	
			# Contents of the script
			script_contents   => $self->_load_data()
		}
	};

	foreach my $key (keys %args) {
		$self->{$key} = $args{$key};
	}

	if (!exists $self->{config}->{paths}) {
		die "Bad config format";
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
		my $line = <>;
		last unless ($line);

		chomp $line;
		my ($command, @args) = split(/\s+/, $line);
		next unless ($command);
	
		$self->run_command($command, @args);
	}
	return;
}

=head2 run_command($command, @args)

Executes a single command with the specified arguments

=cut

sub run_command {
	my ($self, $command, @args) = @_;
	if ( exists $self->{commands}->{$command} ) {
		$self->{log}->debug("Command: $command " . join(' ', @args));
		$self->{commands}->{$command}->($self, @args);
	} else {
		$self->_err("ERROR: Unknown command '$command'. Try 'help'.\n");
	}
	return;
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
	$self->_out("\thelp              Shows this help\n");
	$self->_out("\tsocat <port>      Connects socat on the indicated port\n");
	$self->_out("\tpppd arg1 ..      pppd with the given args\n");
	$self->_out("\tppproute args     call ip route add in ppd script with the given args\n");
	$self->_out("\tppprestartservice restart service in pppd script\n");
	$self->_out("\tquit              Quits the interpreter\n");
	$self->_out("\tversion           Shows the version number\n");
	return;
}

=head2 cmd_quit

Quits the interpreter if called from whithin L</run>

=cut

sub cmd_quit {
	my ($self, @args) = @_;
	$self->{log}->info("Quit command received");
	$self->_out("Bye.\n");
	$self->{done} = 1;
	return;
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
		$self->_err("ERROR: Port '$port' is not allowed. Valid: " . join(' ', @{$self->{config}->{socat}->{allowed_ports}}) . "\n");
	} else {
		if ( ! -e $cport ) {
			$self->_err("ERROR: Port '$port' doesn't exist\n");
		} else {
			my @extra_args;
			if ( $self->{debug} ) {
				push @extra_args, "-v", "-lf/tmp/qvdcmd-socat.log";
			}

			$self->{log}->info("Starting socat on port $cport");
			$self->_out("OK\n");
			exec($self->{config}->{paths}->{socat}, @extra_args, "-", "$cport,nonblock,raw,echo=0");
		}
	}
	return ;
}


=head2 cmd_pppd( @args )

Runs pppd with specified args

=cut

sub cmd_pppd {
	my ($self, @args) = @_;

	my @full_args = $self->_check_pppd_args(@args);
	if (!@full_args) {
	    $self->_err("ERROR: pppd args do not comply with character constraints");
	    return;
	}
	# FIXME do not start pppd if full_args is empty
	if ( $self->{debug} ) {
	    push @full_args, "debug";
	}

	if ( $self->{pppd}->{write_script} ) {
		$self->{log}->info("pppd script commands were executed earlier, creating script first");

		if (!$self->write_pppd_script()) {
			$self->_err("ERROR: failed to write pppd script");
			return;
		}
	}

	$self->{log}->info("Starting pppd with args: ", join(" ", @full_args));
	$self->_out("OK\n");
	exec($self->{config}->{paths}->{pppd}, @full_args);
}

=head2 cmd_ppp_route( @args ) 

=cut

sub cmd_ppp_route {
	my ($self, @args) = @_;
	my $route = $self->_check_route(@args);

	if ( !$route ) {
		$self->_err("ERROR: Route doesn't match constraints");
		return;
	}

	$self->{log}->info("Will add route $route");
	push @{$self->{pppd}->{routes}}, $route;
	$self->{pppd}->{write_script} = 1;


	$self->_out("OK\n");
}

sub cmd_ppp_restart_service {
	my ($self, $arg) = @_;
	my ($service, $type) = $self->_check_service($arg);

	if (!$service) {
		$self->_err("ERROR: Service doesn't match constraints or doesn't exist");
		return;
	}

	$self->{log}->info("Will restart $type service $service");
	
	if ( $type eq "systemd" ) {
		push @{$self->{pppd}->{systemd_restart}}, $service;
	} elsif ( $type eq "upstart" ) {
		push @{$self->{pppd}->{upstart_restart}}, $service;
	} elsif ($type eq "sysv") {
		push @{$self->{pppd}->{sysv_restart}}, $service;
	} else {
		$self->{log}->fatal("Don't know how to handle service of type $type");
	}
	
	
	$self->{pppd}->{write_script} = 1;
	$self->_out("OK\n");
}



=head2 cmd_version

Returns the module's version

=cut

sub cmd_version {
	my ($self, @args) = @_;

	$self->_out("$VERSION\n");
	return;
}



sub write_pppd_script {
	my ($self) = @_;
	$self->{log}->debug("Starting creation of pppd script");

	my $script = $self->{config}->{pppd}->{script_contents};
	my $fh;
	
	my $routes = $self->_concat_list($self->{pppd}->{routes}, "\n", $self->{config}->{paths}->{ip} . " route add ");
	$script =~ s/%routes/$routes/g;


	my %lists;
	foreach my $kind (qw(systemd upstart sysv)) {
		my $list = $self->_concat_list($self->{pppd}->{"${kind}_restart"});
		$script =~ s/%${kind}_services/$list/g;
	}
	
	foreach my $path (keys %{ $self->{config}->{paths} }) {
		my $val = $self->{config}->{paths}->{$path};
		$script =~ s/%$path/$val/g;
	}

	my $file = $self->{config}->{pppd}->{script_path}; 

	$self->{log}->debug("Writing pppd script: $file");

	if (!open($fh, '>', $file)) {
		$self->{log}->error("Failed to open $file: $!");
		return;
	}

	print $fh "$script\n";

	close($fh);
	chmod 0755, $file;
	
	delete $self->{pppd}->{write_script};

	$self->{log}->debug("pppd script written");
 	return 1;
}


# FIXME get this also in config
sub _check_pppd_args {
	my ($self, @args) = @_;
	my @result;
	foreach my $arg ( @args ) {
	    if ($arg =~ qr#([-a-zA-Z0-9:,/]+)#x) {
		push @result, $1;
	    } else {
		print STDERR "check_pppd_args: Argument <$arg> does not match constraints returning non arg";
		$self->{log}->error("check_pppd_args: Argument <$arg> does not match constraints returning non arg");
		return ();
	    }
	}

	return @result;
}


sub _check_port {
	my ($self, $port) = @_;
	foreach my $reg ( @{$self->{config}->{socat}->{allowed_ports}} ) {
	    if ( $port =~ m/($reg)/x ) {
		return $1;
	    }
	}

	return ();
}

sub _check_route {
	my ($self, @args) = @_;
	my $route;
	my $arg = join(' ', @args); # We parse arguments with a regex, easier to handle it as one string

	my $ip_match = qr/(?:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|\$interfacename|\$ttydevice|\$speed|\$localipaddress|\$remoteipaddress|\$ipparam|\$defaultinterfaceip)/;


	if ( $self->{config}->{pppd}->{allow_any_command} ) {
		($route) = ($arg =~ /^([ 0-9A-Za-z]+)$/);

		unless ($route) {
			$self->{log}->error("Route command failed permissive check");
		}

	} elsif ( $self->{config}->{pppd}->{allow} ) {
		my ($dst, $gw, $src) = ($arg =~ /to\s+($ip_match)\s+via\s+($ip_match)(?:\s+src ($ip_match))?/);

		if ( $dst && $gw ) {
			$route = "to $dst via $gw";
			$route .= " src $src" if ($src);
		} else {
			$self->{log}->error("Route command '$arg' failed restrictive check");
			return;
		}
	} else {
		$self->{log}->error("Route commands are not allowed");
		return;
	}

	return $route;
}

sub _check_service {
	my ($self, $arg) = @_;

	my ($service) = ( $arg =~ /^([A-Za-z0-9.]+)$/ );
	my $type;
	
	unless ($service) {
		print STDERR "_check_service: Argument doesn't match constaints\n";
		$self->{log}->error("Argument doesn't match constraints");
		return;
	}

	
	if (!$type) {
		my $systemctl = $self->{config}->{paths}->{systemctl};
		if ( -x $systemctl ) {
			$self->{log}->debug("_check_service: systemctl available");
			
			my $output = `$systemctl status "$service" 2>&1`;
			if ( $? != 0 ) {
				$self->{log}->debug("_check_service: $service is not a valid systemd service");
			} else {
				$self->{log}->debug("_check_service: $service is a systemd service");
				$type = "systemd"; 
			}
		} else {
			$self->{log}->debug("_check_service: systemctl not found");
		}
	}
	
	if (!$type) {
		my $initctl = $self->{config}->{paths}->{initctl};
		if ( -x $initctl ) {
			$self->{log}->debug("_check_service: initctl available");
			
			my @services = `$initctl list 2>&1`;
			chomp @services;
			foreach my $line (@services) {
				if ( $line =~ /^$service\s+/ ) {
					$self->{log}->debug("_check_service: $service is an upstart service");
					$type = "upstart";
					last;
				}
			}
			
			if ( !$type ) {
				$self->{log}->debug("_check_service: $service is not an upstart service");
			}
		} else {
			$self->{log}->debug("_check_service: initctl not found");
		}
	}
	
	if (!$type) {
		my $sysvdir = $self->{config}->{paths}->{sysv_dir};
		
		if ( -d $sysvdir ) {
			$self->{log}->debug("_check_service: checking SysV services in $sysvdir");
			
			if ( -x "$sysvdir/$service" ) {
				$self->{log}->debug("_check_service: $service is a SysV service");
				$type = "sysv";
			} else {
				$self->{log}->debug("_check_service: $service is not a SysV service");
			}
		}
	}
	
	if ($type) {
		$self->{log}->info("_check_service: Identified $service as a $type service");
		return ($service, $type);
	} else {
		$self->{log}->error("_check_service: $service is not a recognized service");
		return;
	}
}
sub _out {
	my ($self, $msg) = @_;
	print $msg;
	return;
}

sub _err {
	my ($self, $msg) = @_;
	$self->{log}->error($msg);
	print $msg;
	return;
}

sub _load_data {
	my ($self) = @_;
	local $/;
	undef $/;
	my $data = <DATA>;
	return $data;
}

sub _concat_list {
	my ($self, $list, $separator, $prefix) = @_;
	my $ret = "";
	$separator //= " ";
	
	
	foreach my $item ( @$list ) {
		$ret .= $separator if ($ret);
		$ret .= $prefix if ($prefix);
		$ret .= $item;
	}
	
	return $ret;
}

=head1 SEE ALSO

L<QVD::CommandInterpreter::Client>

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

This program is released under the following license: GPL3


=cut

1; # End of QVD::CommandInterpreter


__DATA__
#!/bin/bash

# File generated by qvdconnect
# Do not edit -- this file will be overwritten.
# To change its contents, specify a different base pattern in /etc/qvd/qvdcmd.conf

interfacename=$1
ttydevice=$2
speed=$3
localipaddress=$4
remoteipaddress=$5
ipparam=$6


getmachineip() {
  local device=$(ip route list match 0.0.0.0 |  sed -r 's/.* dev ([a-zA-Z0-9]+).*/\1/')
  local ip=$(ip -o  -4 addr show dev $device | sed -r 's/.* inet ([0-9\.]+).*/\1/')
  echo $ip
}


defaultinterfaceip=$(getmachineip)

## IP routes
%routes

## Services
sysv_services=%sysv_services
upstart_services=%upstart_services
systemd_services=%systemd_services

if [ -n "$systemd_services" ] ; then
	for service in $systemd_services ; do
		%systemctl restart $service
	done
fi

if [ -n "$upstart_services" ] ; then
	for service in $upstart_services ; do
		%initctl restart $service
	done
fi

if [ -n "$sysv_services" ] ; then
	for service in $sysv_services ; do
		%sysv_dir/$service restart
	done
fi

