use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Client',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/QVD/Client.pm',
    ABSTRACT_FROM       => 'lib/QVD/Client.pm',
    PL_FILES            => {},
    PREREQ_PM => {
	'IO::Sokcet::Forwarder' => 0,
	'JSON' => 0,
	'MIME::Base64' => 0,
	'parent' => 0,
	'QVD::HTTP' => 0,
	'QVD::HTTPC' => 0,
        'Test::More' => 0,
	'Wx' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Client-*' },
);
