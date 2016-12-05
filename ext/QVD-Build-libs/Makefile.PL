use 5.01;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'QVD::Build::libs',
    VERSION	      => '3.2'.$ENV{BUILD_NUMBER},
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      ( AUTHOR         => 'QVD Team <qvd@qindel.com>') : ()),
    PREREQ_PM         => {
    },
);
