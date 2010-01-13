#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB::Simple;

my @sqlt_args = ({}); #{ add_drop_table => 0 };
my $dir = '.';


db->erase;
db->deploy(@sqlt_args, $dir);
