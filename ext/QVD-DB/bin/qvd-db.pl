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
	       'add-vm' => 'add_vm' );

my %template = ( 'add-user' => [qw(login|l=s)],
		 'add-osi' => [qw(name|n=s path|p=s)],
		 'add-host' => [],
		 'add-vm' => [qw(name|n=s user|u=i osi|o=i ip=s storage|s=s)]
	);

my %options;


GetOptions (\%options, @{$template{$command}}) or die "Parametros Incorrectos";
my $method_name = $method{$command};
$provision->$method_name(%options);

$provision->schema->txn_commit;
