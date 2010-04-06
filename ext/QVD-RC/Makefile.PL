use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::RC',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/QVD/RC.pm',
    ABSTRACT_FROM       => 'lib/QVD/RC.pm',
    EXE_FILES		=> [
	'bin/qvd-rcd.pl',
    ],
    PL_FILES            => {},
    PREREQ_PM => {
	'App::Daemon' => 0,
	'Log::Log4perl' => 0,
	'parent' => 0,
	'QVD::Config' => 0,
	'QVD::HTTPD' => 0,
	'QVD::SimpleRPC' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-RC-*' },
);
