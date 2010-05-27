#!/usr/bin/perl

package QVD::Client::App;

use strict;
use warnings;
BEGIN {
    $QVD::Config::USE_DB = 0;
    @QVD::Config::FILES = ('~/.qvd/client.conf', 
			   'qvd-client.conf');
}
use QVD::Client::Frame;
use parent 'Wx::App';

sub OnInit {
    my $self = shift;
    my $frame = QVD::Client::Frame->new();
    $self->SetTopWindow($frame);
    $frame->Show();
    return 1;
};

package main;

Wx::InitAllImageHandlers();
my $app = QVD::Client::App->new();
$app->MainLoop();

__END__

=head1 NAME

qvd-client - The QVD GUI Client

=head1 DESCRIPTION

B<qvd-client> is a graphic client that lets a user to connect to a virtual machine and take control of the remote desktop.

=head1 COPYRIGHT

Copyright 2009-2010 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
