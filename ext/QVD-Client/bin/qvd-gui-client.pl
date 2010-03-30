#!/usr/bin/perl

package QVD::Client::App;

use strict;
use warnings;
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

=head1 COPYRIGHT AND LICENSE

Copyright 2010 by Qindel Formacion y Servicios S.L., 

This program is free software; you may redistribute it and/or modify it under
the same terms as Perl itself.
