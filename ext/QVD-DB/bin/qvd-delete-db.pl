#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB;

my $db = QVD::DB->new;
$db->erase;
$db->txn_commit;
