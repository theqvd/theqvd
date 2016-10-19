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
    my $color = 'False'; 
    if($printer->{'IsSupportColor'} eq 'true'){
      $color = 'True';   
    }
    
    my $filename = "print_".$id."_driver.ppd";
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";

    # Write file
    ppd_write_line($fh, ppd_line("PPD-Adobe", "\"4.3\""));
    ppd_write_line($fh, ppd_comm("PPD file for FooJet 2000 with CUPS"));
    ppd_write_line($fh, ppd_comm("Created by the CUPS PPD Compiler CUPS v2.1.4"));
    ppd_write_line($fh, ppd_line("FormatVersion", "\"4.3\""));
    ppd_write_line($fh, ppd_line("FileVersion", "\"1.0\""));
    ppd_write_line($fh, ppd_line("LanguageVersion", "English"));
    ppd_write_line($fh, ppd_line("LanguageEncoding", "ISOLatin1"));
    ppd_write_line($fh, ppd_line("PCFileName", "\"printer_".$id.".ppd\""));
    ppd_write_line($fh, ppd_line("Product", "\"(".$name.")\""));
    ppd_write_line($fh, ppd_line("Manufacturer", "\"Foo\""));
    ppd_write_line($fh, ppd_line("ModelName", "\"FooJet 2000\""));
    ppd_write_line($fh, ppd_line("ShortNickName", "\"".$name."\""));
    ppd_write_line($fh, ppd_line("NickName", "\"".$name.", 1.0\""));
    ppd_write_line($fh, ppd_line("PSVersion", "\"(3010.000) 0\""));
    ppd_write_line($fh, ppd_line("LanguageLevel", "\"3\""));
    ppd_write_line($fh, ppd_line("ColorDevice", $color ));
    ppd_write_line($fh, ppd_line("DefaultColorSpace", "Gray"));
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
    ppd_write_line($fh, ppd_comm("End of foojet2k.ppd, 03714 bytes"));
    
    close $fh;
    return;
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
