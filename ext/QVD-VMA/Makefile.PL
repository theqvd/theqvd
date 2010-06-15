use strict;
use warnings;
use ExtUtils::MakeMaker;

my $rev = $ENV{SVN_REVISION} ? ".$ENV{SVN_REVISION}" : "";

WriteMakefile( NAME => 'QVD::VMA',
	       VERSION => "0.01$rev",
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
