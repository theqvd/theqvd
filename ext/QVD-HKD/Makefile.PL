use 5.010;
use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::HKD',
               VERSION_FROM  => 'lib/QVD/HKD.pm',
               PREREQ_PM     => { 'Class::StateMachine' => '0.17',
                                  'Class::StateMachine::Declarative' => '0',
                                  'AnyEvent' => '5.34',
                                  'Pg::PQ' => '0.05',
                                  'AnyEvent::Pg' => '0',
                                  'QVD::Config' => '0' },
               ABSTRACT_FROM => 'lib/QVD/HKD.pm',
               AUTHOR        => 'Salvador Fandiño <sfandino@yahoo.com>',
);
