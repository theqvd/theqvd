use strict;
use warnings;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'QVD::VMProxy',
    AUTHOR            => 'QVD Team <qvd@qindel.es>',
    VERSION	          => '4.0'.$ENV{BUILD_NUMBER},
    ABSTRACT          => 'QVD::VMProxy',
    EXE_FILES         => [ ],
    PREREQ_PM         => {
        'Mojo::IOLoop' => 0,
        'Mojo::URL' => 0,
        'Mojo::Util' => 0,
        'Moo' => 0,
        'QVD::Log' => 0
    },
);
