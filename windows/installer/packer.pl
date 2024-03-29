#!/usr/bin/perl

use 5.022;
use strict;
use warnings;
use Win32::Packer;
use Log::Any::Adapter;
use Getopt::Long;
use Path::Tiny;
use Alien::wxWidgets;
use File::Glob qw(bsd_glob);

my $installer_path = path($0)->realpath->parent;
my $qvd_src_path = $installer_path->parent->parent;
my $ext_path = $qvd_src_path->child('ext');
my $work_path = $installer_path->child('wd');
my $logs_path = $work_path->child('logs');
$logs_path->mkpath;

my $license = $installer_path->child("LICENSE.RTF");

my $guid = '4a934fd2-bccc-402a-8f0e-96a3b42776f8'; # generated by someone, somewhere in summertime!

my ($store, $retrieve);

my $log_level = 'debug';
my $log_file = $logs_path->child('log.txt')->stringify;
my $keep_work_dir;
my $cache = $installer_path->child('cache')->stringify;
my $clean_cache;
my $nx_libs = $qvd_src_path->parent->child('nx-libs')->stringify;
my $vcxsrv = 'c:\\program files\\vcxsrv';

my $pulseaudio = $installer_path->child('pulseaudio');
my $win_sftp_server = $installer_path->child('win-sftp-server');
my $slaveserver_wrapper = $qvd_src_path->child('windows', 'qvd-slaveserver-wrapper');
my $gsview = 'c:\\program files\\ghostgum\\gsview';
my $ghostscript = bsd_glob('c:\\program files\\gs\\gs*');
my $cygwin;
my $cygdrive;
my $qvd_version = '4.2';
my $installer_type = 'zip';
my $output_dir;
my $update;
my $subsystem = 'windows';
my $mingw32 = 'c:\\msys32\\mingw32';


GetOptions('log-file|log|l=s' => \$log_file,
           'log-level|L=s' => \$log_level,
           'installer-type|type|t=s' => \$installer_type,
           'keep-work-dir|k' => \$keep_work_dir,
           'cache-dir|cache|c=s' => \$cache,
           'clean-cache|C' => \$clean_cache,
           'nx-libs=s' => \$nx_libs,
           'vcxsrv=s' => \$vcxsrv,
           'pulseaudio=s' => \$pulseaudio,
           'win-sftp-server=s' => \$win_sftp_server,
           'slaveserver-wrapper=s' => \$slaveserver_wrapper,
           'gsview=s' => \$gsview,
           'ghostscript|gs=s' => \$ghostscript,
           'cygwin=s' => \$cygwin,
           'cygdrive=s' => \$cygdrive,
           'mingw32=s' => \$mingw32,
           'qvd-version|V=s' => \$qvd_version,
           'output-dir|output|o=s' => \$output_dir,
           'guid=s' => \$guid,
           'store=s' => \$store,
           'retrieve=s' => \$retrieve,
           'update' => \$update,
           'subsystem=s' => \$subsystem,
          );

$keep_work_dir //= 1 if grep defined, $store, $retrieve;

# Log::Any::Adapter->set('Stderr', log_level => 'info');

path($log_file)->remove;
warn "logging into $log_file\n";
Log::Any::Adapter->set('File', "$log_file", log_level => $log_level);
my $log = Log::Any->get_logger;

