#!/usr/bin/perl

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
