#!/usr/bin/perl
use strict;
use warnings; 

system("sh", "cp", "tea4cups/tea4cups.conf", "/etc/cups");
system("sh", "cp", "tea4cups/tea4cups", "/usr/lib/cups/backend");
system("sh", "/etc/init.d/cups", "restart");
