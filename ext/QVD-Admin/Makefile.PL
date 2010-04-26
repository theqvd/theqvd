use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Admin',
    AUTHOR              => 'QVD Team <qvd@qindel.es>',
    VERSION	        => '0.01.'.$ENV{SVN_REVISION},
    ABSTRACT_FROM       => 'lib/QVD/Admin.pm',
    EXE_FILES		=> [
	'bin/qvd-admin.pl',
	'bin/qvd-delete-db.pl',
	'bin/qvd-deploy-db.pl',
	'bin/qvd-init-db.pl',
    ],
    PL_FILES            => {},
    PREREQ_PM => {
	'File::Slurp' => 0,
	'QVD::Config' => 0,
	'QVD::DB' => 0,
        'Test::More' => 0,
	'Text::Table' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Admin-*' },
);
