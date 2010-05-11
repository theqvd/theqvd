#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Catalyst::Test 'QVD::Admin::Web';

my $help = 0;

GetOptions( 'help|?' => \$help );

pod2usage(1) if ( $help || !$ARGV[0] );

print request($ARGV[0])->content . "\n";

1;

=head1 NAME

qvd_admin_web_test.pl - Catalyst Test

=head1 SYNOPSIS

qvd_admin_web_test.pl [options] uri

 Options:
   -help    display this help and exits

 Examples:
   qvd_admin_web_test.pl http://localhost/some_action
   qvd_admin_web_test.pl /some_action

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst action from the command line.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm

Qindel Formacion y Servicios S.L.

=head1 COPYRIGHT

Modifications by the QVD team are copyright 2009-2010 by Qindel Formacion y
Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.

=cut
