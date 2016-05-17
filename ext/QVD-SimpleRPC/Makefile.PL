use strict;
use warnings;
use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME                => 'QVD::SimpleRPC',
    AUTHOR              => 'Salvador Fandino <sfandino@yahoo.com>',
    VERSION             => '3.1'.$SUF_VERSION,
    ABSTRACT       => 'lib/QVD/SimpleRPC.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'JSON' => 0,
	'QVD::HTTPC' => 0,
	'QVD::HTTPD' => 0,
	'QVD::URI' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-SimpleRPC-*' },
);
