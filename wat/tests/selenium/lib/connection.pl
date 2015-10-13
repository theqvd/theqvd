#!/usr/bin/perl
use strict;
# Warnings will be disabled due variables redefinition problem
#use warnings;
 
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;

my $selenium_server = $ARGV[0];
my $wat_url = $ARGV[1];

my $sel = Test::WWW::Selenium->new( host => $selenium_server, 
                                    port => 4444, 
                                    browser => "*firefox", 
                                    browser_url => $wat_url );
