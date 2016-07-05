
use ExtUtils::MakeMaker;

$^O eq 'linux' or die "OS unsupported\n";


my $SUF_VERSION = defined $ENV{BUILD_NUMBER} ? ".$ENV{BUILD_NUMBER}" : '';


WriteMakefile( NAME          => 'Linux::Proc::Mounts',
               VERSION  	 => '3.5' . $SUF_VERSION,
               ABSTRACT_FROM => 'lib/Linux/Proc/Mounts.pm',
               AUTHOR        => 'Salvador Fandino <sfandino@yahoo.com>' );
