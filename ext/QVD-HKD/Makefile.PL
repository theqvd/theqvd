use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::HKD',
    AUTHOR              => 'Joni Salonen <jsalonen at qindel.com>',
    VERSION_FROM        => 'lib/QVD/HKD.pm',
    ABSTRACT_FROM       => 'lib/QVD/HKD.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HKD-*' },
);
