use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::L7R::LoadBalancer',
    AUTHOR              => q{QVD Team <qvd@qindel.com>},
    VERSION		=> '3.1'.$ENV{BUILD_NUMBER},
    ABSTRACT       => 'lib/QVD/L7R/LoadBalancer.pm',
    LICENSE		=> 'gpl',
    PL_FILES            => {},
    PREREQ_PM => {
	'Test::More' => 0,
	'QVD::Config' => 0,
	'QVD::Log' => 0,
	'QVD::DB' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-L7R-LoadBalancer-*' },
);
