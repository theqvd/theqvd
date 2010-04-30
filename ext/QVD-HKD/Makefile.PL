use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::HKD',
    AUTHOR              => 'QVD Team <qvd@qindel.com>',
    VERSION             => '0.01.'.$ENV{SVN_REVISION},
    ABSTRACT_FROM       => 'lib/QVD/HKD.pm',
    PL_FILES            => {},
    EXE_FILES		=> [ qw(bin/qvd-hkd.pl) ],
    PREREQ_PM => {
	'App::Daemon' => 0,
	'List::Util' => 0,
	'Log::Log4perl' => 0,
	'QVD::Config' => 0,
	'QVD::DB' => 0,
	'QVD::ParallelNet' => 0,
	'QVD::SimpleRPC' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HKD-*' },
);
