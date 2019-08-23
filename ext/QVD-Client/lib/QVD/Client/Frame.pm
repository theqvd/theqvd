package QVD::Client::Frame;

use threads;
use threads::shared;
use Wx qw[:everything];
use QVD::Config::Core;
use QVD::Client::Proxy;
use base qw(Wx::Frame);
use strict;
use QVD::Log;
use Locale::gettext;
use FindBin;
use Encode;
use POSIX qw(setlocale);
use QVD::Client::USB qw/list_devices get_busid/;

use constant EVT_LIST_OF_VM_LOADED => Wx::NewEventType;
use constant EVT_CONNECTION_ERROR  => Wx::NewEventType;
use constant EVT_CONN_STATUS       => Wx::NewEventType;
use constant EVT_UNKNOWN_CERT      => Wx::NewEventType;
use constant EVT_SET_ENVIRONMENT   => Wx::NewEventType;
use constant EVT_PROXY_ALERT       => Wx::NewEventType;




use constant X509_V_OK                                        => 0;
use constant X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT             => 2;
use constant X509_V_ERR_UNABLE_TO_GET_CRL                     => 3;
use constant X509_V_ERR_UNABLE_TO_DECRYPT_CERT_SIGNATURE      => 4;
use constant X509_V_ERR_UNABLE_TO_DECRYPT_CRL_SIGNATURE       => 5;
use constant X509_V_ERR_UNABLE_TO_DECODE_ISSUER_PUBLIC_KEY    => 6;
use constant X509_V_ERR_CERT_SIGNATURE_FAILURE                => 7;
use constant X509_V_ERR_CRL_SIGNATURE_FAILURE                 => 8;
use constant X509_V_ERR_CERT_NOT_YET_VALID                    => 9;
use constant X509_V_ERR_CERT_HAS_EXPIRED                      => 10;
use constant X509_V_ERR_CRL_NOT_YET_VALID                     => 11;
use constant X509_V_ERR_CRL_HAS_EXPIRED                       => 12;
use constant X509_V_ERR_ERROR_IN_CERT_NOT_BEFORE_FIELD        => 13;
use constant X509_V_ERR_ERROR_IN_CERT_NOT_AFTER_FIELD         => 14;
use constant X509_V_ERR_ERROR_IN_CRL_LAST_UPDATE_FIELD        => 15;
use constant X509_V_ERR_ERROR_IN_CRL_NEXT_UPDATE_FIELD        => 16;
use constant X509_V_ERR_OUT_OF_MEM                            => 17;
use constant X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT           => 18;
use constant X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN             => 19;
use constant X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY     => 20;
use constant X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE       => 21;
use constant X509_V_ERR_CERT_CHAIN_TOO_LONG                   => 22;
use constant X509_V_ERR_CERT_REVOKED                          => 23;
use constant X509_V_ERR_INVALID_CA                            => 24;
use constant X509_V_ERR_PATH_LENGTH_EXCEEDED                  => 25;
use constant X509_V_ERR_INVALID_PURPOSE                       => 26;
use constant X509_V_ERR_CERT_UNTRUSTED                        => 27;
use constant X509_V_ERR_CERT_REJECTED                         => 28;
use constant X509_V_ERR_SUBJECT_ISSUER_MISMATCH               => 29;
use constant X509_V_ERR_AKID_SKID_MISMATCH                    => 30;
use constant X509_V_ERR_AKID_ISSUER_SERIAL_MISMATCH           => 31;
use constant X509_V_ERR_KEYUSAGE_NO_CERTSIGN                  => 32;
use constant X509_V_ERR_APPLICATION_VERIFICATION              => 50;

my $vm_id :shared;

my %connect_info :shared;
my $accept_cert :shared;
my $set_env :shared;
my $proxy_alert :shared;

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

my $version_string = sprintf "Release: %s\nGit commit: %s\nBuild: %s", (eval { require QVD::Client::Version; }) ?
    ($QVD::Client::Version::QVD_RELEASE, $QVD::Client::Version::GIT_COMMIT, $QVD::Client::Version::BUILD_NUMBER) :
    ("(running from source code)", "N/A", "N/A");

