#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB;

my @sqlt_args = { add_drop_table => 1 };
my $dir = '.';

my $schema = QVD::DB->connect('dbi:SQLite:example.db');
print $schema->deploy(@sqlt_args, $dir);
