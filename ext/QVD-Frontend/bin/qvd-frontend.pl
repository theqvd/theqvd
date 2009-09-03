#!/usr/bin/perl

use strict;
use warnings;

use QVD::Frontend;

my $fe = QVD::Frontend->new(port => 8080);
$fe->run();