sub new {
    my( $class, $parent, $id, $title, $pos, $size, $style, $name ) = @_;
    $parent = undef              unless defined $parent;
    $id     = -1                 unless defined $id;
    $title  = ""                 unless defined $title;
    $pos    = wxDefaultPosition  unless defined $pos;
    $size   = wxDefaultSize      unless defined $size;
    $name   = ""                 unless defined $name;

    my ($tab_ctl, $tab_sizer, $settings_panel, $version_panel);

    $style = wxCAPTION|wxCLOSE_BOX|wxSYSTEM_MENU|wxMINIMIZE_BOX
        unless defined $style;

    my $self = $class->SUPER::new( $parent, $id, $title, $pos, $size, $style, $name );

    $self->{usbip_shared_buses} = [];
	
    if ( core_cfg('client.locale') ) {
        my $loc = core_cfg('client.locale');
        INFO "Overriding system locale with config file setting: $loc";
        setlocale(&POSIX::LC_ALL, $loc);
    }

    $self->{domain} = Locale::gettext->domain("qvd-gui-client");
    my $bin = $FindBin::RealBin;
    my $rootdir = "$bin/..";
    my $localepath = "$rootdir/share/locale";

    if ( -f "$rootdir/Build.PL" ) {
        DEBUG "Running from source tree, using in-tree locale";
        require Locale::Msgfmt;
        require File::Path;


        my @po_files = glob("$rootdir/po/*.po");

        foreach my $po_file (@po_files) {
            my ($lang) = ( $po_file =~ /po\/(.*?)\.po$/ );
            my $d = "$localepath/$lang/LC_MESSAGES";
            File::Path::mkpath($d) unless (-d $d);
            DEBUG "Generating locale: $po_file => $d/qvd-gui-client.mo";
            eval {
                Locale::Msgfmt::msgfmt({ in => $po_file, out => "$d/qvd-gui-client.mo" });
            };
            if ( $@ ) {
                WARN "Failed to convert locale from $po_file to $d/qvd-gui-client.mo";
            }

        }
    } else {
        DEBUG "Running from installed package, using installed locale";
    }

    if ( ! -d $localepath ) {
        DEBUG "$localepath not found, trying alternative path";
        $localepath = "$rootdir/locale";
    }

    DEBUG "Locale path is $localepath";
    bindtextdomain("qvd-gui-client", $localepath);

    $self->{tab_ctl} = $tab_ctl = Wx::Notebook->new($self, -1, wxDefaultPosition, wxDefaultSize, 0, "tab");

    my $panel = $self->{panel} = Wx::Panel->new($tab_ctl, -1, wxDefaultPosition, wxDefaultSize, wxTAB_TRAVERSAL ); # / broken highlighter

    $panel->SetBackgroundColour(Wx::Colour->new(217,217,217));

    $tab_ctl->AddPage( $panel, $self->_t("Connect") );
    $tab_sizer = Wx::BoxSizer->new(wxVERTICAL);
    $tab_sizer->Add($tab_ctl);

    if ( core_cfg('client.show.settings') ) {
        $settings_panel = Wx::Panel->new($tab_ctl, -1, wxDefaultPosition, wxDefaultSize, wxTAB_TRAVERSAL );
        $self->{settings_panel} = $settings_panel;
        $settings_panel->SetBackgroundColour(Wx::Colour->new(255,255,255));
        $tab_ctl->AddPage( $settings_panel, $self->_t("Settings"));
        my $settings_sizer = Wx::GridBagSizer->new(0,0);
        $settings_panel->SetSizer($settings_sizer);

        ###############################

        my $this_text = Wx::StaticText->new($settings_panel, -1, $self->_t("Options"));
        $this_text->SetFont(Wx::Font->new(10,wxDEFAULT,wxDEFAULT,wxBOLD,0,""));
        $settings_sizer->Add( $this_text , Wx::GBPosition->new(0,0), Wx::GBSpan->new(1,1) , wxTOP|wxLEFT|wxEXPAND, 10);

        $settings_sizer->Add(Wx::StaticText->new($settings_panel, -1, $self->_t("Enable audio")),Wx::GBPosition->new(1,0), Wx::GBSpan->new(1,1), wxLEFT, 10);
        $self->{audio} = Wx::CheckBox->new($settings_panel, -1, "" , wxDefaultPosition, wxDefaultSize, wxALIGN_RIGHT, wxDefaultValidator, "checkBox");
        $self->{audio}->SetValue( core_cfg("client.audio.enable" ) );
        $settings_sizer->Add($self->{audio},Wx::GBPosition->new(1,1), Wx::GBSpan->new(1,1), wxALL, 0);

        $settings_sizer->Add(Wx::StaticText->new($settings_panel, -1, $self->_t("Enable printing")),Wx::GBPosition->new(2,0), Wx::GBSpan->new(1,1), wxLEFT, 10);
        $self->{printing} = Wx::CheckBox->new($settings_panel, -1, "", wxDefaultPosition, wxDefaultSize, wxALIGN_RIGHT, wxDefaultValidator, "checkBox");
        $self->{printing}->SetValue( core_cfg("client.printing.enable" ) );
        $settings_sizer->Add($self->{printing},Wx::GBPosition->new(2,1), Wx::GBSpan->new(1,1), wxALL, 0);

        $settings_sizer->Add(Wx::StaticText->new($settings_panel, -1, $self->_t("Full screen")),Wx::GBPosition->new(3,0), Wx::GBSpan->new(1,1), wxLEFT, 10);
        $self->{fullscreen} = Wx::CheckBox->new($settings_panel, -1, "", wxDefaultPosition, wxDefaultSize, wxALIGN_RIGHT, wxDefaultValidator, "checkBox");
        $self->{fullscreen}->SetValue( core_cfg("client.fullscreen" ) );
        $settings_sizer->Add($self->{fullscreen},Wx::GBPosition->new(3,1), Wx::GBSpan->new(1,1), wxALL, 0);

        ###############################

        if (!core_cfg('client.force.host.name', 0) or !core_cfg('client.force.link', 0) ) {
            my $this_text = Wx::StaticText->new($settings_panel, -1, $self->_t("Connectivity"));
            $this_text->SetFont(Wx::Font->new(10,wxDEFAULT,wxDEFAULT,wxBOLD,0,""));
            $settings_sizer->Add( $this_text ,Wx::GBPosition->new(4,0), Wx::GBSpan->new(1,1), wxTOP|wxLEFT|wxEXPAND, 10);
        }

        if (!core_cfg('client.force.host.name', 0)) {
            $settings_sizer->Add(Wx::StaticText->new($settings_panel, -1, $self->_t("Server")),Wx::GBPosition->new(5,0), Wx::GBSpan->new(1,1), wxLEFT, 10);
            $self->{host} = Wx::TextCtrl->new($settings_panel, -1, core_cfg('client.host.name'),wxDefaultPosition,[160,30]);
            $settings_sizer->Add($self->{host},Wx::GBPosition->new(5,1), Wx::GBSpan->new(1,3), wxLEFT|wxRIGHT, 10);
        }

        if (!core_cfg('client.force.link', 0)) {
            $settings_sizer->Add(Wx::StaticText->new($settings_panel, -1, $self->_t("Connection type")),Wx::GBPosition->new(6,0), Wx::GBSpan->new(1,1), wxLEFT, 10);
            my @link_options = ("Local", "ADSL", "Modem");
            $self->{link} = Wx::Choice->new($settings_panel, -1, wxDefaultPosition, [160,30]);
            $settings_sizer->Add($self->{link},Wx::GBPosition->new(6,1), Wx::GBSpan->new(1,3), wxLEFT|wxRIGHT, 10);
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


        #######################
        # Sharing
        ########################

        my $share_text = Wx::StaticText->new($settings_panel, -1, $self->_t("Share"));
        $share_text->SetFont(Wx::Font->new(10,wxDEFAULT,wxDEFAULT,wxBOLD,0,""));
        $settings_sizer->Add( $share_text ,Wx::GBPosition->new(7,0), Wx::GBSpan->new(1,1), wxTOP|wxLEFT|wxEXPAND, 10);

        $settings_sizer->Add(Wx::StaticText->new($settings_panel, -1, $self->_t("Enable shared folders")),Wx::GBPosition->new(8,0), Wx::GBSpan->new(1,1), wxLEFT, 10);
        $self->{share_enable} = Wx::CheckBox->new($settings_panel, -1, "", wxDefaultPosition, wxDefaultSize, wxALIGN_RIGHT, wxDefaultValidator, "checkBox");
        $self->{share_enable}->SetValue( core_cfg("client.file_sharing.enable" ) );
        $settings_sizer->Add($self->{share_enable},Wx::GBPosition->new(8,1), Wx::GBSpan->new(1,1), wxALL, 0 );

        $self->{share_add} = Wx::Button->new($settings_panel, -1, $self->_t("Add"));
        $settings_sizer->Add($self->{share_add},Wx::GBPosition->new(8,2), Wx::GBSpan->new(1,1), wxLEFT|wxRIGHT|wxBOTTOM|wxEXPAND, 10);
        $self->{share_add}->SetDefault;

        $self->{share_del} = Wx::Button->new($settings_panel, -1, $self->_t("Remove"));
        $settings_sizer->Add($self->{share_del},Wx::GBPosition->new(8,3), Wx::GBSpan->new(1,1), wxRIGHT|wxBOTTOM|wxEXPAND, 10);
        $self->{share_del}->SetDefault;

        $self->{share_list} = Wx::ListBox->new($settings_panel, -1, wxDefaultPosition, [400,130] ,  [] , wxLB_EXTENDED|wxLB_NEEDED_SB|wxLB_SORT , wxDefaultValidator, "sharedFoldersList");
        $settings_sizer->Add($self->{share_list},Wx::GBPosition->new(9,0), Wx::GBSpan->new(1,4), wxLEFT|wxRIGHT|wxEXPAND , 10);


        #######################
        # USB
        ########################

        if ( !$WINDOWS && !$DARWIN ) {
            if ( try_load_usbip() ) {
                $settings_sizer->Add(Wx::StaticText->new($settings_panel, -1, $self->_t("Enable USB redirection")),Wx::GBPosition->new(10,0), Wx::GBSpan->new(1,1), wxLEFT, 10);
                $self->{usb_redirection} = Wx::CheckBox->new($settings_panel, -1, "", wxDefaultPosition, wxDefaultSize, wxALIGN_RIGHT, wxDefaultValidator, "checkBox");
               $self->{usb_redirection}->SetValue( core_cfg("client.usb.enable" ) );
                $settings_sizer->Add($self->{usb_redirection},Wx::GBPosition->new(10,1), Wx::GBSpan->new(1,1),wxALL,0);

               $self->{usbip_device_list} = Wx::CheckListBox->new($settings_panel, -1, wxDefaultPosition, [400,130] ,  [] , wxLB_EXTENDED|wxLB_NEEDED_SB , wxDefaultValidator, "usbip_devices");
                $settings_sizer->Add($self->{usbip_device_list},Wx::GBPosition->new(11,0), Wx::GBSpan->new(1,4), wxLEFT|wxRIGHT|wxEXPAND , 10);
            } else {
                $settings_sizer->Add(Wx::StaticText->new($settings_panel, -1, $self->_t("USB redirection functionality not installed.")),Wx::GBPosition->new(10,0), Wx::GBSpan->new(1,1), wxLEFT, 10);
            }

        }

        # Register all events related to settings tab
        Wx::Event::EVT_BUTTON($self, $self->{share_add}->GetId, \&share_add);
        Wx::Event::EVT_BUTTON($self, $self->{share_del}->GetId, \&share_del);

        Wx::Event::EVT_CHECKBOX($self, $self->{share_enable}->GetId, \&OnClickSharedFolders);
        Wx::Event::EVT_CHECKBOX($self, $self->{usb_redirection}->GetId, \&OnClickUSBShare) if defined($self->{usb_redirection});

        Wx::Event::EVT_NOTEBOOK_PAGE_CHANGED($self, $self->{tab_ctl}->GetId, \&OnTabChange);


    }

    ############################### version tab

    $self->{version_panel} = $version_panel = Wx::Panel->new($tab_ctl, -1, wxDefaultPosition, wxDefaultSize, wxTAB_TRAVERSAL );
    $version_panel->SetBackgroundColour(Wx::Colour->new(255,255,255));
    $tab_ctl->AddPage( $version_panel, $self->_t("Version"));
    my $version_sizer = Wx::BoxSizer->new(wxVERTICAL);
    $version_panel->SetSizer($version_sizer);

    $self->{version_textctrl} = Wx::TextCtrl->new($version_panel, -1, $version_string, wxDefaultPosition, [200, 200], wxTE_MULTILINE|wxTE_READONLY);
    $self->{version_textctrl}->Disable;
    $version_sizer->Add($self->{version_textctrl}, 0, wxALL|wxEXPAND, 10);

    ###############################

    my $ver_sizer  = Wx::BoxSizer->new(wxVERTICAL);

    my $bm_logo_big = Wx::Bitmap->new(File::Spec->join($QVD::Client::App::pixmaps_dir, 'qvd-big.png'),
        wxBITMAP_TYPE_ANY);
    $ver_sizer->Add( Wx::StaticBitmap->new($panel, -1, $bm_logo_big),
        0, wxTOP|wxALIGN_CENTER_HORIZONTAL, 100 );


    my $grid_sizer = Wx::GridSizer->new(1, 1, -5, 0);
    $ver_sizer->Add($grid_sizer, 1, wxALL|wxEXPAND, 20);

    $self->{username} = Wx::TextCtrl->new($panel, -1, core_cfg('client.remember_username') ?  core_cfg('client.user.name') : "", wxDefaultPosition, wxDefaultSize);
    $grid_sizer->Add($self->{username}, 0, wxALL|wxALIGN_CENTER_HORIZONTAL|wxEXPAND, 5);

    $self->{password} = Wx::TextCtrl->new($panel, -1, core_cfg('client.remember_password') ?  core_cfg('client.user.password') : "", wxDefaultPosition, wxDefaultSize, wxTE_PASSWORD);
    $grid_sizer->Add($self->{password}, 0, wxALL|wxALIGN_CENTER_HORIZONTAL|wxEXPAND, 5);

    if (core_cfg('client.show.remember_password')) {
        $grid_sizer->Add(Wx::StaticText->new($panel, -1, $self->_t("Remember password")), 0, wxALL, 5);
        $self->{remember_pass} = Wx::CheckBox->new ($panel, -1, '', wxDefaultPosition);
        $self->{remember_pass}->SetValue(core_cfg('client.remember_password') ? 1 : 0);
        $grid_sizer->Add($self->{remember_pass}, 1, wxALL, 5);
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
    $self->{connect_button} = Wx::Button->new($panel, -1, $self->_t("Connect"),wxDefaultPosition,wxDefaultSize);
    $self->{connect_button}->SetBackgroundColour(Wx::Colour->new(229,90,0));
    $self->{connect_button}->SetForegroundColour(Wx::Colour->new(255,255,255));
    $grid_sizer->Add($self->{connect_button}, 0, wxALIGN_TOP|wxALL|wxALIGN_CENTER_HORIZONTAL|wxEXPAND, 5);
    $self->{connect_button}->SetDefault;

    $self->{kill_vm} = Wx::CheckBox->new ($panel, -1, $self->_t("Restart session"), wxDefaultPosition,wxDefaultSize);
    $grid_sizer->Add($self->{kill_vm},0,wxALIGN_LEFT|wxALIGN_TOP|wxALL,5);

    $ver_sizer->AddSpacer(100);

    $self->{progress_bar} = Wx::Gauge->new($panel, -1, 100, wxDefaultPosition, wxDefaultSize, wxGA_HORIZONTAL|wxGA_SMOOTH);
    $self->{progress_bar}->SetValue(0);
    $ver_sizer->Add($self->{progress_bar}, 0, wxEXPAND, 0);

    $ver_sizer->Add( Wx::HyperlinkCtrl->new( $panel , -1, 'Qindel Group '.chr(169).' 2018','http://theqvd.com',wxDefaultPosition, wxDefaultSize, wxALIGN_CENTER_HORIZONTAL , ''), 0 , wxALIGN_CENTER_HORIZONTAL, 5 );

    $self->SetTitle("QVD");
    my $icon = Wx::Icon->new();
    my $bm_logo_small = Wx::Bitmap->new(File::Spec->join($QVD::Client::App::pixmaps_dir, 'qvd-small.png'),
        wxBITMAP_TYPE_ANY);
    $icon->CopyFromBitmap($bm_logo_small);
    $self->SetIcon($icon);

    $panel->SetSizer($ver_sizer);

    $ver_sizer->Fit($tab_ctl);
    $tab_sizer->Fit($self);

    if ( core_cfg('client.show.settings') ) {
        $self->OnClickSharedFolders();
        $self->OnClickUSBShare() if defined($self->{usb_redirection});
    }

    $self->Center;
    $self->Show(1) unless core_cfg('client.auto_connect','');
    (core_cfg('client.remember_username') && length core_cfg('client.user.name')) ? $self->{password}->SetFocus() : $self->{username}->SetFocus();

    Wx::Event::EVT_BUTTON($self, $self->{connect_button}->GetId, \&OnClickConnect);
    Wx::Event::EVT_TIMER($self, -1, \&OnTimer);

    Wx::Event::EVT_COMMAND($self, -1, EVT_CONNECTION_ERROR, \&OnConnectionError);
    Wx::Event::EVT_COMMAND($self, -1, EVT_LIST_OF_VM_LOADED, \&OnListOfVMLoaded);
    Wx::Event::EVT_COMMAND($self, -1, EVT_CONN_STATUS, \&OnConnectionStatusChanged);
    Wx::Event::EVT_COMMAND($self, -1, EVT_UNKNOWN_CERT, \&OnUnknownCert);
    Wx::Event::EVT_COMMAND($self, -1, EVT_SET_ENVIRONMENT, \&OnSetEnvironment);
    Wx::Event::EVT_COMMAND($self, -1, EVT_PROXY_ALERT, \&OnAlert);


    Wx::Event::EVT_CLOSE($self, \&OnExit);

    $self->{timer} = Wx::Timer->new($self);
    $self->{proc} = undef;
    $self->{proc_pid} = undef;
    $self->{log} = "";
    $self->{shares} = [];
    $self->{usb_devices} = [];
    $self->{disconnected_usb_devices} = [];


    $self->load_share_list();
    $self->load_usb_devices() if defined($self->{usb_redirection});

    if( $ENV{QVD_PP_BUILD} ) {
        INFO "Being called from PP build. Exiting.";
        $self->Close();
        $self->Destroy();
        exit(0);
    }

    return $self;
}

sub RunWorkerThread {
    my $self = shift;
    my @args = @_;
    lock(%connect_info);
    while (1) {
        unless ( %connect_info ){ DEBUG "Ending connection thread\n"; threads->exit(0) ; }
        local $@;
        eval {
            QVD::Client::Proxy->new($self, %connect_info)->connect_to_vm();
        };
        if ($@) {
            my $msg = $@;
            ERROR "Unable to connect to VM: $msg";
            DEBUG "Notifying master thread...";
            $self->proxy_connection_error(message => $msg);
        }
        DEBUG "Slave thread waiting for \%connect_info";
        cond_wait(%connect_info);
        DEBUG "Slave thread signaled \%connect_info!";
    }
}

################################################################################
#
# QVD::Client::Proxy callbacks
#
################################################################################

sub proxy_unknown_cert {
    my $self = shift;
    my $msg :shared = shared_clone(shift);
    my $evt = new Wx::PlThreadEvent(-1, EVT_UNKNOWN_CERT, $msg);
    Wx::PostEvent($self, $evt);

    { lock $accept_cert; cond_wait $accept_cert; }
    return $accept_cert;
}

sub proxy_list_of_vm_loaded {
    my $self = shift;
    my $list = shift;
    my $vm_data :shared = shared_clone($list);
    if (@$vm_data > 1) {
        lock($vm_id);
        my $evt = new Wx::PlThreadEvent(-1, EVT_LIST_OF_VM_LOADED, $vm_data);
        Wx::PostEvent($self, $evt);
        cond_wait($vm_id);
    } elsif (@$vm_data == 1) {
        $vm_id = $vm_data->[0]{id};
    } else {
        die $self->_t("You don't have any virtual machine available");
    }
    return $vm_id;
}

sub proxy_connection_status {
    my ($self, $status) = @_;
    DEBUG("proxy connection status changed to $status, notifying master thread");
    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, EVT_CONN_STATUS, $status));
}

