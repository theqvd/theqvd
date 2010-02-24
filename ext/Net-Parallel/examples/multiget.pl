#!/usr/bin/perl

use strict;
use warnings;

use Net::Parallel;
use Net::Parallel::HTTP;
use URI;
use IO::Socket::INET;
use Data::Dumper;

$Net::Parallel::debug = -1;

my $np = Net::Parallel->new();
my @httpc;

for (@ARGV) {
    my $uri = URI->new($_);
    my $scheme = $uri->scheme;
    $scheme =~ /^http(s)?$/ or die "bad scheme";
    my $ssl = $1 and die "SSL support not implemented yet";
    my $host = $uri->host;
    my $port = $uri->port;
    my $path = $uri->path_query;
    my $socket = IO::Socket::INET->new(PeerAddr => $host, PeerPort => $port,
				       Proto => 'tcp', Blocking => 0);
    my $httpc = Net::Parallel::HTTP->new($socket);
    $httpc->queue_request(GET => $_, headers => ["Host: $host"]);
    $np->register($httpc);
    push @httpc, $httpc;
}

$np->run;

print Dumper \@httpc;
