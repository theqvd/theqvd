use strict;
use warnings;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'QVD::Session',
    AUTHOR            => 'QVD Team <qvd@qindel.es>',
    VERSION	          => '4.0'.$ENV{BUILD_NUMBER},
    ABSTRACT          => 'QVD::Session',
    EXE_FILES         => [ ],
    PREREQ_PM         => {
        'Session::Token' => 0
    },
);
