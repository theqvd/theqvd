use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Client',
    AUTHOR              => 'Salvador Fandiño <sfandino@yahoo.com>',
    VERSION_FROM        => 'lib/QVD/Client.pm',
    ABSTRACT_FROM       => 'lib/QVD/Client.pm',
    PL_FILES            => {},
    EXE_FILES           => [ qw(bin/qvd-client.pl bin/qvd-gui-client.pl) ],
    PREREQ_PM => {
	'IO::Socket::Forwarder' => 0,
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
