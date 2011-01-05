#!/usr/bin/perl

# Use "-CSL" for utf8 encoding

use strict;
use warnings;

use Getopt::Long;
use QVD::AdminCLI;
use QVD::Log;

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

=item -h, --help

Print the command's built-in help and exit.

=item -f I<filter>

Apply the command only to the objects matched by the given filter. The filter
is specified using the syntax I<key1=value1,key2=value2,...>.

=back

=head1 OPERATIONS

=over

=item config del

Delete a previously set property.

=item config get

Get all the configuration or the value for a specified property.

=item config set

Set a specific property.

=item config ssl

Set up an SSL connection.

=item host add

Add a physical host.

=item host del

Delete a physical host.

=item host list

List all the hosts.

=item host propdel

Delete a specified property.

=item host propget

Get a specified property or all properties.

=item host propset

Set a value for a property.

=item host unblock

Unblock a host specified by a filter.

=item osi add

Add an Operating System Image.

=item osi del

Delete a specified Operating System Image.

=item osi list

List all the Operating System Images.

=item user add

Add a specified user and a password.

=item user del

Delete a specified user.

=item user list

List users.

=item user passwd

Define a password for a specified user.

=item user propdel

Delete all or a specified user.

=item user propget

Get the value of a property from a virtual machine specified by a filter.

=item user propset

Set the value of a property for a virtual machine specified by a filter.

=item vm add

Add a virtual machine.

=item vm block

Block a virtual machine.

=item vm del

Delete a virtual machine.

=item vm disconnect_user

Disconnect a specified user from a specified virtual machine.

=item vm list

List the virtual machines.

=item vm propdel

Delete a specified property from a virtual machine.

=item vm propget

Get all the properties.

=item vm propset

Set a property for a specified virtual machine.

=item vm ssh

Establish the parameters for an SSH connection.

=item vm start

Start a virtual machine.

=item vm stop

Stop a virtual machine.

=item vm unblock

Set a virtual machine as unblocked.

=item vm vnc

Establish the parameters for a VNC connection.

=back






=head1 EXAMPLES

Add a user with user name 'jrh' and the password 'secret':

    qvd-admin user add login=jrh password=secret

Add a virtual machine called 'test' for the user 'jrh', using the OSI 1:

    qvd-admin vm add name=test user=jrh osi_id=1 ip=''

Access the SSH server on the virtual machine of the user 'jrh', assuming he has only one:

    qvd-admin vm ssh -f user=jrh

List all virtual machines running on host 'bootes':

    qvd-admin vm list -f host=bootes

List all hosts:

    qvd-admin.pl host list

Set a property for all the hosts:

    qvd-admin.pl host propset prop3="value for all"

Same for host whose id is 2:

    qvd-admin.pl host propset prop2="value for 2" -f id=2 


=head1 FILES

=over

=item F</etc/qvd/config.ini>

The main configuration file.



=back





=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
