#!/usr/bin/perl
use LWP::Simple;               
use JSON qw( decode_json );    
use Data::Dumper;
use strict;                     
use warnings;                 

my $trendsurl = "http://172.26.9.168:9000/printer";
my @printers = get_printers($trendsurl);
ppd_create($printers[0]);

sub get_printers {
    my ($url) = (@_);

    my $json = get( $url );
    die "Could not get $trendsurl!" unless defined $json;

    # Decode the entire JSON
    my @decoded_json = decode_json( $json );

    return $decoded_json[0]->{'Printers'}[0];
}

# It recieves a driver and wr
sub ppd_create {
    my ($printer) = (@_);
    my $id = $printer->{'Id'};
    my $name = $printer->{'Name'};
    
    my $filename = "print_".$id."_driver.drv";
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

    # Write file
    ppd_write_line($fh, ppd_line("FormatVersion", "4.3"));
    close $fh;
    return;
}

# Write into a file handler for a ppd file
## Side effect
sub ppd_write_line() {
    my ($fh, $line) = (@_);
    print $fh $line."\n"; 
    return;
}

# Create a ppd line
sub ppd_line() {
    my ($first, $second) = (@_);
    return "*".$first.": ".$second;
}

# Create a comment line in a ppd file
sub ppd_comment() {
    my ($comment) = (@_);
    return "*%%%%".$comment.".";
}
