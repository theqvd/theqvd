#!/usr/bin/perl
use LWP::Simple;               
use JSON qw( decode_json );    
use Data::Dumper;
use strict;                     
use warnings;                 

my $cups_path = "/usr/lib/cups/backend";
my $cups_conf_path = "/etc/cups";
my $cups_post_path = "/usr/local/bin"; 
    
my $url_win  = "http://172.26.9.168:9000";
my $printer_url = "printer";
my $printer_job_url = "printjob";
 
create_printers($cups_path, $cups_conf_path, $cups_post_path, $url_win, $printer_url, $printer_job_url);

# Copy to cups
## Side effects
sub copy_tea4cups_files {
    my ($cpath, $cconf_path, $cups_post_path) = (@_);
    system("cp", "tea4cups/tea4cups", $cpath);
    system("cp", "tea4cups/tea4cups.conf", $cconf_path);
    return;
}

# Add printer to tea4cups conf file
## Side effects
sub add_printer_tea4cups {
    my ($cconf_path, $id, $url_win, $printer_url, $printer_job_url) = (@_);
    my $url = $url_win."/".$printer_url."/".$id."/".$printer_job_url;
    my $path_file = "/tmp/tmp".$id.".pdf";
    
    my $line_prehook = "prehook_printer".$id.' : cp $TEADATAFILE '.$path_file;
    my $line_posthook = "posthook_printer".$id." : curl -X POST -d @".$path_file." ".$url;
    my $filename =  $cconf_path."/tea4cups.conf";
    
    open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
    print $fh $line_prehook."\n";
    print $fh $line_posthook."\n\n";
    close $fh;
    
    system("cp", "tea4cups/windowscups", $cups_post_path);
    return;
}

# Create and add to CUPS all the printers
## Side effects
sub create_printers {
    my ($cups_path, $cups_conf_path, $cups_post_path, $url_win, $printer_url, $printer_job_url) = (@_);
    my $url = $url_win."/".$printer_url;
    my @printers = get_printers($url);

    # Copy tea4cups files 
    copy_tea4cups_files($cups_path, $cups_conf_path, $cups_post_path);

    # Remove printers
    remove_printers();

    # Add new printers
    foreach my $printer (@printers){
	my ($id, $name, $filename, $color) = read_json($printer);
	ppd_create($id, $name, $filename, $color);
	
	$name =~s/ /_/g;
	system("lpadmin", "-p", $name, "-v", "tea4cups://", "-P", $filename);
	system("cupsenable", $name);
	system("cupsaccept", $name);
    }

    # Reeboot cups
    system("/etc/init.d/cups", "restart");
    
    return;
}

# Remove printers
## Side effects 
sub remove_printers {
    my @printers = qx{lpstat -s};
    my @filtered = grep(/device/, @printers);
    
    foreach my $line (@filtered) {
	my @fields = split / /, $line;
	my $printer =  substr $fields[2], 0, -1;
	system("lpadmin", "-x", $printer);
    } 
}

# Make a get call to obtain the printer info
sub get_printers {
    my ($url) = (@_);

    my $json = get( $url );
    die "Could not get $url!" unless defined $json;

    # Decode the entire JSON
    my $decoded_json = decode_json( $json );
    my @printers = @{$decoded_json->{'Printers'}};

    # print Dumper $printers[1];
    return @printers; 
}

# Process json
sub read_json {
    my ($printer) = (@_);
    my $id = $printer->{'Id'};
    my $name = $printer->{'Name'};
    my $color = 'False'; 

    if($printer->{'IsSupportColor'}){
      $color = 'True';   
    }
    
    my $filename = "print_".$id."_driver.ppd";

    return ($id, $name, $filename, $color);
}

