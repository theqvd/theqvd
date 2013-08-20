#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;

my ($dialog_type, $caption, $window, $local, $parent, $display, $message);

GetOptions("dialog=s"  => \$dialog_type,
           "caption=s" => \$caption,
           "message=s" => \$message,
           "window=i"  => \$window,
           "local"     => \$local,
           "parent"    => \$parent,
           "display=s" => \$display,
   );

if ($dialog_type ne 'pulldown') {
    kill 1, getppid;
}
