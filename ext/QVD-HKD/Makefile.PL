use 5.010;
use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::HKD',
               VERSION       => '3.5'.$ENV{BUILD_NUMBER},
               PREREQ_PM     => { 'Class::StateMachine' => '0.23',
                                  'Class::StateMachine::Declarative' => '0.01',
                                  'AnyEvent' => '5.34',
                                  'AnyEvent:HTTP' => '2.13',
                                  'AnyEvent::Semaphore' => '0.01',
                                  'Fcntl::Packer' => '0.02',
                                  'EV' => '4.10',
                                  'Pg::PQ' => '0.13',
                                  'AnyEvent::Pg' => '0.12',
                                  'App::Daemon' => '0',
                                  'QVD::Config' => '0',
				  'QVD::Log' => '0',
                                  'File::Slurp' => '0',
                                  'Linux::Proc::Mountinfo' => '0.01',
				  'QVD::L7R' => '0',
				  'QVD::VMKiller' => '0'
                                },
               ABSTRACT      => 'lib/QVD/HKD.pm',
	       EXE_FILES     => [ qw(bin/qvd-hkd
                                     bin/qvd-lxc-autodev
                                     bin/qvd-hkd.initrc.pl
                                     bin/qvd-hkd.debrc.pl
                                     bin/qvd-hkd.postinst
                                     bin/qvd-hkd.prerm) ],
               AUTHOR        => 'QVD Team <qvd@qindel.com>',
);
