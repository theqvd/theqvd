use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'JSON::SimpleRPC',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/JSON/SimpleRPC.pm',
    ABSTRACT_FROM       => 'lib/JSON/SimpleRPC.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'JSON-SimpleRPC-*' },
);
