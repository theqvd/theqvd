
use strict;
use warnings;

use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME          => 'DIG',
    AUTHOR        => 'QVD Team <qvd@qindel.es>',
    VERSION       => '3.5'.$SUF_VERSION,
    ABSTRACT      => 'lib/DIG/DIG.pm',
    EXE_FILES     => [],
    PL_FILES      => {},
    PREREQ_PM     => {
        'Mojo::JSON'                  => 0,
        'QVD::Log'                    => 0,
        'Try::Tiny'                   => 0,
    },
    dist           => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz'
    },
    clean          => { FILES => 'DIG-*' } );
