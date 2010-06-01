use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'QVD::L7R::Authenticator::Plugin::LDAP',
    AUTHOR              => q{Salvador Fandiño <sfandino@yahoo.com>},
    VERSION_FROM        => 'lib/QVD/L7R/Authenticator/Plugin/LDAP.pm',
    ABSTRACT_FROM       => 'lib/QVD/L7R/Authenticator/Plugin/LDAP.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'QVD-L7R-Authenticator-Plugin-LDAP-*' },
);
