#!/usr/bin/perl

use 5.022;
use strict;
use warnings;
use Win32::Packer;
use Log::Any::Adapter;
use Getopt::Long;
use Path::Tiny;
use Alien::wxWidgets;

my $installer_path = path($0)->realpath->parent;
my $qvd_src_path = $installer_path->parent->parent;
my $ext_path = $qvd_src_path->child('ext');
my $work_path = $installer_path->child('wd');
my $logs_path = $work_path->child('logs');
$logs_path->mkpath;

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

my $cygwin;
my $cygdrive;
my $qvd_version = '4.x';
my $installer_type = 'zip';
my $output_dir;

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
           'cygwin=s' => \$cygwin,
           'cygdrive=s' => \$cygdrive,
           'qvd-version|V=s' => \$qvd_version,
           'output-dir|output|o=s' => \$output_dir,
           'store=s' => \$store,
           'retrieve=s' => \$retrieve,
          );

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

    my @extra_exes = ( { path => $nx_libs_path->child('nxproxy/nxproxy.exe'),
                         search_path => $nx_libs_path->child('nxcomp'),
                         subdir => 'nx',
                         subsystem => 'windows',
                         cygwin => 1 },
                       { path => $win_sftp_server_path->child('win-sftp-server.exe'),
                         subsystem => 'windows' },
                     );

    my @extra_dirs = ( { path => $installer_path->child('pixmaps')->stringify },
                       { path => $vcxsrv_path, subdir => 'vcxsrv' },
                       { path => $pulseaudio_path, subdir => 'pulseaudio' },
                     );

    my @qvd_client_modules = qw(QVD::Client QVD::Config::Core QVD::Config
                                QVD::HTTP QVD::HTTPC QVD::HTTPD
                                QVD::Log QVD::SimpleRPC QVD::URI
                                IO::Socket::Forwarder);

    my $icon = $installer_path->child('pixmaps/qvd.ico')->stringify;

    my @extra_inc = grep -d $_, map $ext_path->child(s/::/-/gr)->child('lib'), @qvd_client_modules;

    my %args = (app_name => 'QVD Client',
                app_version => $qvd_version,
                scripts => $qvd_src_path->child('ext/QVD-Client/bin/qvd-gui-client.pl')->stringify,
                app_subsystem => 'windows',
                work_dir => "$work_path",
                extra_inc => \@extra_inc,
                extra_module => [qw(QVD::Client::SlaveClient::Windows
                                    Log::Dispatch::FileRotate
                                    Encode::Unicode
                                    Tie::Hash::NamedCapture
                                    PerlIO::encoding
                                    IO::Socket::IP
                                    X11::Auth
                                    X11::Protocol::Ext::XC_MISC)],
                extra_exe => \@extra_exes,
                extra_dir => \@extra_dirs,
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
if ($installer_type eq 'zip') {
    $im = $p->installer_maker(compression => 'deflated', compression_level => 'best');
}
else {
    $im = $p->installer_maker(type => $installer_type);
}

$p->store($store);

$im->run;
