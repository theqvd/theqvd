use 5.01;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'QVD::Build::libs',
    VERSION	      => '3.1'.$ENV{BUILD_NUMBER},
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      ( AUTHOR         => 'QVD Team <qvd@qindel.com>') : ()),
    PREREQ_PM         => { 'CPAN::Easy'		 	=> 0,
			   'Module::Install' 		=> 0,
			   'ExtUtils::MakeMaker'	=> 0,
			   'Module::Runtime' 		=> 0,
			   'Module::Implementation'	=> 0,
			   'YAML' 			=> 0,
			   'Moose' 			=> 0,
			   'Clone' 			=> 0,
			   'CPAN::FindDependencies' 	=> 0,
			   'Params::Classify' 		=> 0,
			   'Class::MOP' 		=> 0,
			   'File::Copy::Recursive' 	=> 0,
			   'Variable::Magic' 		=> 0,
			   'Params::Validate' 		=> 0,
			   'YAML::XS' 			=> 0,
			   'Proc::Background'		=> 0,
			   ´local::lib' => 0
			 },
);
