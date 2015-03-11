#!/usr/bin/perl

use strict;
use warnings;
use lib::glob '/home/benjamin/wat/*/lib/';
use Getopt::Long;
my $force;
GetOptions("force|f" => \$force) or exit (1);

use QVD::DB::Simple;

unless ($force) {
    eval { db->storage->dbh->do("select count(*) from configs;"); };
    $@ or die "Database already contains QVD tables, use '--force' to redeploy the database\n";
}

db->deploy({add_drop_table => 1});

rs(Tenant)->create({id => 0, name => '*'});
rs(Tenant)->create({id => 1, name => 'default'});
