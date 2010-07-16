
use ExtUtils::MakeMaker;

$^O eq 'linux' or die "OS unsupported\n";

WriteMakefile( NAME         => 'Linux::Proc::Net::TCP',
	       VERSION_FROM => 'lib/Linux/Proc/Net/TCP.pm',
	       AUTHOR       => 'Salvador Fandino <sfandino@yahoo.com>');

