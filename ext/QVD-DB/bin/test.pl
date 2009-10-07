#!/usr/bin/perl 

use QVD::DB;
use strict;

my $IP_SUBNET = '172.20.99.';
my $TEMP_STO = 'En algun lugar';

my $schema = QVD::DB->connect('dbi:SQLite:example.db');

for (my $i=1;$i<=5;$i++){
	$schema->resultset('User')->create({login => 'test'.$i});

	$schema->resultset('VM')->create({name => 'test'.$i,
					  farm_id => 1,
				 	  user_id => $i,
					  osi_id => 1,
					  ip => $IP_SUBNET . $i, 
					  storage => $TEMP_STO
					  });
	$schema->resultset('VM_Runtime')->create({vm_id => $i,
						  host_id => $i,
						  state => 'Stopped',
						  state_x => 'Check',
						  state_user => 'Disconnected',
						  user_ip => 'The ip from user is connecting',
						  real_user_id => 'Real User'
						 });
}

$schema->resultset('Host')->create({farm_id => 1});

$schema->resultset('OSI')->create({name => 'test',
				   disk_image => '/var/local/img'});

$schema->txn_commit;
