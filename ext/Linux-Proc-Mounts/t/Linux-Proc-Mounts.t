#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 2;
BEGIN { use_ok('Linux::Proc::Mounts') };

my $m = Linux::Proc::Mounts->read;

my $at = $m->at('/')->visible;

ok (@$at == 1);
