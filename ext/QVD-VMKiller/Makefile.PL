use ExtUtils::MakeMaker;

WriteMakefile( NAME         => 'QVD::VMKiller',
               VERSION      => '3.4'.$ENV{BUILD_NUMBER},
               PREREQ_PM    => { 'QVD::Config' => '0',
                                 'QVD::Log' => '0',
                                 'QVD::Config::Core' => '0',
                                 'Linux::Fuser' => '1.5',
                               },
               ABSTRACT_FROM => 'lib/QVD/VMKiller.pm',
	       EXE_FILES     => [ qw(bin/qvd-vm-killer) ],
               AUTHOR        => 'QVD Team <qvd@qindel.com>',
);
