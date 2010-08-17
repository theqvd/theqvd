package QVD::Client::Frame;

use threads;
use threads::shared;
use Wx qw[:everything];
use QVD::Config;
use QVD::Client::Proxy;
use File::Spec;
use base qw(Wx::Frame);
use strict;

use constant EVT_LIST_OF_VM_LOADED	=> Wx::NewEventType;
use constant EVT_CONNECTION_ERROR	=> Wx::NewEventType;
use constant EVT_CONN_STATUS		=> Wx::NewEventType;
use constant EVT_UNKNOWN_CERT		=> Wx::NewEventType;

my $vm_id :shared;
my %connect_info :shared;
my $accept_cert :shared;

my $DEFAULT_PORT = cfg('client.host.port');
my $USE_SSL      = cfg('client.use_ssl');
my $LOGO = 'qvd-logo.png';
my $XPM = 'qvd.xpm';

sub _get_logo_path {
    my ($self, $file) = @_;

    foreach (@INC) {
	# Should we use __PACKAGE__ to infer QVD::Client?
	my $path = File::Spec->catfile($_, 'QVD', 'Client', $file);
	if (-r $path) {
	    return $path;
	}
    }
    return $file;
}

sub new {
	my( $class, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
	$parent = undef              unless defined $parent;
	$id     = -1                 unless defined $id;
	$title  = ""                 unless defined $title;
	$pos    = wxDefaultPosition  unless defined $pos;
	$size   = wxDefaultSize      unless defined $size;
	$name   = ""                 unless defined $name;

	$style = wxCAPTION|wxCLOSE_BOX
		unless defined $style;

	my $self = $class->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );

	my $panel = $self->{panel} = Wx::Panel->new($self, -1,
						    wxDefaultPosition, wxDefaultSize,
						    wxTAB_TRAVERSAL );

	my $ver_sizer  = Wx::BoxSizer->new(wxVERTICAL);

	my $logo_image;

	my ($volume, $directories, $file) = File::Spec->splitpath(File::Spec->rel2abs($0));
	if ($WINDOWS) {
	    $logo_image = $ENV{QVDPATH}."/QVD-Client/pixmaps/qvd-logo.png";
	} else {
	    $logo_image = "$volume$directories/../pixmaps/qvd-logo.png";
	    unless (-e $logo_image) {
		$logo_image = "/usr/share/pixmaps/qvd-logo.png";
	    }
	}
	$ver_sizer->Add(Wx::StaticBitmap->new($panel, -1,
					      Wx::Bitmap->new($self->_get_logo_path($LOGO),
							      wxBITMAP_TYPE_ANY)),
			0, wxLEFT|wxRIGHT|wxTOP|wxALIGN_CENTER_HORIZONTAL, 20);

	my $grid_sizer = Wx::GridSizer->new(1, 2, 0, 0);
	$ver_sizer->Add($grid_sizer, 1, wxALL|wxEXPAND, 20);

	$grid_sizer->Add(Wx::StaticText->new($panel, -1, "User"),
			 0, wxALL, 5);

	$self->{username} = Wx::TextCtrl->new($panel, -1, cfg('client.user.name'));
	$grid_sizer->Add($self->{username},
			 1, wxALL|wxEXPAND, 5);
	$self->{username}->SetFocus();
	$grid_sizer->Add(Wx::StaticText->new($panel, -1, "Password"),
			 0, wxALL, 5);
	$self->{password} = Wx::TextCtrl->new($panel, -1, "",
					      wxDefaultPosition, wxDefaultSize,
					      wxTE_PASSWORD);
	$grid_sizer->Add($self->{password},
			 1, wxALL|wxEXPAND, 5);
	$grid_sizer->Add(Wx::StaticText->new($panel, -1, "Server"),
			 0, wxALL, 5);
	$self->{host} = Wx::TextCtrl->new($panel, -1, cfg('client.host.name'));
	$grid_sizer->Add($self->{host},
			 1, wxALL|wxEXPAND, 5);

	$grid_sizer->Add(Wx::StaticText->new($panel, -1, "Connection type"),
			 0, wxALL, 5);			 
			 
	my @link_options = ("Local", "ADSL", "Modem");
	$self->{link} = Wx::Choice->new($panel, -1);
	$grid_sizer->Add($self->{link},
			 1, wxALL|wxEXPAND, 5);
	$self->{link}->AppendItems(\@link_options);
	$self->{link}->Select(0);
	# FIXME Introduce previous user selection here

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
	$icon->CopyFromBitmap(Wx::Bitmap->new($self->_get_logo_path($XPM), wxBITMAP_TYPE_ANY));
	$self->SetIcon($icon);

	$panel->SetSizer($ver_sizer);

	$ver_sizer->Fit($self);
	$self->Center;
	$self->Show(1);

	Wx::Event::EVT_BUTTON($self, $self->{connect_button}->GetId, \&OnClickConnect);
	Wx::Event::EVT_TIMER($self, -1, \&OnTimer);

	Wx::Event::EVT_COMMAND($self, -1, EVT_CONNECTION_ERROR, \&OnConnectionError);
	Wx::Event::EVT_COMMAND($self, -1, EVT_LIST_OF_VM_LOADED, \&OnListOfVMLoaded);
	Wx::Event::EVT_COMMAND($self, -1, EVT_CONN_STATUS, \&OnConnectionStatusChanged);
	Wx::Event::EVT_COMMAND($self, -1, EVT_UNKNOWN_CERT, \&OnUnknownCert);

	Wx::Event::EVT_CLOSE($self, \&OnExit);

	$self->{timer} = Wx::Timer->new($self);
	$self->{proc} = undef;
	$self->{proc_pid} = undef;
	$self->{log} = "";

	return $self;
}

