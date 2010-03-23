#!/usr/bin/perl

# Use "-CSL" for utf8 encoding

use strict;
use warnings;

use Getopt::Long;
use QVD::AdminCLI;

my $filter = '';
my $quiet = '';
my $help = '';
GetOptions('filter|f=s' => \$filter, 'quiet|q' => \$quiet, 'help|h' => \$help);

my $object = shift @ARGV;
my $command = shift @ARGV;
my @args = @ARGV;

my $admin = QVD::AdminCLI->new($quiet);
$admin->set_filter($filter) if $filter;
$admin->dispatch_command($object, $command, $help, @args);

__END__

=head1 NAME

qvd-admin - The QVD administration tool

=head1 SYNOPSIS

qvd-admin I<object> I<command> [I<options>] [I<arguments>]

=head1 DESCRIPTION

B<qvd-admin> is the command line tool for administrating a QVD installation.
The basic interface is structured around the idea of performing commands to
objects that the QVD platform manages. The objects are things like virtual
machines, virtualization hosts, operating system images (OSI) and users.

Run 'qvd-admin -h' and 'qvd-admin I<object> help' to access the online
documentation.

=head1 COMMON OPTIONS

=over

=item -h

Print the help text and exit.

=item -f I<filter>

Apply the command only to the objects matched by the given filter.

=back

=head1 FILES

=over

=item F</etc/qvd/config.ini>

The main configuration file.

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2010 by Qindel Formacion y Servicios S.L., 

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.
