use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::HTTP',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/QVD/HTTP.pm',
    ABSTRACT_FROM       => 'lib/QVD/HTTP.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
	'parent' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HTTP-*' },
);