sub RunWorkerThread {
    my $self = shift;
    my @args = @_;
    while (1) {
	lock(%connect_info);
	local $@;
	eval { 
	    QVD::Client::Proxy->new($self, %connect_info)->connect_to_vm();
	};
	if ($@) {
	    $self->proxy_connection_error(message => $@);
	}
	cond_wait(%connect_info);
    }
}

################################################################################
#
# QVD::Client::Proxy callbacks
#
################################################################################

sub proxy_unknown_cert {
    my $self = shift;
    my $msg :shared = $self->_shared_clone(shift);
    my $evt = new Wx::PlThreadEvent(-1, EVT_UNKNOWN_CERT, $msg);
    Wx::PostEvent($self, $evt);

    { lock $accept_cert; cond_wait $accept_cert; }
    return $accept_cert;
}

sub proxy_list_of_vm_loaded {
    my $self = shift;
    my $vm_data :shared = $self->_shared_clone(shift);
    if (@$vm_data > 1) {
	lock($vm_id);
	my $evt = new Wx::PlThreadEvent(-1, EVT_LIST_OF_VM_LOADED, $vm_data);
	Wx::PostEvent($self, $evt);
	cond_wait($vm_id);
    } elsif (@$vm_data == 1) {
	$vm_id = $vm_data->[0]{id};
    } else {
	die "You don't have any virtual machine available";
    }
    return $vm_id;
}

sub proxy_connection_status {
    my ($self, $status) = @_;
    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, EVT_CONN_STATUS, $status));
}

sub proxy_connection_error {
    my $self = shift;
    my %args = @_;
    my $message :shared = $args{message};
    my $evt = new Wx::PlThreadEvent(-1, EVT_CONNECTION_ERROR, $message);
    Wx::PostEvent($self, $evt);
}

################################################################################
#
# Wx event handlers
#
################################################################################

sub OnClickConnect {
    my( $self, $event ) = @_;
    $self->{state} = "";
    %connect_info = ( link       => cfg('client.link'),
		      audio      => cfg('client.audio.enable'),
		      printing   => cfg('client.printing.enable'),
		      geometry   => cfg('client.geometry'),
		      fullscreen => cfg('client.fullscreen'),
		      keyboard	 => $self->DetectKeyboard,
		      port       => $DEFAULT_PORT,
		      ssl	 => $USE_SSL,
		      map { $_ => $self->{$_}->GetValue } qw(host username password) );

    $connect_info{port} = $1 if $connect_info{host} =~ s/:(\d+)$//;

    $self->SaveConfiguration();

    # Start or notify worker thread
    # Will result in the execution of a loop in RunWorkerThread.
    if (!$self->{worker_thread} || !$self->{worker_thread}->is_running()) {
	@_ = (); # necessary to avoid "Scalars leaked," see perldoc Wx::Thread
	my $thr = threads->create(\&RunWorkerThread, $self);
	$thr->detach();
	$self->{worker_thread} = $thr;
    } else {
	lock(%connect_info);
	cond_signal(%connect_info);
    }
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
	    [map { 
		if ($_->{blocked}) {
		    $_->{name}." (blocked)";
		} else {
		    $_->{name};
		}
		
	    } @$vm_data],
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
	$self->Hide();
	$self->{timer}->Stop();
    } elsif ($status eq 'CLOSED') {
	$self->{timer}->Stop();
	$self->{progress_bar}->SetValue(0);
	$self->{progress_bar}->SetRange(100);
	$self->EnableControls(1);
	$self->Show;
    }
}

