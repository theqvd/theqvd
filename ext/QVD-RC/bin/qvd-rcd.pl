#!/usr/bin/perl

use strict;
use warnings;

use QVD::RC;

# FIXME: make listening port configurable via DB
my $rc = QVD::RC->new(port => 8080);
$rc->run();
