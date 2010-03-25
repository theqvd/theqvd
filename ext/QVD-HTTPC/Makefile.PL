use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::HTTPC',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/QVD/HTTPC.pm',
    ABSTRACT_FROM       => 'lib/QVD/HTTPC.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
	'QVD::HTTP' => 0,
	'parent' => 0,
	'IO::Socket::INET' => 0,
	'URI::Escape' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HTTPC-*' },
);