sub proxy_connection_error {
    my $self = shift;
    my %args = @_;
    DEBUG("proxy connection error: @_");
    my $message :shared = $args{message};
    my $evt = new Wx::PlThreadEvent(-1, EVT_CONNECTION_ERROR, $message);
    Wx::PostEvent($self, $evt);
}

sub proxy_set_environment {
    my $self = shift;
    my %args = @_;
    my $shared_args :shared = shared_clone(\%args);

    lock($set_env);
    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, EVT_SET_ENVIRONMENT, $shared_args));
    cond_wait($set_env);
}

sub proxy_alert {
    my $self = shift;
    my %args = @_;
    my $shared_args :shared = shared_clone(\%args);

    lock($proxy_alert);
    Wx::PostEvent($self, new Wx::PlThreadEvent(-1, EVT_PROXY_ALERT, $shared_args));
    cond_wait($proxy_alert);
}


################################################################################
#
# Wx event handlers
#
################################################################################

sub OnClickConnect {
    my( $self, $event ) = @_;

    $self->SaveConfiguration() unless ( core_cfg('client.auto_connect',0) );

    $self->{state} = "";
    %connect_info = (
        link          => core_cfg('client.force.link', 0) // core_cfg('client.link'),
        audio         => core_cfg('client.audio.enable'),
        printing      => core_cfg('client.printing.enable'),
        usb           => core_cfg('client.usb.enable'),
        usb_impl      => core_cfg('client.usb.implementation'),
        geometry      => core_cfg('client.geometry'),
        fullscreen    => core_cfg('client.fullscreen'),
        extra_args    => core_cfg('client.nxagent.extra_args'),
        keyboard      => $self->DetectKeyboard,
        port          => $DEFAULT_PORT,
        ssl           => $USE_SSL,
        host          => core_cfg('client.force.host.name', 0) // core_cfg('client.host.name'),
        (map { $_ => $self->{$_}->GetValue } grep { defined $self->{$_} } qw(username password kill_vm)),
        vm_id         => core_cfg('client.auto_connect.vm_id',''),
        token           => core_cfg('client.auto_connect.token','')
    );

    if ( core_cfg('client.auth_env_share.enable') ) {
        DEBUG "Environment forwarding enabled";
        my $var;
        my $num = 0;
        while( $var = core_cfg("client.auth_env_share.list.$num", 0 ) ) {
            DEBUG "Var: $var";
            # shared hashes can't be nested, so we're forced to use a flat
            # structure here.
            $connect_info{"auth_vars.${var}"} = $ENV{$var};
            $num++;
        }
    }

    my $u = $self->{username}->GetValue;
    $u =~ s/^\s*//; $u =~ s/\s*$//;
    $self->{username}->SetValue ($u);

    $connect_info{port} = $1 if $connect_info{host} =~ s/:(\d+)$//;

    my $remember_password = ( $self->{remember_pass}
        ? $self->{remember_pass}->GetValue
        : core_cfg("client.remember_password") );

    unless (core_cfg('client.remember_username')) {
        $self->{username}->SetValue('');
    }

    unless ($remember_password) {
        $self->{password}->SetValue('');
    }

    if ( defined $self->{kill_vm} ) {
        # This option normally only needs to be used once
        $self->{kill_vm}->SetValue('');
    }

    # Start or notify worker thread
    # Will result in the execution of a loop in RunWorkerThread.
    if (!$self->{worker_thread} || !$self->{worker_thread}->is_running()) {
        @_ = (); # necessary to avoid "Scalars leaked," see perldoc Wx::Thread
        my $thr = threads->create(\&RunWorkerThread, $self);
        $self->{worker_thread} = $thr;
    } else {
        lock(%connect_info);
        cond_signal(%connect_info);
    }
}


