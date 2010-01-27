#!/usr/bin/perl
# To get wxPerl visit http://wxPerl.sourceforge.net/

use threads;
use threads::shared;
use Wx 0.15 qw[:allclasses];
use strict;
use warnings;

package MyFrame;

use threads;
use threads::shared;
use Wx qw[:everything];
use QVD::HTTP::StatusCodes qw(:status_codes);
use QVD::HTTPC;
use IO::Handle;
use IO::Socket::Forwarder qw(forward_sockets);
use JSON;
use base qw(Wx::Frame);
use strict;

my $EVT_LIST_OF_VM_LOADED :shared = Wx::NewEventType;
my $EVT_CONNECTION_ERROR :shared = Wx::NewEventType;
my $EVT_CONNECTING_TO_VM :shared = Wx::NewEventType;
my $EVT_CONNECTED_TO_VM :shared = Wx::NewEventType;
my $EVT_CONNECTION_CLOSED :shared = Wx::NewEventType;

my $httpc_thread_lock :shared;
my $vm_id :shared;

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
	$self->{host} = Wx::TextCtrl->new($panel, -1, "localhost");
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

	Wx::Event::EVT_BUTTON($self, $self->{connect_button}->GetId, \&OnClickConnect);
	Wx::Event::EVT_TIMER($self, -1, \&OnTimer);

	Wx::Event::EVT_COMMAND($self, -1, $EVT_CONNECTION_ERROR, \&OnConnectionError);
	Wx::Event::EVT_COMMAND($self, -1, $EVT_LIST_OF_VM_LOADED, \&OnListOfVMLoaded);
	Wx::Event::EVT_COMMAND($self, -1, $EVT_CONNECTING_TO_VM, \&OnConnectingToVM);
	Wx::Event::EVT_COMMAND($self, -1, $EVT_CONNECTED_TO_VM, \&OnConnectedToVM);
	Wx::Event::EVT_COMMAND($self, -1, $EVT_CONNECTION_CLOSED, \&OnConnectionClosed);

	$self->{timer} = Wx::Timer->new($self);
	$self->{proc} = undef;
	$self->{proc_pid} = undef;
	$self->{log} = "";

	return $self;
}

sub OnClickConnect {
    my( $self, $event ) = @_;
    $self->{state} = "";
    #$self->{$_}->SetEnabled(0) for (qw(username password host));

    #my @cmd = (qw(perl -Mlib::glob=*/lib QVD-Client/bin/qvd-client.pl),
    #           map $self->{$_}->GetValue, qw(username password host));

    ## FIXME, properly escape arguments.  We don't want the user to
    ## write ";rm -Rf ~/" on some field and get it executed by the
    ## shell!
    ## Does Wx support something execve(2) alike?
    #my $cmd = join(" ", @cmd);
    #print STDERR "running cmd: $cmd\n";
    #$self->{proc} = Wx::Process::Open($cmd);
    #$self->{proc}->Redirect;
    #$self->{proc_pid} = $self->{proc}->GetPid;

    my ($host, $user, $passwd) = map { $self->{$_}->GetValue } qw(host username password);
    @_ = ();
    $self->{httpc_thread} = threads->create(\&GetListOfVM, $self, $host, $user, $passwd);
}

sub _shared_clone {
    my ($self, $ref) = @_;
    my $type = ref $ref;
    if ($type eq 'ARRAY') {
	my @arr :shared = map { $self->_shared_clone($_); } @$ref;
	return \@arr;
    } elsif ($type eq 'HASH') {
	my %hash :shared;
	while (my ($k, $v) = each %$ref) {
	    $hash{$k} = $self->_shared_clone($v);
	}
	return \%hash;
    } else {
	return ${share $ref};
    }
}

