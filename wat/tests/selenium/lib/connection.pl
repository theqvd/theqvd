#!/usr/bin/perl
use strict;
use warnings;
 
use strict;
use warnings;
use Time::HiRes qw(sleep);
use Test::WWW::Selenium;
use Test::More "no_plan";
use Test::Exception;


my $sel = Test::WWW::Selenium->new( host => "172.20.126.53", 
                                    port => 4444, 
                                    browser => "*chrome", 
                                    browser_url => "http://172.20.126.16/" );
