use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::L7R',
	       AUTHOR        => 'QVD Team <qvd@qindel.com>',
	       VERSION       => '0.1'.$ENV{BUILD_NUMBER},
	       ABSTRACT_FROM => 'lib/QVD/L7R.pm',
	       PREREQ_PM     => { 'IO::Socket::Forwarder' => 0,
				  'QVD::Config'           => 0,
				  'QVD::DB'               => 0,
				  'QVD::HTTP'             => 0,
				  'QVD::HTTPD'            => 0,
				  'QVD::Log'              => 0,
				  'QVD::SimpleRPC'        => 0,
				  'QVD::URI'              => 0,
                                  'QVD::Admin'            => 0,
				  'Test::More'            => 0 },
	       dist          => { COMPRESS => 'gzip -9f',
				  SUFFIX   => 'gz', },
	       clean         => { FILES => 'QVD-L7R-*' } );
