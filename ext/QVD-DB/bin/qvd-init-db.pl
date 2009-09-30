#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB;

my @sqlt_args = { add_drop_table => 1 };

my $schema = QVD::DB->new();
$schema->deploy(@sqlt_args);
$schema->resultset('Farm')->create({name => 'Granja de pruebas'});
$schema->resultset('User')->create({login => 'qvd'});
$schema->resultset('Host')->create({
	farm_id => 1,
	});
$schema->populate('OSI', [
	[ qw/name disk_image/ ], 
	[ 'Test image', 'qvd-guest.img' ],
	]);
$schema->populate('VM', [
	[ qw/name osi_id farm_id user_id ip storage/ ], 
	[ 'Test VM 1', 1, 1, 1, '', '' ],
	[ 'Test VM 2', 1, 1, 1, '', '' ],
	[ 'Test VM 3', 1, 1, 1, '', '' ],
	[ 'Test VM 4', 1, 1, 1, '', '' ],
	[ 'Test VM 5', 1, 1, 1, '', '' ],
	[ 'Test VM 6', 1, 1, 1, '', '' ],
	[ 'Test VM 7', 1, 1, 1, '', '' ],
	]);
$schema->populate('VM_Runtime', [
	[ qw/vm_id state host_id state_x state_user user_ip real_user_id/ ], 
	[ 1, 'stopped', 1, '', '', '', 1],
	[ 2, 'stopped', 1, '', '', '', 1],
	[ 3, 'stopped', 1, '', '', '', 1],
	[ 4, 'stopped', 1, '', '', '', 1],
	[ 5, 'stopped', 1, '', '', '', 1],
	[ 6, 'stopped', 1, '', '', '', 1],
	[ 7, 'stopped', 1, '', '', '', 1],
	]);
