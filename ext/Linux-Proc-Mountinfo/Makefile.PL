
use ExtUtils::MakeMaker;

my $SUF_VERSION = defined $ENV{BUILD_NUMBER} ? ".$ENV{BUILD_NUMBER}" : '';

WriteMakefile( NAME          => 'Linux::Proc::Mountinfo',
               VERSION  	 => '3.5' . $SUF_VERSION, 
               PREREQ_PM     => {},
               ABSTRACT_FROM => 'lib/Linux/Proc/Mountinfo.pm',
               AUTHOR        => 'Salvador Fandino <sfandino@yahoo.com>' );
