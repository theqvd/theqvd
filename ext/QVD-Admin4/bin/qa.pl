#!/usr/lib/perl 
use strict;
use warnings;
use Mojo::UserAgent;
use Data::Dumper;

my $url = "http://192.168.56.102:8080?login=superadmin&passsword=superadmin&action=vm_update&arguments={""";
my $ua = Mojo::UserAgent->new;

my $res = $ua->get($url);

print Dumper $res;
