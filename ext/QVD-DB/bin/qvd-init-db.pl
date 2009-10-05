#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB::Provisioning;

my $db = QVD::DB::Provisioning->new(deploy => 1);
$db->add_farm(name => 'Granja de pruebas');
$db->add_user(login => 'qvd');
$db->add_host(farm => 1);
$db->add_osi(name => 'Test image', path => 'qvd-guest.img');
foreach my $i (1..7) {
    $db->add_vm(
	    name => 'Test VM '.$i,
	    osi => 1,
	    farm => 1, 
	    user => 1,
	    ip => '',
	    storage => ''
	    );
}

$db->schema->txn_commit;
