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
        'IO::Socket::SSL' => 0,
        'JSON' => 0,
        'Net::Server::Fork' => 0,
        'Net::Server::INET' => 0,
        'QVD::HTTP::StatusCodes' => 0,
        'QVD::Log' => 0,
        'URI::Split' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-HTTPD-*' },
);
