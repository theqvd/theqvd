#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
my $force;
GetOptions("force|f" => \$force) or exit (1);

use QVD::DB::Simple;

unless ($force) {
    for (qw(VM VM_Runtime Host Osi User)) {
        eval { rs($_)->search->count };
        unless ($@ =~ /relation\s+"(\w+)"\+does\+not\+exist/) {
            die "Database already contains table $_, use '--force' to redeploy the database\n";
        }
    }
}

db->deploy({add_drop_table => 1});

