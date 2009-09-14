#!/usr/bin/perl

use strict;
use warnings;

use QVD::VMA;

my $vma = QVD::VMA->new(port => 3030);
$vma->run();
