package QVD::Client::Frame;

use threads;
use threads::shared;
use Wx qw[:everything];
use QVD::Config::Core;
use QVD::Client::Proxy;
use base qw(Wx::Frame);
use strict;
use QVD::Log;

use constant EVT_LIST_OF_VM_LOADED => Wx::NewEventType;
use constant EVT_CONNECTION_ERROR  => Wx::NewEventType;
use constant EVT_CONN_STATUS       => Wx::NewEventType;
use constant EVT_UNKNOWN_CERT      => Wx::NewEventType;
use constant EVT_SET_ENVIRONMENT   => Wx::NewEventType;

my $vm_id :shared;
my %connect_info :shared;
my $accept_cert :shared;
my $set_env :shared;

my $DEFAULT_PORT = core_cfg('client.host.port');
my $USE_SSL      = core_cfg('client.use_ssl');

my $WINDOWS = ($^O eq 'MSWin32');
my $DARWIN = ($^O eq 'darwin');

## adapted from the VB code at: 
## http://o-st.chat.ru/vb/keyboard/def_rask/def_rask.htm 
my %lang_codes = qw/
    0436 af        0004 zh        080C fr-be     0414 no        300A es-ec
    0419 ru        0404 zh-tw     0C0C fr-ca     0814 no        340A es-cl
    0409 en-us     0804 zh-cn     100C fr-ch     0415 pl        380A es-uy
    041C sq        0C04 zh-hk     140C fr-lu     0416 pt-br     3C0A es-py
    0001 ar        1004 zh-sg     043C gd        0816 pt        400A es-bo
    0401 ar-sa     041A hr        0407 de        0417 rm        440A es-sv
    0801 ar-iq     0405 cs        0807 de-ch     0418 ro        480A es-hn
    0C01 ar-eg     0406 da        0C07 de-at     0818 ro-mo     4C0A es-ni
    1001 ar-ly     0413 nl        1007 de-lu     0819 ru-mo     500A es-pr
    1401 ar-dz     0813 nl-be     1407 de-li     0C1A sr        0430 sx
    1801 ar-ma     0009 en        0408 el        081A sr        041D sv
    1C01 ar-tn     0809 en-gb     040D he        041B sk        081D sv-fi
    2001 ar-om     0C09 en-au     0439 hi        0424 sl        041E th
    2401 ar-ye     1009 en-ca     040E hu        042E sb        0431 ts
    2801 ar-sy     1409 en-nz     040F is        040A es        0432 tn
    2C01 ar-jo     1809 en-ie     0421 in        080A es-mx     041F tr
    3001 ar-lb     1C09 en-za     0410 it        0C0A es        0422 uk
    3401 ar-kw     2009 en-jm     0810 it-ch     100A es-gt     0420 ur
    3801 ar-ae     2809 en-bz     0411 ja        140A es-cr     042A vi
    3C01 ar-bh     2C09 en-tt     0412 ko        180A es-pa     0434 xh
    4001 ar-qa     0425 et        0426 lv        1C0A es-do     043D ji
    042D eu        0438 fo        0427 lt        200A es-ve     0435 zu
    0402 bg        0429 fa        042F mk        240A es-co
    0423 be        040B fi        043E ms        280A es-pe
    0403 ca        040C fr        043A mt        2C0A es-ar
/;

