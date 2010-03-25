use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME                => 'QVD::DB',
	AUTHOR              => 'Joni Salonen <jsalonen@qindel.es>',
	VERSION_FROM        => 'lib/QVD/DB.pm',
	ABSTRACT_FROM       => 'lib/QVD/DB.pm',
	PL_FILES            => {},
	PREREQ_PM => {
		'Config::Tiny' => 0,
		'DBIx::Class' => 0,
		'Log::Log4perl' => 0,
		'parent' => 0,
		'Test::More' => 0,
	},
	dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean               => { FILES => 'QVD-DB-*' },
);
