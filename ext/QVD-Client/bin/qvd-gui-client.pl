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

qvd-gui-client.pl

=head1 DESCRIPTION

Proof of concept GUI QVD-client

=cut