sub new {
    my( $class, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
    $parent = undef              unless defined $parent;
    $id     = -1                 unless defined $id;
    $title  = ""                 unless defined $title;
    $pos    = wxDefaultPosition  unless defined $pos;
    $size   = wxDefaultSize      unless defined $size;
    $name   = ""                 unless defined $name;

    $style = wxCAPTION|wxCLOSE_BOX|wxSYSTEM_MENU|wxMINIMIZE_BOX
        unless defined $style;

    my $self = $class->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );

    my $panel = $self->{panel} = Wx::Panel->new($self, -1, wxDefaultPosition, wxDefaultSize, wxTAB_TRAVERSAL );

    my $ver_sizer  = Wx::BoxSizer->new(wxVERTICAL);

    my $bm_logo_big = Wx::Bitmap->new(File::Spec->join($QVD::Client::App::pixmaps_dir, 'qvd-big.png'),
                                      wxBITMAP_TYPE_ANY);
    $ver_sizer->Add( Wx::StaticBitmap->new($panel, -1, $bm_logo_big),
                     0, wxLEFT|wxRIGHT|wxTOP|wxALIGN_CENTER_HORIZONTAL, 20 );

    my $grid_sizer = Wx::GridSizer->new(1, 2, 0, 0);
    $ver_sizer->Add($grid_sizer, 1, wxALL|wxEXPAND, 20);

    $grid_sizer->Add(Wx::StaticText->new($panel, -1, "User"), 0, wxALL, 5);
    $self->{username} = Wx::TextCtrl->new($panel, -1, core_cfg('client.user.name'));
    $grid_sizer->Add($self->{username}, 1, wxALL|wxEXPAND, 5);

    $grid_sizer->Add(Wx::StaticText->new($panel, -1, "Password"), 0, wxALL, 5);
    $self->{password} = Wx::TextCtrl->new($panel, -1, "", wxDefaultPosition, wxDefaultSize, wxTE_PASSWORD);
    $grid_sizer->Add($self->{password}, 0, wxALL|wxEXPAND, 5);

    length core_cfg('client.user.name') ? $self->{password}->SetFocus() : $self->{username}->SetFocus();

    if (core_cfg('client.show.remember_password')) {
        $grid_sizer->Add(Wx::StaticText->new($panel, -1, "Remember password"), 0, wxALL, 5);
        $self->{remember_pass} = Wx::CheckBox->new ($panel, -1, '', wxDefaultPosition);
        $self->{remember_pass}->SetValue(core_cfg('client.remember_password') ? 1 : 0);
        $grid_sizer->Add($self->{remember_pass}, 1, wxALL, 5);
    }

    if (!core_cfg('client.force.host.name', 0)) {
        $grid_sizer->Add(Wx::StaticText->new($panel, -1, "Server"), 0, wxALL, 5);
        $self->{host} = Wx::TextCtrl->new($panel, -1, core_cfg('client.host.name'));
        $grid_sizer->Add($self->{host}, 1, wxALL|wxEXPAND, 5);
    }

    if (!core_cfg('client.force.link', 0)) {
        $grid_sizer->Add(Wx::StaticText->new($panel, -1, "Connection type"), 0, wxALL, 5);             
        my @link_options = ("Local", "ADSL", "Modem");
        $self->{link} = Wx::Choice->new($panel, -1);
        $grid_sizer->Add($self->{link}, 1, wxALL|wxEXPAND, 5);
        $self->{link}->AppendItems(\@link_options);

	my $link_select; 
	if ( core_cfg('client.link') eq "lan" || core_cfg('client.link') eq "local") {
		$link_select = 0 ; 
	}
	elsif ( core_cfg('client.link') eq "adsl" || core_cfg('client.link') eq "wan" ) {
		$link_select = 1 ; 
	}
	elsif ( core_cfg('client.link') eq "modem" || core_cfg('client.link') eq "isdn") {
		$link_select = 2; 
	}
	else {
		$link_select = 1; 
	}	
        $self->{link}->Select($link_select);
    }

    if ($DARWIN && !core_cfg('client.darwin.screen_resolution.verified')) {
	my @min_res = split(/x/, core_cfg('client.darwin.screen_resolution.min'));
	my $res_ok;

	DEBUG "Verifying screen resolution on Darwin. Min resolution is " . join('x', @min_res);

        foreach my $res ( get_osx_resolutions() ) {
	    DEBUG "Found screen with " . join('x', @$res) . " resolution";

	    if ( $res->[0] >= $min_res[0] && $res->[1] >= $min_res[1] ) {
	        DEBUG "This resolution is good";
	        $res_ok=1;
		last;
	    } else {
                DEBUG "This resolution is too low";
            }
	}

	if ( !$res_ok ) {
		DEBUG "Only low resolution displays were found, defaulting to low res geometry";
		set_core_cfg('client.geometry', core_cfg('client.darwin.screen_resolution.low_res_geometry'));
	} else {
		DEBUG "High resolution display found";
	}

	set_core_cfg('client.darwin.screen_resolution.verified', 1);
    }

    # port goes here!
    $self->{connect_button} = Wx::Button->new($panel, -1, "Connect");
    $ver_sizer->Add($self->{connect_button}, 0, wxLEFT|wxRIGHT|wxBOTTOM|wxEXPAND, 20);
    $self->{connect_button}->SetDefault;

    $self->{progress_bar} = Wx::Gauge->new($panel, -1, 100, wxDefaultPosition, wxDefaultSize, wxGA_HORIZONTAL|wxGA_SMOOTH);
    $self->{progress_bar}->SetValue(0);
    $ver_sizer->Add($self->{progress_bar}, 0, wxEXPAND, 0);

    $self->SetTitle("QVD");
    my $icon = Wx::Icon->new();
    my $bm_logo_small = Wx::Bitmap->new(File::Spec->join($QVD::Client::App::pixmaps_dir, 'qvd-small.png'),
                                        wxBITMAP_TYPE_ANY);
    $icon->CopyFromBitmap($bm_logo_small);
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
    Wx::Event::EVT_COMMAND($self, -1, EVT_SET_ENVIRONMENT, \&OnSetEnvironment);

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
            my $msg = $@;
            ERROR "Unable to connect to VM: $msg";
            $self->proxy_connection_error(message => $msg);
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

sub proxy_set_environment {
    my $self = shift;
    my %args = @_;
    my $shared_args :shared = $self->_shared_clone(\%args);

    lock($set_env);
    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, EVT_SET_ENVIRONMENT, $shared_args));
    cond_wait($set_env);
}



