#!/usr/bin/perl

use strict;
use warnings;

# ensure we load the VMA configuration

BEGIN {
    $QVD::Config::USE_DB = 0;
    $QVD::Config::FILE = '/etc/qvd/vma.conf';
}
use QVD::Config;

use QVD::VMA;
use App::Daemon qw(daemonize);
$App::Daemon::pidfile = cfg('vma.pid_file');

$ENV{PATH} = join(':', $ENV{PATH}, '/sbin/');

my $port = cfg('internal.vm.port.vma');




daemonize();
my $vma = QVD::VMA->new(port => $port);
$vma->run();

__END__

=head1 NAME

qvd-vma - The QVD Virtual Machine Agent

=head1 SYNOPSIS

qvd-vma -h

qvd-vma start [-X] 

qvd-vma stop

qvd-vma status

=head1 DESCRIPTION

B<qvd-vma> is a daemon that runs the QVD virtual machine agent. It can be used
to start and stop the agent, and to check if it is running.

=head1 OPTIONS

=over

=item -h

Print usage and exit.

=item -X 

Start the VMA in foreground and log messages to screen. Useful for debugging.

=back

=head1 FILES

=over 

=item F</etc/qvd/vma.ini>

The main configuration file. 

=item F</etc/qvd/log4perl.conf>

The configuration file for Log4perl, the logging framework.

=item F</var/run/qvd/vma.pid>

The file where the VMA pid is stored. The path can be configured in F<vma.ini>.

=item F</var/log/qvd/vma.log>

The log file. The path can be configured in F<vma.ini>.

=back

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