# It recieves a driver and wr
sub ppd_create {
    # Open file
    my ($id, $name, $filename, $color) = (@_);    
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    
    # Write file
    ppd_general_info($fh, $filename);

    ppd_write_line($fh, ppd_line("Product", "\"(".$name.")\""));
    ppd_write_line($fh, ppd_line("Manufacturer", "\"Foo\""));
    ppd_write_line($fh, ppd_line("ModelName", "\"FooJet 2000\""));
    ppd_write_line($fh, ppd_line("ShortNickName", "\"".$name."\""));
    ppd_write_line($fh, ppd_line("NickName", "\"".$name.", 1.0\""));
    ppd_write_line($fh, ppd_line("PSVersion", "\"(3010.000) 0\""));
    ppd_write_line($fh, ppd_line("LanguageLevel", "\"3\""));

    ppd_color($fh, $color);

    ppd_write_line($fh, ppd_line("FileSystem", "False"));
    ppd_write_line($fh, ppd_line("Throughput", "\"1\""));
    ppd_write_line($fh, ppd_line("LandscapeOrientation", "Plus90"));
    ppd_write_line($fh, ppd_line("TTRasterizer", "Type42"));
    ppd_write_line($fh, ppd_line("cupsVersion", "2.1"));
    ppd_write_line($fh, ppd_line("cupsModelNumber", "0"));
    ppd_write_line($fh, ppd_line("cupsManualCopies", "False"));
    ppd_write_line($fh, ppd_line("cupsLanguages", "\"en\""));
    ppd_write_line($fh, ppd_line("OpenUI *PageSize/Media Size", "PickOne"));
    ppd_write_line($fh, ppd_line("OrderDependency", "10 AnySetup *PageSize"));
    ppd_write_line($fh, ppd_line("DefaultPageSize", "Letter"));
    ppd_write_line($fh, ppd_line("PageSize Letter/US Letter", "\"<</PageSize[612 792]/ImagingBBox null>>setpagedevice\""));
    ppd_write_line($fh, ppd_line("PageSize A4/A4", "\"<</PageSize[595 842]/ImagingBBox null>>setpagedevice\""));
    ppd_write_line($fh, ppd_line("CloseUI", "*PageSize"));
    ppd_write_line($fh, ppd_line("OpenUI *PageRegion/Media Size", "PickOne"));
    ppd_write_line($fh, ppd_line("OrderDependency", "10 AnySetup *PageRegion"));
    ppd_write_line($fh, ppd_line("DefaultPageRegion", "Letter"));
    ppd_write_line($fh, ppd_line("PageRegion Letter/US Letter", "\"<</PageSize[612 792]/ImagingBBox null>>setpagedevice\""));
    ppd_write_line($fh, ppd_line("PageRegion A4/A4", "\"<</PageSize[595 842]/ImagingBBox null>>setpagedevice\""));
    ppd_write_line($fh, ppd_line("CloseUI", "*PageRegion"));
    ppd_write_line($fh, ppd_line("DefaultImageableArea", "Letter"));
    ppd_write_line($fh, ppd_line("ImageableArea Letter/US Letter", "\"0 0 612 792\""));
    ppd_write_line($fh, ppd_line("ImageableArea A4/A4", "\"0 0 595 842\""));
    ppd_write_line($fh, ppd_line("DefaultPaperDimension", "Letter"));
    ppd_write_line($fh, ppd_line("PaperDimension Letter/US Letter", "\"612 792\""));
    ppd_write_line($fh, ppd_line("PaperDimension A4/A4", "\"595 842\""));
    ppd_write_line($fh, ppd_line("OpenUI *Resolution/Resolution", "PickOne"));
    ppd_write_line($fh, ppd_line("OrderDependency", "10 AnySetup *Resolution"));
    ppd_write_line($fh, ppd_line("DefaultResolution", "600dpi"));
    ppd_write_line($fh, ppd_line("Resolution 600dpi/600 DPI", "\"<</HWResolution[600 600]/cupsBitsPerColor 8/cupsRowCount 0/cupsRowFeed 0/cupsRowStep 0/cupsColorSpace 3>>setpagedevice\""));
    ppd_write_line($fh, ppd_line("CloseUI", "*Resolution"));
    ppd_write_line($fh, ppd_line("DefaultFont", "Courier"));
    ppd_fonts($fh);
    ppd_write_line($fh, ppd_comm("End of ".$filename.", 03714 bytes"));
    
    close $fh;
    return;
}

# Create color config
## Side effects
sub ppd_color() {
    my ($fh, $color) = (@_);

    ppd_write_line($fh, ppd_comm("Color config"));

    if($color eq 'True'){
     ppd_write_line($fh, ppd_line("ColorDevice", 'True' ));
     ppd_write_line($fh, ppd_line("DefaultColorSpace", "CMYK"));

    }else{
     ppd_write_line($fh, ppd_line("ColorDevice", 'False' ));
     ppd_write_line($fh, ppd_line("DefaultColorSpace", "Gray"));
    }
    return;
}

# Create general info
## Side effects
sub ppd_general_info() {
    my ($fh, $filename) = (@_);
    
    ppd_write_line($fh, ppd_line("PPD-Adobe", "4.3"));
    
    ppd_write_line($fh, ppd_comm("Created by the CUPS PPD Compiler CUPS v2.1.4"));
    
    ppd_write_line($fh, ppd_line("FormatVersion", "\"4.3\""));
    ppd_write_line($fh, ppd_line("FileVersion", "\"1.0\""));
    ppd_write_line($fh, ppd_line("LanguageVersion", "English"));
    ## Add multiple idiom in the future
    ppd_write_line($fh, ppd_line("LanguageEncoding", "ISOLatin1"));
    ppd_write_line($fh, ppd_line("PCFileName", "\"".$filename."\""));

    return;
}

# Create fonts
## Side effects
sub ppd_fonts() {
    my ($fh) = (@_);
    ppd_write_line($fh, ppd_line("Font AvantGarde-Book", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font AvantGarde-BookOblique", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font AvantGarde-Demi", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font AvantGarde-DemiOblique", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Bookman-Demi", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Bookman-DemiItalic", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Bookman-Light", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Bookman-LightItalic", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Courier", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Courier-Bold", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Courier-BoldOblique", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Courier-Oblique", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Helvetica", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Helvetica-Bold", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Helvetica-BoldOblique", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Helvetica-Narrow", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Helvetica-Narrow-Bold", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Helvetica-Narrow-BoldOblique", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Helvetica-Narrow-Oblique", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Helvetica-Oblique", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font NewCenturySchlbk-Bold", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font NewCenturySchlbk-BoldItalic", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font NewCenturySchlbk-Italic", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font NewCenturySchlbk-Roman", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Palatino-Bold", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Palatino-BoldItalic", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Palatino-Italic", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Palatino-Roman", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Symbol", "Special \"(001.005)\" Special ROM"));
    ppd_write_line($fh, ppd_line("Font Times-Bold", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Times-BoldItalic", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Times-Italic", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font Times-Roman", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font ZapfChancery-MediumItalic", "Standard \"(1.05)\" Standard ROM"));
    ppd_write_line($fh, ppd_line("Font ZapfDingbats", "Special \"(001.005)\" Special ROM"));
}
    
# Write into a file handler for a ppd file
## Side effects
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
sub ppd_comm() {
    my ($comment) = (@_);
    return "*%%%% ".$comment.".";
}




