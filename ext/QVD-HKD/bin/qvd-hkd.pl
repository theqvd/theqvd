#!/usr/bin/perl

use strict;
use warnings;

use App::Daemon qw/daemonize/;
use QVD::HKD;
use QVD::Config;
use QVD::Log;

$App::Daemon::pidfile = cfg('hkd.pid_file');
$App::Daemon::as_user = cfg('hkd.as_user');

daemonize;
my $ok = QVD::HKD->new->run;
exit($ok ? 0 : 1);

__END__

=head1 NAME

qvd-hkd - The QVD house-keeping daemon

=head1 SYNOPSIS

qvd-hkd -h

qvd-hkd start [-X]

qvd-hkd stop

qvd-hkd status

=head1 DESCRIPTION

The QVD house-keeping daemon monitors the QVD database for commands it has to
perform. It also maintains the states of the virtual machines assinged to its
host consistent with the database. The B<qvd-hkd> command is used to start and
stop the HKD, and to check if it is running.

=head1 OPTIONS

=over

=item -h

Print usage and exit.

=item -X 

Start the HKD in foreground and log messages to screen. Useful for debugging.

=back

=head1 FILES

=over 

=item F</etc/qvd/config.ini>

The main configuration file. The details of the QVD database connection are
specified here.

=item F</etc/qvd/log4perl.conf>

The configuration file for Log4perl, the logging framework.

=item F</var/run/qvd/hkd.pid>

The file where the HKD pid is stored. The path can be configured in the QVD
database.

=item F</var/log/qvd.log>

The log file. The path is configured in the QVD database.

=back

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
