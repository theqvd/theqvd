#!/usr/lib/qvd/bin/perl

## usage: $0 </path/to/image-file> ...

use warnings;
use strict;
use QVD::UntarDIs;

die "No images given\nUsage: $0 <image_path> ...\n" unless @ARGV;
QVD::UntarDIs->new->untar_dis (@ARGV);
