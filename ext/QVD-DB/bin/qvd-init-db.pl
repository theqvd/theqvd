#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB::Provisioning;

my $db = QVD::DB::Provisioning->new(deploy => 1);

$db->add_user(login => 'qvd');
$db->add_osi(name => 'Test image', path => 'qvd-guest.img');
$db->add_host(name => 'localhost', address => 'localhost');
$db->add_vm(
	name => 'Test VM 1',
	osi => 1,
	host => 1,
	user => 1,
	ip => '',
	storage => ''
	);

$db->schema->txn_commit;
