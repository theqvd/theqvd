#!/usr/bin/perl

use strict;
use warnings;

use IO::Socket::SSL;
use IO::Socket::Forwarder qw(forward_sockets);

my $port = $ARGV[0] || 3333;

my $listener = IO::Socket::SSL->new(LocalPort => $port,
				    Proto => 'tcp',
				    Listen => 2,
				    ReuseAddr => 1)
    or die "unable to create socket" . IO::Socket::SSL::errstr();

while (1) {
    my $local = $listener->accept();
    my $nntp = IO::Socket::INET->new('news.gmane.org:nntp');
    forward_sockets($local, $nntp);
}


