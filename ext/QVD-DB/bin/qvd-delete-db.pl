#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB::Provisioning;

my $db = QVD::DB->new;

eval { $db->storage->dbh->do("DROP TABLE osis CASCADE") };
warn $@ if $@;
$db->txn_commit;

eval { $db->storage->dbh->do("DROP TABLE vm_runtimes CASCADE") };
warn $@ if $@;
$db->txn_commit;

eval { $db->storage->dbh->do("DROP TABLE vms CASCADE") };
warn $@ if $@;
$db->txn_commit;

eval { $db->storage->dbh->do("DROP TABLE hosts CASCADE") };
warn $@ if $@;
$db->txn_commit;

eval { $db->storage->dbh->do('DROP TABLE users CASCADE') };
warn $@ if $@;
$db->txn_commit;
