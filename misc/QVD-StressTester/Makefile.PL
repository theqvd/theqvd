use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.


my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME          => 'QVD::StressTester',
    AUTHOR        => 'QVD Team <qvd@qindel.es>',
    VERSION	      => '3.5'.$SUF_VERSION ,
    ABSTRACT      => 'QVD::StressTester',
    EXE_FILES     => [ 'bin/qvd-stresstester.pl'],
    PL_FILES      => {},
    PREREQ_PM     => {
        'AnyEvent' => 0,
        'AnyEvent::Handle' => 0,
        'AnyEvent::Socket' => 0,
        'AnyEvent::Util' => 0,
        'common::sense' => 0,
        'JSON' => 0,
        'URI::Encode' => 0,
        'Text::CSV_XS' => 0,
    },
);
