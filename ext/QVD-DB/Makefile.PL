
use strict;
use warnings;

use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
	$SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile( NAME          => 'QVD::DB',
	       AUTHOR        => 'QVD Team <qvd@qindel.es>',
	       VERSION	     => '3.5'.$SUF_VERSION,
	       ABSTRACT      => 'lib/QVD/DB.pm',
	       EXE_FILES     => [ 'bin/qvd-deploy-db.pl', 
				  'bin/qvd-upgrade-db'
		 ],
	       PL_FILES      => {},
	       PREREQ_PM     => { 'DBD::Pg'           => 0,
				  'DBIx::Class'       => 0,
				  'DBIx::Error'       => 0,
				  'Log::Log4perl'     => 0,
				  'parent'            => 0,
				  'QVD::Config::Core' => 0,
				  'QVD::Log'          => 0,
				  'Socket::Linux'     => 0,
				  'SQL::Translator'   => 0,
				  'Test::More'        => 0,
                                  'Sort::Versions'    => '1.5' },
	       dist           => { COMPRESS => 'gzip -9f',
				   SUFFIX   => 'gz' },
	       clean          => { FILES => 'QVD-DB-*' } );
