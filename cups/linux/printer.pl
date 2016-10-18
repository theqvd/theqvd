#!/usr/bin/perl
use LWP::Simple;               
use JSON qw( decode_json );    
use Data::Dumper;
use strict;                     
use warnings;                 

my $trendsurl = "http://172.26.9.168:9000/printer";
my @printers = get_printers($trendsurl);
write_driver($printers[0]);

#write_driver();
sub get_printers {
    my @variables = @_;

    my $json = get( $variables[0] );
    die "Could not get $trendsurl!" unless defined $json;

    # Decode the entire JSON
    my @decoded_json = decode_json( $json );

    return $decoded_json[0]->{'Printers'}[0];
}

# It recieves a driver and wr
sub write_driver {
    my @variables = @_;
    my $id = $variables[0]->{'Id'};
    my $name = $variables[0]->{'Name'};
    
    my $filename = "print_".$id."_driver.drv";
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

    # Write file
    print $fh "#include <fonts.defs>\n";
    print $fh "#include <media.defs>\n";
    print $fh "Font *\n";
    # print $fh "Manufacturer ";
    print $fh "ModelName \"".$name."\"\n";
    print $fh "Version 1.0\n";
    print $fh "PCFileName \"print_".$id."_.ppd\"\n";
    
    close $fh;
    return;
}


