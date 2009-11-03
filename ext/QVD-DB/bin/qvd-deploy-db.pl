#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB;

my @sqlt_args = ({}); #{ add_drop_table => 0 };
my $dir = '.';

my $db = QVD::DB->new();
$db->erase;
$db->txn_commit;
$db->deploy(@sqlt_args, $dir);
$db->txn_commit;
