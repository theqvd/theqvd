use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::HTTPD',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION	        => '0.1'.$ENV{BUILD_NUMBER},
    ABSTRACT_FROM       => 'lib/QVD/HTTPD.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'Net::Server::Fork' => 0,
	'parent' => 0,
	'QVD::HTTP' => 0,
        'Test::More' => 0,
	'URI::Split' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HTTPD-*' },
);
