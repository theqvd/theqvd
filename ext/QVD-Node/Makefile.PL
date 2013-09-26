use 5.01;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'QVD::Node',
    VERSION	      => '3.1'.$ENV{BUILD_NUMBER},
    AUTHOR        => 'QVD Team <qvd@qindel.com>',
    PREREQ_PM         => { 'QVD::HKD' 			=> 3.2,
			   'QVD::L7R' 			=> 3.2,
			   'QVD::VMKiller' 		=> 3.2 },
);