################################################################################
#
# Wx event handlers
#
################################################################################

sub OnClickConnect {
    my( $self, $event ) = @_;
    $self->{state} = "";
    %connect_info = (
        link          => core_cfg('client.force.link', 0) // core_cfg('client.link'),
        audio         => core_cfg('client.audio.enable'),
        printing      => core_cfg('client.printing.enable'),
        geometry      => core_cfg('client.geometry'),
        fullscreen    => core_cfg('client.fullscreen'),
        keyboard      => $self->DetectKeyboard,
        port          => $DEFAULT_PORT,
        ssl           => $USE_SSL,
        host          => core_cfg('client.force.host.name', 0) // $self->{host}->GetValue,
        (map { $_ => $self->{$_}->GetValue } qw(username password)),
    );

    my $u = $self->{username}->GetValue;
    $u =~ s/^\s*//; $u =~ s/\s*$//;
    $self->{username}->SetValue ($u);

    $connect_info{port} = $1 if $connect_info{host} =~ s/:(\d+)$//;

    my $remember_password = ( $self->{remember_pass}
                              ? $self->{remember_pass}->GetValue
                              : core_cfg("client.remember_password") );

    unless ($remember_password) {
        $self->{password}->SetValue('');
    }

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
    my $dialog = Wx::MessageDialog->new($self, $message, "Connection error.", wxOK | wxICON_ERROR);
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
            [
                map { 
                    if ($_->{blocked}) {
                        $_->{name}." (blocked)";
                    } else {
                        $_->{name};
                    }
                } @$vm_data
            ],
            [ map { $_->{id} } @$vm_data ],
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
        if (core_cfg('client.show.remember_password')) {
            # $self->{remember_pass} only exists when client.show.remember_password is set
            $self->{password}->SetValue ('') if !$self->{remember_pass}->IsChecked;
        }
        $self->Hide();
        $self->{timer}->Stop();
    } elsif ($status eq 'FORWARDING') {
        $self->start_file_sharing();
    } elsif ($status eq 'CLOSED') {
        $self->{timer}->Stop();
        $self->{progress_bar}->SetValue(0);
        $self->{progress_bar}->SetRange(100);
        $self->EnableControls(1);
        $self->{username}->SetFocus();
        $self->Show;
    }
}

