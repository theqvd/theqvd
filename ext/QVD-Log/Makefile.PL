use strict;
use warnings;
use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME        => 'QVD::Log',
    AUTHOR      => q{QVD Team <qvd@qindel.com>},
    VERSION     => '3.5'.$SUF_VERSION,
    ABSTRACT    => 'lib/QVD/Log.pm',
    LICENSE     => 'gpl',
    PL_FILES    => {},
    PREREQ_PM   => {
        'QVD::Config::Core' => 0,
        'Log::Log4perl' => 0,
        'Log::Dispatch::FileRotate' => 0,
    },
    dist        => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean       => { FILES => 'QVD-Log-*' },
);
