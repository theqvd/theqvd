#!/usr/bin/perl

use strict;
use warnings;

use Win32::Packer;
use Path::Tiny;
use Log::Any::Adapter;

Log::Any::Adapter->set(Stderr => log_level => 'debug');
my $logger = Log::Any->get_logger;

my $this_path = path($0)->realpath->parent;
my $p = Win32::Packer->new( app_name => 'qvd-automate',
                            scripts => $this_path->child('automate.pl'),
                            extra_file => $this_path->child('automate.yaml'),
                            logger => $logger);

$p->make_installer(type => 'dir', update => 1);
