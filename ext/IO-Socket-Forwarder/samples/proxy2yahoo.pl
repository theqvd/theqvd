#!/usr/bin/perl

use strict;
use warnings;

use IO::Socket::INET;
use IO::Socket::Forwarder qw(forward_sockets);

my $port = $ARGV[0] || 3333;
my $listener = IO::Socket::INET->new(LocalPort => $port,
				     Proto => 'tcp',
				     Listen => 2,
				     ReuseAddr => 1);

while (1) {
    my $local = $listener->accept();
    my $yahoo = IO::Socket::INET->new('www.yahoo.com:80');
    forward_sockets($local, $yahoo, debug => 1);
}


