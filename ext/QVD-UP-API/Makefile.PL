use strict;
use warnings;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'QVD::API',
    AUTHOR            => 'QVD Team <qvd@qindel.es>',
    VERSION	          => '4.0'.$ENV{BUILD_NUMBER},
    ABSTRACT          => 'QVD::API',
    EXE_FILES         => [ 'bin/qvd-up-api.pl' ],
    PREREQ_PM         => {
        'HTTP::BrowserDetect' => 0,
        'Mojolicious::Lite' => 0,
        'MojoX::Session' => 0,
        'MIME::Base64' => 0,
        'Try::Tiny' => 0,
        'QVD::Config' => 0,
        'Digest::SHA' => 0,
        'Switch' => 0,
    },
);