sub OnUnknownCert {
    my ($self, $event) = @_;
    my $evt_data = $event->GetData();
    my ($cert_pem_str, $cert_data) = @$evt_data;

    my $dialog = Wx::Dialog->new($self, undef, 'Invalid certificate');
    my $vsizer = Wx::BoxSizer->new(wxVERTICAL);

    $vsizer->Add(Wx::StaticText->new($dialog, -1, 'Certificate information:'), 0, wxALL, 5); 
    my $tc = Wx::TextCtrl->new($dialog, -1, $cert_data ? $cert_data : 'Certificate not found, maybe HKD component is not runnning at server side.', wxDefaultPosition, [400,200], wxTE_MULTILINE|wxTE_READONLY);
    $tc->SetFont (Wx::Font->new(9, wxDEFAULT, wxNORMAL, wxNORMAL, 0, 'Courier New'));
    $vsizer->Add($tc, 1, wxALL|wxEXPAND, 5);

    my $but_clicked = sub {
	lock $accept_cert;
	$accept_cert = (shift and ($cert_data ne ""));
	$dialog->Destroy();
    };
    my $bsizer = Wx::BoxSizer->new(wxHORIZONTAL);
    my $but_ok     = Wx::Button->new($dialog, -1, 'Ok');
    my $but_cancel = Wx::Button->new($dialog, -1, 'Cancel');
    Wx::Event::EVT_BUTTON($dialog, $but_ok    ->GetId, sub { $but_clicked->(1) });
    Wx::Event::EVT_BUTTON($dialog, $but_cancel->GetId, sub { $but_clicked->(0) });
    $bsizer->Add($but_ok);
    $bsizer->Add($but_cancel);
    $vsizer->Add($bsizer);

    $but_ok->SetFocus;
    $dialog->SetSizer($vsizer);
    $vsizer->Fit($dialog);

    $self->{timer}->Stop();
    $dialog->ShowModal();
    $self->{timer}->Start();

    { lock $accept_cert; cond_signal $accept_cert; }
}

sub OnTimer {
    my $self = shift;
    $self->{progress_bar}->Pulse;
}

sub OnExit {
    my $self = shift;
    $self->Destroy();
}

################################################################################
#
# Helpers
#
################################################################################

sub DetectKeyboard {
    if ($^O eq 'MSWin32') {
	require Win32::API;

	my $gkln = Win32::API->new ('user32', 'GetKeyboardLayoutName', 'P', 'I');
	my $str = ' ' x 8;
	$gkln->Call ($str);

	my $k = substr $str, -4;
	my $layout = $lang_codes{$k} // 'es';

	## use a hardcoded 'pc105' since windows doesn't seem to have the notion of keyboard model
	return "pc105/$layout";

    } else {
	require X11::Protocol;

	my $x11 = X11::Protocol->new;
	my ($raw) = $x11->GetProperty ($x11->root, $x11->atom ('_XKB_RULES_NAMES'), 'AnyPropertyType', 0, 4096, 0);
	my ($rules, $model, $layout, $variant, $options) = split /\x00/, $raw;

	## these may be comma-separated values, pick the first element
	($layout, $variant) = map { (split /,/)[0] // '' } $layout, $variant;

	return "$model/$layout";
    }
}

sub EnableControls {
    my ($self, $enabled) = @_;
    $self->{$_}->Enable($enabled) for qw(connect_button host username password link);
}

sub SaveConfiguration {
    my $self = shift;
    set_core_cfg('client.user.name', $self->{username}->GetValue());
    set_core_cfg('client.host.name', $self->{host}->GetValue());
    #set_core_cfg('client.host.port', $self->{port}->GetValue());
    set_core_cfg('client.link', lc($self->{link}->GetStringSelection()));
        
    #set_core_cfg('client.audio.enable', $self->{audio}->GetValue());
    #set_core_cfg('client.printing.enable', $self->{printing}->GetValue());
    #set_core_cfg('client.fullscreen', $self->{fullscreen}->GetValue());
    #set_core_cfg('client.geometry', $self->{geometry}->GetValue());

    local $@;
    eval {
	my $qvd_dir = ($ENV{HOME} || $ENV{APPDATA}).'/.qvd';
	mkdir $qvd_dir unless -e $qvd_dir;
	save_core_cfg($qvd_dir.'/client.conf');
    };
    if ($@) {
	my $message = $@;
	my $dialog = Wx::MessageDialog->new($self, $message, 
	    "Error saving configuration", wxOK | wxICON_ERROR);
	$dialog->ShowModal();
	$dialog->Destroy();
    }
}

# threads::shared doesn't have shared_clone on Ubuntu 9.10
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

1;
