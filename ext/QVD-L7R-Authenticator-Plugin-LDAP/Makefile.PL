
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::L7R::Authenticator::Plugin::LDAP',
	       AUTHOR        => 'QVD Team <qvd@qindel.com>',
	       VERSION_FROM  => 'lib/QVD/L7R/Authenticator/Plugin/LDAP.pm',
	       ABSTRACT_FROM => 'lib/QVD/L7R/Authenticator/Plugin/LDAP.pm',
	       LICENSE       => 'GPL3',
	       PREREQ_PM     => { 'Test::More'       => 0,
				  'QVD::Config'      => 0,
				  'QVD::Log'         => 0,
				  'QVD::StatusCodes' => 0,
				  'Net::LDAP'        => 0 },
	       dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	       clean         => { FILES => 'QVD-L7R-Authenticator-Plugin-LDAP-*' } );
