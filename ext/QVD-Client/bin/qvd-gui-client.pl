#!/usr/bin/perl
# To get wxPerl visit http://wxPerl.sourceforge.net/

use Wx 0.15 qw[:allclasses];
use strict;
use warnings;

package MyFrame;

use Wx qw[:everything];
use IO::Handle;
use base qw(Wx::Frame);
use strict;

sub new {
	my( $class, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

# begin wxGlade: MyFrame::new

	$style = wxICONIZE|wxCAPTION|wxMINIMIZE|wxCLOSE_BOX
		unless defined $style;

	my $self = $class->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );

	my $panel = $self->{panel} = Wx::Panel->new($self, -1,
						    wxDefaultPosition, wxDefaultSize,
						    wxTAB_TRAVERSAL );

	my $ver_sizer  = Wx::BoxSizer->new(wxVERTICAL);
	# $self->SetSizer($ver_sizer);

	# FIXME Hardcoded path!
	# logo image
	$ver_sizer->Add(Wx::StaticBitmap->new($panel, -1,
					      Wx::Bitmap->new("QVD-Client/bin/qvd-logo.png",
							      wxBITMAP_TYPE_ANY)),
			0, wxLEFT|wxRIGHT|wxTOP|wxALIGN_CENTER_HORIZONTAL, 20);

	my $grid_sizer = Wx::GridSizer->new(1, 2, 0, 0);
	$ver_sizer->Add($grid_sizer, 1, wxALL|wxEXPAND, 20);

	$grid_sizer->Add(Wx::StaticText->new($panel, -1, "Usuario"),
			 0, wxALL, 5);

	$self->{username} = Wx::TextCtrl->new($panel, -1, "qvd");
	$grid_sizer->Add($self->{username},
			 1, wxALL|wxEXPAND, 5);
	$self->{username}->SetFocus();
	$grid_sizer->Add(Wx::StaticText->new($panel, -1, "Contraseña"),
			 0, wxALL, 5);
	$self->{password} = Wx::TextCtrl->new($panel, -1, "passw0rd",
					      wxDefaultPosition, wxDefaultSize,
					      wxTE_PASSWORD);
	$grid_sizer->Add($self->{password},
			 1, wxALL|wxEXPAND, 5);
	$grid_sizer->Add(Wx::StaticText->new($panel, -1, "Servidor"),
			 0, wxALL, 5);
	$self->{host} = Wx::TextCtrl->new($panel, -1, "aguila");
	$grid_sizer->Add($self->{host},
			 1, wxALL|wxEXPAND, 5);

	# port goes here!
	$self->{connect_button} = Wx::Button->new($panel, -1, "Conectar");
	$ver_sizer->Add($self->{connect_button},
			0, wxLEFT|wxRIGHT|wxBOTTOM|wxEXPAND, 20);
	$self->{connect_button}->SetDefault;

	$self->{progress_bar} = Wx::Gauge->new($panel, -1, 100,
					       wxDefaultPosition, wxDefaultSize,
					       wxGA_HORIZONTAL|wxGA_SMOOTH);
	$self->{progress_bar}->SetValue(0);
	$ver_sizer->Add($self->{progress_bar},
			 0, wxEXPAND, 0);

	$self->SetTitle("QVD");
	my $icon = Wx::Icon->new();
	# FIXME Hardcoded path!
	$icon->CopyFromBitmap(Wx::Bitmap->new("QVD-Client/bin/qvd.xpm", wxBITMAP_TYPE_ANY));
	$self->SetIcon($icon);

	# $panel->SetAutoLayout(1);
	$panel->SetSizer($ver_sizer);

	$ver_sizer->Fit($self);
	$self->Center;
	$self->Show(1);


	Wx::Event::EVT_BUTTON($self, $self->{connect_button}->GetId, \&OnClick);
	Wx::Event::EVT_TIMER($self, -1, \&OnTimer);

	$self->{timer} = Wx::Timer->new($self);
	$self->{proc} = undef;
	$self->{proc_pid} = undef;
	$self->{log} = "";

	return $self;
}

sub OnClick {
    my( $self, $event ) = @_;
    $self->{state} = "";
    $self->{$_}->SetEditable(0) for (qw(username password host));

    my @cmd = (qw(perl -Mlib::glob=*/lib QVD-Client/bin/qvd-client.pl),
	       map $self->{$_}->GetValue, qw(username password host));

    # FIXME, properly escape arguments.  We don't want the user to
    # write ";rm -Rf ~/" on some field and get it executed by the
    # shell!
    # Does Wx support something execve(2) alike?
    my $cmd = join(" ", @cmd);
    print STDERR "running cmd: $cmd\n";
    $self->{proc} = Wx::Process::Open($cmd);
    $self->{proc}->Redirect;
    $self->{proc_pid} = $self->{proc}->GetPid;
    $self->{timer}->Start(100, 0);
}

sub OnTimer {
    my $self = shift;
    $self->{progress_bar}->Pulse;
    if (Wx::Process::Exists($self->{proc_pid})) {
	while ($self->{proc}->IsInputAvailable) {
	    my $response = "";
	    my $bytesread = $self->{proc}->GetInputStream->read($response, 1000,0);
	    if (defined ($bytesread) and ($bytesread != 0)) {
		print STDERR $response;
		$self->{log} .= $response;
		for (reverse split /\r?\n/, $self->{log}) {
		    # print STDERR "line: >$_<\n";
		    if (my ($status) = m/X-QVD-VM-Status:(.*)/) {
			print "Status: $status\n";
			$self->Hide if $status =~ /\bConnected\b/;
			last;
		    }
		}
	    }
	}
    } else {
	print STDERR "child exited\n";
	$self->{timer}->Stop;
	$self->{progress_bar}->SetValue(0);
	$self->{progress_bar}->SetRange(100);
	$self->{$_}->SetEditable(1) for (qw(username password host));
	$self->Show;
    }
}


# end of class MyFrame

package main;

local *Wx::App::OnInit = sub{1};
my $app = Wx::App->new();
Wx::InitAllImageHandlers();

my $frame = MyFrame->new();

$app->SetTopWindow($frame);
$app->MainLoop();


__END__

=head1 NAME

qvd-gui-client.pl

=head1 DESCRIPTION

probe of concept graphic client for the new QVD

=cut
