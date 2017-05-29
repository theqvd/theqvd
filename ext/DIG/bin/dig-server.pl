#!/Applications/Qvd.app/Contents/Resources/usr/lib/qvd/bin/perl 

package DIG::Server;

use strict;
use warnings;
use 5.010;
use Mojolicious::Lite;
use QVD::Log;

get '/' => {text => 'I ♥ Mojolicious!'};

app->start('daemon', 'l', 'http://*:3000');

=head1 NAME

dig-server - DIG Server

=head1 DESCRIPTION

B<dig-server> runs a server to provide an API-Rest to use Disk Images.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.
lo
This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
