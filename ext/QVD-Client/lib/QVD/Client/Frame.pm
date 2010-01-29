package QVD::Client::Frame;

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
my $EVT_CONN_STATUS :shared = Wx::NewEventType;

my $vm_id :shared;

sub new {
	my( $class, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

	$style = wxICONIZE|wxCAPTION|wxMINIMIZE|wxCLOSE_BOX
		unless defined $style;

	my $self = $class->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );

	my $panel = $self->{panel} = Wx::Panel->new($self, -1,
						    wxDefaultPosition, wxDefaultSize,
						    wxTAB_TRAVERSAL );

	my $ver_sizer  = Wx::BoxSizer->new(wxVERTICAL);

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

	$panel->SetSizer($ver_sizer);

	$ver_sizer->Fit($self);
	$self->Center;
	$self->Show(1);

	Wx::Event::EVT_BUTTON($self, $self->{connect_button}->GetId, \&OnClickConnect);
	Wx::Event::EVT_TIMER($self, -1, \&OnTimer);

	Wx::Event::EVT_COMMAND($self, -1, $EVT_CONNECTION_ERROR, \&OnConnectionError);
	Wx::Event::EVT_COMMAND($self, -1, $EVT_LIST_OF_VM_LOADED, \&OnListOfVMLoaded);
	Wx::Event::EVT_COMMAND($self, -1, $EVT_CONN_STATUS, \&OnConnectionStatusChanged);

	$self->{timer} = Wx::Timer->new($self);
	$self->{proc} = undef;
	$self->{proc_pid} = undef;
	$self->{log} = "";

	return $self;
}

sub OnClickConnect {
    my( $self, $event ) = @_;
    $self->{state} = "";
    my ($host, $user, $passwd) = map { $self->{$_}->GetValue } qw(host username password);
    @_ = ();
    $self->{httpc_thread} = threads->create(\&ConnectToVM, $self, $host, $user, $passwd);
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

sub ConnectToVM {
    my ($self, $host, $user, $passwd) = @_;
    my $port = 8443;

    use MIME::Base64 qw(encode_base64);
    my $auth = encode_base64("$user:$passwd", '');

    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, $EVT_CONN_STATUS, 'CONNECTING'));
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
    if ($code != HTTP_OK) {
	my $message :shared = "$host replied with $msg";
	my $evt = new Wx::PlThreadEvent(-1, $EVT_CONNECTION_ERROR, $message);
	Wx::PostEvent($self, $evt);
	return;
    }

    my $json = JSON->new->ascii->pretty;
    my $vm_data :shared = $self->_shared_clone($json->decode($body));

    if (@$vm_data > 1) {
	lock($vm_id);
	my $evt = new Wx::PlThreadEvent(-1, $EVT_LIST_OF_VM_LOADED, $vm_data);
	Wx::PostEvent($self, $evt);
	cond_wait($vm_id);
    } else {
	$vm_id = $vm_data->[0]{id};
    }

    $httpc->send_http_request(GET => '/qvd/connect_to_vm?id='.$vm_id,
	headers => [
	"Authorization: Basic $auth",
	'Connection: Upgrade',
	'Upgrade: QVD/1.0',
	]);

    while (1) {
	my ($code, $msg, $headers, $body) = $httpc->read_http_response;
	if ($code == HTTP_SWITCHING_PROTOCOLS) {
	    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, $EVT_CONN_STATUS, 'CONNECTED'));
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
    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, $EVT_CONN_STATUS, 'CLOSED'));
}

sub OnConnectionError {
    my ($self, $event) = @_;
    $self->{timer}->Stop();
    $self->{progress_bar}->SetValue(0);
    $self->{progress_bar}->SetRange(100);
    my $message = $event->GetData;
    new Wx::MessageDialog($self, $message, "Error de conexión",
			    wxOK | wxICON_ERROR)->ShowModal;
    $self->{httpc_thread}->join();
}

sub OnListOfVMLoaded {
    my ($self, $event) = @_;
    my $vm_data = $event->GetData;
    {
	lock($vm_id);
	my $dialog = new Wx::SingleChoiceDialog(
	    $self, 
	    "Seleccionar máquina virtual:", 
	    "Seleccionar máquina virtual", 
	    [map { $_->{name} } @$vm_data],
	    [map { $_->{id} } @$vm_data]
	);
	$self->{timer}->Stop();
	$dialog->ShowModal();
	$vm_id = $dialog->GetSelectionClientData();
	$self->{timer}->Start();

	cond_signal($vm_id);
    }
}


sub OnConnectionStatusChanged {
    my ($self, $event) = @_;
    my $status = $event->GetData();
    if ($status eq 'CONNECTING') {
	$self->{timer}->Start(50, 0);
    } elsif ($status eq 'CONNECTED') {
	$self->{timer}->Stop();
	$self->{progress_bar}->SetValue(0);
	$self->{progress_bar}->SetRange(100);
	$self->Hide();
    } elsif ($status eq 'CLOSED') {
	$self->{httpc_thread}->join();
	$self->Show;
    }
}

sub OnTimer {
    my $self = shift;
    $self->{progress_bar}->Pulse;
}


1;
