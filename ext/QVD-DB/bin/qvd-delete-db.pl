#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB::Provisioning;

my $db = QVD::DB->new;

$db->sth->do("DROP TABLE osi CASCADE");
$db->schema->txn_commit;

$db->sth->do("DROP TABLE vm_runtime CASCADE");
$db->schema->txn_commit;

$db->sth->do("DROP TABLE vm_ CASCADE");
$db->schema->txn_commit;

$db->sth->do("DROP TABLE host CASCADE");
$db->schema->txn_commit;

$db->sth->do("DROP TABLE user CASCADE");
$db->schema->txn_commit;
