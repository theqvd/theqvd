#!/usr/bin/perl
use LWP::Simple;               
use JSON qw( decode_json );    
use Data::Dumper;
use strict;                     
use warnings;                 

my $trendsurl = "http://172.26.9.168:9000/printer";

my $json = get( $trendsurl );
die "Could not get $trendsurl!" unless defined $json;

# Decode the entire JSON
my @decoded_json = decode_json( $json );

print Dumper $decoded_json[0]->{'Printers'}[0];


