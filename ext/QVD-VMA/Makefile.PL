use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile( NAME => 'QVD::VMA',
	       VERSION => "3.1".$ENV{BUILD_NUMBER},
	       ABSTRACT_FROM => 'lib/QVD/VMA.pm',
	       EXE_FILES => [ 'bin/nxdiag.pl',
			      'bin/qvd-printing',
			      'bin/qvd-vma.pl' ],
	       PL_FILES => {},
	       PREREQ_PM => { 'QVD::Log' => 0,
			      'QVD::SimpleRPC' => 0,
			      'App::Daemon' => 0,
			      'Config::Properties' => 0,
			      'Test::More' => 0 },
	       dist => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	       clean => { FILES => 'QVD-VMA-*' },
);
