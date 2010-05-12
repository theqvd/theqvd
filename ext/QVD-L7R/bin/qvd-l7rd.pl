#!/usr/bin/perl

use strict;
use warnings;

use App::Daemon qw/daemonize/;
use QVD::L7R;
use QVD::Config;
use QVD::Log;
use File::Slurp qw(write_file);

$App::Daemon::pidfile = cfg('l7r.pid_file', '/var/run/qvd/l7r.pid');
$App::Daemon::as_user = cfg('l7r.as_user', 'qvd');

# retrieve SSL certificates from the database and install them locally

my $server_cert = ssl_cfg('ssl_server_cert');
my $server_key = ssl_cfg('ssl_server_key');

defined $server_cert or die "ssl_server_cert not available from database\n";
defined $server_key or die "ssl_server_key not available from database\n";

mkdir 'certs', 0700;
-d 'certs' or die "unable to create directory 'certs'\n";
my ($mode, $uid) = (stat 'certs')[2, 4];
$uid == $> or die "bad owner for directory 'certs'\n";
$mode & 0077 and die "bad permissions for directory 'certs'\n";
write_file('certs/server-cert.pem', $server_cert);
write_file('certs/server-key.pem', $server_key);

daemonize;
my $l7r = QVD::L7R->new(port => 8443, SSL => 1);
$l7r->run();

__END__

=head1 NAME

qvd-l7rd - The QVD Level 7 Router

=head1 SYNOPSIS

qvd-l7rd -h

qvd-l7rd start [-X] 

qvd-l7rd stop

qvd-l7rd status

=head1 DESCRIPTION

B<qvd-l7rd> is a daemon that runs the QVD level 7 router. It can be used
to start and stop the router, and to check if it is running.

=head1 OPTIONS

=over

=item -h

Print usage and exit.

=item -X 

Start the L7R in foreground and log messages to screen. Useful for debugging.

=back

=head1 FILES

=over 

=item F</etc/qvd/log4perl.conf>

The configuration file for Log4perl, the logging framework.

=item F</var/run/qvd/l7r.pid>

The file where the L7R pid is stored. The path can be configured in "l7r_pid_file" config entry.

=item F</var/log/qvd.log>

The log file. The path can be configured in "l7r_log_file" config entry.

=back

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
