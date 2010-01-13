#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use QVD::DB::Provisioning;

my $provision = QVD::DB::Provisioning->new();

my $command = shift;

my %method = ( 'add-user' => 'add_user',
	       'add-osi' => 'add_osi', 
	       'add-host' => 'add_host', 
	       'add-vm' => 'add_vm',
	       'add-vm-state' => 'add_vm_state',
	       'add-vm-cmd' => 'add_vm_cmd',
	       'add-user-state' => 'add_user_state',
	       'add-user-cmd' => 'add_user_cmd',
	       'add-x-state' => 'add_x_state',
	       'add-x-cmd' => 'add_x_cmd' );

my %template = ( 'add-user' => [qw(login|l=s)],
		 'add-osi' => [qw(name|n=s path|p=s)],
		 'add-host' => [],
		 'add-vm' => [qw(name|n=s user|u=i osi|o=i ip=s storage|s=s)],
		 'add-vm-state' => [qw(name|n=s)],
		 'add-vm-cmd' => [qw(name|n=s)],
		 'add-user-state' => [qw(name|n=s)],
		 'add-user-cmd' => [qw(name|n=s)],
		 'add-x-state' => [qw(name|n=s)],
		 'add-x-cmd' => [qw(name|n=s)] );

my %options;


GetOptions (\%options, @{$template{$command}}) or die "Parametros Incorrectos";
my $method_name = $method{$command};
$provision->$method_name(%options);
