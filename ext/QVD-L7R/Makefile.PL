use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::L7R',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/QVD/L7R.pm',
    ABSTRACT_FROM       => 'lib/QVD/L7R.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'File::Slurp' => 0,
	'IO::Socket::Forwarder' => 0,
	'Log::Log4perl' => 0,
	'parent' => 0,
	'QVD::Auth' => 0,
	'QVD::Config' => 0,
	'QVD::DB' => 0,
	'QVD::HTTP' => 0,
	'QVD::HTTPD' => 0,
	'QVD::URI' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-L7R-*' },
);
