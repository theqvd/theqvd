use 5.010;
use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::HKD',
               VERSION       => '3.1'.$ENV{BUILD_NUMBER},
               PREREQ_PM     => { 'Class::StateMachine' => '0.19',
                                  'QVD::StateMachine::Declarative' => '0',
                                  'AnyEvent' => '5.34',
                                  'AnyEvent:HTTP' => '2.13',
                                  'EV' => '4.10',
                                  'Pg::PQ' => '0.06',
                                  'AnyEvent::Pg' => '0.04',
                                  'App::Daemon' => '0',
                                  'QVD::Config' => '0',
				  'QVD::Log' => '0',
                                  'File::Slurp' => '0',
                                  'Linux::Proc::Mountinfo' => '0.01',
                                },
               ABSTRACT_FROM => 'lib/QVD/HKD.pm',
	       EXE_FILES     => [ qw(bin/qvd-hkd bin/qvd-hkd.initrc.pl bin/qvd-hkd.debrc.pl bin/qvd-hkd.postinst) ],
               AUTHOR        => 'QVD Team <qvd@qindel.com>',
);
