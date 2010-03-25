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
	'File::Slurp' => 0,
	'QVD::Config' => 0,
	'QVD::DB' => 0,
        'Test::More' => 0,
	'Text::Table' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Admin-*' },
);
