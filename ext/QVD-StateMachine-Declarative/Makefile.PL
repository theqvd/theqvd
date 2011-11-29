
use ExtUtils::MakeMaker;

WriteMakefile( NAME         => 'QVD::StateMachine::Declarative',
               VERSION_FROM => 'lib/QVD/StateMachine/Declarative.pm', # finds $VERSION
               PREREQ_PM    => { Class::StateMachine => '0.18' },
               AUTHOR       => 'sfandino@yahoo.com');
