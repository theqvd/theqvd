# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
#use inc::Module::Install;
use strict;
use warnings;
use Module::Build;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}
my $cron_dst = '/etc/cron.d';

my $build = Module::Build->new(
    module_name      => 'QVD::VMKiller',
    dist_author      => 'QVD Team <qvd@qindel.com',
    dist_version     => '3.5'.$SUF_VERSION ,
    dist_abstract    => 'QVD::VMKiller - Kill QVD Zombies VM',
    license          => 'gpl',


    configure_requires => {
        'Module::Build'                      => 0.38
    },

    requires => {
        'Linux::Fuser' => 0,
        'QVD::Config::Core' => '0',
        'QVD::Log' => '0',
    },

    etc_files=> { 'etc/cron.d/qvd-vm-killer' => '/etc/cron.d/qvd-vm-killer'},
    install_path => { 'etc' => '/etc' },

);


foreach my $ext (qw( etc )) {
    $build->add_build_element($ext);
}

$build->create_build_script();
