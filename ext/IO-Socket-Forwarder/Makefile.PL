use strict;
use warnings;
use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME                => 'IO::Socket::Forwarder',
    AUTHOR              => 'Salvador Fandino <sfandino@yahoo.com>',
    VERSION             => '3.5' . $SUF_VERSION , 
    ABSTRACT_FROM       => 'lib/IO/Socket/Forwarder.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'IO-Socket-Forwarder-*' },
);
