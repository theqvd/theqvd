#!/usr/bin/perl

use strict;
use warnings;

use Win32::Packer;
use Path::Tiny;
use Log::Any::Adapter;

use Getopt::Std;

my $app_name = 'qvd-automate';

our $opt_f;


getopts('f');

Log::Any::Adapter->set(Stderr => log_level => 'debug');
my $logger = Log::Any->get_logger;

my $this_path = path($0)->realpath->parent;

if ($opt_f) {
    $this_path->child('automate.pl')->copy("$app_name/lib/automate.pl");
    $this_path->child('automate.yaml')->copy("$app_name/automate.yaml");
}
else {
    my $p = Win32::Packer->new( app_name => $app_name,
                                scripts => { path => $this_path->child('automate.pl'),
                                             require_administrator => 1 },
                                extra_module => [qw(if IO::Socket::SSL IO::Socket::IP)],
                                extra_file => $this_path->child('automate.yaml'),
                                logger => $logger,
                                work_dir => $this_path->child('wd'));

    #$p->make_installer(type => 'dir', update => 1);
    $p->make_installer(type => 'zip', update => 1);
}



