#!/usr/bin/perl

use strict;
use warnings;

use QVD::DB::Simple;
db->deploy({add_drop_table => 1});

