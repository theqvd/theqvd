use ExtUtils::MakeMaker;

WriteMakefile( NAME         => 'QVD::VMKiller',
               VERSION             => '3.1'.$ENV{BUILD_NUMBER},
               PREREQ_PM    => {
                   'Proc::ProcessTable' => 0,
               } );
