#!/usr/bin/perl
use strict;
use warnings; 

system("mkdir" "/PDF");
system("cp", "tea4cups/tea4cups.conf", "/etc/cups");
system("cp", "tea4cups/tea4cups", "/usr/lib/cups/backend");
system("/etc/init.d/cups", "restart");
