#!/usr/bin/perl -wT
use strict;
use lib 'lib';
use Getopt::Long;
use QVD::CommandInterpreter;


# Protocol:
#
# The prompt is "\n> "
# 
# The format is a command/response pattern, except for commands that end
# the session. Currently this is the "socat" command when it succeeds.
#
# Responses are terminated by a blank line.
# Errors start with "ERROR:"
# Fatal errors start with "FATAL:"
#
# Sample session:
#
#########################
# > help
# Commands:
#     help
#     version
#     socat
#
# > version
# 3.1.123
#
# > socat /dev/ttyS0
#########################
#
#

my $config_file = "/etc/qvd/qvdcmd.conf";
my $debug;
my $help;
my %args;


delete $ENV{PATH};

GetOptions(
	"config|c=s"    => \$config_file,
	"debug|D"       => \$debug,
	"help|h"        => \$help
) or die "Bad arguments";

if ( $help ) {
	print <<HELP;
Syntax: $0 [options]

Options:
	--help, -h	Show this help
	--config, -c	Specify the config file to use

HELP
	exit(0);
}


$args{options} = {
	debug => $debug
};

# Untaint the config file. The taint check is for the data coming
# from the socket.

$config_file = untaint($config_file);

if ( $config_file && -f $config_file ) {
	eval {
		$args{config} = do($config_file);
	};
	if ($@) {
		print "FATAL: Syntax error in config file: $@\n";
		exit(1);
	}

	if (!$args{config} || ref($args{config}) ne "HASH" || !$args{config}->{socat}) {
		print "FATAL: Bad config file\n";
		exit(2);
	}

}


my $cmd = new QVD::CommandInterpreter( %args );
$cmd->run();


sub untaint {
	my $arg = shift;
	$arg =~ /(.*)/;
	return $1;
}