my $p;
if (defined $retrieve) {
    $p = Win32::Packer->retrieve($retrieve, $log);
}
else {

    -d $nx_libs or die "$nx_libs not found";
    my $nx_libs_path = path($nx_libs)->realpath;
    -d $vcxsrv or die "$vcxsrv not found";
    my $vcxsrv_path = path($vcxsrv)->realpath;
    -d $win_sftp_server or die "$win_sftp_server not found";
    my $win_sftp_server_path = path($win_sftp_server)->realpath;
    -d $pulseaudio or die "$pulseaudio not found";
    my $pulseaudio_path = path($pulseaudio)->realpath;
    -d $slaveserver_wrapper or die "$slaveserver_wrapper not found";
    my $slaveserver_wrapper_path = path($slaveserver_wrapper)->realpath;
    -d $gsview or die "$gsview not found";
    my $gsview_path = path($gsview)->realpath;
    defined $ghostscript or die "ghostscript not found";
    -d $ghostscript or die "$ghostscript not found";
    my $ghostscript_path = path($ghostscript)->realpath;
    my $mingw32_path = path($mingw32)->realpath;
    -d $mingw32_path or die "$mingw32 not found";

	my @pulse_search_path = ($pulseaudio_path);

    my @extra_exes = ( { path => $nx_libs_path->child('libexec/nxproxy.exe'),
                         search_path => $nx_libs_path->child('bin'),
                         subdir => 'bin',
                         subsystem => 'windows',
                         cygwin => 1 },
                       { path => $win_sftp_server_path->child('win-sftp-server.exe'),
                         subsystem => 'windows' },
                       { path => $slaveserver_wrapper_path->child('qvd-slaveserver-wrapper.exe'),
                         subsystem => 'windows',
                         subdir => 'bin',
                         cygwin => 1 },
                       { path => 'cygwin-console-helper.exe',
                         subdir => 'bin',
                         cygwin => 1 },
                       { path => $gsview_path->child('gsprint.exe'),
                         subdir => 'gsview',
                         subsystem => 'windows' },
                       { path => $ghostscript_path->child('bin', 'gswin32.exe'),
                         subdir => 'ghostscript/bin',
                         subsystem => 'windows' },
                       { path => $pulseaudio_path->child('pulseaudio.exe'),
                         subdir => 'pulseaudio',
                         subsystem => 'windows',
                         search_path => \@pulse_search_path },
                     );

    my @extra_dlls = map( { path => $_,
                            subdir => 'pulseaudio',
                            search_path => \@pulse_search_path },
                          $pulseaudio_path->children(qr/\.dll$/i) );

    my @extra_dirs = ( { path => $installer_path->child('pixmaps'), subdir => 'pixmaps' },
                       { path => $vcxsrv_path, subdir => 'vcxsrv' },
                       # { path => $pulseaudio_path, subdir => 'pulseaudio', skip => 'bin/pulseaudio.exe' },
                       { path => $ghostscript_path, subdir => 'ghostscript', skip => 'bin/gswin32.exe' },
                     );

    my @extra_files = map ( { path => $_,
                              subdir => 'pulseaudio' },
							 $pulseaudio_path->child('qvd.pa'));

    my @qvd_client_modules = qw(QVD::Client QVD::Config::Core QVD::Config
                                QVD::HTTP QVD::HTTPC QVD::HTTPD
                                QVD::Log QVD::SimpleRPC QVD::URI
                                IO::Socket::Forwarder
                                Net::Server Net::Server::Fork);

    my $icon = $installer_path->child('pixmaps/qvd.ico')->stringify;

    my @extra_inc = grep -d $_, map $ext_path->child(s/::/-/gr)->child('lib'), @qvd_client_modules;

    my %args = (app_name => 'QVD Client',
                app_vendor => 'Qindel Formación y Servicios SL',
                app_version => $qvd_version,
                app_id => $guid,
                license => $license,
                scripts => [ { path => $qvd_src_path->child('ext/QVD-Client/bin/qvd-gui-client.pl'),
                               shortcut => "QVD Client",
                               shortcut_description => "The QVD Client Application",
                               handles => { scheme => 'qvd',
                                            extension => '.qvd' } },
                             { path => $qvd_src_path->child('ext/QVD-Client/bin/qvd-client-slaveserver') } ],
                app_subsystem => $subsystem,
                work_dir => "$work_path",
                extra_inc => \@extra_inc,
                extra_module => [qw(QVD::Client::SlaveClient::Windows
                                    QVD::Client::SlaveServer::Windows
                                    Log::Dispatch::FileRotate
                                    Encode::Unicode
                                    Tie::Hash::NamedCapture
                                    PerlIO::encoding
                                    IO::Socket::IP
                                    X11::Auth
                                    X11::Protocol::Ext::XC_MISC)],
                extra_exe => \@extra_exes,
                extra_dir => \@extra_dirs,
                extra_file => \@extra_files,
                extra_dll => \@extra_dlls,
                merge => [ { path => 'vcxsrv/vcxsrv.exe', firewall_allow => 'localhost' },
                           { path => 'pulseaudio/pulseaudio.exe', firewall_allow => 'localhost' } ],
                keep_work_dir => $keep_work_dir,
                cache => $cache,
                clean_cache => $clean_cache,
                icon => $icon,
                cygwin => $cygwin,
                cygdrive => $cygdrive,
                search_path => 'c:\strawberry\win-builds\bin',
                output_dir => $output_dir,
               );

    delete $args{$_} for grep !defined $args{$_}, keys %args;
    $log->tracef("Win32::Packer args: %s", \%args);

    $p = Win32::Packer->new(%args);
}

my $im;
my @im_args = (type => $installer_type);
if ($installer_type eq 'zip') {
    push @im_args, (compression => 'deflated', compression_level => 'best')
}
elsif ($installer_type eq 'dir') {
    push @im_args, update => 1 if $update;
}
$im = $p->installer_maker(@im_args);
$p->store($store);
$im->run;
