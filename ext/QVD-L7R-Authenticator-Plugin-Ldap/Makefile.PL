
use strict;
use warnings;

use ExtUtils::MakeMaker;

my $SUF_VERSION = "";
if  ( defined $ENV{BUILD_NUMBER} ) {
    $SUF_VERSION = '.' . $ENV{BUILD_NUMBER} ;
}


WriteMakefile(
    NAME          => 'QVD::L7R::Authenticator::Plugin::Ldap',
    AUTHOR        => 'QVD Team <qvd@qindel.com>',
    VERSION	     => '3.5'.$SUF_VERSION,
    ABSTRACT => 'lib/QVD/L7R/Authenticator/Plugin/Ldap.pm',
    LICENSE       => 'GPL3',
    PREREQ_PM     => {
        'QVD::Config'                     => 0,
        'QVD::L7R::Authenticator::Plugin' => 0,
        'QVD::Log'                        => 0,
        'Net::LDAP'                       => 0,
        'Net::LDAP::Util'                 => 0,
    },
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'QVD-L7R-Authenticator-Plugin-Ldap-*' } );
