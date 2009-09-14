use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Client',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/QVD/Client.pm',
    ABSTRACT_FROM       => 'lib/QVD/Client.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Client-*' },
);
