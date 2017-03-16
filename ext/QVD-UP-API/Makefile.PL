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
        'Mojo::ByteStream' => 0,
        'Mojo::JSON' => 0,
        'Mojo::Log' => 0,
        'Mojo::Pg' => 0,
        'Mojo::URL' => 0,
        'Mojo::UserAgent' => 0,
        'Mojolicious::Lite' => 0,
        'Mojolicious::Plugin::SetUserGroup' => 0,
        'MojoX::Session' => 0,
        'Moo' => 0,
        'MooX::Types::MooseLike::Base' => 0,
        'Try::Tiny' => 0,
        'QVD::Config' => 0,
        'QVD::DB::Common' => 0,
        'QVD::DB::Simple' => 0,
        'QVD::H5GW::DockerManager' => 0,
        'QVD::H5GW::SessionManager' => 0,
        'QVD::VMProxy' => 0,
    },
);
