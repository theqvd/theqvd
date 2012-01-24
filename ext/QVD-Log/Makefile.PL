use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Log',
    AUTHOR              => q{QVD Team <qvd@qindel.com>},
    VERSION		=> '3.1'.$ENV{BUILD_NUMBER},
    ABSTRACT_FROM       => 'lib/QVD/Log.pm',
    LICENSE		=> 'gpl',
    PL_FILES            => {},
    PREREQ_PM => { 'QVD::Config' => 0,
		   'Log::Log4perl' => 0,
		   'Log::Dispatch::FileRotate' => 0,
		   'Test::More' => 0 },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Log-*' },
);
