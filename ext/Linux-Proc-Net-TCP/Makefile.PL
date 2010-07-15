use 5.010001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Linux::Proc::Net::TCP',
    VERSION_FROM      => 'lib/Linux/Proc/Net/TCP.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Linux/Proc/Net/TCP.pm', # retrieve abstract from module
       AUTHOR         => 'root <root@>') : ()),
);
