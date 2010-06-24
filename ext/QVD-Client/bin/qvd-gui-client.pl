#!/usr/bin/perl

package QVD::Client::App;

use strict;
use warnings;

use Proc::Background;

my $WINDOWS;

BEGIN {
    $QVD::Config::USE_DB = 0;
    @QVD::Config::FILES = ('/etc/qvd/client.conf',
			   ($ENV{HOME} || $ENV{APPDATA}).'/.qvd/client.conf',
			   'qvd-client.conf');

    # FIXME NX_CLIENT is used for showing the user information on things
    # like broken connection, perhaps we should show them to the user
    # instead of ignoring them? 
    $WINDOWS = ($^O eq 'MSWin32');
    $ENV{NX_CLIENT} = $WINDOWS ? 'cmd.exe /c :' : '/bin/false';
}
use QVD::Client::Frame;
use parent 'Wx::App';

sub OnInit {
    my $self = shift;
    
    if ($WINDOWS) {
      my @cmd;
      my @opts = ("-multiwindow", "-notrayicon");
      push @cmd, ($ENV{QVDPATH}."/Xming/Xming.exe", @opts);
      #push @cmd, "-notrayicon";
      Proc::Background->new(@cmd);   
    }
    
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
