#!/usr/bin/perl

use strict;
use warnings;
use YAML;
use Path::Tiny;
use Getopt::Long;
use Log::Any::Adapter;
use HTTP::Tiny;

my $this_path = path($0)->realpath->parent;
my $cfg_fn = $this_path->child('automate.yaml');
my $log_fn = $this_path->child('log.txt');
my $log_level = 'info';

GetOptions('config|cfg|f=s'   => \$cfg_fn,
           'log-level|ll|l=s' => \$log_level)
    or die "Error in command line arguments\n";

Log::Any::Adapter->set(File => $log_fn, log_level => $log_level);
my $log = Log::Any->get_logger;

sub logdie {
    my $msg = join ': ', @_;
    log->fatal($msg);
    die "$msg\n";
}

my $wd = Path::Tiny->tempdir;
$log->info("Working dir: $wd");

my $cfg = YAML::LoadFile($cfg_fn)
    or logdie($cfg_fn, "Loading configuration file failed");

install_msys2();
exit(0);

sub install_msys2 {
    my $msys2 = $cfg->{msys2};
    my $src = $msys2->{src};
    my $exe = $wd->child($src =~ s{.*/}{}r);
    my $ua = HTTP::Tiny->new();
    $log->info("Downloading $src to $exe");
    $ua->mirror($src, $exe);
    $log->info("Running $exe");
    system $exe $exe;
}

