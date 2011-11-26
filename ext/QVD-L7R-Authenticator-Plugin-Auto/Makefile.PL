
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::L7R::Authenticator::Plugin::Auto',
	       AUTHOR        => 'QVD Team <qvd@qindel.com>',
	       VERSION	     => '0.1'.$ENV{BUILD_NUMBER},
	       ABSTRACT_FROM => 'lib/QVD/L7R/Authenticator/Plugin/Auto.pm',
	       LICENSE       => 'GPL3',
	       PREREQ_PM     => { 'Test::More'       => 0,
				  'QVD::Admin'	     => 0,
				  'QVD::Config'      => 0,
				  'QVD::L7R'         => 0,
				  'QVD::Log'         => 0,
	                        },
	       dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	       clean         => { FILES => 'QVD-L7R-Authenticator-Plugin-Auto-*' } );
