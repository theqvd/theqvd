#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

my $fstype;
my $mount_point;
my $device;

GetOptions('type|t=s' =>  \$fstype, 
	'mount-point=s' => \$mount_point);

$fstype //= 'ext3';
$mount_point //= '/home';

unless (system ("mount", "/dev/sdb1", $mount_point) == 0) {
    die 'Unable to mount user storage' if -e '/dev/sdb1';

    system ('echo , | sfdisk /dev/sdb') == 0
	or die "Unable to create partition table on user storage";

    system ('mkfs.'.$fstype, '/dev/sdb1') == 0
	or die "Unable to create file system on user storage";

    system ('mount', '/dev/sdb1', $mount_point) == 0
	or die 'Unable to mount user storage';

    # FIXME Create user home and copy /etc/skel
}
