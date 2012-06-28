#!/usr/bin/perl

package QVD::Client::App;

use strict;
use warnings;

use Cwd;
use File::Spec;
use Proc::Background;
use Log::Log4perl qw(:levels :easy);

my $WINDOWS;
my $DOTQVD;
my $log;

BEGIN {
    $DOTQVD = ($ENV{HOME} || $ENV{APPDATA}).'/.qvd';
    mkdir($DOTQVD);
    
    if ( -f "$DOTQVD/log.conf" ) {
        Log::Log4perl->init("$DOTQVD/log.conf");
        print "Log configuration loaded from $DOTQVD/log.conf";
    } else {

        Log::Log4perl->easy_init( { level => $DEBUG, file => ">>$DOTQVD/qvd_client.log" } );
        print "Default log configuration. Logging to $DOTQVD/qvd_client.log";
    }

    $log = Log::Log4perl->get_logger("QVD::Client::App");

    $log->info("Starting up...");
    $log->info("Home dir is $DOTQVD, OS is $^O");

    $SIG{__WARN__} = sub { my $l = Log::Log4perl->get_logger("QVD::Client::App"); $l->warn(@_); };
    $SIG{__DIE__}  = sub { my $l = Log::Log4perl->get_logger("QVD::Client::App"); $l->error(@_); die(@_); };

    mkdir $DOTQVD if (!-e $DOTQVD);
    $QVD::Config::USE_DB = 0;
    @QVD::Config::FILES = (
        '/etc/qvd/client.conf',
        $DOTQVD.'/client.conf',
        'qvd-client.conf',
    );

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
    $log->debug("OnInit called");

    if ($WINDOWS) {
        my ($volume,$directories,$file) = File::Spec->splitpath(Cwd::realpath($0));
        $ENV{QVDPATH} //= File::Spec->catpath( $volume, $directories);
        $ENV{DISPLAY} //= '127.0.0.1:0';
        
        my @cmd;
        my @opts = qw(-multiwindow -notrayicon -nowinkill -clipboard +bs -wm);
        push @opts, (-logfile => $DOTQVD.'/xserver.log');
        push @cmd, ($ENV{QVDPATH}."/Xming/Xming.exe", @opts);
        $log->debug("Starting Xming: " . join(' ', @cmd));
        
        if ( Proc::Background->new(@cmd) ) {
            $log->debug("Xming started");
        } else {
            $log->error("Xming failed to start");
        }
        
    }
    
    $log->debug("Showing frame");
    my $frame = QVD::Client::Frame->new();
    $self->SetTopWindow($frame);
    $frame->Show();
    return 1;
};

package main;

Wx::InitAllImageHandlers();
my $app = QVD::Client::App->new();

$log->debug("Starting main loop");
$app->MainLoop();
$log->info("Exiting");

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
