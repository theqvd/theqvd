package QVD::Client::Frame;

use threads;
use threads::shared;
use Wx qw[:everything];
use QVD::HTTP::StatusCodes qw(:status_codes);
use IO::Handle;
use IO::Socket::Forwarder qw(forward_sockets);
use JSON;
use base qw(Wx::Frame);
use strict;

my $EVT_LIST_OF_VM_LOADED :shared = Wx::NewEventType;
my $EVT_CONNECTION_ERROR :shared = Wx::NewEventType;
my $EVT_CONN_STATUS :shared = Wx::NewEventType;

my $vm_id :shared;
my %connect_info :shared;

my $DEFAULT_PORT = 8443;

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

	$grid_sizer->Add(Wx::StaticText->new($panel, -1, "User"),
			 0, wxALL, 5);

	$self->{username} = Wx::TextCtrl->new($panel, -1, "qvd");
	$grid_sizer->Add($self->{username},
			 1, wxALL|wxEXPAND, 5);
	$self->{username}->SetFocus();
	$grid_sizer->Add(Wx::StaticText->new($panel, -1, "Password"),
			 0, wxALL, 5);
	$self->{password} = Wx::TextCtrl->new($panel, -1, "passw0rd",
					      wxDefaultPosition, wxDefaultSize,
					      wxTE_PASSWORD);
	$grid_sizer->Add($self->{password},
			 1, wxALL|wxEXPAND, 5);
	$grid_sizer->Add(Wx::StaticText->new($panel, -1, "Server"),
			 0, wxALL, 5);
	$self->{host} = Wx::TextCtrl->new($panel, -1, "localhost");
	$grid_sizer->Add($self->{host},
			 1, wxALL|wxEXPAND, 5);

	# port goes here!
	$self->{connect_button} = Wx::Button->new($panel, -1, "Connect");
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
    %connect_info = map { $_ => $self->{$_}->GetValue } qw(host username password);
    $connect_info{port} = $DEFAULT_PORT;
    if (!$self->{worker_thread} || !$self->{worker_thread}->is_running()) {
	@_ = ();
	my $thr = threads->create(\&RunWorkerThread, $self);
	$thr->detach();
	$self->{worker_thread} = $thr;
    } else {
	lock(%connect_info);
	cond_signal(%connect_info);
    }
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

sub RunWorkerThread {
    my $self = shift;
    my @args = @_;
    while (1) {
	lock(%connect_info);
	local $@;
	eval { $self->ConnectToVM(@args) };
	if ($@) {
	    my $evt = new Wx::PlThreadEvent(-1, $EVT_CONNECTION_ERROR, $@);
	    Wx::PostEvent($self, $evt);
	}
	cond_wait(%connect_info);
    }
}

sub ConnectToVM {
    my $self = shift;
    my ($host, $port, $user, $passwd) = @connect_info{qw/host port username password/};

    use MIME::Base64 qw(encode_base64);
    my $auth = encode_base64("$user:$passwd", '');

    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, $EVT_CONN_STATUS, 'CONNECTING'));
    require QVD::HTTPC;
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
	my $message :shared;
	if ($code == HTTP_UNAUTHORIZED) {
	    $message = "The server has rejected your login. Please verify that your username and password are correct.";
	}
        $message ||= "$host replied with $msg";
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
	elsif ($code == HTTP_PROCESSING) {
	    # Server is starting the virtual machine and connecting to the VMA
	}
	else {
	    # Fatal error
	    my $message :shared;
	    if ($code == HTTP_NOT_FOUND) {
		$message = "Your virtual machine does not exist any more.";
	    } elsif ($code == HTTP_UPGRADE_REQUIRED) {
		$message = "The server requires a more up-to-date client version.";
	    } elsif ($code == HTTP_UNAUTHORIZED) {
		$message = "Login error. Please verify your user and password.";
	    } elsif ($code == HTTP_BAD_GATEWAY) {
		$message = "Server error: ".$body;
	    }
	    $message ||= "Unable to connect to remote vm: $code $msg";
	    my $evt = new Wx::PlThreadEvent(-1, $EVT_CONNECTION_ERROR, $message);
	    Wx::PostEvent($self, $evt);
	    last;
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
    my $dialog = Wx::MessageDialog->new($self, $message, "Connection error.",
			    wxOK | wxICON_ERROR);
    $dialog->ShowModal();
    $dialog->Destroy();
    $self->EnableControls(1);
}

sub OnListOfVMLoaded {
    my ($self, $event) = @_;
    my $vm_data = $event->GetData;
    {
	lock($vm_id);
	my $dialog = new Wx::SingleChoiceDialog(
	    $self, 
	    "Select virtual machine:", 
	    "Select virtual machine", 
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
	$self->EnableControls(0);
	$self->{timer}->Start(50, 0);
    } elsif ($status eq 'CONNECTED') {
	$self->{timer}->Stop();
	$self->{progress_bar}->SetValue(0);
	$self->{progress_bar}->SetRange(100);
	$self->Hide();
    } elsif ($status eq 'CLOSED') {
	$self->EnableControls(1);
	$self->Show;
    }
}

sub EnableControls {
    my ($self, $enabled) = @_;
    $self->{$_}->Enable($enabled) for qw(connect_button host username password);
}

sub OnTimer {
    my $self = shift;
    $self->{progress_bar}->Pulse;
}

1;
