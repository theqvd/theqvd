use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::L7R::Forwarder',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/QVD/L7R/Forwarder.pm',
    ABSTRACT_FROM       => 'lib/QVD/L7R/Forwarder.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-L7R-Forwarder-*' },
);
