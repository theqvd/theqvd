use 5.010;
use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME          => 'QVD::HKD',
    VERSION       => '3.5'.$SUF_VERSION ,
    PREREQ_PM     => {
        'AnyEvent' => '5.34',
        'AnyEvent::Debug' => 0,
        'AnyEvent::HTTP' => '2.13',
        'AnyEvent::Impl::Perl' => 0,
        'AnyEvent::Pg::Pool' => 0,
        'AnyEvent::Util' => 0,
        'AnyEvent::Semaphore' => '0.01',
        'AnyEvent::Socket' => 0,
        'App::Daemon' => '0',
        'Class::StateMachine' => '0.23',
        'Class::StateMachine::Declarative' => '0.01',
        'Config::Properties' => 0,
        'Fcntl::Packer' => '0.02',
        'File::Slurp' => '0',
        'JSON' => 0,
        'Linux::Proc::Mountinfo' => '0.01',
        'Linux::Proc::Net::TCP' => '0.07',
        'Linux::Proc::Net::UDP' => 0,
        'Method::WeakCallback' => 0,
        'Pg::PQ' => '0.13',
        'QVD::Config::Core' => '0',
        'QVD::Config::Core::Defaults' => 0,
        'QVD::Log' => '0',
        'QVD::StateMachine::Declarative' => 0,
        'URI::Escape' => 0,
    },
    ABSTRACT      => 'lib/QVD/HKD.pm',
    EXE_FILES     => [ qw(
        bin/qvd-hkd
        bin/qvd-lxc-autodev
        bin/qvd-hkd.initrc.pl
        bin/qvd-hkd.debrc.pl
        bin/qvd-hkd.postinst
        bin/qvd-hkd.prerm
        ) ],
    AUTHOR        => 'QVD Team <qvd@qindel.com>',
);
