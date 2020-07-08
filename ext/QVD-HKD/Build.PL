# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use strict;
use warnings;
use Module::Build;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

my $build = Module::Build->new(
    module_name      => 'QVD::HKD',
    dist_author      => 'QVD Team <qvd@qindel.com',
    dist_version     => '3.5'.$SUF_VERSION,
    dist_abstract    => 'QVD::HKD - House Keeping Daemon for the QVD Server.',
    license          => 'gpl',

    configure_requires => {
        'Module::Build'                      => 0.38
    },

    requires => {
        'AnyEvent' => '5.34',
        'AnyEvent::Debug' => 0,
        'AnyEvent::HTTP' => '2.13',
        'AnyEvent::Impl::EV' => 0,
        'AnyEvent::Pg::Pool' => 0,
        'AnyEvent::Util' => 0,
        'AnyEvent::Semaphore' => '0.01',
        'AnyEvent::Socket' => 0,
        'App::Daemon' => '0',
        'Class::StateMachine' => '0.23',
        'Class::StateMachine::Declarative' => '0.01',
        'Config::Properties' => 0,
        'ExtUtils::CChecker' => '0.10',
        'EV' => '4.0',
        'Fcntl::Packer' => '0.02',
        'File::Slurp' => '0',
        'JSON' => 0,
        'Linux::Inotify2' => '2.2',
        'Linux::Proc::Mountinfo' => '0.01',
        'Linux::Proc::Net::TCP' => '0.07',
        'Linux::Proc::Net::UDP' => 0,
        'Method::WeakCallback' => 0,
        'Pg::PQ' => '0.13',
        'QVD::Config::Core' => '0',
        'QVD::L7R' => '0',
        'QVD::Log' => '0',
        'Socket' => '2.029',
        'URI::Escape' => 0,
        'BSD::Resource' => '1.2910',
        'Mojo::Template' => '0',
        'Linux::Inotify2' => '0',
        'Socket::Netlink' => '0.05'
    },
    etc_files=> {
        "etc/qvd/templates/lxc.mt" => "/etc/qvd/templates/lxc.mt",
        "etc/apparmor.d/lxc/lxc-qvd"    => "/etc/apparmor.d/lxc/lxc-qvd",
        "etc/apparmor.d/abstractions/lxc/container-base-qvd"
                                        => "/etc/apparmor.d/abstractions/lxc/container-base-qvd"
    },
    install_path => { 'etc' => '/etc' },
);

foreach my $ext (qw(fb tt png jar css gif js zip ico etc conf)) {
    $build->add_build_element($ext);
}

$build->create_build_script();
