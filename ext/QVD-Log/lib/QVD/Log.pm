package QVD::Log;

use Log::Log4perl;

use warnings;
use strict;

our $VERSION = '0.01';

my $config = {
    'log4perl.rootLogger' => 'DEBUG, LOGFILE',
    'log4perl.appender.LOGFILE' => 'Log::Log4perl::Appender::File',
    'log4perl.appender.LOGFILE.filename' => '/var/log/qvd.log',
    'log4perl.appender.LOGFILE.mode' => 'append',
    'log4perl.appender.LOGFILE.layout' => 'PatternLayout',
    'log4perl.appender.LOGFILE.layout.ConversionPattern' => '%d %P %F %L %c - %m%n',
};

print "Init'ing Log::Log4perl\n";
Log::Log4perl::init_once($config);

1;

__END__

=head1 NAME

QVD::Log - QVD logging utilities

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Initializes Log::Log4perl with QVD configuration. For example:

    use Log::Log4perl qw(:easy :levels);
    use QVD::Log;

    INFO "Logging works!";

=head1 AUTHOR

QVD Team, C<< <qvd at qindel.com> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; version 2 dated June, 1991 or at your option
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License 2 for more details.

A copy of the GNU General Public License is available in the source tree;
if not, write to the Free Software Foundation, Inc.,
59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
