use 5.01;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'QVD::ParallelNet',
    VERSION           => '3.1'.$ENV{BUILD_NUMBER},
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT  => 'lib/QVD/ParallelNet.pm', # retrieve abstract from module
       AUTHOR         => 'Salvador Fandino <salva@>') : ()),
    PREREQ_PM => {
	'Time::HiRes' => 0,
	'QVD::Log' => 0,
    },
);
