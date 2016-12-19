use strict;
use warnings;
use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME                => 'QVD::HTTP',
    AUTHOR              => 'Salvador Fandino <sfandino@yahoo.com>',
    VERSION	            => '3.5'.$SUF_VERSION,
    ABSTRACT            => 'lib/QVD/HTTP.pm',
    PL_FILES            => {},
    PREREQ_PM           => {},
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HTTP-*' },
);
