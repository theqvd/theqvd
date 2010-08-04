use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::URI',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION             => '0.1'.$ENV{BUILD_NUMBER},
    ABSTRACT_FROM       => 'lib/QVD/URI.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-URI-*' },
);
