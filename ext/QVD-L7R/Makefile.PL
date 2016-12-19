use strict;
use warnings;
use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}


WriteMakefile(
    NAME          => 'QVD::L7R',
    AUTHOR        => 'QVD Team <qvd@qindel.com>',
    VERSION       => '3.5'.$SUF_VERSION,
    ABSTRACT      => 'lib/QVD/L7R.pm',
    PREREQ_PM     => {
        'IO::Socket::Forwarder'  => 0,
        'QVD::Config'            => 0,
        'QVD::DB::Simple'        => 0,
        'QVD::HTTP::Headers'     => 0,
        'QVD::HTTP::StatusCodes' => 0,
        'QVD::HTTPD'             => 0,
        'QVD::L7R::LoadBalancer' => 0,
        'QVD::Log'               => 0,
        'QVD::SimpleRPC::Client' => 0,
        'QVD::URI'               => 0,
        'URI::Split'             => 0,
    },
    EXE_FILES => [qw(bin/qvd-l7r-slave bin/qvd-l7r-nothing-slave)]
);

