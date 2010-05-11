#!/usr/bin/env perl

BEGIN { $ENV{CATALYST_ENGINE} ||= 'CGI' }

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use QVD::Admin::Web;

QVD::Admin::Web->run;

1;

=head1 NAME

qvd_admin_web_cgi.pl - Catalyst CGI

=head1 SYNOPSIS

See L<Catalyst::Manual>

=head1 DESCRIPTION

Run a Catalyst application as a cgi script.

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