sub OnClickSharedFolders {
    my( $self, $event ) = @_;

    if ( $self->{share_enable}->GetValue() ){
        # Enable picking
        $self->{share_add}->Show(1);
        $self->{share_del}->Show(1);
        $self->{share_list}->Show(1);
    }else{
        # Disable picking
        $self->{share_add}->Show(0);
        $self->{share_del}->Show(0);
        $self->{share_list}->Show(0);
    }

    $self->{settings_panel}->Layout();

}

sub OnClickUSBShare {
    my( $self, $event ) = @_;

    if ( $self->{usb_redirection}->GetValue() ){
        # Enable device list
        $self->{usbip_device_list}->Show(1);
    }else{
        # Disable device list
        $self->{usbip_device_list}->Show(0);
    }

    $self->{settings_panel}->Layout();

}

sub OnTabChange {
    my( $self, $event ) = @_;

    # We only save settings when we're leaving the settings tab
    if ( $self->{tab_ctl}->GetPageText($event->GetOldSelection()) eq 'Settings' ){
        $self->SaveConfiguration();
        if ( $self->{worker_thread} && $self->{worker_thread}->is_running() ){
            undef %connect_info ;
            cond_signal(%connect_info);
            $self->{worker_thread}->join();
        }
    }

}

sub OnConnectionError {
    my ($self, $event) = @_;
    $self->{timer}->Stop();
    $self->{progress_bar}->SetValue(0);
    $self->{progress_bar}->SetRange(100);
    my $message = $event->GetData;
    my $msg = "";

    if ( $message =~ /Unable to connect to (.*?:\d+): (\w+) \((.*?)\) (\[.*?\])/ ) {
        my ($ehost, $err, $errmsg, $sslerr) = ($1,$2,$3,$4);
        $sslerr =~ s/^\[//;
        $sslerr =~ s/\]$//;
        DEBUG "Connection error on host '$ehost', error '$err', message '$errmsg', SSL error '$sslerr'";

        if ( $sslerr && $sslerr !~ /IO::Socket::INET configuration failed/ ) {
            # "IO::Socket::INET configuration failed" means something went wrong in the IO::Socket::INET
            # layer, so there's nothing interesting to say about SSL.
            $msg .= sprintf($self->_t("Error establishing a SSL connection"), $sslerr) . "\n\n";
        }

        $msg .= sprintf($self->_t("Error when trying to connect to %s:"), $ehost) . "\n$errmsg";
        $msg .= "\n\n" . $self->_t("Make sure your connection settings are correct, and that the server is accepting connections.");
    } else {
        $msg = $message;
    }

    my $translated = $msg;

    if ( $msg =~ /The server has rejected your login/ ) {
        $translated = $self->_t("The server has rejected your login. Please verify that your username and password are correct");
    } else {
        WARN "Untranslated connection error: $msg";
    }

    my $dialog = Wx::MessageDialog->new($self, $msg, $self->_t("Connection error"), wxOK | wxICON_ERROR);
    DEBUG "Showing error to user";
    $dialog->ShowModal();
    $dialog->Destroy();
    DEBUG "Calling EnableControls(1)";
    $self->EnableControls(1);
    $self->Show;
}

