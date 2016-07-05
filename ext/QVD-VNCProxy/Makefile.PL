
use ExtUtils::MakeMaker;


my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
	$SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile( NAME          => 'QVD::VNCProxy',
               VERSION 		 => '3.5' . $SUF_VERSION , 
               PREREQ_PM     => { App::pnc               => '0.02',
                                  QVD::DB                => '0',
                                  QVD::HTTPC             => '0',
                                  QVD::HTTP::StatusCodes => 0 },
	       ABSTRACT      => 'lib/QVD/VNCProxy.pm',
               AUTHOR        => 'Salvador Fandino <sfandino@yahoo.com>'
);
