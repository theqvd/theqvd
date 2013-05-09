
use ExtUtils::MakeMaker;

WriteMakefile( NAME          => 'QVD::VNCProxy',
               VERSION_FROM  => 'lib/QVD/VNCProxy.pm',
               PREREQ_PM     => { App::pnc               => '0.02',
                                  QVD::DB                => '0',
                                  QVD::HTTPC             => '0',
                                  QVD::HTTP::StatusCodes => 0 },
	       ABSTRACT      => 'lib/QVD/VNCProxy.pm',
               AUTHOR        => 'Salvador Fandino <sfandino@yahoo.com>'
);
