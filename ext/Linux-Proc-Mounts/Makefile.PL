
use ExtUtils::MakeMaker;

$^O eq 'linux' or die "OS unsupported\n";

WriteMakefile( NAME          => 'Linux::Proc::Mounts',
               VERSION_FROM  => 'lib/Linux/Proc/Mounts.pm',
               ABSTRACT_FROM => 'lib/Linux/Proc/Mounts.pm',
               AUTHOR        => 'Salvador Fandino <sfandino@yahoo.com>' );
