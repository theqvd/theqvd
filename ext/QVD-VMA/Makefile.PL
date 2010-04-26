use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::VMA',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION             => '0.01.'.$ENV{SVN_REVISION},
    ABSTRACT_FROM       => 'lib/QVD/VMA.pm',
    EXE_FILES		=> [
	'bin/nxagent-monitor.pl',
	'bin/nxdiag.pl',
	'bin/qvd-initialize-user-storage.pl',
	'bin/qvd-vma.pl',
    ],
    PL_FILES            => {},
    PREREQ_PM => {
	'App::Daemon' => 0,
	'Config::Tiny' => 0,
	'File::Slurp' => 0,
	'Log::Log4perl' => 0,
	'parent' => 0,
	'QVD::SimpleRPC' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-VMA-*' },
);
