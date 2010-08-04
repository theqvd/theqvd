use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Config',
    AUTHOR              => q{Hugo Cornejo <hcornejo@qindel.com>},
    VERSION             => '0.1'.$ENV{BUILD_NUMBER},
    ABSTRACT_FROM       => 'lib/QVD/Config.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
	'Config::Properties' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Config-*' },
);
