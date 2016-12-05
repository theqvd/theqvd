use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.


my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
	$SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME              => 'QVD::StressTester',
    VERSION           => '3.5'.$SUF_VERSION,
    PREREQ_PM         => {
        'AnyEvent' => 0,
        'AnyEvent::Handle' => 0,
        'AnyEvent::Socket' => 0,
        'AnyEvent::Util' => 0,
        'common::sense' => 0,
        'JSON' => 0,
        'URI::Encode' => 0,
        'Text::CSV_XS' => 0,
    }, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
        (ABSTRACT_FROM  => 'lib/QVD/StressTester.pm', # retrieve abstract from module
            AUTHOR         => 'root <root@>') : ()),
);
