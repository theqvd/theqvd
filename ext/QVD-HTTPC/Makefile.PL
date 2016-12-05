use strict;
use warnings;
use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
  $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}


WriteMakefile(
    NAME                => 'QVD::HTTPC',
    AUTHOR              => 'Salvador Fandino <sfandino@yahoo.com>',
    VERSION	            => '3.5'.$SUF_VERSION,
    ABSTRACT            => 'lib/QVD/HTTPC.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'IO::Socket::SSL' => 0,
        'Net::SSLeay' => 0,
        'QVD::Config' => 0,
        'QVD::HTTP::Headers' => 0,
        'QVD::HTTP::StatusCodes' => 0,
        'QVD::ParallelNet' => 0,
        'QVD::ParallelNet::Socket' => 0,
        'URI' => 0,
        'URI::Escape' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HTTPC-*' },
);
