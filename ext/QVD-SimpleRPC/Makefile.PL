use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::SimpleRPC',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION             => '3.1'.$ENV{BUILD_NUMBER},
    ABSTRACT_FROM       => 'lib/QVD/SimpleRPC.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'JSON' => 0,
	'QVD::HTTPC' => 0,
	'QVD::HTTPD' => 0,
	'QVD::URI' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-SimpleRPC-*' },
);
