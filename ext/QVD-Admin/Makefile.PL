use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Admin',
    AUTHOR              => 'Qindel Formacion y Servicios S.L. <joni.salonen at qindel.es>',
    VERSION_FROM        => 'lib/QVD/Admin.pm',
    ABSTRACT_FROM       => 'lib/QVD/Admin.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Admin-*' },
);
