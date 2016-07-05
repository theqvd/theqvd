use strict;
use warnings;
use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
  $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}


WriteMakefile(
    NAME                => 'QVD::HTTPD',
    AUTHOR              => 'Salvador Fandino <sfandino@yahoo.com>',
    VERSION	            => '3.5'.$SUF_VERSION,
    ABSTRACT   	        => 'lib/QVD/HTTPD.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'Net::Server::Fork' => 0,
	'parent' => 0,
	'QVD::HTTP' => 0,
	'QVD::Log' => 0,
        'Test::More' => 0,
	'URI::Split' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HTTPD-*' },
);
