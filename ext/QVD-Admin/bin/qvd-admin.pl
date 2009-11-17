#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use QVD::Admin;

my $filter = '';
my $quiet = '';
GetOptions('filter|f=s' => \$filter, 'quiet|q' => \$quiet);

my $object = shift @ARGV;
my $command = shift @ARGV;
my @args = @ARGV;

my $admin = QVD::Admin->new($quiet);
$admin->set_filter($filter) if $filter;
$admin->dispatch_command($object, $command, @args);
