#!/usr/bin/perl
use LWP::Simple;               
use JSON qw( decode_json );    
use Data::Dumper;
use strict;                     
use warnings;                 

my $trendsurl = "http://172.26.9.168:9000/printer";
my @printers = get_printers($trendsurl);
print Dumper $printers[0];

sub get_printers {
    my @variables = @_;

    my $json = get( $variables[0] );
    die "Could not get $trendsurl!" unless defined $json;

    # Decode the entire JSON
    my @decoded_json = decode_json( $json );

    return $decoded_json[0]->{'Printers'};
}

# It recieves a driver and wr
sub write_driver {
    my $variables = @_;
    return;
}


