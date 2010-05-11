#!/usr/bin/env perl

BEGIN { $ENV{CATALYST_ENGINE} ||= 'FastCGI' }

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";
use QVD::Admin::Web;

my $help = 0;
my ( $listen, $nproc, $pidfile, $manager, $detach, $keep_stderr );

GetOptions(
    'help|?'      => \$help,
    'listen|l=s'  => \$listen,
    'nproc|n=i'   => \$nproc,
    'pidfile|p=s' => \$pidfile,
    'manager|M=s' => \$manager,
    'daemon|d'    => \$detach,
    'keeperr|e'   => \$keep_stderr,
);

pod2usage(1) if $help;

QVD::Admin::Web->run(
    $listen,
    {   nproc   => $nproc,
        pidfile => $pidfile,
        manager => $manager,
        detach  => $detach,
	keep_stderr => $keep_stderr,
    }
);

1;

=head1 NAME

qvd_admin_web_fastcgi.pl - Catalyst FastCGI

=head1 SYNOPSIS

qvd_admin_web_fastcgi.pl [options]

 Options:
   -? -help      display this help and exits
   -l -listen    Socket path to listen on
                 (defaults to standard input)
                 can be HOST:PORT, :PORT or a
                 filesystem path
   -n -nproc     specify number of processes to keep
                 to serve requests (defaults to 1,
                 requires -listen)
   -p -pidfile   specify filename for pid file
                 (requires -listen)
   -d -daemon    daemonize (requires -listen)
   -M -manager   specify alternate process manager
                 (FCGI::ProcManager sub-class)
                 or empty string to disable
   -e -keeperr   send error messages to STDOUT, not
                 to the webserver

=head1 DESCRIPTION

Run a Catalyst application as fastcgi.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

Qindel Formacion y Servicios S.L.

=head1 COPYRIGHT

Modifications by the QVD team are copyright 2009-2010 by Qindel Formacion y
Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.


=cut
