#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use QVD::Admin;

my $filter = '';
GetOptions('filter|f=s' => \$filter);

my $object = shift @ARGV;
my $command = shift @ARGV;
my @args = @ARGV;

my $admin = QVD::Admin->new;
$admin->set_filter($filter) if $filter;
$admin->dispatch_command($object, $command, @args);
