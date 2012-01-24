
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::DB',
	       AUTHOR        => 'QVD Team <qvd@qindel.es>',
	       VERSION	     => '3.1'.$ENV{BUILD_NUMBER},
	       ABSTRACT_FROM => 'lib/QVD/DB.pm',
	       EXE_FILES     => [ 'bin/qvd-deploy-db.pl' ],
	       PL_FILES      => {},
	       PREREQ_PM     => { 'DBD::Pg'       => 0,
				  'DBIx::Class'   => 0,
				  'Log::Log4perl' => 0,
				  'parent'        => 0,
				  'QVD::Config'   => 0,
				  'QVD::Log'      => 0,
				  'Socket::Linux' => 0,
				  # 'SQL::Translator' => 0,
				  'Test::More'    => 0 },
	       dist           => { COMPRESS => 'gzip -9f',
				   SUFFIX   => 'gz' },
	       clean          => { FILES => 'QVD-DB-*' } );
