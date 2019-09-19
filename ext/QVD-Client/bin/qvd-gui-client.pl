#!/usr/bin/perl

package QVD::Client::App;
use strict;
use warnings;
use 5.010;

use QVD::Client::Setup;
use File::Spec;
use URI::Escape qw(uri_unescape);
use QVD::Config::Core qw(core_cfg set_core_cfg);
use QVD::Log;


use QVD::Client::Frame;
use parent 'Wx::App';


our $orig_display = $ENV{DISPLAY};
our $user_certs_dir = File::Spec->rel2abs(core_cfg('path.ssl.ca.personal'), $user_dir);
mkdir $user_certs_dir;
INFO "user_certs_dir: $user_certs_dir";

our $pixmaps_dir = File::Spec->rel2abs(core_cfg('path.client.pixmaps'), $app_dir);
DEBUG "pixmaps_dir, first attempt: $pixmaps_dir";

$pixmaps_dir = File::Spec->rel2abs(core_cfg('path.client.pixmaps.alt'), $app_dir) unless -d $pixmaps_dir;
INFO "pixmaps_dir, final value: $pixmaps_dir";


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
use strict;
use warnings;
use QVD::Client::Setup;
use QVD::Log;
use Getopt::Long;
use QVD::Config::Core;
use MIME::Base64;
use QVD::Config::Core qw(core_cfg set_core_cfg);

INFO "Client starting";
INFO "User dir: $user_dir";
INFO "App dir : $app_dir";



$SIG{PIPE} = 'IGNORE';

$SIG{__WARN__} = sub {
    local $Log::Log4perl::caller_depth =
          $Log::Log4perl::caller_depth + 1;
    WARN "@_";
};

$SIG{__DIE__} = sub {
    local $Log::Log4perl::caller_depth =
          $Log::Log4perl::caller_depth + 1;

    if ( $^S ) {
        DEBUG "die called inside eval: @_";
    } else {
        LOGDIE "@_";
    }
};

INFO "Parsing options";
my ($opt_host, $opt_port, $opt_vm_id, $opt_username, $opt_password, $opt_token, $opt_ssl);
my ($help);

GetOptions(
    "host=s"      => \$opt_host,
    "port=s"      => \$opt_port,
    "vm-id=i"     => \$opt_vm_id,
    "username=s"  => \$opt_username,
    "password=s"  => \$opt_password,
    "token=s"     => \$opt_token,
    "ssl!"        => \$opt_ssl,
    "help"        => \$help
) or die "Getopt failed: $!";

if ( $help ) {
    print <<HELP;

$0 [options]
QVD graphical client

--username         Login username
--password         Login password
--token            Login bearer token (used instead of password)
--host             Server to connect to
--port             Port QVD is running on
--file             Open file in VM
--ssl, --no-ssl    Enable or disable the use of SSL
--help             Shows this text
HELP
    exit(0);

}

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

set_if_arg("client.host.name", $opt_host);
set_if_arg("client.host.port", $opt_port);
set_if_arg("client.user.name", $opt_username);
set_if_arg("client.user.password", $opt_password);
set_if_arg("client.auto_connect.token", encode_base64($opt_token)) if ( defined $opt_token );
set_if_arg("client.auto_connect.vm_id", $opt_vm_id);
set_if_arg("client.use_ssl", $opt_ssl); 

if ( $opt_token && $opt_vm_id ) {
    INFO "Token and VM id provided, client will auto-connect";
    set_core_cfg("client.auto_connect", 1);
}


Wx::InitAllImageHandlers();
my $app = QVD::Client::App->new();

DEBUG("Starting main loop");
$app->MainLoop();
INFO("Exiting");

# TODO: Investigate why ordered exit from within Frame.pm ends up in SEGFAULT.
use POSIX;
POSIX::_exit(0);

sub set_if_arg {
    my ($setting, $value) = @_;

    if ( defined $value ) {
        chomp $value;

        INFO "Changing setting '$setting' to value '$value' from command line argument";
        set_core_cfg($setting, $value);
    }
}


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
