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
The basic interface is structured around the idea of performing commands on
objects that the QVD platform manages. The objects are things like virtual
machines, virtualization hosts, operating system images (OSI) and users.

Run 'qvd-admin -h' to list the available objects and commands. Run 'qvd-admin
I<object> -h' to list the commands that an object accepts. Each command has
online help that can be viewed using the option B<-h>.

=head1 COMMON OPTIONS

=over

=item -h

Print the command's built-in help and exit.

=item -f I<filter>

Apply the command only to the objects matched by the given filter. The filter
is specified using the syntax I<key1=value1,key2=value2,...>.

=back

=head1 EXAMPLES

Add a user with user name 'jrh':

    qvd-admin user add login=jrh password=secret

Add a virtual machine called 'test' for the user 'jrh', using the OSI 1:

    qvd-admin vm add name=test user=jrh osi_id=1 ip=''

Access the SSH server on the virtual machine of the user 'jrh', assuming he has only one:

    qvd-admin vm ssh -f user=jrh

List all virtual machines running on host 'bootes':

    qvd-admin vm list -f host=bootes


=head1 FILES

=over

=item F</etc/qvd/config.ini>

The main configuration file.

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2010 by Qindel Formacion y Servicios S.L., 

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.
