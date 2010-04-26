use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::Auth',
    AUTHOR              => q{Hugo Cornejo <hcornejo@qindel.com>},
    VERSION	        => '0.01.'.$ENV{SVN_REVISION},
    ABSTRACT_FROM       => 'lib/QVD/Auth.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
	'QVD::Config' => 0,
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-Auth-*' },
);
