#!/usr/bin/perl

use strict;
use warnings;

use QVD::L7R;

my $l7r = QVD::L7R->new(port => 8443, SSL => 1);
$l7r->run();
