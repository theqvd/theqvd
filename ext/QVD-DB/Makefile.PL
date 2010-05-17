use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME                => 'QVD::DB',
	AUTHOR              => 'QVD Team <qvd@qindel.es>',
	VERSION	            => '0.01.'.$ENV{SVN_REVISION},
	ABSTRACT_FROM       => 'lib/QVD/DB.pm',
	PL_FILES            => {},
	PREREQ_PM => {
		'DBD::Pg' => 0,
		'DBIx::Class' => 0,
		'Log::Log4perl' => 0,
		'parent' => 0,
		'QVD::Config' => 0,
		'SQL::Translator' => 0,
		'Test::More' => 0,
	},
	dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean               => { FILES => 'QVD-DB-*' },
);
