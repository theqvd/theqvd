#!/usr/bin/env perl

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('QVD::Admin::Web', 'FastCGI');

1;

=head1 NAME

qvd_admin_web_fastcgi.pl - Catalyst FastCGI

=head1 SYNOPSIS

qvd_admin_web_fastcgi.pl [options]

 Options:
   -? -help      display this help and exits
   -l --listen   Socket path to listen on
                 (defaults to standard input)
                 can be HOST:PORT, :PORT or a
                 filesystem path
   -n --nproc    specify number of processes to keep
                 to serve requests (defaults to 1,
                 requires -listen)
   -p --pidfile  specify filename for pid file
                 (requires -listen)
   -d --daemon   daemonize (requires -listen)
   -M --manager  specify alternate process manager
                 (FCGI::ProcManager sub-class)
                 or empty string to disable
   -e --keeperr  send error messages to STDOUT, not
                 to the webserver

=head1 DESCRIPTION

Run a Catalyst application as fastcgi.

=head1 AUTHOR

QVD,,,

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut
