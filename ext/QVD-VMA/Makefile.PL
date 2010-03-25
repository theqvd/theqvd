use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::VMA',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/QVD/VMA.pm',
    ABSTRACT_FROM       => 'lib/QVD/VMA.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'App::Daemon' => 0,
	'File::Slurp' => 0,
	'JSON' => 0,
	'Log::Log4perl' => 0,
	'parent' => 0,
	'QVD::SimpleRPC' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-VMA-*' },
);