sub OnListOfVMLoaded {
    my ($self, $event) = @_;
    my $vm_data = $event->GetData;
    {
        lock($vm_id);
        my $dialog = new Wx::SingleChoiceDialog(
                $self,
                $self->_t("Select virtual machine:"),
                $self->_t("Select virtual machine"),
                [
                    map {
                        if ($_->{blocked}) {
                            $_->{name}.$self->_t(" (blocked)");
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

    DEBUG "OnConnectionStatusChanged($status)";
    
    if ($status eq 'CONNECTING') {
        $self->EnableControls(0);
        $self->{timer}->Start(50, 0);

        $self->_clear_errors;
    } elsif ($status eq 'CONNECTED') {
        if (core_cfg('client.show.remember_password')) {
            # $self->{remember_pass} only exists when client.show.remember_password is set
            $self->{password}->SetValue ('') if !$self->{remember_pass}->IsChecked;
        }
        $self->Hide();
        $self->{timer}->Stop();
    } elsif ($status eq 'FORWARDING') {
        $self->start_file_sharing();
        $self->start_remote_mounts();
        $self->start_device_sharing();

        $self->_show_errors;
    } elsif ($status eq 'CLOSED') {
        $self->{timer}->Stop();
        $self->stop_device_sharing();
        $self->Destroy() if ( core_cfg('client.auto_connect',0) ); # We don't want to let the user do anything else if this was autoconnected session (don't let him change a config that won't be saved..)
        $self->{progress_bar}->SetValue(0);
        $self->{progress_bar}->SetRange(100);
        $self->EnableControls(1);
        $self->Show;
        (core_cfg('client.remember_username') && length core_cfg('client.user.name')) ? $self->{password}->SetFocus() : $self->{username}->SetFocus();

    }
}

sub OnUnknownCert {
    my ($self, $event) = @_;
    my $data = $event->GetData();
    my $err_desc;
    my @advice;

    my $dialog = Wx::Dialog->new($self, -1, $self->_t("Invalid certificate"));
    my $main_sizer = Wx::BoxSizer->new(wxVERTICAL);
    my $no_ok_button;


    #use Data::Dumper;
    #print STDERR Dumper([$data]);

    my $tab_ctl;
    my $show_details = 1;


    if ( $show_details ) {
        $tab_ctl = Wx::Notebook->new($dialog, -1, wxDefaultPosition, wxDefaultSize, 0, "tab");
        $main_sizer->Add($tab_ctl);
    }


    my $info_panel = $self->{panel} = Wx::Panel->new($tab_ctl // $dialog, -1, wxDefaultPosition, wxDefaultSize, wxTAB_TRAVERSAL ); # / broken highlighter
    my $info_sizer = Wx::BoxSizer->new(wxVERTICAL);
    $info_panel->SetSizer( $info_sizer );

    my $details_panel;
    my $details_sizer;





    if ( $tab_ctl ) {
        $tab_ctl->AddPage( $info_panel, $self->_t("Problems") );


        $details_panel = Wx::Panel->new($tab_ctl, -1, wxDefaultPosition, wxDefaultSize, wxTAB_TRAVERSAL );
        $details_sizer = Wx::BoxSizer->new(wxVERTICAL);
        $details_panel->SetSizer($details_sizer);

        $tab_ctl->AddPage( $details_panel, $self->_t("Details"));
    } else {
        $main_sizer->Add($info_panel);
    }


    my $problems_box  = Wx::StaticBox->new($info_panel, -1, $self->_t("Results of the certificate check"));
    my $problems_sizer= Wx::StaticBoxSizer->new($problems_box, wxVERTICAL);
    $info_sizer->Add($problems_sizer, 0, wxALL | wxEXPAND, 5);

    my $cert_data;

    foreach my $cert (@$data) {
        if ( @{ $cert->{errors} } ){
            my $infoline = _cert_name($cert, $cert->{subject});
            my $infotext = Wx::StaticText->new($info_panel, -1, $infoline);
            my $font = $infotext->GetFont();
            $font->SetWeight(wxFONTWEIGHT_BOLD);
            $infotext->SetFont($font);
            $problems_sizer->Add($infotext, 0, wxALL, 5);


            foreach my $error (@{ $cert->{errors} }) {
                my $e = $error->{err_no};

                # Net::SSLeay doesn't seem to have error constants. Values taken from:
                # http://www.openssl.org/docs/apps/verify.html#

                $err_desc = sprintf($self->_t("Error #%s:"), $e) . " ";

                if ( $e == X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT ) {
                    $err_desc .= $self->_t("Unable to find issuer's certificate.");
                    _add_advice(\@advice, $self->_t("If you are using your own CA, see the documentation on how to make the client use your certificate."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_untrusted');
                } elsif ( $e == X509_V_ERR_UNABLE_TO_GET_ISSUER_CERT_LOCALLY ) {
                    $err_desc .= $self->_t("Unable to find issuer's certificate.");
                    _add_advice(\@advice, $self->_t("If you are using your own CA, see the documentation on how to make the client use your certificate."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_untrusted');
                } elsif ( $e == X509_V_ERR_UNABLE_TO_VERIFY_LEAF_SIGNATURE ) {
                    $err_desc .= $self->_t("Unable to verify the first certificate");
                    _add_advice(\@advice, $self->_t("If you are using your own CA, see the documentation on how to make the client use your certificate."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_untrusted');
                } elsif ( $e == X509_V_ERR_CERT_UNTRUSTED ) {
                    $err_desc .= $self->_t("Root certificate not trusted.");
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_untrusted');
                } elsif ( $e == X509_V_ERR_CERT_NOT_YET_VALID ) {
                    $err_desc .= $self->_t("The certificate is not yet valid.");
                    _add_advice(\@advice, $self->_t("Make sure your clock is set correctly."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_not_yet_valid');
                } elsif ( $e == X509_V_ERR_CERT_HAS_EXPIRED ) {
                    $err_desc .= $self->_t("The certificate has expired.");
                    _add_advice(\@advice, sprintf($self->_t("Remind %s (%s) to renew the certificate", $cert->{subject}->{o}, $cert->{subject}->{email})));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_expired');
                } elsif ( $e == X509_V_ERR_CERT_REVOKED ) {
                    $err_desc .= $self->_t("The certificate has been revoked.");
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_revoked');
                } elsif ( $e == X509_V_ERR_DEPTH_ZERO_SELF_SIGNED_CERT ) {
                    $err_desc .= $self->_t("The certificate is self-signed");
                    _add_advice(\@advice, $self->_t("If you are using your own CA, see the documentation on how to make the client use your certificate."));
                } elsif ( $e == X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN ) {
                    $err_desc .= $self->_t("A certificate in the chain is self-signed");
                    _add_advice(\@advice, $self->_t("If you are using your own CA, see the documentation on how to make the client use your certificate."));
                } elsif ( $e == 1001 ) {
                    my @hostnames = ( $cert->{subject}->{cn} );
                    my $str_hostnames = "";

                    # If SubjectAltName is present, the clients are supposed to ignore the Common Name.
                    #
                    # TODO: Perhaps check if SubjectAltName includes the CN, and warn if it doesn't. But
                    # this is really an improperly created certificate, so the value of telling the user
                    # that is limited.

                    if ( exists $cert->{extensions}->{altnames} ) {
                        @hostnames = ();

                        foreach my $ent ( @{ $cert->{extensions}->{altnames} } ) {
                            push @hostnames, values(%$ent);
                        }
                    }

                    while(@hostnames) {
                        if ( $str_hostnames ) {
                            if ( scalar @hostnames > 1 ) {
                                $str_hostnames .= ", ";
                            } else {
                                $str_hostnames .= " " . $self->_t("and") . " ";
                            }
                        }

                        $str_hostnames .= shift(@hostnames);
                    }

                    $err_desc .= sprintf($self->_t("Hostname verification failed.\nThe cert is only valid for %s"), $str_hostnames);
                    _add_advice(\@advice, $self->_t("This certificate belongs to another host. ".
                            "This is a sign of either misconfiguration or an ongoing attempt to compromise security."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_bad_host');
                } elsif ( $e == 1002 ) {
                    # sig_algo contains something like: md5WithRSAEncryption. 
                    # Extract the hash part from it.
                    my $hash = $cert->{sig_algo};
                    $hash =~ m/^(\w+\d+)/;

                    $err_desc .= sprintf($self->_t("Insecure hash algorithm: %s"), $1);
                    _add_advice(\@advice, $self->_t("This certificate uses a deprecated and insecure hash algorithm. ".
                            "It should be replaced with a new one as soon as possible."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_insecure_sign_algo');
                } elsif ( $e == 1003 ) {
                    $err_desc .= sprintf($self->_t("Weak key: %s bits"), $cert->{bit_length});
                    _add_advice(\@advice, $self->_t("This certificate uses a weak key and can be broken by brute force. ".
                            "It should be replaced with a stronger one as soon as possible."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_weak_key');
                } elsif ( $e == 2001 ) {
                    $err_desc .= $self->_t("The certificate has been revoked");
                    _add_advice(\@advice, $self->_t("The certificate has been revoked by its issuing authority. A new certificate is required."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_revoked');
                } elsif ( $e == 2100 ) {
                    $err_desc .= $self->_t("OCSP server internal error");
                    _add_advice(\@advice, $self->_t("The OCSP server returned an internal error. It wasn't possible to determine whether the certificate has been revoked. This may be a temporary error, and can be ignored."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_ocsp_server_failure');
                } elsif ( $e == 2101 ) {
                    $err_desc .= $self->_t("Failed to make OCSP request");
                    _add_advice(\@advice, $self->_t("It wasn't possible to contact the OCSP server to determine whether the certificate has been revoked. This is likely a temporary error, and can be ignored."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_ocsp_server_failure');
                } elsif ( $e == 2102 ) {
                    $err_desc .= $self->_t("OCSP signer certificate not found");
                    _add_advice(\@advice, $self->_t("The OCSP server uses an unrecognized certificate. This may be a misconfiguration, and can be ignored."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_ocsp_server_failure');
                } elsif ( $e == 2103 ) {
                    $err_desc .= $self->_t("OCSP server certificate lacks OCSP extension");
                    _add_advice(\@advice, $self->_t("The OCSP server uses an incorrect certificate. This is likely a misconfiguration, and can be ignored."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_ocsp_server_failure');
                } elsif ( $e == 2104 ) {
                    $err_desc .= $self->_t("OCSP CA not trusted");
                    _add_advice(\@advice, $self->_t("The OCSP server uses a certificate signed by an untrusted CA. This may be a misconfiguration, and can be ignored."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_ocsp_server_failure');
                } elsif ( $e == 2105 ) {
                    $err_desc .= $self->_t("OCSP answer signed with unrecognized certificate");
                    _add_advice(\@advice, $self->_t("The OCSP server uses a certificate signed by an untrusted CA. This may be a misconfiguration, and can be ignored."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_ocsp_server_failure');
                } elsif ( $e == 2200 ) {
                    $err_desc .= $self->_t("Unrecognized OCSP problem");
                    _add_advice(\@advice, $self->_t("The OCSP server returned an unrecognized error code."));
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_ocsp_server_failure');

                } else {
                    $err_desc .= sprintf($self->_t("Unrecognized SSL error."), $e);
                    $no_ok_button = 1 unless core_cfg('client.ssl.allow_unknown_error');
                }

                my $hsizer = Wx::BoxSizer->new(wxHORIZONTAL);
                my $excl = Wx::StaticText->new($info_panel, -1, "    " . chr(0x26A0));

                $font = $excl->GetFont();
                $font->SetWeight(wxFONTWEIGHT_BOLD);
                $excl->SetFont($font);
                $excl->SetForegroundColour(wxRED);
                $hsizer->Add($excl, 0, wxALL, 5);



                $hsizer->Add(Wx::StaticText->new($info_panel, -1, $err_desc), 0, wxALL, 5);
                $problems_sizer->Add($hsizer, 0, wxALL, 0);
            }
        }


        my $info = [];
        push @$info,  { $self->_t("Certificate for") => _format_aligned( _cert_fullname($cert, $cert->{subject}), "\t") };
        push @$info,  { $self->_t("Issued by") => _format_aligned( _cert_fullname($cert, $cert->{issuer}), "\t") };

        if ( exists $cert->{extensions}->{altnames} ) {
            push @$info, { $self->_t("Alternative names") => _format_aligned($cert->{extensions}->{altnames}, "\t") };
        }

        if ( exists $cert->{extensions}->{cert_type} ) {
            my $ct = $cert->{extensions}->{cert_type};
            push @$info, { $self->_t("Uses") => join(", ", grep { $ct->{$_} } keys %$ct) };
        }

        push @$info, { $self->_t("Bit length") => $cert->{bit_length} };
        push @$info, { $self->_t("Signature algorithm") => $cert->{sig_algo} };

        foreach my $algo ( keys %{ $cert->{fingerprint} } ) {
            push @$info,  {  $self->_t("Fingerprint") . " ($algo)" => $cert->{fingerprint}->{$algo} };
        }
        push @$info,  { $self->_t("Hash")        => $cert->{hash} };
        push @$info,  { $self->_t("Serial")      => $cert->{serial} };
        push @$info,  { $self->_t("Valid from")  => $cert->{not_before} };
        push @$info,  { $self->_t("Valid until") => $cert->{not_after} };

        if ( $cert_data ){
            $cert_data .= "\n---\n\n";
        }
        $cert_data .= _format_aligned($info);

    }

    if (@advice) {
        $info_sizer->Add(Wx::StaticText->new($info_panel, -1, $self->_t('Recommendations:')), 0, wxALL, 5);
        foreach my $line (@advice) {
            $info_sizer->Add(Wx::StaticText->new($info_panel, -1, "  " . chr(0x2022) . " " . $line), 0, wxALL, 5);
        }

    }


    if ( $details_sizer ) {
        my $tc = Wx::TextCtrl->new($details_panel, -1, $cert_data, wxDefaultPosition, [600,300], wxTE_MULTILINE|wxTE_READONLY);
        $tc->SetFont (Wx::Font->new(10, wxDEFAULT, wxNORMAL, wxNORMAL, 0, 'Courier New'));
        $details_sizer->Add($tc, 1, wxALL|wxEXPAND, 5);
    }

    my $but_clicked = sub {
        lock $accept_cert;
        my $do_accept = shift;
        $accept_cert = $do_accept; # ($do_accept and ($cert_data ne ""));
        cond_signal $accept_cert;
        $dialog->EndModal(0);
        $dialog->Destroy();
    };

    my $bsizer = Wx::BoxSizer->new(wxHORIZONTAL);

    my $but_ok;
    my $but_ok_permanent;
    unless ($no_ok_button) {
        $but_ok     = Wx::Button->new($dialog, -1, $self->_t('Accept temporarily')) ;
        Wx::Event::EVT_BUTTON($dialog, $but_ok    ->GetId, sub { $but_clicked->(1) });
        $bsizer->Add($but_ok, 0, wxALL, 5);

        $but_ok_permanent = Wx::Button->new($dialog, -1, $self->_t('Accept permanently')) ;
        Wx::Event::EVT_BUTTON($dialog, $but_ok_permanent->GetId, sub { $but_clicked->(2) });
        $bsizer->Add($but_ok_permanent, 0, wxALL, 5);

    }


    my $but_cancel = Wx::Button->new($dialog, -1, $self->_t('Cancel'));
    Wx::Event::EVT_BUTTON($dialog, $but_cancel->GetId, sub { $but_clicked->(0) });
    $bsizer->Add($but_cancel, 0, wxALL, 5);
    $main_sizer->Add($bsizer);

    $dialog->SetSizer($main_sizer);
    $main_sizer->Fit($dialog);

    $self->{timer}->Stop();


    if ( $but_ok ) {
        $but_ok->SetDefault;
    } else {
        $but_cancel->SetDefault;
    }


    if ( !$no_ok_button && core_cfg('client.ssl.error_timeout') > 0 ) {
        my $timeout = core_cfg('client.ssl.error_timeout');

        $but_ok->Enable(0);
        $but_ok_permanent->Enable(0);

        Wx::Event::EVT_TIMER($dialog, -1, \&OnCertDialogTimer);
        my $timer = Wx::Timer->new($dialog);
        $dialog->{accept_countdown} = $timeout;
        $dialog->{ok_button} = $but_ok;
        $dialog->{save_button} = $but_ok_permanent;
        $dialog->{ok_orig_text} = $but_ok->GetLabel();
        $dialog->{save_orig_text} = $but_ok_permanent->GetLabel();
        $dialog->{timer} = $timer;
        $but_ok->SetLabel( $dialog->{ok_orig_text} . " ($timeout)" );
        $but_ok_permanent->SetLabel( $dialog->{save_orig_text} . " ($timeout)" );



        $timer->Start(1000,0);
    }



    $dialog->SetEscapeId( $but_cancel->GetId );

    $dialog->ShowModal();

    if ( $dialog->{timer} ) {
        $dialog->{timer}->Stop();
    }

    $self->{timer}->Start();

    { lock $accept_cert; cond_signal $accept_cert; }
}

sub OnCertDialogTimer {
    my $self = shift;

    $self->{accept_countdown}--;

    if ( $self->{accept_countdown} <= 0 ) {
        $self->{ok_button}->Enable(1) if ($self->{ok_button});
        $self->{save_button}->Enable(1) if ($self->{save_button});

        $self->{ok_button}->SetLabel( $self->{ok_orig_text} );
        $self->{save_button}->SetLabel( $self->{save_orig_text} );
        $self->{timer}->Stop();

    } else {
        $self->{ok_button}->SetLabel( $self->{ok_orig_text} . " ($self->{accept_countdown})" );
        $self->{save_button}->SetLabel( $self->{save_orig_text} . " ($self->{accept_countdown})" );
    }


}
sub OnTimer {
    my $self = shift;
    $self->{progress_bar}->Pulse;
}

sub OnExit {
    my $self = shift;
    if ( $self->{worker_thread} && $self->{worker_thread}->is_running() ){
        undef %connect_info ;
        cond_signal(%connect_info);
        $self->{worker_thread}->join();
    }

    $self->SaveConfiguration();
    if ( $self->{worker_thread} && $self->{worker_thread}->is_running() ){
        undef %connect_info ;
        cond_signal(%connect_info);
        $self->{worker_thread}->join();
    }

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

sub OnAlert {
    my ($self, $event) = @_;
    my $args = $event->GetData();
    DEBUG "Alert: start";


    my $flags = wxOK;

    if ( $args->{level} =~ /warn/i ) {
        $flags |= wxICON_WARNING;
        WARN "$args->{title}: $args->{message}";
    } elsif ( $args->{level} =~ /err/i ) {
        $flags |= wxICON_ERROR;
        ERROR "$args->{title}: $args->{message}";
    } elsif ( $args->{level} =~ /notice/i ) {
        $flags |= wxICON_INFORMATION;
        INFO "$args->{title}: $args->{message}";
    } else {
        $flags |= wxICON_ERROR;
        ERROR "$args->{title}: $args->{message}";
        ERROR "Unknown alert level '$args->{type}' for the previous message.";
    }

    my $type = $args->{type} // "notice";

    if ( $^O =~ /linux/ || $type eq "dialog" ) {
        # Wx::NotificationMessage currently pops up a rather odd and ugly
        # window on Linux instead of using the actual notification capability
        # of desktops like Gnome and KDE
        my $dialog = Wx::MessageDialog->new($self,
                                            $self->_t( $args->{message} ),
                                            $self->_t( $args->{title} // "QVD Client" ),
                                            $flags);
        $dialog->ShowModal();
        $dialog->Destroy();
    } elsif ( $type eq "notice" ) {
        my $tm = $self->_t( $args->{message} );
        my $tt = $self->_t( $args->{title} // "QVD Client" );

        my $notice = Wx::NotificationMessage->new($tm, $tt, $self, $flags);
        $notice->Show();
    } else {
        ERROR "Unknown alert type '$type' for the previous message.";
    }


    lock $proxy_alert;
    $proxy_alert = 1;
    cond_signal $proxy_alert;
}

sub try_load_usbip {
    eval {
        require Linux::USBIP;
    };
    if ( $@ ) {
        DEBUG "try_load_usbip: Got: $@";
        return 0;
    }

    return 1;
}

sub load_usb_devices {
    my ($self) = shift;
    
    my @devices = list_devices();
    my @selected;

    foreach my $d ( @devices ){

        my $dev = $d->{vendor} . " " . $d->{product}
            .  " (" . $d->{vid} . ":" . $d->{pid}
            . ( $d->{serial} ? '@' . $d->{serial} : "") . ")";
        push @{$self->{usb_devices}} , $dev;
    }

    $self->{usbip_device_list}->InsertItems( $self->{usb_devices}, 0 ) if ( core_cfg('client.show.settings') );



    # Build selection list from our saved config

    my $cursel = core_cfg('client.usb.share_list', '');
    my @parts = split(/,/, $cursel);

    foreach my $part (@parts) {
        my ($v, $p, $id);
        $part =~ s/^\s+//;
        $part =~ s/\s+$//;

        ($v, $p) = split(/:/, $part);
        ($p, $id) = split(/@/, $p) if ( $p =~ /@/ );

        my $is_connected=0;
        for(my $i=0;$i<=scalar @devices;$i++) {
            my $d = $devices[$i];
            if ( $d->{vid} eq $v && $d->{pid} eq $p && (!defined $id || $d->{serial} eq $id)) {
                push @selected, $i;
                $is_connected=1;
            }
        }
        if ( ! $is_connected ) {
            # Make sure we don't forget about devices although they're not connected now
            push @{$self->{disconnected_usb_devices}}, $v.":".$p.( defined $id ? "@".$id : '');
        }
    }

    foreach my $i (@selected){
        $self->{usbip_device_list}->Check($i,1);
    }

}

sub share_add {
    my ($self) = @_;
    my $dialog = Wx::DirDialog->new($self, $self->_t("Select the folder to share"), "");
    $dialog->ShowModal();
    my $selected = $dialog->GetPath();

    if ( $selected ) {
        push @{ $self->{shares} }, $selected;
        $self->update_share_list();
    }
}

sub share_del {
    my ($self) = @_;

    my ($first_selection) = $self->{share_list}->GetSelections();
    $self->{share_list}->Delete($first_selection);
    splice @{$self->{shares}}, $first_selection,1;
}


################################################################################
#
# Helpers
#
################################################################################


sub update_share_list() {
    my ($self) = @_;

    $self->{shares} //= [];
    my %tmp = map { $_ => 1 } @{$self->{shares}};
    $self->{shares} = [ sort keys %tmp ];
    $self->{share_list}->Clear();
    $self->{share_list}->InsertItems( $self->{shares}, 0 );

}


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
            my $xhostparam = core_cfg('command.xhost.family') eq "local" ? "+local:" : "+si:localuser:$user" ;
            system $xhost, $xhostparam;
            DEBUG("xhost $xhostparam executed for $user");
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
    if (!core_cfg('client.force.link',      0)) { $self->{link}->Enable($enabled) if( core_cfg('client.show.settings') ); }
    if (!core_cfg('client.force.host.name', 0)) { $self->{host}->Enable($enabled) if( core_cfg('client.show.settings') ); }
}

sub SaveConfiguration {
    my $self = shift;
    if (core_cfg('client.remember_username')) {
        set_core_cfg('client.user.name', $self->{username}->GetValue());
    } else {
        # If remembering the username is disabled, erase any previously stored value
        set_core_cfg('client.user.name', "");
    }
    if (!core_cfg('client.force.host.name', 0) and $self->{host}) {
        set_core_cfg('client.host.name', $self->{host}->GetValue());
    }
    #set_core_cfg('client.host.port', $self->{port}->GetValue());
    if (!core_cfg('client.force.link', 0) and $self->{link}) {
        set_core_cfg('client.link', lc($self->{link}->GetStringSelection()));
    }

    if ($self->{remember_pass}) {
        set_core_cfg('client.remember_password', ($self->{remember_pass}->IsChecked() ? 1 : 0));
    }

    if ($self->{usbip_device_list}) {
        my $usb_list;
        # If it was checked, save it
        foreach my $usb_t ( @{ $self->{usb_devices} } ){
            if ( $self->{usbip_device_list}->IsChecked( $self->{usbip_device_list}->FindString($usb_t) ) ){
                my $usb = $usb_t;  # Do not modify the original contents of usb_devices
                $usb =~ s/.*\((.*)\)/$1/;
                $usb_list .= "," if ( $usb_list );
                $usb_list .= $usb ;
            }
        }
        # If it is in the disconnected list, it was checked before. Don't forget about it
        foreach my $disconnected ( @{ $self->{disconnected_usb_devices} } ){
            $usb_list .= "," if ( $usb_list );
            $usb_list .= $disconnected;
        }
        set_core_cfg('client.usb.share_list', ($usb_list ? $usb_list : "") );
        set_core_cfg('client.usb.enable', $self->{usb_redirection}->GetValue());
    }

    # The widgets only exist if the settings tab is enabled.
    set_core_cfg('client.audio.enable', $self->{audio}->GetValue())       if ( $self->{audio} );
    set_core_cfg('client.printing.enable', $self->{printing}->GetValue()) if ( $self->{printing} );
    set_core_cfg('client.fullscreen', $self->{fullscreen}->GetValue())    if ( $self->{fullscreen} );
    set_core_cfg('client.slave.enable', $self->{forwarding}->GetValue())  if ( $self->{forwarding} );

    #set_core_cfg('client.geometry', $self->{geometry}->GetValue());

    set_core_cfg('client.file_sharing.enable', $self->{share_enable}->IsChecked() ? 1 : 0) if ($self->{share_enable});

    my $share_num=0;
    foreach my $share (@{ $self->{shares} }) {
        set_core_cfg("client.share.$share_num", $share);
        $share_num++;
    }

    set_core_cfg("client.share.$share_num", "");

    local $@;
    eval { save_core_cfg($QVD::Client::App::user_config_fn) };
    if ($@) {
        my $message = $@;
        my $dialog = Wx::MessageDialog->new($self, $message,
            $self->_t("Error saving configuration"), wxOK | wxICON_ERROR);
        $dialog->ShowModal();
        $dialog->Destroy();
    }
    else {
        INFO "Configuration saved to $QVD::Client::App::user_config_fn";
    }
}


sub load_share_list {
    my ($self) = @_;
    $self->{shares} = [];


    if ( core_cfg("client.share.0", 0) ne "" ) {
        my $num = 0;
        my $dir;
        while( ($dir = core_cfg("client.share.$num", 0)) ne "" ) {
            push @{$self->{shares}}, $dir;
            $num++;
        }
    } else {
        if ($WINDOWS) {
            # User's home + all drives
            push @{ $self->{shares} }, $ENV{USERPROFILE};
            DEBUG "Sharing user profile: $ENV{USERPROFILE}";

            eval "use Win32API::File";
            for my $drive (Win32API::File::getLogicalDrives()) {
                my $dt = Win32API::File::GetDriveType($drive);
                if (!-d $drive) {
                    DEBUG "Not sharing $drive: not a directory";
                    next;
                }

                unless($dt == Win32API::File::DRIVE_REMOVABLE() || $dt == Win32API::File::DRIVE_CDROM()) {
                    DEBUG "Not sharing $drive: not removable nor CD-ROM. Type: $dt";
                    next;
                }

                push @{$self->{shares}}, $drive;
            }
        } else {
            # User's home + /media
            push @{$self->{shares}}, $ENV{HOME};
            push @{$self->{shares}}, '/media' if -e '/media';
            push @{$self->{shares}}, '/Volumes' if -e '/Volumes'; # For OS X
        }
    }
 DEBUG "Shares: @{$self->{shares}}";
    $self->update_share_list() if ( core_cfg('client.show.settings') );

}

sub _slave_client_invoke {
    my $self = shift;
    my $method = shift;

    require QVD::Client::SlaveClient;
    for (reverse 0..10) {
        eval { QVD::Client::SlaveClient->new()->$method(@_) };
        last unless $@ =~ /ECONNREFUSED|EPIPE/;
        DEBUG "Unable to mount share: $@";
        sleep 1 if $_;
    }

    if ($@) {
        ERROR $@;
        $@ =~ /\bServer\s+replied\s+(\d+)\b/i;
        return ($1 // 500);
    }
    return 200;
}

sub start_file_sharing {
    my $self = shift;

    unless (core_cfg('client.slave.enable') and
            core_cfg('client.file_sharing.enable')) {
        INFO "Slave channel or file sharing is disabled, not exporting local shares into the remote VM";
        return;
    }
    INFO "Exporting local shares into remote VM";

    for my $share (@{ $self->{shares} }) {
        INFO "Starting folder sharing for $share";
        local $@;
        my $code = $self->_slave_client_invoke(handle_share => $share);
        if ($code == 200) {
            DEBUG "Share $share exported into VM";
        }
        else {
            ERROR "Unable to mount share $share: [$code] $@";
            my $message = sprintf($self->_t("Failed to mount share %s:"), $share) . ' ' . $@;
            $self->_add_error($self->_t("File sharing"), $message); 
        }
    }
}

sub start_device_sharing {
    my ($self) = @_;

    if (core_cfg('client.slave.enable') && core_cfg('client.usb.enable')) {

        INFO "USBIP sharing starting";
        use QVD::Client::SlaveClient;
        my @devs = map { $_ } split(/,/, core_cfg('client.usb.share_list'));
        foreach my $devid (@devs) {
            my $busid = get_busid($devid);
            unless ($busid){
                DEBUG "Can't find busid for device $devid";
                next;
            }
            for my $conn_attempt (0..10) {
                local $@;
                my $client = QVD::Client::SlaveClient->new();
                eval { $client->handle_usbip($busid) };
                    if ($@) {
                        my $errmsg = $self->_t("Unknown USB/IP error");

                        if ($@ =~ 'ECONNREFUSED' || $@ =~ 'EPIPE' ) {
                            sleep 1;
                            next;
                        }

                        if ( $@ =~ /Failed to bind/ ) {
                            my ($err, $usbip_out) = split(/\n/, $@);

                            DEBUG "USBIP command returned error: $err";
                            DEBUG "Error message: $usbip_out";

                            if ( $usbip_out =~ /not bound to usbip-host driver, but to (.*?):/ ) {
                                $errmsg = $self->_t("Failed to connect device to USB/IP driver. USB/IP support may not be available.");
                            } elsif ( $usbip_out =~ /already in use/ ) {
                                $errmsg = $self->_t("Device is already in use by another application.");
                            } elsif ( $usbip_out =~ /Unable to find an unused USB-IP port/ ) {
                                $errmsg = $self->_t("Unable to find an USB-IP port. You need to use a kernel with the QVD patch.");
                            } elsif ( $usbip_out =~ /driver\/unbind: No such file or directory/ ) {
                                $errmsg = $self->_t("Unable to detach the device from the system");
                            } else {
                                WARN "Didn't find a match for message";
                                $errmsg = $self->_t("Unknown USP/IP problem: ") . $usbip_out;
                            }
                        } else {
                            ERROR "Unidentified error in USBIP: $@";
                        }

                        $self->_add_error($self->_t("USB sharing"), sprintf($self->_t("Failed to share device %s: %s"), $devid, $errmsg));
                        ERROR $@;
                    } else {
                        push @{$self->{usbip_shared_buses}},$busid;
                        DEBUG("Device sharing started for dev: $devid connected at bus: $busid");
                    }
                last;
            }
        }
    }
}

sub stop_device_sharing {
    my ($self) = @_;

    if (core_cfg('client.slave.enable') && core_cfg('client.usb.enable') && try_load_usbip ) {

        my $command_usbip = core_cfg('client.slave.command.qvd-client-slaveclient-usbip');

        INFO "USBIP sharing stopping";
        while ( my $busid = shift @{$self->{usbip_shared_buses}}) {
            if ( system($command_usbip,'unbind',$busid) ){
              ERROR "Can't unbind $busid";
            }else{
              DEBUG "Device with busid: $busid was successfully unbound from usbip driver";
            }
        }

    }
}

sub start_remote_mounts {
	my $self = shift;

    unless (core_cfg('client.slave.enable')) {
		INFO"Slave channel disabled, remote mounts  won't be started";
		return;
	}INFO "Starting remote mounts";

    for my $num (map /^client\.mount\.(\d+)\.remote$/, core_cfg_keys) {
        local $@;
		my $remote_dir = core_cfg("client.mount.$num.remote", 0)// next;
		my $local_dir  = core_cfg("client.mount.$num.local", 0)//
					next;
				

                my $message = sprintf($self->_t("Failed to mount remote folder %s at %s:"), $remote_dir, $local_dir) . "\n\n";
                if ( $@ =~ /Server replied 404/ ) {
                    $message .= sprintf($self->_t("Path %s was not found on the VM"), $remote_dir);
                } elsif ( $@ =~ /Server replied 403/ ) {
                    $message .= sprintf($self->_t("Path %s is forbidden on the VM"), $remote_dir);
                } elsif ( $@ =~ /Server replied 501/ ) {
                    $message .= $self->_t("VM lacks file sharing support. Please install the qvd-sshfs package.");
                } else {
                    $message .= $self->_t("Unrecognized error, full error message follows:") .  "\n\n$@";
                }

				INFO "Mounting remote directory $remote_dir at $local_dir";

        my $code = $self->_slave_client_invoke(handle_mount => $remote_dir, $local_dir);

        if ($code == 200) {
            DEBUG "Remote directory $remote_dir mounted at $local_dir";
        }
        else {
            ERROR "Unable to mount remote directory $remote_dir at $local_dir: [$code] $@";
            my $reason = (($code == 404) ? sprintf($self->_t("Path %s was not found on the VM"), $remote_dir) :
                          ($code == 403) ? sprintf($self->_t("Path %s is forbidden on the VM"), $remote_dir)  :
                          ($code == 501) ? $self->_t("VM lacks file sharing support. Please install the qvd-sshfs package.") :
                          $self->_t("Unrecognized error, full error message follows:")."\n\n$@");
            my $message = sprintf($self->_t("Failed to mount remote folder %s at %s:"),
                                  $remote_dir, $local_dir)." ".$reason;

            $self->_add_error($self->_t("Remote mounts", $message));
        }
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

sub _t {
    my ($self, @args) = @_;
    return $self->{domain}->get(@args);
}

sub _cert_name {
    my ($cert, $object) = @_;
    my $ret;
    if ( exists $cert->{extensions}->{cert_type} ) {
        my $ct = $cert->{extensions}->{cert_type};
        $ret = "[" . join(", ", grep { $ct->{$_} } keys %$ct) . "] ";
    }

    $ret .= "$object->{cn}";
    return $ret;
}

sub _cert_fullname {
    my ($cert, $object) = @_;
    my @ret;
    my $types;

    # Keeps things sorted
    push @ret, { 'Common Name (CN)'        => $object->{cn} };
    push @ret, { 'Organization (O)'        => $object->{o}  };
    push @ret, { 'Organizational Unit (OU)'=> $object->{ou} };
    push @ret, { 'Location (L)'            => $object->{l}  };
    push @ret, { 'Country (C)'             => $object->{c}  };

    return \@ret;
}

sub _format_aligned {
    my ($data, $indent) = @_;
    my $maxlen = 0;
    my $ret;
    $indent //= "";

    foreach my $row (@$data) {
        my ($k) = keys(%{$row});
        $maxlen = length($k) if ( $maxlen < length($k));
    }

    foreach my $row (@$data) {
        my ($k) = keys(%{$row});
        my $v = $row->{$k};

        $ret .= $indent . $k . (" " x ($maxlen-length($k))) . ": ";
        if ( $v =~ /\n/ ) {
            $ret .= "\n";
        }

        if ( $v =~ /^([A-F0-9]{2}:?)+$/i ) {
            # Format fingerprints in a more readable way
            my @bytes = split(/:/, $v);
            my $count;
            while(my $byte = shift @bytes) {
                $ret .= "$byte ";
                $count++;

                $ret .= " " if ( $count % 4 == 0);
                $ret .= " " if ( $count % 8 == 0);
                $ret .= "\n" . (" "x($maxlen+2)) if ( $count % 16 == 0 && scalar @bytes);
            }

            $ret .= "\n"; # unless ( $count % 16 == 0 ); # Already added a newline in the loop
        } else {
            $ret .= "$v\n";
        }

    }

    return $ret;
}

sub _add_advice {
    my ($aref, $advice) = @_;
    foreach my $line (@$aref) {
        return if $line eq $advice;
    }

    push @$aref, $advice;
}


sub _clear_errors {
    my ($self) = @_;

    DEBUG "Clearing error list";
    $self->{errors} = {};
}

sub _add_error {
    my ($self, $category, $error) = @_;

    DEBUG "Adding error of category $category: $error";

    $self->{errors} //= {};
    $self->{errors}->{$category} //= [];
    push @{ $self->{errors}->{$category} }, $error;
}

sub _show_errors {
    my ($self) = @_;

    my @lines;

    DEBUG "Showing errors";
    foreach my $category ( sort keys %{ $self->{errors} } ) {
        foreach my $err ( @{ $self->{errors}->{$category} } ) {
            push @lines, $err;
        }
    }

    if ( @lines ) {
        my $text = $self->_t("Errors during connection:") . "\n\n";
        $text .= join("\n", @lines);

        my $dialog = Wx::MessageDialog->new($self, $text,
                                            $self->_t(""), wxOK | wxICON_ERROR);
        $dialog->ShowModal();
        $dialog->Destroy();
    }

    $self->_clear_errors;
}

1;
