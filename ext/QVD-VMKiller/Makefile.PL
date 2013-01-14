use ExtUtils::MakeMaker;

WriteMakefile( NAME         => 'QVD::VMKiller',
               VERSION      => '3.1'.$ENV{BUILD_NUMBER},
               PREREQ_PM    => {
                  'Proc::ProcessTable' => 0,
                  'QVD::Config' => '0',
                  'QVD::Log' => '0',
               }
               ABSTRACT_FROM => 'lib/QVD/VMKiller.pm',
	       EXE_FILES     => [ qw(bin/qvd-vm-killer) ],
               AUTHOR        => 'QVD Team <qvd@qindel.com>',
);
