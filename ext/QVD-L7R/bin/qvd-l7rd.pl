#!/usr/bin/perl

use strict;
use warnings;

use QVD::L7R;
use QVD::Config;
use QVD::Config::SSL;
use File::Slurp qw(write_file);

# retrieve SSL certificates from the database and install them locally

my $server_cert = QVD::Config::SSL->get('ssl_server_cert');
my $server_key = QVD::Config::SSL->get('ssl_server_key');

defined $server_cert or die "ssl_server_cert not available from database\n";
defined $server_key or die "ssl_server_key not available from database\n";

mkdir 'certs', 0700;
-d 'certs' or die "unable to create directory 'certs'\n";
my ($mode, $uid) = (stat 'certs')[2, 4];
$uid == $> or die "bad owner for directory 'certs'\n";
$mode & 0077 and die "bad permissions for directory 'certs'\n";
write_file('certs/server-cert.pem', $server_cert);
write_file('certs/server-key.pem', $server_key);

my $l7r = QVD::L7R->new(port => 8443, SSL => 1);
$l7r->run();
