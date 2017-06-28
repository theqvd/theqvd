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

my $log_level = 'debug';
my $log_file = $logs_path->child('log.txt')->stringify;
my $keep_work_dir;
my $cache = $installer_path->child('cache')->stringify;
my $clean_cache;
my $nx_libs = $qvd_src_path->parent->child('nx-libs')->stringify;
my $vcxsrv = 'c:\\program files\\vcxsrv';
my $cygwin;
my $cygdrive;

GetOptions('log-file|log|l=s' => \$log_file,
           'log-level|L=s' => \$log_level,
           'keep-work-dir|k' => \$keep_work_dir,
           'cache-dir|cache|c=s' => \$cache,
           'clean-cache|C' => \$clean_cache,
           'nx-libs|n=s' => \$nx_libs,
           'vcxsrv|x=s' => \$vcxsrv,
           'cygwin=s' => \$cygwin,
           'cygdrive=s' => \$cygdrive,
          );

# Log::Any::Adapter->set('Stderr', log_level => 'info');

path($log_file)->remove;
warn "logging into $log_file\n";
Log::Any::Adapter->set('File', "$log_file", log_level => $log_level);
my $log = Log::Any->get_logger;

-d $nx_libs or die "$nx_libs not found";
my $nx_libs_path = path($nx_libs)->realpath;
-d $vcxsrv or die "$vcxsrv not found";
my $vcxsrv_path = path($vcxsrv)->realpath;

my @extra_exes = ( { path => $nx_libs_path->child('nxproxy/nxproxy.exe')->stringify,
                     search_path => $nx_libs_path->child('nxcomp')->stringify,
                     subdir => 'nxproxy',
                     cygwin => 1},

                   { path => $vcxsrv_path->child('vcxsrv.exe')->stringify,
                     subdir => 'vcxsrv' } );

my @extra_dirs = ( { path => $installer_path->child('pixmaps')->stringify } );

my @qvd_client_modules = qw(QVD::Client QVD::Config::Core QVD::Config
                         QVD::HTTP QVD::HTTPC QVD::HTTPD
                         QVD::Log QVD::SimpleRPC QVD::URI
                         IO::Socket::Forwarder);

my @extra_inc = grep -d $_, map $ext_path->child(s/::/-/gr)->child('lib'), @qvd_client_modules;

my %args = (app_name => 'QVD Client',
            scripts => $qvd_src_path->child('ext/QVD-Client/bin/qvd-gui-client.pl')->stringify,
            work_dir => "$work_path",
            extra_inc => \@extra_inc,
            extra_module => [qw(Log::Dispatch::FileRotate
                                Tie::Hash::NamedCapture
                                PerlIO::encoding)],
            extra_exe => \@extra_exes,
            extra_dir => \@extra_dirs,
            keep_work_dir => $keep_work_dir,
            cache => $cache,
            clean_cache => $clean_cache,
            cygwin => $cygwin,
            cygdrive => $cygdrive);

delete $args{$_} for grep !defined $args{$_}, keys %args;
$log->tracef("Win32::Packer args: %s", \%args);

my $p = Win32::Packer->new(%args);
$p->build;
