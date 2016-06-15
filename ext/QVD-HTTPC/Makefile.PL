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
	'IO::Socket::INET' => 0,
	'parent' => 0,
	'QVD::HTTP' => 0,
	'QVD::Config' => 0,
    'Test::More' => 0,
	'URI::Escape' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HTTPC-*' },
);
