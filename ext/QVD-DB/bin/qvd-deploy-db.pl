#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
my $force;
GetOptions("force|f" => \$force) or exit (1);

use QVD::DB;
use QVD::DB::Simple;

unless ($force) {
    my $rs = QVD::DB->new();
    my $dbh = $rs->storage->dbh;
    eval { $dbh->do("select count(*) from configs;"); };
    $@ or die "Database already contains QVD tables, use '--force' to redeploy the database\n";
}

db->deploy({add_drop_table => 1});

