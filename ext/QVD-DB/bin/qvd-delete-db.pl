#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB::Provisioning;

my $db = QVD::DB->new;

eval { $db->storage->dbh->do("DROP TABLE osi CASCADE") };
warn $@ if $@;
$db->txn_commit;

eval { $db->storage->dbh->do("DROP TABLE vm_runtime CASCADE") };
warn $@ if $@;
$db->txn_commit;

eval { $db->storage->dbh->do("DROP TABLE vm CASCADE") };
warn $@ if $@;
$db->txn_commit;

eval { $db->storage->dbh->do("DROP TABLE host CASCADE") };
warn $@ if $@;
$db->txn_commit;

eval { $db->storage->dbh->do('DROP TABLE "user" CASCADE') };
warn $@ if $@;
$db->txn_commit;
