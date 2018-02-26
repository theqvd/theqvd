package QVD::Client::USB;
use Exporter 'import';
@EXPORT_OK = qw/list_devices get_busid/;

use strict;
use QVD::Log;
use QVD::Config::Core;


our $usbroot = core_cfg('path.usb.usbroot');
our @files = split ',' , core_cfg('path.usb.database');

=head1 NAME

QVD::Client::USB

=head1 SYNOPSIS

USB hardware information module

=head1 DESCRIPTION

This module lets the Client interrogate the linux system about USB hardware available for sharing with the vm desktop.

=over 4

=head1 FUNCTIONS

=cut

=head2 list_devices()

Returns the list of current devices

=cut

sub list_devices {
    my @devices;

    opendir my $device_dir , $usbroot
        or do { ERROR "Can't open $usbroot" ; return; };
    while ( defined(my $busid = readdir($device_dir)) ){

        my $device_class;
        my $manufacturer;
        my $product;
        my $vendorid;
        my $productid;
        my $serial;

        # Ignore hubs
        if ( -f "$usbroot/$busid/bDeviceClass" ){
            $device_class = _read_line("$usbroot/$busid/bDeviceClass",1);
        }else{
            DEBUG "Device doesn't have bDeviceClass";
            next;
        }
        chomp $device_class;
        next if ($device_class == '09');

        # idVendor and idProduct MUST exist
        if ( -f "$usbroot/$busid/idVendor" ){
            $vendorid = _read_line("$usbroot/$busid/idVendor",1);
        }else{
            DEBUG "Device doesn't have idVendor";
            next;
        }

        if ( -f "$usbroot/$busid/idProduct" ){
            $productid = _read_line("$usbroot/$busid/idProduct",1);
        }else{
            DEBUG "Device doesn't have idProduct";
            next;
        }

        # String manufacturer and product name may not exist. That goes for the serial too.
        if ( -f "$usbroot/$busid/manufacturer" ){
            $manufacturer = _read_line("$usbroot/$busid/manufacturer");
        }

        if ( -f "$usbroot/$busid/product" ){
            $product = _read_line("$usbroot/$busid/product");
        }

        if ( -f "$usbroot/$busid/serial" ){
            $serial = _read_line("$usbroot/$busid/serial");
        }

        # Try to get the names from usb.ids file
        unless ($manufacturer && $product){
            ($manufacturer,$product) = _get_names_from_file($vendorid,$productid);
        }

        push @devices,{
                        vendor => $manufacturer,
                        product => $product,
                        vid => $vendorid,
                        pid => $productid,
                        serial => $serial
                      };
    }

    return @devices;

}

=head2 get_busid($devid)

Get the busid the device is connected to

=cut

sub get_busid {
    my $devid = shift;
    my $target_busid;

    opendir my $device_dir , $usbroot
        or do { ERROR "Can't open $usbroot" ; return; };

    while ( defined(my $busid = readdir($device_dir)) ){
        if ( $devid eq _read_devid_from_bus($busid)) {
            $target_busid = $busid;
        }
    }
    closedir $device_dir
        or ERROR "Can't close $usbroot";

    return $target_busid;
}

=head2_read_devid_from_bus($busid)

Read device id connected to busid

=cut

sub _read_devid_from_bus {
    my $busid = shift;
    my $vendorid;
    my $productid;
    my $serial;

    $vendorid = _read_line("$usbroot/$busid/idVendor") // return;

    $productid = _read_line("$usbroot/$busid/idProduct") // return;

    $serial = _read_line("$usbroot/$busid/serial");

    return $serial ? "$vendorid:$productid\@$serial" : "$vendorid:$productid";
}

sub _read_line {
    my ($file,$fatal) = @_;
    my $result;

    open my $fh, '<', $file
        or do { ERROR "Can't open $file" if $fatal; return; };
    $result = <$fh>;
    close $fh
        or do { ERROR "Can't close $file";};
    chomp $result;

    return $result;
}

=head2 _get_names_from_file($vendorid,$productid)

Try to get product vendor and name

=cut

sub _get_names_from_file {
    my ($vendorid,$productid) = @_;
    my %hwdata;

    foreach my $file (@files){
        if ( -f $file ){
            %hwdata = _parse_hwdata($file);
            last;
        }
    }

    WARN "hwdata parsing failed. Couldn't obtain data" unless (%hwdata);

    my $vendor = defined($hwdata{$vendorid}) ? $hwdata{$vendorid}->{name} : 'unknown';
    my $product = $hwdata{$vendorid}->{products}->{$productid} // 'unknown';

    return ($vendor,$product);
}

=head2 _parse_hwdata($file)

Parse an usb.ids file.

=cut

sub _parse_hwdata {
    my $file = shift;
    my %hwdata;

    open my $fd, '<',$file
        or do { WARN "Can't open $file: ".$!;
                return;
              };

    my $last_seen;
    while ( my $line = <$fd> ){
    
        if ($line =~ m/^([\d,a,b,c,d,e,f]{4})  (.*)$/){
             $hwdata{$1} = { name => $2, products => {} };
             $last_seen = $1; 
        };  
    
        if ($line =~ m/^\t([\d,a,b,c,d,e,f]{4})  (.*)\n/){
            $hwdata{$last_seen}->{products}->{$1} = $2; 
        }   
    
    }

    return %hwdata;
}
 
1;


=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut
