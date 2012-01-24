
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::L7R::Authenticator::Plugin::Ldap',
	       AUTHOR        => 'QVD Team <qvd@qindel.com>',
	       VERSION	     => '3.1'.$ENV{BUILD_NUMBER},
	       ABSTRACT_FROM => 'lib/QVD/L7R/Authenticator/Plugin/Ldap.pm',
	       LICENSE       => 'GPL3',
	       PREREQ_PM     => { 'Test::More'       => 0,
				  'QVD::Config'      => 0,
				  'QVD::L7R'         => 0,
				  'QVD::Log'         => 0,
				  'Net::LDAP'        => 0 },
	       dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	       clean         => { FILES => 'QVD-L7R-Authenticator-Plugin-Ldap-*' } );
