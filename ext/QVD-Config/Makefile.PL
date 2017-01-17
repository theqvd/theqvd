use strict;
use warnings;
use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}

WriteMakefile(
    NAME                => 'QVD::Config',
    AUTHOR              => q{Hugo Cornejo <hcornejo@qindel.com>},
    VERSION             => '3.5'.$SUF_VERSION,
    ABSTRACT            => 'QVD::Config',
    PREREQ_PM           => {
        'Config::Properties' => 0,
        'QVD::Config::Core'  => 0,
        'QVD::DB::Simple'    => 0,
        'QVD::Log'           => 0,
    },
    clean               => { FILES => 'QVD-Config-*' }
);
