#! /usr/bin/perl

use strict;
use warnings;

use HTTP::Lite;

# Definición del protocolo la que hacer Upgrade
my $protocol = "QVD/1.0";

my $http = new HTTP::Lite;

# Establece HTTP/1.1
$http->http11_mode(1);

# Conecta contra una máquina virtual
sub connect_to_vm {
	my $host = shift(@_);

	$http->method("GET");

	$http->add_req_header ("Upgrade", $protocol);

	my $req = $http->request($host)
	or die "Unable to get host: $!";

	if ($http->status() == 101) {
		print "OK";
	} else {
		print "Upgrade unsuccessful\n";
		print $http->status_message();
	}

}

connect_to_vm("http://127.0.0.1/");


