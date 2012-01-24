use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::HTTPC',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION	        => '3.1'.$ENV{BUILD_NUMBER},
    ABSTRACT_FROM       => 'lib/QVD/HTTPC.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'IO::Socket::INET' => 0,
	'parent' => 0,
	'QVD::HTTP' => 0,
	'QVD::Config' => 0,
        'Test::More' => 0,
	'URI::Escape' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HTTPC-*' },
);
