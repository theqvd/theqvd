use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::HKD',
	       AUTHOR        => 'QVD Team <qvd@qindel.com>',
	       VERSION	     => '0.1'.$ENV{BUILD_NUMBER},
	       ABSTRACT_FROM => 'lib/QVD/HKD.pm',
	       PL_FILES      => {},
	       EXE_FILES     => [ qw(bin/qvd-hkd.pl) ],
	       PREREQ_PM     => { 'App::Daemon' => 0,
				  'List::Util' => 0,
				  'QVD::Config' => 0,
				  'QVD::DB' => 0,
				  'QVD::Log' => 0,
				  'QVD::ParallelNet' => 0,
				  'QVD::SimpleRPC' => 0,
				  'QVD::L7R' => 0,
				  'Test::More' => 0 },
	       dist          => { COMPRESS => 'gzip -9f',
				  SUFFIX => 'gz', },
	       clean         => { FILES => 'QVD-HKD-*' },
);
