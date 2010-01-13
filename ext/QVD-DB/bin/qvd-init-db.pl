#!/usr/bin/perl

use strict;
use warnings;
use QVD::DB::Provisioning;
use Sys::Hostname;

my $prov = QVD::DB::Provisioning->new(deploy => 1);

$prov->add_user(login => 'qvd', password => 'passw0rd');
$prov->add_osi(name => 'Test image',
	       memory => '256',
	       use_overlay => 1,
	       path => 'qvd-guest.img');
$prov->add_host(name => hostname, address => '127.0.0.1');
$prov->add_vm(name => 'Test VM 1',
	      osi => 1,
	      user => 1,
	      ip => '',
	      storage => '' );
