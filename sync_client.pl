#!/usr/bin/perl -w
use strict;
use File::Copy::Recursive qw(dircopy);

my $root_dir = ".";
my $install_dir = "C:/Program Files/QVD Client/";
local $File::Copy::Recursive::SkipFlop = 1;


my ($total, $dirs, $depth)  = dircopy("$root_dir/ext/QVD-Client/lib", "$install_dir/lib");
print "$total total files copied, $dirs dirs, $depth level deep.\n";