sub OnUnknownCert {
    my ($self, $event) = @_;
    my $evt_data = $event->GetData();
    my ($cert_pem_str, $cert_data, $cert_errno) = @$evt_data;
    my $err_desc;

    my $dialog = Wx::Dialog->new($self, undef, 'Invalid certificate');
    my $vsizer = Wx::BoxSizer->new(wxVERTICAL);
    my $no_ok_button;

    # Net::SSLeay doesn't seem to have error constants. Values taken from:
    # http://www.openssl.org/docs/apps/verify.html#
    
    if ( $cert_errno == 2 || $cert_errno == 20 || $cert_errno == 21 || $cert_errno == 27 ) {
        $err_desc = "Unrecognized Certificate Authority. See the documentation for instructions on how to use your own CA.\n"; 
    } elsif ( $cert_errno == 9 ) {
        $err_desc = "The ertificate is not yet valid. Make sure your clock is set correctly.\n"; 
    } elsif ( $cert_errno == 10 ) {
        $err_desc = "The certificate has expired.\n"; 
    } elsif ( $cert_errno == 23 ) {
        $err_desc = "The certificate has been revoked.\n";
        $no_ok_button = 1;
    } else {
        $err_desc = "Unrecognized SSL error #$cert_errno. See the certificate information below for details.\n";
    }

    $vsizer->Add(Wx::StaticText->new($dialog, -1, $err_desc), 0, wxALL, 5);

    $vsizer->Add(Wx::StaticText->new($dialog, -1, 'Certificate information:'), 0, wxALL, 5); 
    my $tc = Wx::TextCtrl->new($dialog, -1, $cert_data ? $cert_data : 'Certificate not found, maybe HKD component is not runnning at server side.', wxDefaultPosition, [600,300], wxTE_MULTILINE|wxTE_READONLY);
    $tc->SetFont (Wx::Font->new(12, wxDEFAULT, wxNORMAL, wxNORMAL, 0, 'Courier New'));
    $vsizer->Add($tc, 1, wxALL|wxEXPAND, 5);

    my $but_clicked = sub {
        lock $accept_cert;
        $accept_cert = (shift and ($cert_data ne ""));
	cond_signal $accept_cert;
        $dialog->EndModal(0);
        $dialog->Destroy();
    };
    my $bsizer = Wx::BoxSizer->new(wxHORIZONTAL);

    my $but_ok;
    unless ($no_ok_button) {
        $but_ok     = Wx::Button->new($dialog, -1, 'Ok') ;
        Wx::Event::EVT_BUTTON($dialog, $but_ok    ->GetId, sub { $but_clicked->(1) });
        $bsizer->Add($but_ok, 0, wxALL, 5);
    }

    my $but_cancel = Wx::Button->new($dialog, -1, 'Cancel');
    Wx::Event::EVT_BUTTON($dialog, $but_cancel->GetId, sub { $but_clicked->(0) });
    $bsizer->Add($but_cancel, 0, wxALL, 5);
    $vsizer->Add($bsizer);

    if ($but_ok) {
        $but_ok->SetFocus;
    } else {
        $but_cancel->SetFocus;
    }

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

sub OnSetEnvironment {
    my ($self, $event) = @_;
    my $args = $event->GetData();
    DEBUG "Setting environment: start";

    foreach my $k (keys %$args) {
        DEBUG("Setting environment var '$k' to '" . $args->{$k} . "' in main thread");
        $ENV{$k} = $args->{$k};
    }

    DEBUG "Setting environment: done";
    lock $set_env;
    $set_env = 1;
    cond_signal $set_env;
}

################################################################################
#
# Helpers
#
################################################################################

sub DetectKeyboard {

    my $log = Log::Log4perl->get_logger("QVD::Client::Frame"); 

    if ($^O eq 'MSWin32' ) {
        require Win32::API;

        my $gkln = Win32::API->new ('user32', 'GetKeyboardLayoutName', 'P', 'I');
        my $str = ' ' x 8;
        $gkln->Call ($str);

        my $k = substr $str, -4;
        my $layout = $lang_codes{$k} // 'es';

        ## use a hardcoded 'pc105' since windows doesn't seem to have the notion of keyboard model
        DEBUG "Detected layout $layout, assuming pc105 keyboard";
        return "pc105/$layout";
    } else {
	# See http://www.nomachine.com/tr/view.php?id=TR02H02326
	my $user = getpwuid($>);
	if (defined $user and length $user){
            my $xhost = core_cfg('command.xhost') ;
            system $xhost, "+si:localuser:$user";
            DEBUG("xhost executed for $user");
	}
	else {
            WARN("Cannot execute xhost for $user");
	}

        require X11::Protocol;
        my $x11 = X11::Protocol->new;
        my ($raw) = $x11->GetProperty ($x11->root, $x11->atom ('_XKB_RULES_NAMES'), 'AnyPropertyType', 0, 4096, 0);
        my ($rules, $model, $layout, $variant, $options) = split /\x00/, $raw;

        ## these may be comma-separated values, pick the first element
        ($layout, $variant) = map { (split /,/)[0] // '' } $layout, $variant;
        DEBUG "Detected layout: $model/$layout";
        return "$model/$layout";
    }
}

sub EnableControls {
    my ($self, $enabled) = @_;
    $self->{$_}->Enable($enabled) for qw(connect_button username password);
    if (!core_cfg('client.force.link',      0)) { $self->{link}->Enable($enabled); }
    if (!core_cfg('client.force.host.name', 0)) { $self->{host}->Enable($enabled); }
}

sub SaveConfiguration {
    my $self = shift;
    set_core_cfg('client.user.name', $self->{username}->GetValue());
    if (!core_cfg('client.force.host.name', 0)) {
        set_core_cfg('client.host.name', $self->{host}->GetValue());
    }
    #set_core_cfg('client.host.port', $self->{port}->GetValue());
    if (!core_cfg('client.force.link', 0)) {
        set_core_cfg('client.link', lc($self->{link}->GetStringSelection()));
    }

    if ($self->{remember_pass}) {
        set_core_cfg('client.remember_password', ($self->{remember_pass}->IsChecked() ? 1 : 0));
    }

    #set_core_cfg('client.audio.enable', $self->{audio}->GetValue());
    #set_core_cfg('client.printing.enable', $self->{printing}->GetValue());
    #set_core_cfg('client.fullscreen', $self->{fullscreen}->GetValue());
    #set_core_cfg('client.geometry', $self->{geometry}->GetValue());

    local $@;
    eval { save_core_cfg($QVD::Client::App::user_config_filename) };
    if ($@) {
        my $message = $@;
        my $dialog = Wx::MessageDialog->new($self, $message, 
            "Error saving configuration", wxOK | wxICON_ERROR);
        $dialog->ShowModal();
        $dialog->Destroy();
    }
}

sub start_file_sharing {
    my $slave_client_proc;
    if (core_cfg('client.slave.enable', 1)) {
        #my $slave_client_cmd = $QVD::Client::App::app_dir . '/bin/qvd-slaveclient';
        my @shares;
        if ($WINDOWS) {
            # User's home + all drives
            push @shares, $ENV{USERPROFILE};
            eval "use Win32API::File";
            for my $drive (Win32API::File::getLogicalDrives()) {
            	push @shares, $drive if -d $drive;
            }
        } else {
            # User's home + /media
            push @shares, $ENV{HOME};
            push @shares, '/media' if -e '/media';
            push @shares, '/Volumes' if -e '/Volumes'; # For OS X
        }

        use QVD::Client::SlaveClient;
        for my $share (@shares) {
            INFO("Starting folder sharing for $share");
            for (my $conn_attempt = 0; $conn_attempt < 10; $conn_attempt++) {
                local $@;
                my $client = QVD::Client::SlaveClient->new('localhost:12040');
                eval { $client->handle_share($share) };
                if ($@) {
                    if ($@ =~ 'Connection refused') {
                        sleep 1;
                        next;
                    }
                    ERROR $@;
                } else {
                    DEBUG("Folder sharing started for $share");
                }
                last;
            }
        }
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

sub get_osx_resolutions {
    my @ret;

    foreach my $line (`system_profiler SPDisplaysDataType`) {
        if ( $line =~ /Resolution: (\d+) x (\d+)/ ) {
            push @ret, [$1, $2];
        }
    }

    return @ret;
}

1;
