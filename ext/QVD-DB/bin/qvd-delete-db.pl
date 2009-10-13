#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB::Provisioning;

my $db = QVD::DB::Provisioning->new();

$db->storage->dbh->do("DROP TABLE osi CASCADE");
$db->schema->txn_commit;

$db->storage->dbh->do("DROP TABLE vm_runtime CASCADE");
$db->schema->txn_commit;

$db->storage->dbh->do("DROP TABLE vm_ CASCADE");
$db->schema->txn_commit;

$db->storage->dbh->do("DROP TABLE host CASCADE");
$db->schema->txn_commit;

$db->storage->dbh->do("DROP TABLE user CASCADE");
$db->schema->txn_commit;
