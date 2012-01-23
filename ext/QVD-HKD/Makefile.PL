use 5.010;
use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::HKD',
               VERSION       => '0.1'.$ENV{BUILD_NUMBER},
               PREREQ_PM     => { 'Class::StateMachine' => '0.17',
                                  'QVD::StateMachine::Declarative' => '0',
                                  'AnyEvent' => '5.34',
                                  'AnyEvent:HTTP' => '2.13',
                                  'Pg::PQ' => '0.06',
                                  'AnyEvent::Pg' => '0.03',
                                  'App::Daemon' => '0',
                                  'QVD::Config' => '0',
                                  'File::Slurp' => 0 },
               ABSTRACT_FROM => 'lib/QVD/HKD.pm',
	       EXE_FILES     => [ qw(bin/qvd-hkd bin/qvd-hkd.initrc.pl) ],
               AUTHOR        => 'QVD Team <qvd@qindel.com>',
);
