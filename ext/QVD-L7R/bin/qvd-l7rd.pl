#!/usr/bin/perl

use strict;
use warnings;

use App::Daemon qw/daemonize/;
use QVD::L7R;
use QVD::Config;
use QVD::Log;
use File::Slurp qw(write_file);

$App::Daemon::pidfile = cfg('l7r.pid_file');
$App::Daemon::as_user = cfg('l7r.as_user');

# retrieve SSL certificates from the database and install them locally
my $certs_path = cfg('path.ssl.certs');
mkdir $certs_path, 0700;
-d $certs_path or die "unable to create directory $certs_path\n";
my ($mode, $uid) = (stat $certs_path)[2, 4];
$uid == $> or $uid == 0 or die "bad owner for directory $certs_path\n";
$mode & 0077 and die "bad permissions for directory $certs_path\n";
my $cert_fn = "$certs_path/l7r-cert.pem";
my $key_fn  = "$certs_path/l7r-key.pem";
write_file($cert_fn, cfg('l7r.ssl.cert'))
    or die "unable to write L7R SSL certificate to $cert_fn";
write_file($key_fn, cfg('l7r.ssl.key'))
    or die "unable to write L7R SSL key to $key_fn";

daemonize;
my $l7r = QVD::L7R->new(port => 8443, SSL => 1,
                        SSL_key_file => $key_fn,
                        SSL_cert_file => $cert_fn);
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
