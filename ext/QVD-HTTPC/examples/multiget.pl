#!/usr/bin/perl

use strict;
use warnings;

use QVD::ParallelNet;
use QVD::HTTPC::Parallel;
use URI;
use IO::Socket::INET;
use Data::Dumper;

$Net::Parallel::debug = -1;

my $par = QVD::ParallelNet->new();
my @httpc;

for (@ARGV) {
    my $uri = URI->new($_);
    my $scheme = $uri->scheme // 'http';
    $scheme =~ /^http(s)?$/ or die "bad scheme";
    my $ssl = $1 and die "SSL support not implemented yet";
    my $host = $uri->host;
    my $port = $uri->port;
    my $path = $uri->path_query;
    my $socket = IO::Socket::INET->new(PeerAddr => $host, PeerPort => $port,
				       Proto => 'tcp', Blocking => 0);
    my $httpc = QVD::HTTPC::Parallel->new($socket);
    $httpc->queue_request(GET => $_, headers => ["Host: $host"]);
    $par->register($httpc);
    push @httpc, $httpc;
}

$par->run;

print Dumper \@httpc;