sub GetListOfVM {
    my ($self, $host, $user, $passwd) = @_;
    my $port = 8443;

    use MIME::Base64 qw(encode_base64);
    my $auth = encode_base64("$user:$passwd", '');

    my $httpc = eval { new QVD::HTTPC("$host:$port", SSL => 1) };
    if ($@) {
	my $message :shared = $@;
	my $evt = new Wx::PlThreadEvent(-1, $EVT_CONNECTION_ERROR, $message);
	Wx::PostEvent($self, $evt);
	return;
    }

    $httpc->send_http_request(GET => '/qvd/list_of_vm', 
	headers => [
	"Authorization: Basic $auth",
	"Accept: application/json"
	]);

    my ($code, $msg, $response_headers, $body) = $httpc->read_http_response();
    use Data::Dumper;
    print Dumper [$code, $msg, $response_headers, $body];
    if ($code != HTTP_OK) {
	my $message :shared = "$host replied with $msg";
	my $evt = new Wx::PlThreadEvent(-1, $EVT_CONNECTION_ERROR, $message);
	Wx::PostEvent($self, $evt);
	return;
    }

    my $json = JSON->new->ascii->pretty;
    my $vm_data :shared = $self->_shared_clone($json->decode($body));

    {
	lock($httpc_thread_lock);
	my $evt = new Wx::PlThreadEvent(-1, $EVT_LIST_OF_VM_LOADED, $vm_data);
	Wx::PostEvent($self, $evt);
	cond_wait($httpc_thread_lock);
    }

    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, $EVT_CONNECTING_TO_VM, ''));

    $httpc->send_http_request(GET => '/qvd/connect_to_vm?id='.$vm_id,
	headers => [
	"Authorization: Basic $auth",
	'Connection: Upgrade',
	'Upgrade: QVD/1.0',
	]);

    while (1) {
	my ($code, $msg, $headers, $body) = $httpc->read_http_response;
	if ($code == HTTP_SWITCHING_PROTOCOLS) {
	    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, $EVT_CONNECTED_TO_VM, ''));
	    my $ll = IO::Socket::INET->new(LocalPort => 4040,
		ReuseAddr => 1,
		Listen => 1);

	    # FIXME NX_CLIENT is used for showing the user information on things
	    # like broken connection, perhaps we should show them to the user
	    # instead of ignoring them? 
	    $ENV{NX_CLIENT} = '/bin/false';
	    # XXX: make media port configurable (4713 for pulseaudio)
	    system "nxproxy -S localhost:40 media=4713 &";
	    my $s1 = $ll->accept()
		or die "connection from nxproxy failed";
	    undef $ll; # close the listening socket
	    my $s2 = $httpc->get_socket;
	    forward_sockets($s1, $s2); # , debug => 1);
	    last;
	}
	elsif ($code >= 100 and $code < 200) {
	    print "$code\ncontinuing...\n"
	}
	else {
	    my $message :shared = "Unable to connect to remote vm: $code $msg";
	    my $evt = new Wx::PlThreadEvent(-1, $EVT_CONNECTION_ERROR, $message);
	    Wx::PostEvent($self, $evt);
	    return;
	}
    }
    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, $EVT_CONNECTION_CLOSED, ''));
}

sub OnConnectionError {
    my ($self, $event) = @_;
    my $message = $event->GetData;
    new Wx::MessageDialog($self, $message, "Error de conexión",
			    wxOK | wxICON_ERROR)->ShowModal;
    $self->{httpc_thread}->join();
}

sub OnListOfVMLoaded {
    my ($self, $event) = @_;
    my $vm_data = $event->GetData;
    {
	lock($httpc_thread_lock);
	my $dialog = new Wx::SingleChoiceDialog(
	    $self, 
	    "Seleccionar máquina virtual:", 
	    "Seleccionar máquina virtual", 
	    [map { $_->{name} } @$vm_data],
	    [map { $_->{id} } @$vm_data]
	);
	$dialog->ShowModal();
	$vm_id = $dialog->GetSelectionClientData();

	cond_signal($httpc_thread_lock);
    }
}

sub OnConnectingToVM {
    my ($self, $event) = @_;
    $self->{timer}->Start(100, 0);
}

sub OnConnectedToVM {
    my ($self, $event) = @_;
    $self->{timer}->Stop();
    $self->Hide();
}

sub OnConnectionClosed {
    my ($self, $event) = @_;
    $self->{progress_bar}->SetValue(0);
    $self->{progress_bar}->SetRange(100);
    $self->Show;
}

sub OnTimer {
    my $self = shift;
    $self->{progress_bar}->Pulse;
    #if (Wx::Process::Exists($self->{proc_pid})) {
    #    while ($self->{proc}->IsInputAvailable) {
    #        my $response = "";
    #        my $bytesread = $self->{proc}->GetInputStream->read($response, 1000,0);
    #        if (defined ($bytesread) and ($bytesread != 0)) {
    #    	print STDERR $response;
    #    	$self->{log} .= $response;
    #    	for (reverse split /\r?\n/, $self->{log}) {
    #    	    if (my ($status) = m/X-QVD-VM-Status:(.*)/) {
    #    		print "Status: $status\n";
    #    		$self->Hide if $status =~ /\bConnected\b/;
    #    		last;
    #    	    }
    #    	}
    #        }
    #    }
    #} else {
    #    print STDERR "child exited\n";
    #    $self->{timer}->Stop;
    #    $self->{progress_bar}->SetValue(0);
    #    $self->{progress_bar}->SetRange(100);
    #    $self->{$_}->SetEditable(1) for (qw(username password host));
    #    $self->Show;
    #}
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
