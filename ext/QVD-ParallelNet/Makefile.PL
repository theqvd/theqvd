use 5.01;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
  $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME              => 'QVD::ParallelNet',
    VERSION           => '3.5'. $SUF_VERSION,
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT  => 'lib/QVD/ParallelNet.pm', # retrieve abstract from module
       AUTHOR         => 'Salvador Fandino <salva@>') : ()),
    PREREQ_PM => { 
        'QVD::Log' => 0,
    },
);
