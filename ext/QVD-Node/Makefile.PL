use 5.01;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
  $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME              => 'QVD::Node',
    VERSION	      => '3.5'.$SUF_VERSION,
    AUTHOR        => 'QVD Team <qvd@qindel.com>',
    PREREQ_PM         => {  'QVD::HKD' 			=> 3.5,
			   				'QVD::L7R' 			=> 3.5 },
);
