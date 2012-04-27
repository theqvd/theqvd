use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Test',
    AUTHOR              => 'QVD Team <qvd@qindel.com>',
    VERSION_FROM        => 'lib/QVD/Test.pm',
    ABSTRACT_FROM       => 'lib/QVD/Test.pm',
    LICENSE		=> 'gpl',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::Class' 	=> 0,
	'File::Slurp'	=> 0,
        'Test::More' 	=> 0,
        'X11::GUITest'  => 0,
        'parent'        => 0,
        'lib::glob'     => 0 
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Test-*' },
);
