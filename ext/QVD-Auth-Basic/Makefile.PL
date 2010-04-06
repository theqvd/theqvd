use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Auth::Basic',
    AUTHOR              => q{Hugo Cornejo <hcornejo@qindel.com>},
    VERSION_FROM        => 'lib/QVD/Auth/Basic.pm',
    ABSTRACT_FROM       => 'lib/QVD/Auth/Basic.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
	'QVD::Auth' => 0,
	'QVD::DB' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Auth-Basic-*' },
);
