use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Log',
    AUTHOR              => q{QVD Team <qvd@qindel.com>},
    VERSION_FROM        => 'lib/QVD/Log.pm',
    ABSTRACT_FROM       => 'lib/QVD/Log.pm',
    LICENSE		=> 'gpl',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
	'Log::Log4perl' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Log-*' },
);
