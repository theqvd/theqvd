#!/usr/bin/perl

use strict;
use warnings;

use App::Daemon qw/daemonize/;
use QVD::RC;
use QVD::Config;


my $PID_FILE = cfg('rc_pid_file', '/var/run/qvd/rc.pid');

$App::Daemon::pidfile = $PID_FILE;
$App::Daemon::logfile = cfg('rc_log_file');

use Log::Log4perl qw(:levels);
Log::Log4perl::init('log4perl.conf');

$App::Daemon::loglevel = $DEBUG;
$App::Daemon::as_user = "root";

daemonize;

# FIXME: make listening port configurable via DB
my $rc = QVD::RC->new(port => 8080);
$rc->run();

__END__

=head1 NAME

qvd-rcd - The QVD remote control service

=head1 SYNOPSIS

qvd-rcd -h

qvd-rcd start [-X]

qvd-rcd stop

qvd-rcd status

=head1 DESCRIPTION

B<qvd-rcd> can be used to start and stop the QVD remote control service, and to
check if it's running. The QVD remote control is a network service for the QVD
house-keeping daemon.

=head1 OPTIONS

=over

=item -h

Print the usage and exit.

=item -X

Start in foreground and log to screen. Useful for debugging.

=back

=head1 FILES

=over

=item F</etc/qvd/config.ini>

The main configuration file.

=item F</etc/qvd/log4perl.conf>

The configuration for Log4perl, the logging framework.

=item F</var/run/qvd/rc.pid>

The file that stores the process id of the daemon. The path can be configured
in F<config.ini>.

=back

=head1 SEE ALSO

L<qvd-hkd(1)> - The QVD house-keeping daemon.

=head1 COPYRIGHT AND LICENSE

Copyright 2010 by Qindel Formacion y Servicios S.L.

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.
