#!/usr/bin/perl
use LWP::Simple;               
use JSON qw( decode_json );    
use Data::Dumper;
use strict;                     
use warnings;                 

my @printers = get_printers();
print Dumper $printers[0];

sub get_printers {
    my $trendsurl = "http://172.26.9.168:9000/printer";

    my $json = get( $trendsurl );
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


