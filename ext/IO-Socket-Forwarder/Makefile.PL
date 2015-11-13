use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'IO::Socket::Forwarder',
    AUTHOR              => 'Salvador Fandino <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/IO/Socket/Forwarder.pm',
    ABSTRACT_FROM       => 'lib/IO/Socket/Forwarder.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'IO-Socket-Forwarder-*' },
);
