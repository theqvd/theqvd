use 5.01;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'QVD::Node',
    VERSION	      => '0.1'.$ENV{BUILD_NUMBER},
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/QVD/Node.pm', # retrieve abstract from module
       AUTHOR         => 'root <root@>') : ()),
    PREREQ_PM         => { 'App::Daemon' 		=> 0,
			   'JSON'     			=> 0,
			   'Linux::Proc::Net::TCP' 	=> 0.02,
			   'QVD::HKD' 			=> 0.1,
			   'QVD::Log' 			=> 0.1,
			   'QVD::L7R' 			=> 0.1 },
);
