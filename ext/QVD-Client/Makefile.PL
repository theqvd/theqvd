use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::Client',
	       AUTHOR        => 'QVD Team <qvd@qindel.com>',
	       VERSION       => '0.01.'.$ENV{SVN_REVISION},
	       ABSTRACT_FROM => 'lib/QVD/Client.pm',
	       PL_FILES      => {},
	       EXE_FILES     => [ qw(bin/qvd-client.pl bin/qvd-gui-client.pl) ],
	       PREREQ_PM     => { 'IO::Socket::Forwarder' => 0,
				  'IO::Socket::SSL' => 0,
				  'JSON' => 0,
				  'MIME::Base64' => 0,
				  'parent' => 0,
				  'Proc::Background' => 0,
				  'QVD::Config' => 0,
				  'QVD::HTTP' => 0,
				  'QVD::HTTPC' => 0,
				  'Test::More' => 0,
				  'Wx' => 0,
				  'URI::Escape' => 0,
				  'File::Spec' => 0 },

	       dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	       clean           => { FILES => 'QVD-Client-*' },
);
