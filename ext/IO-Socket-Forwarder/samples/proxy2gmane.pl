#!/usr/bin/perl

use strict;
use warnings;

use IO::Socket::INET;
use Net::Forwarder;

my $port = $ARGV[0] || 3333;

my $listener = IO::Socket::INET->new(LocalPort => $port,
				     Proto => 'tcp',
				     Listen => 2,
				     ReuseAddr => 1);

while (1) {
    my $local = $listener->accept();
    my $yahoo = IO::Socket::INET->new('news.gmane.org:nntp');

    my $fwd = Net::Forwarder->new($local, $yahoo);
    $fwd->run;
}


