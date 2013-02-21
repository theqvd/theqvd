#!/usr/bin/env perl

package Helper;

use parent 'Net::Server::Fork';
use QVD::SlaveServer;
use File::Basename qw(dirname);

sub process_request {
    my $client = shift->{server}{client};
    open STDOUT, ">&", $client or die "Unable to dup stdout: $^E";
    open STDIN, "<&", $client or die "Unable to dup stdin: $^E";
    close $client;
    my $server = QVD::SlaveServer->new();
    $server->run();
    close STDOUT;
    close STDIN;
}

package main;

my $helper = Helper->new;
$helper->run;
