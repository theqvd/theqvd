#!/usr/bin/perl

package QVD::Client::App;
use QVD::Client::Setup;

use strict;
use warnings;
use 5.010;

use File::Spec;
use URI::Escape qw(uri_unescape);
use QVD::Config::Core qw(core_cfg);
use QVD::Log;

BEGIN {
    for $ARGV (@ARGV) {
        my @args = ($ARGV);
        if( $ARGV =~ /^qvd:(.*)$/ ) {
            @args = split(/\s+/, uri_unescape($1));
        }
        for my $arg (@args) {
            if (my ($k, $v) = $arg =~ /^\s*([\w\.]+)\s*[:=\s]\s*(.*?)\s*$/) {
                set_core_cfg($k, $v);
            }
        }
    }
}

our $orig_display = $ENV{DISPLAY};
our $user_certs_dir = File::Spec->rel2abs(core_cfg('path.ssl.ca.personal'), $user_dir);
mkdir $user_certs_dir;
INFO "user_certs_dir: $user_certs_dir";

our $pixmaps_dir = File::Spec->rel2abs(core_cfg('path.client.pixmaps'), $app_dir);
$pixmaps_dir = File::Spec->rel2abs(core_cfg('path.client.pixmaps.alt'), $app_dir) unless -d $pixmaps_dir;
INFO "pixmaps_dir: $pixmaps_dir";

$SIG{PIPE} = 'IGNORE';
$SIG{__WARN__} = sub { WARN "@_"; };
$SIG{__DIE__} = sub { ERROR "@_"; die (@_) };

use QVD::Client::Frame;
use parent 'Wx::App';

sub OnInit {
    my $self = shift;
    DEBUG("OnInit called");
    DEBUG("Showing frame");
    my $frame = QVD::Client::Frame->new();
    $self->SetTopWindow($frame);
    if ($self->should_autoconnect()) {
	INFO("Launching autoconnect");
	$frame->OnClickConnect;
    }else{
        $frame->Show();
    }

    return 1;
};

sub _osx_error {
    my ($message) = @_;
    ERROR("$message");

    open(OSA, "|/usr/bin/osascript") or die "Can't call osascript: $!";
    print OSA <<SCRIPT;
        tell application "System Events"
            activate
            display dialog "$message" buttons {"Ok"} with title "QVD Client" with icon 0
        end tell
SCRIPT

    close(OSA);
}

sub should_autoconnect {
    core_cfg('client.auto_connect', 0);
}
package main;

use QVD::Log;

Wx::InitAllImageHandlers();
my $app = QVD::Client::App->new();

DEBUG("Starting main loop");
$app->MainLoop();
INFO("Exiting");

# TODO: Investigate why ordered exit from within Frame.pm ends up in SEGFAULT.
use POSIX;
POSIX::_exit(0);
__END__

=head1 NAME

qvd-gui-client - The QVD GUI Client

=head1 DESCRIPTION

B<qvd-client> is a graphical client that lets a user connect to a
virtual machine and take control of the remote desktop.

=head1 COPYRIGHT

Copyright 2009-2017 by Qindel Formacion y Servicios S.L.

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU GPL version 3 as published by the Free
Software Foundation.
