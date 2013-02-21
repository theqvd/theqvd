#!/usr/bin/env perl

package Helper;

use parent 'Net::Server::Fork';
use QVD::Client::SlaveServer;
use File::Basename qw(dirname);

sub process_request {
    my $client = shift->{server}{client};
    open STDOUT, ">&", $client or die "Unable to dup stdout: $^E";
    open STDIN, "<&", $client or die "Unable to dup stdin: $^E";
    close $client;
    my $server = QVD::Client::SlaveServer->new();
    $server->run();
    close STDOUT;
    close STDIN;
}

package main;

my $helper = Helper->new(port => 12100);
$helper->run;
