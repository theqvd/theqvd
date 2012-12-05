use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::L7R::Authenticator::Plugin::Passthrough',
    AUTHOR              => q{QVD Team <qvd-devel@theqvd.com>},
    VERSION_FROM        => 'lib/QVD/L7R/Authenticator/Plugin/Passthrough.pm',
    ABSTRACT_FROM       => 'lib/QVD/L7R/Authenticator/Plugin/Passthrough.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'gpl')
      : ()),
    PL_FILES            => {},
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'QVD::Log' => 0,
        'QVD::Config' => 0,
        'QVD::L7R' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-L7R-Authenticator-Plugin-Passthrough-*' },
);
