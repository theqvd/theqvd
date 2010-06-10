#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Long;

# move this boilerplate to a new module QVD::VMA::Config
BEGIN {
    $QVD::Config::USE_DB = 0;
    @QVD::Config::FILES = ('/etc/qvd/vma.conf');
}
use QVD::Config;

my $fstype      = cfg('vma.user.home.fs');
my $mount_point = cfg('vma.user.home.path');
my $user        = cfg('vma.user.name');
my $drive       = cfg('vma.user.drive');

my $partition = $drive . '1';

my $user_home = "$mount_point/$user";

unless (-d $user_home) {

    my $root_dev = (stat '/')[0];
    my $user_dev = (stat $mount_point)[0];

    if ($root_dev == $user_dev) {
	unless (-e $partition) {
	    system ("echo , | sfdisk $drive")
		and die "Unable to create partition table on user storage";

	    system ("mkfs.$fstype" =>  $partition)
		and die "Unable to create file system on user storage";
	}

	system mount => $partition, $mount_point
	    and die 'Unable to mount user storage';
    }

    system (cp => "-a", "/etc/skel", $user_home)
	and die "Unable to copy /etc/skel to $user_home";

    system (chown => "-R", "$user:$user", $user_home)
	and die "Unable to change the owner of user storage to $user";
}
