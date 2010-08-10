#!/usr/bin/env perl -T

use strict;
use warnings;

use lib 't/lib';

use Test::Class::Load 't/lib';

Test::Class->runtests;
