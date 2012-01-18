#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;
BEGIN { use_ok('Linux::Proc::Mountinfo') };

my $mi = Linux::Proc::Mountinfo->read;

my $at = $mi->at('/');

is ($at->mount_point, '/');
